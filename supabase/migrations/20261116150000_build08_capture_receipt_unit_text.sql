-- Build 08 (batch AIDB-4): a receipt for a capture registration, no quote against a unit without text, and app_reader's
-- one unusable grant.
--
-- 1. Knowledge Services registers one of its executor's own captures (source_prepare_captured: fetch, artifact, source,
--    capture, document, version, representation and units in one transaction, as executor_service). It files an operation
--    intent, a receipt and receipt targets for the registration only when orchestration.intent_type declares
--    capture_registration, and until now reported INTENT_TYPE_UNDECLARED instead. The code is declared here. Its receipt
--    targets (evidence.source_capture subject created, evidence.source provenance created or reused, acquisition.fetch
--    provenance created) use schemas, roles and actions the receipt-target checks already allow (20261116130000), and
--    executor_service already holds INSERT on the intent, receipt and receipt-target tables under their tenant policies, so
--    nothing else changes for it.
-- 2. verification.chain_anchor (20261116130000) is the one place a governed write makes a new evidence anchor: every quote
--    anchor of api.record_claim and the captured output of api.record_probe_run go through it (api.restate_claim copies the
--    original's links and makes none). It compared the quote and the unit in the form verification.chain_norm gives them,
--    and chain_norm folds a NULL unit to ''. So:
--      a. a quote of only whitespace other than the space (a tab, a newline, a no-break space) passed QUOTE_REQUIRED (btrim
--         removes spaces only), normalised to '', and position('' in <any unit>) = 1 accepted it against every unit, a unit
--         with NULL text included, for a text_quote anchor and for a json_pointer anchor that carries a quote;
--      b. a json_pointer anchor without a quote on a unit whose text is only such whitespace passed the blank check and was
--         stored with a blank value;
--      c. a json_pointer anchor on a unit with no text was refused EVIDENCE_INVALID telling the caller to pass a quote, which
--         no unit without text can hold.
--    A non-blank quote against a unit with NULL text was already refused QUOTE_NOT_IN_UNIT (position(q in '') = 0).
--    Now a quote that normalises to nothing is QUOTE_REQUIRED, and any new anchor on a unit with no text after
--    normalisation (NULL, empty or whitespace) is QUOTE_NOT_IN_UNIT. No error code is added.
-- 3. app_reader held SELECT on content.document_about_entity, a row-secured table whose only policy (km_tenant_access)
--    names the four agent roles. app_reader is denied every other table of that policy (catalog.entity among them), and
--    everything it reads about a document's entities comes through api views and functions that run as their owner. The
--    grant is revoked; supabase/tests/governed_chain_writes.sql now asserts the "no grant without a usable policy" rule for
--    every bounded role of the contract, not only product_api_owner.
-- Promoted 2026-11-16 from the lab draft 20261116150000 (kept in supabase/drafts/; the statements are the same). Lab-proven on
-- disposable-aieng-build04 (a populated database); not yet run on a fresh install from empty. SQL suite
-- supabase/tests/governed_chain_writes.sql.
begin;
set local lock_timeout = '15s';

-- ------------------------------------------------------------------ 1. ledger vocabulary
insert into orchestration.intent_type(code, description, schema_version)
values ('capture_registration', 'Knowledge Services registered one of its executor''s own captures so that it can be quoted (source_prepare_captured): the acquisition.fetch, orchestration.artifact, evidence.source, evidence.source_capture, content.document, document_version, document_representation and document_node rows, written in one transaction as executor_service; payload.operation names the operation, payload.executor_capture_id the executor''s capture, payload.content_sha256 and payload.representation_sha256 the bytes, payload.actor who acted. Receipt targets: the capture (subject), its source and its fetch (provenance)', 1)
on conflict (code) do update set description = excluded.description;

-- ------------------------------------------------------------------ 2. an anchor needs a unit with text and a quote with text
create or replace function verification.chain_anchor(p_tenant uuid, p_spec jsonb, p_function text,
  out locator_id uuid, out capture_id uuid, out source_id uuid, out created boolean)
language plpgsql set search_path = '' as $fn$
declare v_loc evidence.locator; v_cap evidence.source_capture; v_node record; v_kind text; v_quote text; v_value text; v_selector jsonb; v_unit text;
begin
  created := false;
  if (case when p_spec is null or jsonb_typeof(p_spec) <> 'object' then true
           else exists (select 1 from jsonb_object_keys(p_spec) k where k not in ('locator_id', 'capture_id', 'node_id', 'quote', 'selector_kind', 'pointer', 'role')) end) then
    perform verification.chain_fail('EVIDENCE_INVALID', '22023', 'an evidence anchor is {"locator_id"} or {"capture_id", "node_id", "quote"} (selector_kind text_quote, or json_pointer with "pointer"), with an optional link "role"');
  end if;
  if p_spec ? 'locator_id' then
    if p_spec ?| array['capture_id', 'node_id', 'quote', 'selector_kind', 'pointer'] then
      perform verification.chain_fail('EVIDENCE_INVALID', '22023', 'name an existing locator or describe a new anchor, not both');
    end if;
    select * into v_loc from evidence.locator l where l.id = verification.chain_uuid(p_spec ->> 'locator_id', 'EVIDENCE_INVALID') and l.tenant_id = p_tenant;
    if not found then
      perform verification.chain_fail('EVIDENCE_NOT_FOUND', 'P0002', format('no locator %s in this tenant', p_spec ->> 'locator_id'));
    end if;
    locator_id := v_loc.id; capture_id := v_loc.capture_id;
    select c.source_id into source_id from evidence.source_capture c where c.id = v_loc.capture_id;
    return;
  end if;
  select * into v_cap from evidence.source_capture c where c.id = verification.chain_uuid(p_spec ->> 'capture_id', 'EVIDENCE_INVALID') and c.tenant_id = p_tenant;
  if not found then
    perform verification.chain_fail('EVIDENCE_NOT_FOUND', 'P0002', format('no source capture %s in this tenant', coalesce(p_spec ->> 'capture_id', '(none given)')));
  end if;
  select n.id, n.inline_text, r.media_type into v_node
    from content.document_node n
    join content.document_representation r on r.id = n.representation_id
    join content.document_version_source_capture vc on vc.document_version_id = r.document_version_id
   where n.id = verification.chain_uuid(p_spec ->> 'node_id', 'EVIDENCE_INVALID') and n.tenant_id = p_tenant and vc.source_capture_id = v_cap.id
   limit 1;
  if not found then
    perform verification.chain_fail('EVIDENCE_UNIT_NOT_IN_CAPTURE', 'P0002', 'node_id must name a content unit of a document version read from this capture');
  end if;
  v_kind := coalesce(p_spec ->> 'selector_kind', 'text_quote');
  v_quote := p_spec ->> 'quote';
  -- the comparison form of the unit: '' for a unit whose text is NULL, empty or only whitespace
  v_unit := verification.chain_norm(v_node.inline_text);
  if v_kind = 'text_quote' then
    if v_quote is null or verification.chain_norm(v_quote) = '' then
      perform verification.chain_fail('QUOTE_REQUIRED', '22023', 'a text_quote anchor carries the verbatim quote; a quote of only whitespace is none');
    end if;
    v_value := v_quote;
    v_selector := jsonb_build_object('node_id', v_node.id, 'exact', left(v_quote, 1000));
  elsif v_kind = 'json_pointer' then
    if nullif(btrim(p_spec ->> 'pointer'), '') is null then
      perform verification.chain_fail('EVIDENCE_INVALID', '22023', 'a json_pointer anchor carries the pointer into the captured document');
    end if;
    if v_quote is not null and verification.chain_norm(v_quote) = '' then
      perform verification.chain_fail('QUOTE_REQUIRED', '22023', 'a quote, when a json_pointer anchor carries one, has text; leave it out to anchor the unit''s own text');
    end if;
    v_value := coalesce(v_quote, v_node.inline_text);
    v_selector := jsonb_build_object('node_id', v_node.id, 'pointer', p_spec ->> 'pointer');
  else
    perform verification.chain_fail('EVIDENCE_SELECTOR_UNSUPPORTED', '22023', format('a new anchor is text_quote or json_pointer, not %s; pass the locator_id of an anchor made by the capture pipeline', v_kind));
  end if;
  if v_unit = '' then
    perform verification.chain_fail('QUOTE_NOT_IN_UNIT', '23514', 'the unit has no text (NULL, empty or only whitespace), so it holds no quote and anchors nothing; name a unit that has text');
  end if;
  if v_quote is not null and position(verification.chain_norm(v_quote) in v_unit) = 0 then
    perform verification.chain_fail('QUOTE_NOT_IN_UNIT', '23514', 'the quote is not verbatim in the unit (whitespace and typographic quotes normalised)');
  end if;
  select l.id into locator_id from evidence.locator l
   where l.tenant_id = p_tenant and l.capture_id = v_cap.id and l.selector_kind = v_kind and l.selector ->> 'node_id' = v_node.id::text
     and l.normalized_value = left(v_value, 500)
   order by l.created_at limit 1;
  if locator_id is null then
    locator_id := util.uuidv7(); created := true;
    insert into evidence.locator(id, tenant_id, capture_id, media_type, selector, selector_kind, selected_content_sha256, normalized_value, extractor_name, extractor_version, extraction_params)
    values (locator_id, p_tenant, v_cap.id, case when v_kind = 'json_pointer' then 'application/json' else v_node.media_type end, v_selector, v_kind,
            verification.chain_sha(v_value), left(v_value, 500), 'governed-chain', '1', jsonb_build_object('function', p_function));
  end if;
  capture_id := v_cap.id; source_id := v_cap.source_id;
end $fn$;
comment on function verification.chain_anchor(uuid, jsonb, text) is
  'One evidence anchor of a governed write (api.record_claim evidence, api.record_probe_run output): an existing locator of the tenant, or a new one on a capture naming a content unit of it. A new anchor needs a unit with text: a unit whose text is NULL, empty or only whitespace is QUOTE_NOT_IN_UNIT. A text_quote anchor needs a quote with text (QUOTE_REQUIRED) that is verbatim in the unit after verification.chain_norm (QUOTE_NOT_IN_UNIT); a json_pointer anchor may carry such a quote or anchor the unit''s own text.';

-- ------------------------------------------------------------------ 3. app_reader: no grant without a policy that lets it use it
revoke select on content.document_about_entity from app_reader;

commit;
