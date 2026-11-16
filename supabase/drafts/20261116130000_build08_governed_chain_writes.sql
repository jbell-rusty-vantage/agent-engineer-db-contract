-- Build 08 (batch AIDB-2): governed writes of the research verification chain, and the product owner's row policies.
--
-- 1. The chain (claim, restatement, probe, probe run, verdict, triage, source assessment, attention sweep) was written only by
--    lab scripts that connect as the database owner and INSERT. Nine api functions now make each write a mission agent
--    legitimately makes, callable by the bounded roles: every one resolves the tenant from the session (never an argument),
--    is idempotent on a caller-supplied key, validates what the lab scripts relied on, and leaves an operation intent, a
--    receipt and receipt targets that name the session role and the Mission Control invocation that caused the write.
-- 2. Lines an agent does not cross, enforced on the tables as well as in the functions:
--      - a claim becomes verified only through verification.record_admitted_claim_verification (unchanged; no function here
--        sets a status other than proposed, or proposed -> disputed on a deterministic contradiction);
--      - a row that records a person's judgment (probe_verdict / claim_triage review_state human_confirmed or human_rejected,
--        source_assessment method reviewed) is written by the owner of the table only, never by a bounded role;
--      - probe_verdict, claim_triage and source_assessment are append-only for every role (they were by convention).
-- 3. product_api_owner held SELECT on 18 row-secured tables that no policy let it read, so product.insert_revision refused a
--    statement that cites a shared claim (NOT_FOUND) and product.restricted missed a restriction placed on a capture's source.
--    The two tables its functions read get a tenant-scoped SELECT policy; the 16 it never reads lose the grant.
-- Lab draft for disposable-aieng-build04; suite supabase/tests/governed_chain_writes.sql.
begin;

-- ------------------------------------------------------------------ 1. ledger vocabulary
insert into orchestration.intent_type(code, description, schema_version)
values ('governed_chain_write', 'A write of the research verification chain made through a governed api function (api.record_claim, api.restate_claim, api.register_probe, api.record_probe_run, api.propose_verdict, api.record_triage, api.record_source_assessment, api.raise_attention_sweep, api.settle_attention_sweep), applied in the calling transaction; payload.function names the function, payload.request the arguments, payload.actor who acted', 1)
on conflict (code) do update set description = excluded.description;

-- Receipt targets could name only the pre-R2 schema names, so a receipt could not point at a probe, a verdict or a sweep.
alter table orchestration.operation_receipt_target drop constraint operation_receipt_target_target_schema_check;
alter table orchestration.operation_receipt_target add constraint operation_receipt_target_target_schema_check
  check (target_schema = any (array['corpus','staging','temporal','evidence','knowledge','ranking','research','catalog','guidance','verification','acquisition']));
alter table orchestration.operation_receipt_target drop constraint operation_receipt_target_action_check;
alter table orchestration.operation_receipt_target add constraint operation_receipt_target_action_check
  check (action = any (array['created','reused','superseded','staged','verified','updated']));
comment on column orchestration.operation_receipt_target.action is
  'created, reused, superseded, staged; verified (loop 6): the receipt, bound to an admitted knowledge_verification use decision, moved the target claim to status verified; updated (governed chain writes): the receipt changed the row in place (an attention sweep settled, a proposed claim disputed by a deterministic contradiction).';
comment on column orchestration.operation_receipt_target.target_schema is
  'Schema of the native row. The pre-R2 names (corpus, knowledge, research) stay valid for receipts written before the rename; catalog, guidance, verification and acquisition are the current ones.';

-- A claim is reused when the same statement is recorded again (the lab rule); the lookup needs an index.
create index if not exists claim_tenant_statement_md5_ix on evidence.claim (tenant_id, md5(statement));

-- ------------------------------------------------------------------ 2. helpers (not callable by any bounded role)
-- Failure convention of the knowledge api (api.submit_intent, verification.record_admitted_claim_verification): the message
-- is a stable code, the SQLSTATE its class, the detail a sentence. 42501 no tenant or not allowed; 22023 a malformed
-- argument; P0002 a named row does not exist in the tenant; 23514 the row exists but its state refuses the write; 23505 a
-- key, slug or run already taken.
create or replace function verification.chain_fail(p_code text, p_state text, p_detail text default null) returns void
language plpgsql set search_path = '' as $fn$
begin
  raise exception '%', p_code using errcode = p_state, detail = coalesce(p_detail, '');
end $fn$;

create or replace function verification.chain_sha(p_text text) returns text
language sql immutable set search_path = '' as $fn$
  select encode(extensions.digest(convert_to(p_text, 'utf8'), 'sha256'), 'hex')
$fn$;

create or replace function verification.chain_norm(p_text text) returns text
language sql immutable set search_path = '' as $fn$
  select btrim(regexp_replace(translate(coalesce(p_text, ''), chr(8217) || chr(8220) || chr(8221), '''""'), '\s+', ' ', 'g'))
$fn$;
comment on function verification.chain_norm(text) is
  'The comparison form of a quote and of the unit it is read from: typographic quotes folded to plain ones, runs of whitespace to one space (the rule the lab used to accept a verbatim quote).';

create or replace function verification.chain_uuid(p_text text, p_code text) returns uuid
language plpgsql set search_path = '' as $fn$
begin
  if p_text is null or btrim(p_text) = '' then return null; end if;
  return p_text::uuid;
exception when invalid_text_representation then
  perform verification.chain_fail(p_code, '22023', format('%s is not a uuid', left(p_text, 80)));
  return null;
end $fn$;

-- Opens a governed write: tenant, idempotency, who acts. Returns {"replay": <stored result>} for a repeated key with the
-- same request, else the context the function passes to chain_record.
create or replace function verification.chain_begin(p_function text, p_key text, p_request jsonb, p_actor jsonb) returns jsonb
language plpgsql set search_path = '' as $fn$
declare
  v_tenant uuid := util.current_tenant_id();
  v_key text; v_sha text; v_role text; v_intent orchestration.operation_intent; v_result jsonb;
  v_actor jsonb := coalesce(p_actor, '{}'::jsonb); v_label text; v_mc jsonb; v_mission uuid; v_m orchestration.mission; v_origin text; v_seen jsonb;
begin
  if v_tenant is null then
    perform verification.chain_fail('TENANT_CONTEXT_REQUIRED', '42501', 'set app.tenant_id for the transaction; the tenant is never an argument');
  end if;
  if p_key is null or btrim(p_key) = '' or length(p_key) > 200 then
    perform verification.chain_fail('IDEMPOTENCY_KEY_REQUIRED', '22023', 'a caller-supplied key of 1 to 200 characters; the same key with the same arguments returns the first result');
  end if;
  v_key := 'chain:' || p_key;
  v_sha := 'sha256:' || verification.chain_sha(p_function || ' ' || p_request::text);
  v_role := coalesce(nullif(pg_catalog.current_setting('role', true), 'none'), session_user::text);

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_key, 0));
  select * into v_intent from orchestration.operation_intent i where i.idempotency_key = v_key;
  if found then
    if v_intent.tenant_id is distinct from v_tenant then
      perform verification.chain_fail('IDEMPOTENCY_KEY_FOREIGN_TENANT', '23505', 'the key belongs to another tenant');
    end if;
    if v_intent.payload ->> 'request_sha256' is distinct from v_sha then
      perform verification.chain_fail('IDEMPOTENCY_KEY_REUSED', '23505',
        format('key %s was used by %s with other arguments; a retry repeats the arguments, a new write takes a new key', p_key, v_intent.payload ->> 'function'));
    end if;
    select r.changes_summary -> 'result' into v_result from orchestration.operation_receipt r where r.intent_id = v_intent.id;
    return jsonb_build_object('replay', coalesce(v_result, '{}'::jsonb) || jsonb_build_object('replayed', true));
  end if;

  if (case when jsonb_typeof(v_actor) <> 'object' then true
           else exists (select 1 from jsonb_object_keys(v_actor) k where k not in ('label', 'mission_id', 'mc', 'origin_digest')) end) then
    perform verification.chain_fail('ACTOR_INVALID', '22023', 'p_actor is an object with the optional keys label, mission_id, mc, origin_digest');
  end if;
  v_label := nullif(btrim(v_actor ->> 'label'), '');
  if length(v_label) > 200 or v_label ~* '^\s*human\M' then
    perform verification.chain_fail('ACTOR_INVALID', '22023', 'label names the agent or tool in at most 200 characters; a governed write is never labelled as a person');
  end if;
  if v_actor ? 'mc' and jsonb_typeof(v_actor -> 'mc') <> 'null' then
    v_mc := v_actor -> 'mc';
    if (case when jsonb_typeof(v_mc) <> 'object' then true
             else exists (select 1 from jsonb_object_keys(v_mc) k where k not in ('mission_id', 'run_id', 'activation_id', 'operation_id', 'operation_attempt', 'execution_generation', 'lane'))
               or exists (select 1 from unnest(array['mission_id', 'run_id', 'operation_id', 'operation_attempt', 'execution_generation', 'lane']) k where nullif(btrim(v_mc ->> k), '') is null)
               or (v_mc ->> 'operation_attempt') !~ '^[0-9]{1,9}$' or (v_mc ->> 'execution_generation') !~ '^[0-9]{1,9}$' end) then
      perform verification.chain_fail('ACTOR_INVALID', '22023',
        'mc names the Mission Control invocation: mission_id, run_id, operation_id, operation_attempt, execution_generation and lane are all required (activation_id optional)');
    end if;
  end if;
  if nullif(btrim(v_actor ->> 'mission_id'), '') is not null then
    v_mission := verification.chain_uuid(v_actor ->> 'mission_id', 'ACTOR_INVALID');
    select * into v_m from orchestration.mission m where m.id = v_mission and m.tenant_id = v_tenant;
    if not found then
      perform verification.chain_fail('MISSION_NOT_FOUND', 'P0002', format('no orchestration.mission %s in this tenant', v_mission));
    end if;
    if v_m.ended_at is not null then
      perform verification.chain_fail('MISSION_ENDED', '23514', format('mission %s ended (%s)', coalesce(v_m.slug, v_m.id::text), v_m.status));
    end if;
  end if;
  v_seen := jsonb_strip_nulls(jsonb_build_object('label', v_label, 'session_role', v_role, 'mission_id', v_mission, 'mc', v_mc));
  v_origin := coalesce(nullif(btrim(v_actor ->> 'origin_digest'), ''), 'sha256:' || verification.chain_sha(v_seen::text));
  if v_origin !~ '^sha256:[0-9a-f]{64}$' then
    perform verification.chain_fail('ACTOR_INVALID', '22023', 'origin_digest is sha256:<64 hex>');
  end if;
  return jsonb_strip_nulls(jsonb_build_object(
    'tenant', v_tenant, 'key', v_key, 'request_sha256', v_sha, 'session_role', v_role, 'actor', v_seen,
    'acting', 'agent:' || coalesce(v_label, v_role) || ' (role ' || v_role || coalesce(', Mission Control run ' || (v_mc ->> 'run_id'), '') || ')',
    'origin_kind', case when v_mc is null then 'standalone' else 'mission_invocation' end, 'origin_digest', v_origin,
    'mission_id', v_mission, 'mission_budget_usd', v_m.budget_cost_usd, 'mc', v_mc));
end $fn$;
comment on function verification.chain_begin(text, text, jsonb, jsonb) is
  'Opens a governed chain write: resolves the tenant (util.current_tenant_id), takes the idempotency key (stored as chain:<key>; same key and same arguments replays the first result, other arguments are refused), reads the session role and validates the actor the caller passes (label, the AI Engineer mission, the Mission Control invocation).';

-- Writes the intent and its receipt (ids chosen here so the result is complete before the rows exist) and returns the result.
create or replace function verification.chain_record(p_function text, p_ctx jsonb, p_request jsonb, p_result jsonb, p_refs jsonb) returns jsonb
language plpgsql set search_path = '' as $fn$
declare v_intent uuid := util.uuidv7(); v_receipt uuid := util.uuidv7(); v_mc jsonb := p_ctx -> 'mc'; v_final jsonb;
begin
  v_final := p_result || jsonb_build_object('intent_id', v_intent, 'receipt_id', v_receipt, 'replayed', false);
  insert into orchestration.operation_intent(id, tenant_id, intent_type, schema_version, payload, idempotency_key, approval_state, mission_id, origin_digest, origin_kind,
    mc_mission_id, mc_run_id, mc_activation_id, mc_operation_id, mc_operation_attempt, mc_execution_generation, mc_lane)
  values (v_intent, (p_ctx ->> 'tenant')::uuid, 'governed_chain_write', 1,
    jsonb_build_object('function', p_function, 'request', p_request, 'request_sha256', p_ctx ->> 'request_sha256', 'actor', p_ctx -> 'actor'),
    p_ctx ->> 'key', 'approved', (p_ctx ->> 'mission_id')::uuid, p_ctx ->> 'origin_digest', p_ctx ->> 'origin_kind',
    v_mc ->> 'mission_id', v_mc ->> 'run_id', v_mc ->> 'activation_id', v_mc ->> 'operation_id',
    (v_mc ->> 'operation_attempt')::integer, (v_mc ->> 'execution_generation')::integer, v_mc ->> 'lane');
  insert into orchestration.operation_receipt(id, intent_id, executor_version, outcome, changes_summary, affected_refs, requires_admission, origin_digest)
  values (v_receipt, v_intent, p_function || '/1', 'applied',
    jsonb_build_object('function', p_function, 'acting', p_ctx ->> 'acting', 'session_role', p_ctx ->> 'session_role', 'result', v_final),
    coalesce(p_refs, '[]'::jsonb), false, p_ctx ->> 'origin_digest');
  return v_final;
end $fn$;

create or replace function verification.chain_target(p_ctx jsonb, p_receipt uuid, p_schema text, p_table text, p_id uuid, p_role text, p_action text, p_claim uuid default null) returns void
language plpgsql set search_path = '' as $fn$
declare v_tenant uuid := (p_ctx ->> 'tenant')::uuid;
begin
  insert into orchestration.operation_receipt_target(tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, role, action, claim_id)
  select v_tenant, p_receipt, coalesce((select max(t.ordinal) + 1 from orchestration.operation_receipt_target t where t.tenant_id = v_tenant and t.receipt_id = p_receipt), 0),
         p_schema, p_table, p_id::text, p_role, p_action, p_claim
  on conflict (tenant_id, receipt_id, target_schema, target_table, target_id, role) do nothing;
end $fn$;

-- One evidence anchor: an existing locator of the tenant, or a new one on a capture, naming the content unit that holds
-- the quote. A new anchor is stored only when the quote is verbatim in that unit.
create or replace function verification.chain_anchor(p_tenant uuid, p_spec jsonb, p_function text,
  out locator_id uuid, out capture_id uuid, out source_id uuid, out created boolean)
language plpgsql set search_path = '' as $fn$
declare v_loc evidence.locator; v_cap evidence.source_capture; v_node record; v_kind text; v_quote text; v_value text; v_selector jsonb;
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
  if v_kind = 'text_quote' then
    if v_quote is null or btrim(v_quote) = '' then
      perform verification.chain_fail('QUOTE_REQUIRED', '22023', 'a text_quote anchor carries the verbatim quote');
    end if;
    v_value := v_quote;
    v_selector := jsonb_build_object('node_id', v_node.id, 'exact', left(v_quote, 1000));
  elsif v_kind = 'json_pointer' then
    if nullif(btrim(p_spec ->> 'pointer'), '') is null then
      perform verification.chain_fail('EVIDENCE_INVALID', '22023', 'a json_pointer anchor carries the pointer into the captured document');
    end if;
    v_value := coalesce(v_quote, v_node.inline_text);
    if v_value is null or btrim(v_value) = '' then
      perform verification.chain_fail('EVIDENCE_INVALID', '22023', 'the unit has no text to anchor; pass the quote');
    end if;
    v_selector := jsonb_build_object('node_id', v_node.id, 'pointer', p_spec ->> 'pointer');
  else
    perform verification.chain_fail('EVIDENCE_SELECTOR_UNSUPPORTED', '22023', format('a new anchor is text_quote or json_pointer, not %s; pass the locator_id of an anchor made by the capture pipeline', v_kind));
  end if;
  if v_quote is not null and position(verification.chain_norm(v_quote) in verification.chain_norm(v_node.inline_text)) = 0 then
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

-- ------------------------------------------------------------------ 3. a person's judgment is not written by a bounded role
-- review_state human_confirmed / human_rejected and method reviewed say that a person decided. A bounded role holds INSERT on
-- these tables, so the rule is on the table: only its owner (the role migrations and the governed functions run as) or a
-- superuser writes such a row. No function granted to a bounded role writes one; a person-facing writer does not exist yet.
create or replace function verification.guard_human_judgment() returns trigger
language plpgsql set search_path = '' as $fn$
declare v_row jsonb := to_jsonb(new);
begin
  if (coalesce(v_row ->> 'review_state', 'agent_proposed') <> 'agent_proposed' or coalesce(v_row ->> 'method', '') = 'reviewed')
     and current_user <> (select pg_catalog.pg_get_userbyid(c.relowner) from pg_catalog.pg_class c where c.oid = tg_relid)
     and not coalesce((select r.rolsuper from pg_catalog.pg_roles r where r.rolname = current_user), false) then
    raise exception 'HUMAN_REVIEW_NOT_AGENT_WRITABLE' using errcode = '42501',
      detail = format('%s.%s: a row that records a person''s judgment (review_state %s, method %s) is not written by role %s',
                      tg_table_schema, tg_table_name, coalesce(v_row ->> 'review_state', '-'), coalesce(v_row ->> 'method', '-'), current_user),
      hint = 'agents propose (review_state agent_proposed; method prior or derived); a person confirms or rejects through a path that is not granted to an agent role';
  end if;
  return new;
end $fn$;
comment on function verification.guard_human_judgment() is
  'Refuses an insert of a row that records a person''s judgment (probe_verdict / claim_triage review_state other than agent_proposed, source_assessment method reviewed) unless the acting role owns the table or is a superuser: no bounded role (pipeline_agent, verifier_agent, executor_service, control_plane, app_reader, service_role) can record a human review.';

drop trigger if exists probe_verdict_human_judgment on verification.probe_verdict;
create trigger probe_verdict_human_judgment before insert on verification.probe_verdict for each row execute function verification.guard_human_judgment();
drop trigger if exists claim_triage_human_judgment on verification.claim_triage;
create trigger claim_triage_human_judgment before insert on verification.claim_triage for each row execute function verification.guard_human_judgment();
drop trigger if exists source_assessment_human_judgment on evidence.source_assessment;
create trigger source_assessment_human_judgment before insert on evidence.source_assessment for each row execute function verification.guard_human_judgment();

-- Append-only, as their comments say: a later row supersedes, nothing is rewritten (no script, service or suite updates them).
drop trigger if exists probe_verdict_append_only on verification.probe_verdict;
create trigger probe_verdict_append_only before update or delete on verification.probe_verdict for each row execute function util.reject_mutation();
drop trigger if exists claim_triage_append_only on verification.claim_triage;
create trigger claim_triage_append_only before update or delete on verification.claim_triage for each row execute function util.reject_mutation();
drop trigger if exists source_assessment_append_only on evidence.source_assessment;
create trigger source_assessment_append_only before update or delete on evidence.source_assessment for each row execute function util.reject_mutation();
revoke update on verification.probe_verdict from pipeline_agent, verifier_agent, control_plane;
comment on table verification.probe_verdict is
  'Loop 4: what a probe''s runs say about one claim. Append-only: a changed verdict is a new row that supersedes. agent_proposed by default; human_confirmed and human_rejected record a person''s review and are not writable by a bounded role. A supportive verdict never verifies a claim (only a Knowledge Services admission does); a deterministic probe that contradicts a proposed claim moves it to disputed.';

-- ------------------------------------------------------------------ 4. the governed writes
-- 4.1 a claim with its evidence anchors
create or replace function api.record_claim(
  p_idempotency_key text, p_claim_type text, p_statement text, p_evidence jsonb,
  p_subjects jsonb default '[]'::jsonb, p_attributions jsonb default '[]'::jsonb, p_structured jsonb default '{}'::jsonb, p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid;
  v_statement text := btrim(coalesce(p_statement, ''));
  v_structured jsonb := coalesce(p_structured, '{}'::jsonb);
  v_evidence jsonb := coalesce(p_evidence, '[]'::jsonb);
  v_subjects jsonb := coalesce(p_subjects, '[]'::jsonb);
  v_attributions jsonb := coalesce(p_attributions, '[]'::jsonb);
  v_claim uuid; v_existing evidence.claim; e jsonb; a record; v_role text; v_entity uuid; v_source uuid; v_index integer; i integer;
  v_locators uuid[] := '{}'; v_roles text[] := '{}'; v_sources uuid[] := '{}'; v_created boolean[] := '{}';
  v_subject_ids uuid[] := '{}'; v_subject_roles text[] := '{}';
  v_attr_entities uuid[] := '{}'; v_attr_roles text[] := '{}'; v_attr_sources uuid[] := '{}'; v_attr_locators uuid[] := '{}';
begin
  v_request := jsonb_build_object('claim_type', p_claim_type, 'statement', v_statement, 'evidence', v_evidence, 'subjects', v_subjects,
                                  'attributions', v_attributions, 'structured', v_structured);
  ctx := verification.chain_begin('api.record_claim', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid;

  if v_statement = '' or length(v_statement) > 4000 then
    perform verification.chain_fail('STATEMENT_REQUIRED', '22023', 'a statement of 1 to 4000 characters');
  end if;
  if not exists (select 1 from evidence.claim_type t where t.code = p_claim_type) then
    perform verification.chain_fail('CLAIM_TYPE_UNKNOWN', '22023', format('%s is not a code of evidence.claim_type', coalesce(p_claim_type, '(null)')));
  end if;
  if jsonb_typeof(v_structured) <> 'object' then
    perform verification.chain_fail('STRUCTURED_INVALID', '22023', 'p_structured is an object');
  end if;
  if v_structured ->> 'path' = 'restatement' or v_structured ? 'restates' then
    perform verification.chain_fail('STRUCTURED_RESERVED', '22023', 'path restatement and restates are written by api.restate_claim');
  end if;
  if jsonb_typeof(v_evidence) <> 'array' or jsonb_array_length(v_evidence) not between 1 and 50 then
    perform verification.chain_fail('EVIDENCE_REQUIRED', '22023', 'a claim is recorded with 1 to 50 evidence anchors');
  end if;
  if jsonb_typeof(v_subjects) <> 'array' or jsonb_typeof(v_attributions) <> 'array' then
    perform verification.chain_fail('SUBJECT_INVALID', '22023', 'p_subjects and p_attributions are arrays');
  end if;

  -- the same statement again is the same claim (the lab rule): nothing is added to it, the caller gets its id and status
  select * into v_existing from evidence.claim c
   where c.tenant_id = v_tenant and md5(c.statement) = md5(v_statement) and c.statement = v_statement and c.atomized_from_id is null
   order by c.created_at limit 1;
  if found then
    v_result := verification.chain_record('api.record_claim', ctx, v_request,
      jsonb_build_object('claim_id', v_existing.id, 'created', false, 'reused', true, 'status', v_existing.status::text, 'locator_ids', '[]'::jsonb),
      jsonb_build_array(jsonb_build_object('schema', 'evidence', 'table', 'claim', 'id', v_existing.id)));
    perform verification.chain_target(ctx, (v_result ->> 'receipt_id')::uuid, 'evidence', 'claim', v_existing.id, 'subject', 'reused', v_existing.id);
    return v_result;
  end if;

  for e in select * from jsonb_array_elements(v_evidence) loop
    select * into a from verification.chain_anchor(v_tenant, e, 'api.record_claim');
    v_role := coalesce(e ->> 'role', 'context');
    if v_role not in ('supports', 'contradicts', 'qualifies', 'context') then
      perform verification.chain_fail('EVIDENCE_INVALID', '22023', 'an evidence link role is supports, contradicts, qualifies or context');
    end if;
    v_locators := array_append(v_locators, a.locator_id); v_roles := array_append(v_roles, v_role);
    v_sources := array_append(v_sources, a.source_id); v_created := array_append(v_created, a.created);
  end loop;

  for e in select * from jsonb_array_elements(v_subjects) loop
    v_entity := verification.chain_uuid(case jsonb_typeof(e) when 'string' then e #>> '{}' when 'object' then e ->> 'entity_id' end, 'SUBJECT_INVALID');
    v_role := case when jsonb_typeof(e) = 'object' then coalesce(e ->> 'role', 'subject') else 'subject' end;
    if v_entity is null or v_role not in ('subject', 'object', 'context') then
      perform verification.chain_fail('SUBJECT_INVALID', '22023', 'a subject is an entity id or {"entity_id", "role"} with role subject, object or context');
    end if;
    if not exists (select 1 from catalog.entity x where x.id = v_entity and x.tenant_id = v_tenant) then
      perform verification.chain_fail('SUBJECT_NOT_FOUND', 'P0002', format('no catalog entity %s in this tenant', v_entity));
    end if;
    v_subject_ids := array_append(v_subject_ids, v_entity); v_subject_roles := array_append(v_subject_roles, v_role);
  end loop;

  for e in select * from jsonb_array_elements(v_attributions) loop
    if (case when jsonb_typeof(e) <> 'object' then true
             else exists (select 1 from jsonb_object_keys(e) k where k not in ('entity_id', 'role', 'source_id', 'evidence_index')) end) then
      perform verification.chain_fail('ATTRIBUTION_INVALID', '22023', 'an attribution is {"entity_id", "role" (default stated_by), "source_id" (default: the source of the anchor), "evidence_index" (default 0)}');
    end if;
    v_entity := verification.chain_uuid(e ->> 'entity_id', 'ATTRIBUTION_INVALID');
    v_role := coalesce(nullif(btrim(e ->> 'role'), ''), 'stated_by');
    v_index := case when (e ->> 'evidence_index') ~ '^[0-9]{1,3}$' then (e ->> 'evidence_index')::integer when e ? 'evidence_index' then -1 else 0 end;
    if v_entity is null or v_index < 0 or v_index >= cardinality(v_locators) or length(v_role) > 60 then
      perform verification.chain_fail('ATTRIBUTION_INVALID', '22023', 'an attribution names an entity and, by evidence_index, one of the anchors of this call');
    end if;
    if not exists (select 1 from catalog.entity x where x.id = v_entity and x.tenant_id = v_tenant) then
      perform verification.chain_fail('ATTRIBUTION_ENTITY_NOT_FOUND', 'P0002', format('no catalog entity %s in this tenant', v_entity));
    end if;
    v_source := coalesce(verification.chain_uuid(e ->> 'source_id', 'ATTRIBUTION_INVALID'), v_sources[v_index + 1]);
    if not exists (select 1 from evidence.source s where s.id = v_source and s.tenant_id = v_tenant) then
      perform verification.chain_fail('ATTRIBUTION_SOURCE_NOT_FOUND', 'P0002', format('no evidence source %s in this tenant', v_source));
    end if;
    v_attr_entities := array_append(v_attr_entities, v_entity); v_attr_roles := array_append(v_attr_roles, v_role);
    v_attr_sources := array_append(v_attr_sources, v_source); v_attr_locators := array_append(v_attr_locators, v_locators[v_index + 1]);
  end loop;

  -- readers show the quote and its unit (api.claim_verdicts, api.community_claims): taken from the first anchor unless the caller set them
  select jsonb_strip_nulls(jsonb_build_object('quote', l.normalized_value, 'node_id', l.selector ->> 'node_id')) || v_structured into v_structured
    from evidence.locator l where l.id = v_locators[1];

  v_claim := util.uuidv7();
  v_result := verification.chain_record('api.record_claim', ctx, v_request,
    jsonb_build_object('claim_id', v_claim, 'created', true, 'reused', false, 'status', 'proposed', 'locator_ids', to_jsonb(v_locators),
                       'subjects', cardinality(v_subject_ids), 'attributions', cardinality(v_attr_entities)),
    jsonb_build_array(jsonb_build_object('schema', 'evidence', 'table', 'claim', 'id', v_claim)));
  v_receipt := (v_result ->> 'receipt_id')::uuid;
  insert into evidence.claim(id, tenant_id, claim_type, statement, structured, status, composite, producer_origin_digest, created_by_receipt_id)
  values (v_claim, v_tenant, p_claim_type, v_statement, v_structured, 'proposed', false, ctx ->> 'origin_digest', v_receipt);
  insert into evidence.claim_evidence_link(tenant_id, claim_id, locator_id, role)
  select v_tenant, v_claim, t.l, t.r from unnest(v_locators, v_roles) as t(l, r) on conflict do nothing;
  insert into evidence.claim_subject(tenant_id, claim_id, entity_id, role)
  select v_tenant, v_claim, t.e, t.r from unnest(v_subject_ids, v_subject_roles) as t(e, r) on conflict do nothing;
  insert into evidence.attribution(tenant_id, source_id, claim_id, entity_id, role, locator_id)
  select v_tenant, t.s, v_claim, t.e, t.r, t.l from unnest(v_attr_sources, v_attr_entities, v_attr_roles, v_attr_locators) as t(s, e, r, l);
  perform verification.chain_target(ctx, v_receipt, 'evidence', 'claim', v_claim, 'subject', 'created', v_claim);
  for i in 1 .. cardinality(v_locators) loop
    perform verification.chain_target(ctx, v_receipt, 'evidence', 'locator', v_locators[i], 'supporting', case when v_created[i] then 'created' else 'reused' end, v_claim);
  end loop;
  return v_result;
end $fn$;
comment on function api.record_claim(text, text, text, jsonb, jsonb, jsonb, jsonb, jsonb) is
  'Governed write: record a claim read from a source, with its evidence anchors, subjects and attributions. Always proposed. Each anchor is an existing locator or a quote that is verbatim in a content unit of a capture; structured.quote and structured.node_id default to the first anchor. The same statement again returns the existing claim (reused) and adds nothing to it. Idempotent on p_idempotency_key. Returns {claim_id, created, reused, status, locator_ids, receipt_id, intent_id, replayed}. Errors: TENANT_CONTEXT_REQUIRED, IDEMPOTENCY_KEY_REQUIRED, IDEMPOTENCY_KEY_REUSED, ACTOR_INVALID, MISSION_NOT_FOUND, MISSION_ENDED, STATEMENT_REQUIRED, CLAIM_TYPE_UNKNOWN, STRUCTURED_INVALID, STRUCTURED_RESERVED, EVIDENCE_REQUIRED, EVIDENCE_INVALID, EVIDENCE_NOT_FOUND, EVIDENCE_UNIT_NOT_IN_CAPTURE, EVIDENCE_SELECTOR_UNSUPPORTED, QUOTE_REQUIRED, QUOTE_NOT_IN_UNIT, SUBJECT_INVALID, SUBJECT_NOT_FOUND, ATTRIBUTION_INVALID, ATTRIBUTION_ENTITY_NOT_FOUND, ATTRIBUTION_SOURCE_NOT_FOUND.';

-- 4.2 a restatement (D-80): a new claim atomized from an attribution-framed one
create or replace function api.restate_claim(
  p_idempotency_key text, p_original_claim_id uuid, p_statement text,
  p_qualified boolean default false, p_dropped text default null, p_polarity jsonb default null, p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid;
  v_statement text := btrim(coalesce(p_statement, ''));
  orig evidence.claim; v_existing evidence.claim; v_claim uuid; v_probe text; v_structured jsonb; n_subjects integer; n_attr integer; n_links integer;
begin
  v_request := jsonb_build_object('original_claim_id', p_original_claim_id, 'statement', v_statement, 'qualified', coalesce(p_qualified, false),
                                  'dropped', p_dropped, 'polarity', p_polarity);
  ctx := verification.chain_begin('api.restate_claim', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid;

  select * into orig from evidence.claim c where c.id = p_original_claim_id and c.tenant_id = v_tenant for update;
  if not found then
    perform verification.chain_fail('CLAIM_NOT_FOUND', 'P0002', format('no claim %s in this tenant', coalesce(p_original_claim_id::text, '(null)')));
  end if;
  if orig.structured ->> 'path' = 'restatement' then
    perform verification.chain_fail('CLAIM_NOT_RESTATABLE', '23514', 'a restatement is not restated; restate the claim it was atomized from');
  end if;
  if orig.status::text <> 'proposed' then
    perform verification.chain_fail('CLAIM_NOT_RESTATABLE', '23514', format('only a proposed claim is restated; claim %s is %s', orig.id, orig.status));
  end if;
  if v_statement = '' or length(v_statement) > 4000 then
    perform verification.chain_fail('STATEMENT_REQUIRED', '22023', 'a statement of 1 to 4000 characters');
  end if;
  if verification.chain_norm(v_statement) = verification.chain_norm(orig.statement) then
    perform verification.chain_fail('RESTATEMENT_UNCHANGED', '22023', 'the restated statement is the original statement');
  end if;
  if p_polarity is not null and jsonb_typeof(p_polarity) <> 'object' then
    perform verification.chain_fail('POLARITY_INVALID', '22023', 'p_polarity is an object such as {"negative": true} or null');
  end if;

  select * into v_existing from evidence.claim r
   where r.tenant_id = v_tenant and r.atomized_from_id = orig.id and r.structured ->> 'path' = 'restatement' order by r.created_at limit 1;
  if found then
    if v_existing.statement <> v_statement then
      perform verification.chain_fail('RESTATEMENT_EXISTS', '23505', format('claim %s is already restated as claim %s; one restatement per original', orig.id, v_existing.id));
    end if;
    v_result := verification.chain_record('api.restate_claim', ctx, v_request,
      jsonb_build_object('claim_id', v_existing.id, 'original_claim_id', orig.id, 'created', false, 'reused', true, 'status', v_existing.status::text),
      jsonb_build_array(jsonb_build_object('schema', 'evidence', 'table', 'claim', 'id', v_existing.id)));
    perform verification.chain_target(ctx, (v_result ->> 'receipt_id')::uuid, 'evidence', 'claim', v_existing.id, 'subject', 'reused', v_existing.id);
    return v_result;
  end if;

  select p.slug into v_probe from verification.probe_verdict v join verification.probe p on p.id = v.probe_id
   where v.claim_id = orig.id and v.tenant_id = v_tenant and v.review_state <> 'human_rejected'
     and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id)
   order by v.decided_at desc limit 1;
  v_structured := jsonb_strip_nulls(jsonb_build_object(
      'path', 'restatement', 'restates', orig.id, 'probe', v_probe, 'qualified', coalesce(p_qualified, false), 'dropped', nullif(btrim(p_dropped), ''),
      'source_role', coalesce(orig.structured ->> 'source_role', case when orig.structured ->> 'path' = 'community_thread' then 'community' else 'first_party' end),
      'original_quote', orig.structured ->> 'quote', 'original_document', orig.structured ->> 'document'))
    || case when p_polarity is null then '{}'::jsonb else jsonb_build_object('polarity', p_polarity) end;
  select count(*) into n_subjects from evidence.claim_subject s where s.claim_id = orig.id;
  select count(*) into n_attr from evidence.attribution s where s.claim_id = orig.id;
  select count(*) into n_links from evidence.claim_evidence_link s where s.claim_id = orig.id;

  v_claim := util.uuidv7();
  v_result := verification.chain_record('api.restate_claim', ctx, v_request,
    jsonb_strip_nulls(jsonb_build_object('claim_id', v_claim, 'original_claim_id', orig.id, 'created', true, 'reused', false, 'status', 'proposed', 'probe', v_probe,
                       'copied', jsonb_build_object('subjects', n_subjects, 'attributions', n_attr, 'evidence_links', n_links))),
    jsonb_build_array(jsonb_build_object('schema', 'evidence', 'table', 'claim', 'id', v_claim)));
  v_receipt := (v_result ->> 'receipt_id')::uuid;
  insert into evidence.claim(id, tenant_id, claim_type, statement, structured, status, composite, atomized_from_id, producer_origin_digest, created_by_receipt_id)
  values (v_claim, v_tenant, orig.claim_type, v_statement, v_structured, 'proposed', false, orig.id, ctx ->> 'origin_digest', v_receipt);
  insert into evidence.claim_subject(tenant_id, claim_id, entity_id, role)
  select s.tenant_id, v_claim, s.entity_id, s.role from evidence.claim_subject s where s.claim_id = orig.id on conflict do nothing;
  insert into evidence.attribution(tenant_id, source_id, claim_id, entity_id, role, locator_id)
  select s.tenant_id, s.source_id, v_claim, s.entity_id, s.role, s.locator_id from evidence.attribution s where s.claim_id = orig.id;
  insert into evidence.claim_evidence_link(tenant_id, claim_id, locator_id, role)
  select v_tenant, v_claim, s.locator_id, s.role from evidence.claim_evidence_link s where s.claim_id = orig.id on conflict do nothing;
  perform verification.chain_target(ctx, v_receipt, 'evidence', 'claim', v_claim, 'subject', 'created', v_claim);
  perform verification.chain_target(ctx, v_receipt, 'evidence', 'claim', orig.id, 'provenance', 'reused', orig.id);
  return v_result;
end $fn$;
comment on function api.restate_claim(text, uuid, text, boolean, text, jsonb, jsonb) is
  'Governed write (D-80): restate an attribution-framed proposed claim as the statement a probe can test. A new proposed claim with atomized_from_id, the original''s subjects, attributions and evidence links copied; the original is not changed. One restatement per original. Its verdict is proposed separately (api.propose_verdict) and confirmed by a person. Idempotent on p_idempotency_key. Returns {claim_id, original_claim_id, created, reused, status, probe, copied, receipt_id, intent_id, replayed}. Errors: the common ones, CLAIM_NOT_FOUND, CLAIM_NOT_RESTATABLE, STATEMENT_REQUIRED, RESTATEMENT_UNCHANGED, RESTATEMENT_EXISTS, POLARITY_INVALID.';

-- 4.3 a probe and the claims it tests
create or replace function api.register_probe(
  p_idempotency_key text, p_slug text, p_title text, p_hypothesis text, p_kind text, p_claims jsonb,
  p_subject_entity_ids uuid[] default '{}'::uuid[], p_script jsonb default '{}'::jsonb, p_environment jsonb default '{}'::jsonb, p_matrix jsonb default '[]'::jsonb,
  p_model_policy text default 'none', p_budget_usd numeric default 0, p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid; v_probe uuid;
  v_claims jsonb := coalesce(p_claims, '[]'::jsonb); v_script jsonb := coalesce(p_script, '{}'::jsonb); v_environment jsonb := coalesce(p_environment, '{}'::jsonb);
  v_matrix jsonb := coalesce(p_matrix, '[]'::jsonb); v_subjects uuid[] := coalesce(p_subject_entity_ids, '{}'::uuid[]);
  v_policy text := coalesce(p_model_policy, 'none'); v_budget numeric := trim_scale(coalesce(p_budget_usd, 0));
  e jsonb; v_claim uuid; v_claim_ids uuid[] := '{}'; v_expectations jsonb[] := '{}'; v_missing uuid; i integer;
begin
  v_request := jsonb_build_object('slug', p_slug, 'title', p_title, 'hypothesis', p_hypothesis, 'kind', p_kind, 'claims', v_claims, 'subject_entity_ids', to_jsonb(v_subjects),
                                  'script', v_script, 'environment', v_environment, 'matrix', v_matrix, 'model_policy', v_policy, 'budget_usd', v_budget);
  ctx := verification.chain_begin('api.register_probe', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid;

  if p_slug is null or p_slug !~ '^[A-Za-z0-9][A-Za-z0-9._-]{1,99}$' then
    perform verification.chain_fail('PROBE_SLUG_INVALID', '22023', 'a slug of 2 to 100 letters, digits, dot, underscore or hyphen');
  end if;
  if nullif(btrim(p_title), '') is null or nullif(btrim(p_hypothesis), '') is null then
    perform verification.chain_fail('PROBE_INVALID', '22023', 'a probe has a title and a hypothesis');
  end if;
  if p_kind is null or p_kind not in ('executed', 'static_docs', 'resolution', 'registry_check', 'live_model') then
    perform verification.chain_fail('PROBE_KIND_INVALID', '22023', 'kind is executed, static_docs, resolution, registry_check or live_model');
  end if;
  if v_policy not in ('none', 'fake', 'live') then
    perform verification.chain_fail('PROBE_MODEL_POLICY_INVALID', '22023', 'model_policy is none, fake or live');
  end if;
  if (p_kind = 'live_model') <> (v_policy = 'live') then
    perform verification.chain_fail('PROBE_MODEL_POLICY_MISMATCH', '22023', 'a live_model probe has model_policy live, and only a live_model probe does');
  end if;
  if v_budget < 0 or (v_policy <> 'live' and v_budget <> 0) then
    perform verification.chain_fail('PROBE_BUDGET_INVALID', '22023', 'budget_usd is 0 for a probe that calls no live model, and never negative');
  end if;
  if (case when jsonb_typeof(v_script) <> 'object' then true
           else exists (select 1 from jsonb_object_keys(v_script) k where k not in ('path', 'sha256'))
             or (v_script ? 'sha256' and (v_script ->> 'sha256') !~ '^[0-9a-f]{64}$') end) then
    perform verification.chain_fail('PROBE_INVALID', '22023', 'p_script is {"path", "sha256"} with sha256 as 64 hex characters');
  end if;
  if jsonb_typeof(v_environment) <> 'object' or jsonb_typeof(v_matrix) <> 'array' then
    perform verification.chain_fail('PROBE_INVALID', '22023', 'p_environment is an object and p_matrix an array of cells');
  end if;
  select s into v_missing from unnest(v_subjects) s where not exists (select 1 from catalog.entity x where x.id = s and x.tenant_id = v_tenant) limit 1;
  if found then
    perform verification.chain_fail('SUBJECT_NOT_FOUND', 'P0002', format('no catalog entity %s in this tenant', v_missing));
  end if;
  if jsonb_typeof(v_claims) <> 'array' or jsonb_array_length(v_claims) not between 1 and 200 then
    perform verification.chain_fail('PROBE_CLAIMS_REQUIRED', '22023', 'a probe is registered with the 1 to 200 claims it tests, each with what is expected before any run');
  end if;
  for e in select * from jsonb_array_elements(v_claims) loop
    v_claim := verification.chain_uuid(case jsonb_typeof(e) when 'string' then e #>> '{}' when 'object' then e ->> 'claim_id' end, 'PROBE_CLAIMS_REQUIRED');
    if v_claim is null or (jsonb_typeof(e) = 'object' and e ? 'expectation' and jsonb_typeof(e -> 'expectation') <> 'object') or v_claim = any(v_claim_ids) then
      perform verification.chain_fail('PROBE_CLAIMS_REQUIRED', '22023', 'each claim is an id or {"claim_id", "expectation": {...}}, named once');
    end if;
    if not exists (select 1 from evidence.claim c where c.id = v_claim and c.tenant_id = v_tenant) then
      perform verification.chain_fail('CLAIM_NOT_FOUND', 'P0002', format('no claim %s in this tenant', v_claim));
    end if;
    v_claim_ids := array_append(v_claim_ids, v_claim);
    v_expectations := array_append(v_expectations, case when jsonb_typeof(e) = 'object' then coalesce(e -> 'expectation', '{}'::jsonb) else '{}'::jsonb end);
  end loop;
  if exists (select 1 from verification.probe p where p.tenant_id = v_tenant and p.slug = p_slug) then
    perform verification.chain_fail('PROBE_SLUG_TAKEN', '23505', format('a probe with slug %s exists', p_slug));
  end if;

  v_probe := util.uuidv7();
  v_result := verification.chain_record('api.register_probe', ctx, v_request,
    jsonb_build_object('probe_id', v_probe, 'slug', p_slug, 'state', 'active', 'claims', cardinality(v_claim_ids)),
    jsonb_build_array(jsonb_build_object('schema', 'verification', 'table', 'probe', 'id', v_probe)));
  v_receipt := (v_result ->> 'receipt_id')::uuid;
  insert into verification.probe(id, tenant_id, slug, title, hypothesis, kind, subject_entity_ids, script_path, script_sha256, environment, matrix, model_policy, budget_usd, designed_by)
  values (v_probe, v_tenant, p_slug, btrim(p_title), btrim(p_hypothesis), p_kind, v_subjects, v_script ->> 'path', v_script ->> 'sha256', v_environment, v_matrix, v_policy, v_budget, ctx ->> 'acting');
  insert into verification.probe_claim(tenant_id, probe_id, claim_id, expectation)
  select v_tenant, v_probe, t.c, t.x from unnest(v_claim_ids, v_expectations) as t(c, x);
  perform verification.chain_target(ctx, v_receipt, 'verification', 'probe', v_probe, 'subject', 'created');
  for i in 1 .. cardinality(v_claim_ids) loop
    perform verification.chain_target(ctx, v_receipt, 'evidence', 'claim', v_claim_ids[i], 'supporting', 'reused', v_claim_ids[i]);
  end loop;
  return v_result;
end $fn$;
comment on function api.register_probe(text, text, text, text, text, jsonb, uuid[], jsonb, jsonb, jsonb, text, numeric, jsonb) is
  'Governed write: register a probe (an experiment against a matrix of cells) with the claims it tests and what is expected of each before any run. Only a live_model probe has model_policy live and a budget. Idempotent on p_idempotency_key. Returns {probe_id, slug, state, claims, receipt_id, intent_id, replayed}. Errors: the common ones, PROBE_SLUG_INVALID, PROBE_INVALID, PROBE_KIND_INVALID, PROBE_MODEL_POLICY_INVALID, PROBE_MODEL_POLICY_MISMATCH, PROBE_BUDGET_INVALID, PROBE_CLAIMS_REQUIRED, CLAIM_NOT_FOUND, SUBJECT_NOT_FOUND, PROBE_SLUG_TAKEN.';

-- 4.4 one execution of a probe in one cell, with what it observed
create or replace function api.record_probe_run(
  p_idempotency_key text, p_probe_id uuid, p_cell_label text, p_outcome text, p_started_at timestamptz,
  p_observations jsonb default '{}'::jsonb, p_output jsonb default null, p_cell jsonb default '{}'::jsonb, p_resolved jsonb default '{}'::jsonb,
  p_run jsonb default '{}'::jsonb, p_sweep_id uuid default null, p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid; v_run uuid; v_mission uuid;
  v_observations jsonb := coalesce(p_observations, '{}'::jsonb); v_cell jsonb := coalesce(p_cell, '{}'::jsonb); v_resolved jsonb := coalesce(p_resolved, '{}'::jsonb);
  v_extra jsonb := coalesce(p_run, '{}'::jsonb); v_label text := btrim(coalesce(p_cell_label, ''));
  pr verification.probe; sw acquisition.attention_sweep; a record;
  v_ended timestamptz; v_exit integer; v_tokens_in integer; v_tokens_out integer; v_cost numeric; v_latency integer; v_capture uuid; v_locator uuid; v_anchor_created boolean := false;
begin
  v_request := jsonb_build_object('probe_id', p_probe_id, 'cell_label', v_label, 'outcome', p_outcome,
    'started_at', to_char(p_started_at at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'), 'observations', v_observations, 'output', p_output,
    'cell', v_cell, 'resolved', v_resolved, 'run', v_extra, 'sweep_id', p_sweep_id);
  ctx := verification.chain_begin('api.record_probe_run', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid; v_mission := (ctx ->> 'mission_id')::uuid;

  select * into pr from verification.probe p where p.id = p_probe_id and p.tenant_id = v_tenant;
  if not found then
    perform verification.chain_fail('PROBE_NOT_FOUND', 'P0002', format('no probe %s in this tenant', coalesce(p_probe_id::text, '(null)')));
  end if;
  if pr.state <> 'active' then
    perform verification.chain_fail('PROBE_NOT_ACTIVE', '23514', format('probe %s is %s', pr.slug, pr.state));
  end if;
  if v_label = '' or length(v_label) > 200 or p_outcome is null or p_outcome not in ('pass', 'fail', 'error', 'skipped') or p_started_at is null
     or p_started_at > clock_timestamp() + interval '5 minutes'
     or jsonb_typeof(v_observations) <> 'object' or jsonb_typeof(v_cell) <> 'object' or jsonb_typeof(v_resolved) <> 'object'
     or (case when jsonb_typeof(v_extra) <> 'object' then true
              else exists (select 1 from jsonb_object_keys(v_extra) k where k not in ('ended_at', 'exit_code', 'lock_sha256', 'python_version', 'platform', 'tokens_in', 'tokens_out', 'cost_usd', 'latency_ms')) end) then
    perform verification.chain_fail('PROBE_RUN_INVALID', '22023',
      'a run has a cell label, an outcome (pass, fail, error, skipped: about the probe''s own checks, not the claim), a start time that is not in the future, object observations, cell and resolved, and p_run keys ended_at, exit_code, lock_sha256, python_version, platform, tokens_in, tokens_out, cost_usd, latency_ms');
  end if;
  begin
    v_ended := (v_extra ->> 'ended_at')::timestamptz; v_exit := (v_extra ->> 'exit_code')::integer;
    v_tokens_in := (v_extra ->> 'tokens_in')::integer; v_tokens_out := (v_extra ->> 'tokens_out')::integer;
    v_cost := (v_extra ->> 'cost_usd')::numeric; v_latency := (v_extra ->> 'latency_ms')::integer;
  exception when data_exception then
    perform verification.chain_fail('PROBE_RUN_INVALID', '22023', 'p_run: ' || sqlerrm);
  end;
  if v_ended < p_started_at or coalesce(v_cost, 0) < 0 or coalesce(v_tokens_in, 0) < 0 or coalesce(v_tokens_out, 0) < 0 or coalesce(v_latency, 0) < 0 then
    perform verification.chain_fail('PROBE_RUN_INVALID', '22023', 'ended_at is not before started_at; cost, tokens and latency are not negative');
  end if;
  if pr.model_policy <> 'live' and (coalesce(v_cost, 0) > 0 or coalesce(v_tokens_in, 0) > 0 or coalesce(v_tokens_out, 0) > 0) then
    perform verification.chain_fail('PROBE_RUN_SPEND_NOT_ALLOWED', '23514', format('probe %s has model_policy %s: a run of it reports no model tokens or cost', pr.slug, pr.model_policy));
  end if;
  if ctx ? 'mc' and v_mission is null then
    perform verification.chain_fail('MISSION_REQUIRED', '22023', 'a run made by a Mission Control invocation names the AI Engineer mission whose budget bounds it (p_actor.mission_id)');
  end if;
  if p_output is null or jsonb_typeof(p_output) = 'null' then
    if p_outcome in ('pass', 'fail') then
      perform verification.chain_fail('PROBE_RUN_OUTPUT_REQUIRED', '22023', 'a run that passed or failed is recorded with its captured output as an evidence anchor, so a verdict can cite it');
    end if;
  else
    select * into a from verification.chain_anchor(v_tenant, p_output, 'api.record_probe_run');
    v_capture := a.capture_id; v_locator := a.locator_id; v_anchor_created := a.created;
  end if;
  if p_sweep_id is not null then
    select * into sw from acquisition.attention_sweep s where s.id = p_sweep_id and s.tenant_id = v_tenant;
    if not found then
      perform verification.chain_fail('SWEEP_NOT_FOUND', 'P0002', format('no attention sweep %s in this tenant', p_sweep_id));
    end if;
    if sw.ended_at is not null then
      perform verification.chain_fail('SWEEP_NOT_OPEN', '23514', format('sweep %s is settled (%s)', sw.id, sw.outcome));
    end if;
    if sw.mission_id is distinct from v_mission then
      perform verification.chain_fail('SWEEP_MISSION_MISMATCH', '23514', 'the run and the sweep it belongs to name the same mission, or neither names one');
    end if;
  end if;
  if exists (select 1 from verification.probe_run r where r.probe_id = pr.id and r.tenant_id = v_tenant and r.cell_label = v_label and r.started_at = p_started_at) then
    perform verification.chain_fail('PROBE_RUN_DUPLICATE', '23505', format('probe %s already has a run in cell %s started at %s', pr.slug, v_label, p_started_at));
  end if;

  v_run := util.uuidv7();
  v_result := verification.chain_record('api.record_probe_run', ctx, v_request,
    jsonb_strip_nulls(jsonb_build_object('probe_run_id', v_run, 'probe_id', pr.id, 'probe', pr.slug, 'cell_label', v_label, 'outcome', p_outcome,
      'output_capture_id', v_capture, 'output_locator_id', v_locator, 'origin_kind', case when v_mission is null then 'standalone' else 'mission' end,
      'over_budget', pr.model_policy = 'live' and coalesce(v_cost, 0) > pr.budget_usd)),
    jsonb_build_array(jsonb_build_object('schema', 'verification', 'table', 'probe_run', 'id', v_run)));
  v_receipt := (v_result ->> 'receipt_id')::uuid;
  insert into verification.probe_run(id, tenant_id, probe_id, cell_label, cell, resolved, lock_sha256, python_version, platform, started_at, ended_at, exit_code, outcome, observations,
    output_capture_id, output_locator_id, tokens_in, tokens_out, cost_usd, latency_ms, sweep_id, mission_id, origin_kind, receipt_id)
  values (v_run, v_tenant, pr.id, v_label, v_cell, v_resolved, v_extra ->> 'lock_sha256', v_extra ->> 'python_version', v_extra ->> 'platform', p_started_at, v_ended, v_exit, p_outcome, v_observations,
    v_capture, v_locator, v_tokens_in, v_tokens_out, v_cost, v_latency, p_sweep_id, v_mission, case when v_mission is null then 'standalone' else 'mission' end, v_receipt);
  perform verification.chain_target(ctx, v_receipt, 'verification', 'probe_run', v_run, 'subject', 'created');
  if v_locator is not null then
    perform verification.chain_target(ctx, v_receipt, 'evidence', 'locator', v_locator, 'supporting', case when v_anchor_created then 'created' else 'reused' end);
  end if;
  return v_result;
end $fn$;
comment on function api.record_probe_run(text, uuid, text, text, timestamptz, jsonb, jsonb, jsonb, jsonb, jsonb, uuid, jsonb) is
  'Governed write: record one execution of an active probe in one cell: outcome (about the probe''s own checks), observations, the versions it resolved, and its captured output as an evidence anchor (required when it passed or failed). A probe that is not live reports no tokens or cost. A run under a mission names it; under a sweep, an open one of the same mission. Idempotent on p_idempotency_key. Returns {probe_run_id, probe_id, probe, cell_label, outcome, output_capture_id, output_locator_id, origin_kind, over_budget, receipt_id, intent_id, replayed}. Errors: the common ones and the evidence ones, PROBE_NOT_FOUND, PROBE_NOT_ACTIVE, PROBE_RUN_INVALID, PROBE_RUN_SPEND_NOT_ALLOWED, PROBE_RUN_OUTPUT_REQUIRED, PROBE_RUN_DUPLICATE, MISSION_REQUIRED, SWEEP_NOT_FOUND, SWEEP_NOT_OPEN, SWEEP_MISSION_MISMATCH.';

-- 4.5 what a probe's runs say about one claim: always proposed by the agent
create or replace function api.propose_verdict(
  p_idempotency_key text, p_claim_id uuid, p_probe_id uuid, p_verdict text, p_cells jsonb, p_rationale text, p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid; v_verdict uuid;
  v_cells jsonb := coalesce(p_cells, '{}'::jsonb); v_rationale text := btrim(coalesce(p_rationale, ''));
  c evidence.claim; pr verification.probe; cur verification.probe_verdict; v_has_current boolean; v_linked boolean; v_missing text;
  v_locator uuid; v_link_role text; v_status text; v_disputed boolean := false; v_supportive boolean; v_restatements jsonb; v_needs_review boolean;
begin
  v_request := jsonb_build_object('claim_id', p_claim_id, 'probe_id', p_probe_id, 'verdict', p_verdict, 'cells', v_cells, 'rationale', v_rationale);
  ctx := verification.chain_begin('api.propose_verdict', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid;

  select * into c from evidence.claim x where x.id = p_claim_id and x.tenant_id = v_tenant for update;
  if not found then
    perform verification.chain_fail('CLAIM_NOT_FOUND', 'P0002', format('no claim %s in this tenant', coalesce(p_claim_id::text, '(null)')));
  end if;
  select * into pr from verification.probe p where p.id = p_probe_id and p.tenant_id = v_tenant;
  if not found then
    perform verification.chain_fail('PROBE_NOT_FOUND', 'P0002', format('no probe %s in this tenant', coalesce(p_probe_id::text, '(null)')));
  end if;
  if p_verdict is null or not (p_verdict = any (enum_range(null::evidence.support_verdict)::text[])) then
    perform verification.chain_fail('VERDICT_INVALID', '22023', format('%s is not a value of evidence.support_verdict', coalesce(p_verdict, '(null)')));
  end if;
  if v_rationale = '' then
    perform verification.chain_fail('RATIONALE_REQUIRED', '22023', 'a verdict says what the runs showed');
  end if;
  if jsonb_typeof(v_cells) <> 'object' or v_cells = '{}'::jsonb then
    perform verification.chain_fail('VERDICT_REQUIRES_RUNS', '22023', 'p_cells is an object keyed by the cell labels of the runs the verdict rests on, with what each showed');
  end if;
  select k into v_missing from jsonb_object_keys(v_cells) k
   where not exists (select 1 from verification.probe_run r where r.probe_id = pr.id and r.tenant_id = v_tenant and r.cell_label = k) limit 1;
  if found then
    perform verification.chain_fail('VERDICT_CELL_NOT_RUN', '23514', format('probe %s has no recorded run in cell %s', pr.slug, v_missing));
  end if;
  -- the claim is one the probe was registered to test; a restatement is tested by the probe of the claim it restates
  v_linked := exists (select 1 from verification.probe_claim pc where pc.probe_id = pr.id and pc.claim_id = c.id);
  if not v_linked and not (c.structured ->> 'path' = 'restatement' and exists (select 1 from verification.probe_claim pc where pc.probe_id = pr.id and pc.claim_id = c.atomized_from_id)) then
    perform verification.chain_fail('CLAIM_NOT_PROBED', '23514', format('probe %s was not registered to test claim %s', pr.slug, c.id));
  end if;

  select * into cur from verification.probe_verdict v
   where v.claim_id = c.id and v.probe_id = pr.id and v.tenant_id = v_tenant and not exists (select 1 from verification.probe_verdict w where w.supersedes_id = v.id)
   order by v.decided_at desc limit 1;
  v_has_current := found;
  v_supportive := p_verdict in ('directly_supported', 'supported_with_qualification', 'partially_supported', 'derived_verified');
  select coalesce(jsonb_agg(r.id order by r.created_at), '[]'::jsonb) into v_restatements from evidence.claim r
   where r.tenant_id = v_tenant and r.atomized_from_id = c.id and r.structured ->> 'path' = 'restatement';

  if v_has_current and cur.verdict::text = p_verdict then
    if cur.review_state = 'human_rejected' then
      perform verification.chain_fail('VERDICT_REJECTED_BY_PERSON', '23514', format('a person rejected verdict %s of probe %s on this claim; propose a different verdict or ask for a review', p_verdict, pr.slug));
    end if;
    -- the same verdict again is not a new row (the revalidation rule: only a changed verdict is written)
    v_result := verification.chain_record('api.propose_verdict', ctx, v_request,
      jsonb_build_object('verdict_id', cur.id, 'written', false, 'unchanged', true, 'verdict', p_verdict, 'review_state', cur.review_state,
                         'claim_status', c.status::text, 'claim_status_changed', false, 'needs_review', false, 'restatements_to_review', '[]'::jsonb),
      jsonb_build_array(jsonb_build_object('schema', 'verification', 'table', 'probe_verdict', 'id', cur.id)));
    perform verification.chain_target(ctx, (v_result ->> 'receipt_id')::uuid, 'verification', 'probe_verdict', cur.id, 'subject', 'reused', c.id);
    return v_result;
  end if;

  -- D-55: a probe verdict is evidence, never verification. A deterministic probe that contradicts a proposed claim disputes it.
  v_status := c.status::text;
  if c.status::text = 'proposed' and p_verdict = 'contradicted' and pr.kind in ('executed', 'static_docs', 'resolution', 'registry_check') then
    v_status := 'disputed'; v_disputed := true;
  end if;
  if c.status::text in ('proposed', 'disputed') then
    select r.output_locator_id into v_locator from verification.probe_run r
     where r.probe_id = pr.id and r.tenant_id = v_tenant and v_cells ? r.cell_label and r.output_locator_id is not null
     order by r.started_at desc limit 1;
  end if;
  v_link_role := case when v_supportive then 'supports' when p_verdict in ('contradicted', 'not_supported', 'derived_failed') then 'contradicts' else 'context' end;
  v_needs_review := (c.status::text = 'verified' and not v_supportive) or (v_has_current and cur.review_state = 'human_confirmed') or jsonb_array_length(v_restatements) > 0;

  v_verdict := util.uuidv7();
  v_result := verification.chain_record('api.propose_verdict', ctx, v_request,
    jsonb_strip_nulls(jsonb_build_object('verdict_id', v_verdict, 'written', true, 'unchanged', false, 'verdict', p_verdict, 'review_state', 'agent_proposed',
      'supersedes_id', case when v_has_current then cur.id end, 'claim_status', v_status, 'claim_status_changed', v_disputed,
      'evidence_locator_id', v_locator, 'needs_review', v_needs_review, 'restatements_to_review', v_restatements)),
    jsonb_build_array(jsonb_build_object('schema', 'verification', 'table', 'probe_verdict', 'id', v_verdict)));
  v_receipt := (v_result ->> 'receipt_id')::uuid;
  if not v_linked then
    insert into verification.probe_claim(tenant_id, probe_id, claim_id, expectation)
    values (v_tenant, pr.id, c.id, jsonb_build_object('restates', c.atomized_from_id, 'linked_by', 'api.propose_verdict')) on conflict do nothing;
  end if;
  insert into verification.probe_verdict(id, tenant_id, claim_id, probe_id, verdict, cells, rationale, decided_by, review_state, decided_at, supersedes_id)
  values (v_verdict, v_tenant, c.id, pr.id, p_verdict::evidence.support_verdict, v_cells, v_rationale, ctx ->> 'acting', 'agent_proposed', clock_timestamp(),
          case when v_has_current then cur.id end);
  if v_locator is not null then
    insert into evidence.claim_evidence_link(tenant_id, claim_id, locator_id, role, support_verdict)
    values (v_tenant, c.id, v_locator, v_link_role, p_verdict::evidence.support_verdict) on conflict do nothing;
  end if;
  if v_disputed then
    update evidence.claim set status = 'disputed' where id = c.id and status = 'proposed';
  end if;
  perform verification.chain_target(ctx, v_receipt, 'verification', 'probe_verdict', v_verdict, 'subject', 'created', c.id);
  if v_has_current then
    perform verification.chain_target(ctx, v_receipt, 'verification', 'probe_verdict', cur.id, 'provenance', 'superseded', c.id);
  end if;
  if v_disputed then
    perform verification.chain_target(ctx, v_receipt, 'evidence', 'claim', c.id, 'canonical', 'updated', c.id);
  end if;
  return v_result;
end $fn$;
comment on function api.propose_verdict(text, uuid, uuid, text, jsonb, text, jsonb) is
  'Governed write: propose what a probe''s recorded runs say about a claim the probe tests. Always review_state agent_proposed: a person confirms or rejects through a path no agent role holds, and only a Knowledge Services admission verifies. Append-only: a changed verdict supersedes the current one; the same verdict again writes nothing. A deterministic contradiction moves a proposed claim to disputed; no other status is touched. Idempotent on p_idempotency_key. Returns {verdict_id, written, unchanged, verdict, review_state, supersedes_id, claim_status, claim_status_changed, evidence_locator_id, needs_review, restatements_to_review, receipt_id, intent_id, replayed}. Errors: the common ones, CLAIM_NOT_FOUND, PROBE_NOT_FOUND, VERDICT_INVALID, RATIONALE_REQUIRED, VERDICT_REQUIRES_RUNS, VERDICT_CELL_NOT_RUN, CLAIM_NOT_PROBED, VERDICT_REJECTED_BY_PERSON.';

-- 4.6 what to do with a claim candidate before anyone checks it
create or replace function api.record_triage(
  p_idempotency_key text, p_claim_id uuid, p_disposition text, p_checkability text, p_rationale text,
  p_priority numeric default null, p_components jsonb default '{}'::jsonb, p_duplicate_of_claim_id uuid default null, p_probe_id uuid default null, p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid; v_triage uuid;
  v_components jsonb := coalesce(p_components, '{}'::jsonb); v_rationale text := btrim(coalesce(p_rationale, '')); v_priority numeric := trim_scale(p_priority);
  c evidence.claim; cur verification.claim_triage; v_has_current boolean;
begin
  v_request := jsonb_build_object('claim_id', p_claim_id, 'disposition', p_disposition, 'checkability', p_checkability, 'rationale', v_rationale, 'priority', v_priority,
                                  'components', v_components, 'duplicate_of_claim_id', p_duplicate_of_claim_id, 'probe_id', p_probe_id);
  ctx := verification.chain_begin('api.record_triage', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid;

  select * into c from evidence.claim x where x.id = p_claim_id and x.tenant_id = v_tenant;
  if not found then
    perform verification.chain_fail('CLAIM_NOT_FOUND', 'P0002', format('no claim %s in this tenant', coalesce(p_claim_id::text, '(null)')));
  end if;
  if c.status::text <> 'proposed' then
    perform verification.chain_fail('CLAIM_NOT_TRIAGEABLE', '23514', format('triage is for a candidate; claim %s is %s', c.id, c.status));
  end if;
  if p_disposition is null or p_disposition not in ('probe', 'docs_check', 'registry_check', 'not_checkable', 'duplicate', 'out_of_scope')
     or p_checkability is null or p_checkability not in ('deterministic_local', 'needs_live_model', 'needs_external_service', 'historical_only', 'not_applicable')
     or jsonb_typeof(v_components) <> 'object' or v_priority not between 0 and 9999.99 then
    perform verification.chain_fail('TRIAGE_INVALID', '22023',
      'disposition is probe, docs_check, registry_check, not_checkable, duplicate or out_of_scope; checkability is deterministic_local, needs_live_model, needs_external_service, historical_only or not_applicable; components is an object; priority is 0 to 9999.99');
  end if;
  if v_rationale = '' then
    perform verification.chain_fail('RATIONALE_REQUIRED', '22023', 'a triage row says why');
  end if;
  if (p_disposition = 'duplicate') <> (p_duplicate_of_claim_id is not null) or p_duplicate_of_claim_id = c.id
     or (p_duplicate_of_claim_id is not null and not exists (select 1 from evidence.claim x where x.id = p_duplicate_of_claim_id and x.tenant_id = v_tenant)) then
    perform verification.chain_fail('TRIAGE_DUPLICATE_INVALID', '22023', 'disposition duplicate names another claim of the tenant in p_duplicate_of_claim_id, and only it does');
  end if;
  if p_probe_id is not null and (p_disposition <> 'probe' or not exists (select 1 from verification.probe p where p.id = p_probe_id and p.tenant_id = v_tenant)) then
    perform verification.chain_fail('TRIAGE_PROBE_INVALID', '22023', 'p_probe_id names the probe a candidate became, with disposition probe');
  end if;

  select * into cur from verification.claim_triage t
   where t.claim_id = c.id and t.tenant_id = v_tenant and not exists (select 1 from verification.claim_triage w where w.supersedes_id = t.id)
   order by t.decided_at desc limit 1;
  v_has_current := found;
  if v_has_current and cur.review_state <> 'agent_proposed' then
    perform verification.chain_fail('TRIAGE_REVIEWED_BY_PERSON', '23514', format('a person reviewed the triage of claim %s (%s); an agent does not supersede it', c.id, cur.review_state));
  end if;
  if v_has_current and cur.disposition = p_disposition and cur.checkability = p_checkability and cur.probe_id is not distinct from p_probe_id
     and cur.duplicate_of_claim_id is not distinct from p_duplicate_of_claim_id then
    v_result := verification.chain_record('api.record_triage', ctx, v_request,
      jsonb_build_object('triage_id', cur.id, 'written', false, 'unchanged', true, 'disposition', cur.disposition, 'review_state', cur.review_state),
      jsonb_build_array(jsonb_build_object('schema', 'verification', 'table', 'claim_triage', 'id', cur.id)));
    perform verification.chain_target(ctx, (v_result ->> 'receipt_id')::uuid, 'verification', 'claim_triage', cur.id, 'subject', 'reused', c.id);
    return v_result;
  end if;

  v_triage := util.uuidv7();
  v_result := verification.chain_record('api.record_triage', ctx, v_request,
    jsonb_strip_nulls(jsonb_build_object('triage_id', v_triage, 'written', true, 'unchanged', false, 'disposition', p_disposition, 'review_state', 'agent_proposed',
                       'supersedes_id', case when v_has_current then cur.id end)),
    jsonb_build_array(jsonb_build_object('schema', 'verification', 'table', 'claim_triage', 'id', v_triage)));
  v_receipt := (v_result ->> 'receipt_id')::uuid;
  insert into verification.claim_triage(id, tenant_id, claim_id, disposition, checkability, priority, components, duplicate_of_claim_id, probe_id, rationale, decided_by, review_state, decided_at, supersedes_id)
  values (v_triage, v_tenant, c.id, p_disposition, p_checkability, v_priority, v_components, p_duplicate_of_claim_id, p_probe_id, v_rationale, ctx ->> 'acting', 'agent_proposed', clock_timestamp(),
          case when v_has_current then cur.id end);
  perform verification.chain_target(ctx, v_receipt, 'verification', 'claim_triage', v_triage, 'subject', 'created', c.id);
  if v_has_current then
    perform verification.chain_target(ctx, v_receipt, 'verification', 'claim_triage', cur.id, 'provenance', 'superseded', c.id);
  end if;
  return v_result;
end $fn$;
comment on function api.record_triage(text, uuid, text, text, text, numeric, jsonb, uuid, uuid, jsonb) is
  'Governed write: record what to do with a proposed claim before anyone checks it (probe it, check the docs or a registry, not checkable, duplicate, out of scope). Never a judgment of truth. Always review_state agent_proposed; append-only: a changed triage supersedes the agent''s current row, the same triage again writes nothing, and a row a person reviewed is not superseded by an agent. Idempotent on p_idempotency_key. Returns {triage_id, written, unchanged, disposition, review_state, supersedes_id, receipt_id, intent_id, replayed}. Errors: the common ones, CLAIM_NOT_FOUND, CLAIM_NOT_TRIAGEABLE, TRIAGE_INVALID, RATIONALE_REQUIRED, TRIAGE_DUPLICATE_INVALID, TRIAGE_PROBE_INVALID, TRIAGE_REVIEWED_BY_PERSON.';

-- 4.7 what we know about a source: a role prior, or the assessment derived from verdicts
create or replace function api.record_source_assessment(
  p_idempotency_key text, p_subject_entity_id uuid, p_method text, p_topic_entity_id uuid default null,
  p_source_role_code text default null, p_conflict_of_interest text default null, p_method_disclosure text default null, p_rationale text default null,
  p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid; v_id uuid;
  v_note text := nullif(btrim(coalesce(p_rationale, '')), ''); v_kind text; v_rank numeric; v_prev uuid; base evidence.source_assessment; v_has_base boolean;
  v_coi text := coalesce(p_conflict_of_interest, 'unknown'); v_disclosure text := coalesce(p_method_disclosure, 'not_applicable'); made evidence.source_assessment;
begin
  v_request := jsonb_build_object('subject_entity_id', p_subject_entity_id, 'method', p_method, 'topic_entity_id', p_topic_entity_id, 'source_role_code', p_source_role_code,
                                  'conflict_of_interest', p_conflict_of_interest, 'method_disclosure', p_method_disclosure, 'rationale', v_note);
  ctx := verification.chain_begin('api.record_source_assessment', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid;

  if p_method = 'reviewed' then
    perform verification.chain_fail('HUMAN_REVIEW_NOT_AGENT_WRITABLE', '42501', 'a reviewed assessment records a person''s judgment; an agent records a prior or a derived assessment');
  end if;
  if p_method is null or p_method not in ('prior', 'derived') then
    perform verification.chain_fail('ASSESSMENT_METHOD_INVALID', '22023', 'method is prior (from the source role) or derived (from the verdicts on the claims the source stated)');
  end if;
  select e.kind into v_kind from catalog.entity e where e.id = p_subject_entity_id and e.tenant_id = v_tenant;
  if not found then
    perform verification.chain_fail('ASSESSMENT_SUBJECT_NOT_FOUND', 'P0002', format('no catalog entity %s in this tenant', coalesce(p_subject_entity_id::text, '(null)')));
  end if;
  if v_kind not in ('source_channel', 'community_actor', 'organization', 'person') then
    perform verification.chain_fail('ASSESSMENT_SUBJECT_INVALID', '22023', format('a source is a source_channel, community_actor, organization or person, not a %s', v_kind));
  end if;
  if p_topic_entity_id is not null and not exists (select 1 from catalog.entity e where e.id = p_topic_entity_id and e.tenant_id = v_tenant) then
    perform verification.chain_fail('ASSESSMENT_TOPIC_NOT_FOUND', 'P0002', format('no catalog entity %s in this tenant', p_topic_entity_id));
  end if;
  select a.id into v_prev from evidence.source_assessment a
   where a.tenant_id = v_tenant and a.subject_entity_id = p_subject_entity_id and a.topic_entity_id is not distinct from p_topic_entity_id
   order by a.as_of desc, a.created_at desc limit 1;

  if p_method = 'prior' then
    select r.authority_rank into v_rank from content.source_role r where r.code = p_source_role_code;
    if not found then
      perform verification.chain_fail('ASSESSMENT_ROLE_UNKNOWN', '22023', format('%s is not a code of content.source_role', coalesce(p_source_role_code, '(null)')));
    end if;
    if v_coi not in ('none', 'vendor_self', 'vendor_adjacent', 'competitor', 'unknown') or v_disclosure not in ('none', 'partial', 'full', 'not_applicable') then
      perform verification.chain_fail('ASSESSMENT_INVALID', '22023', 'conflict_of_interest is none, vendor_self, vendor_adjacent, competitor or unknown; method_disclosure is none, partial, full or not_applicable');
    end if;
    select * into base from evidence.source_assessment a
     where a.tenant_id = v_tenant and a.subject_entity_id = p_subject_entity_id and a.topic_entity_id is not distinct from p_topic_entity_id and a.method in ('prior', 'reviewed')
     order by a.as_of desc, a.created_at desc limit 1;
    v_has_base := found;
    if v_has_base and base.method = 'reviewed' then
      perform verification.chain_fail('ASSESSMENT_REVIEWED_BY_PERSON', '23514', 'a person reviewed this source on this topic; an agent does not replace that base with a prior');
    end if;
    if v_has_base and base.source_role_code = p_source_role_code and base.conflict_of_interest = v_coi and base.method_disclosure = v_disclosure then
      v_result := verification.chain_record('api.record_source_assessment', ctx, v_request,
        jsonb_build_object('assessment_id', base.id, 'method', 'prior', 'written', false, 'unchanged', true, 'authority_score', base.authority_score),
        jsonb_build_array(jsonb_build_object('schema', 'evidence', 'table', 'source_assessment', 'id', base.id)));
      perform verification.chain_target(ctx, (v_result ->> 'receipt_id')::uuid, 'evidence', 'source_assessment', base.id, 'subject', 'reused');
      return v_result;
    end if;
    v_id := util.uuidv7();
    v_result := verification.chain_record('api.record_source_assessment', ctx, v_request,
      jsonb_strip_nulls(jsonb_build_object('assessment_id', v_id, 'method', 'prior', 'written', true, 'unchanged', false, 'authority_score', v_rank, 'claims_checked', 0, 'supersedes_id', v_prev)),
      jsonb_build_array(jsonb_build_object('schema', 'evidence', 'table', 'source_assessment', 'id', v_id)));
    v_receipt := (v_result ->> 'receipt_id')::uuid;
    insert into evidence.source_assessment(id, tenant_id, subject_entity_id, topic_entity_id, method, source_role_code, conflict_of_interest, method_disclosure, authority_score,
                                           recommended_watch_level, rationale, inputs, assessed_by, receipt_id, supersedes_id)
    values (v_id, v_tenant, p_subject_entity_id, p_topic_entity_id, 'prior', p_source_role_code, v_coi, v_disclosure, v_rank, null,
            'prior from source role ' || p_source_role_code || coalesce(': ' || v_note, ''), jsonb_build_object('prior', v_rank), ctx ->> 'acting', v_receipt, v_prev);
  else
    if p_source_role_code is not null or p_conflict_of_interest is not null or p_method_disclosure is not null then
      perform verification.chain_fail('ASSESSMENT_INVALID', '22023', 'a derived assessment takes role, conflict of interest and method disclosure from the prior or reviewed row; pass none of them');
    end if;
    if not exists (select 1 from evidence.source_assessment a where a.tenant_id = v_tenant and a.subject_entity_id = p_subject_entity_id and a.method in ('prior', 'reviewed')
                    and (a.topic_entity_id is not distinct from p_topic_entity_id or a.topic_entity_id is null)) then
      perform verification.chain_fail('ASSESSMENT_BASE_REQUIRED', '23514', 'record the source''s prior first: a derived assessment moves a role prior, it does not invent one');
    end if;
    v_id := evidence.derive_source_assessment(p_subject_entity_id, p_topic_entity_id, ctx ->> 'acting', v_note);
    select * into made from evidence.source_assessment a where a.id = v_id;
    v_result := verification.chain_record('api.record_source_assessment', ctx, v_request,
      jsonb_strip_nulls(jsonb_build_object('assessment_id', v_id, 'method', 'derived', 'written', true, 'unchanged', false, 'authority_score', made.authority_score,
        'claims_observed', made.claims_observed, 'claims_checked', made.claims_checked, 'self_checked', made.self_checked,
        'recommended_watch_level', made.recommended_watch_level, 'supersedes_id', made.supersedes_id)),
      jsonb_build_array(jsonb_build_object('schema', 'evidence', 'table', 'source_assessment', 'id', v_id)));
    v_receipt := (v_result ->> 'receipt_id')::uuid;
  end if;
  perform verification.chain_target(ctx, v_receipt, 'evidence', 'source_assessment', v_id, 'subject', 'created');
  return v_result;
end $fn$;
comment on function api.record_source_assessment(text, uuid, text, uuid, text, text, text, text, jsonb) is
  'Governed write: append what we know about a source (a channel, a handle, an organization, a person), on a topic or overall. method prior: the role prior, scored by the role''s authority rank, never by the caller. method derived: evidence.derive_source_assessment over the latest verdicts on the claims the source stated (self-checked claims not scored, D-61; a watch level only from 5 checked claims, D-69); needs a prior. method reviewed is a person''s and is refused. Idempotent on p_idempotency_key. Returns {assessment_id, method, written, unchanged, authority_score, claims_observed, claims_checked, self_checked, recommended_watch_level, supersedes_id, receipt_id, intent_id, replayed}. Errors: the common ones, HUMAN_REVIEW_NOT_AGENT_WRITABLE, ASSESSMENT_METHOD_INVALID, ASSESSMENT_SUBJECT_NOT_FOUND, ASSESSMENT_SUBJECT_INVALID, ASSESSMENT_TOPIC_NOT_FOUND, ASSESSMENT_ROLE_UNKNOWN, ASSESSMENT_INVALID, ASSESSMENT_REVIEWED_BY_PERSON, ASSESSMENT_BASE_REQUIRED.';

-- 4.8 attention: open one execution of an attention policy (a sweep) ...
create or replace function api.raise_attention_sweep(
  p_idempotency_key text, p_policy text, p_trigger_kind text, p_trigger_ref jsonb default '{}'::jsonb, p_note text default null,
  p_window_from timestamptz default null, p_window_to timestamptz default null, p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid; v_sweep uuid; v_mission uuid; v_mc jsonb;
  v_ref jsonb := coalesce(p_trigger_ref, '{}'::jsonb); pol acquisition.attention_policy; v_spent numeric := 0; v_budget numeric; v_stop boolean := false;
begin
  v_request := jsonb_build_object('policy', p_policy, 'trigger_kind', p_trigger_kind, 'trigger_ref', v_ref, 'note', p_note,
    'window_from', to_char(p_window_from at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'), 'window_to', to_char(p_window_to at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'));
  ctx := verification.chain_begin('api.raise_attention_sweep', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid; v_mission := (ctx ->> 'mission_id')::uuid; v_mc := ctx -> 'mc';
  v_budget := (ctx ->> 'mission_budget_usd')::numeric;

  select * into pol from acquisition.attention_policy p where p.tenant_id = v_tenant and (p.slug = p_policy or p.id::text = p_policy) order by p.created_at desc limit 1;
  if not found then
    perform verification.chain_fail('ATTENTION_POLICY_NOT_FOUND', 'P0002', format('no attention policy %s in this tenant', coalesce(p_policy, '(null)')));
  end if;
  if pol.state <> 'active' or pol.watch_level = 'W0' or exists (select 1 from acquisition.attention_policy q where q.supersedes_id = pol.id) then
    perform verification.chain_fail('ATTENTION_POLICY_NOT_SWEEPABLE', '23514', format('policy %s is %s at watch level %s: only an active, current policy above W0 is swept', pol.slug, pol.state, pol.watch_level));
  end if;
  if p_trigger_kind is null or p_trigger_kind not in ('schedule', 'event', 'manual', 'backfill') or jsonb_typeof(v_ref) <> 'object' or p_window_from > p_window_to then
    perform verification.chain_fail('SWEEP_INVALID', '22023', 'trigger_kind is schedule, event, manual or backfill; trigger_ref is an object; the window does not end before it starts');
  end if;
  if v_mc is not null and v_mission is null then
    perform verification.chain_fail('MISSION_REQUIRED', '22023', 'a sweep made by a Mission Control invocation names the AI Engineer mission whose budget bounds it (p_actor.mission_id)');
  end if;
  if v_mc is not null then
    v_ref := v_ref || jsonb_build_object('mc_run_id', v_mc ->> 'run_id', 'mc_operation_id', v_mc ->> 'operation_id', 'mc_mission_id', v_mc ->> 'mission_id');
  end if;
  -- the budget gate of the watch: what the mission's sweeps already spent, against the mission's budget, before any work
  if v_mission is not null then
    select coalesce(sum(s.spend_usd), 0) into v_spent from acquisition.attention_sweep s where s.tenant_id = v_tenant and s.mission_id = v_mission;
    v_stop := v_budget is not null and v_spent >= v_budget;
  end if;

  v_sweep := util.uuidv7();
  v_result := verification.chain_record('api.raise_attention_sweep', ctx, v_request,
    jsonb_strip_nulls(jsonb_build_object('sweep_id', v_sweep, 'policy_id', pol.id, 'policy', pol.slug, 'origin_kind', case when v_mission is null then 'standalone' else 'mission' end,
      'budget_stopped', v_stop, 'open', not v_stop, 'mission_spent_usd', case when v_mission is not null then v_spent end, 'mission_budget_usd', v_budget,
      'budget_usd_per_run', pol.budget_usd_per_run, 'budget_credits_per_run', pol.budget_credits_per_run)),
    jsonb_build_array(jsonb_build_object('schema', 'acquisition', 'table', 'attention_sweep', 'id', v_sweep)));
  v_receipt := (v_result ->> 'receipt_id')::uuid;
  insert into acquisition.attention_sweep(id, tenant_id, policy_id, trigger_kind, trigger_ref, mission_id, origin_kind, window_from, window_to, note, receipt_id,
                                          ended_at, rejected, outcome)
  values (v_sweep, v_tenant, pol.id, p_trigger_kind, v_ref || case when v_stop then jsonb_build_object('budget_usd', v_budget, 'spent_usd', v_spent) else '{}'::jsonb end,
          v_mission, case when v_mission is null then 'standalone' else 'mission' end, p_window_from, p_window_to,
          case when v_stop then format('budget stop: spent %s of %s USD across this mission''s runs', v_spent, v_budget) else p_note end, v_receipt,
          case when v_stop then clock_timestamp() end,
          case when v_stop then jsonb_build_object('budget', format('spent %s >= budget %s', v_spent, v_budget)) else '{}'::jsonb end,
          case when v_stop then 'budget_stopped' end);
  perform verification.chain_target(ctx, v_receipt, 'acquisition', 'attention_sweep', v_sweep, 'subject', 'created');
  return v_result;
end $fn$;
comment on function api.raise_attention_sweep(text, text, text, jsonb, text, timestamptz, timestamptz, jsonb) is
  'Governed write: open one execution (a sweep) of an active attention policy above W0, by slug or id. Under a mission the budget gate runs first: when the mission''s sweeps already spent its budget, the sweep is written settled as budget_stopped and the result says budget_stopped true: do no work. Policies themselves (what to watch, how often, on what budget) are decided by a person and are not written here. Idempotent on p_idempotency_key. Returns {sweep_id, policy_id, policy, origin_kind, open, budget_stopped, mission_spent_usd, mission_budget_usd, budget_usd_per_run, budget_credits_per_run, receipt_id, intent_id, replayed}. Errors: the common ones, ATTENTION_POLICY_NOT_FOUND, ATTENTION_POLICY_NOT_SWEEPABLE, SWEEP_INVALID, MISSION_REQUIRED.';

-- ... and settle it once, with what it saw, selected, captured and spent
create or replace function api.settle_attention_sweep(
  p_idempotency_key text, p_sweep_id uuid, p_outcome text, p_items_seen integer, p_items_selected integer, p_items_captured integer,
  p_rejected jsonb default '{}'::jsonb, p_spend_usd numeric default 0, p_credits integer default 0, p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $fn$
declare
  ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid; v_mission uuid;
  v_rejected jsonb := coalesce(p_rejected, '{}'::jsonb); v_spend numeric := trim_scale(coalesce(p_spend_usd, 0)); v_credits integer := coalesce(p_credits, 0);
  sw acquisition.attention_sweep; pol acquisition.attention_policy; v_spent numeric; v_budget numeric;
begin
  v_request := jsonb_build_object('sweep_id', p_sweep_id, 'outcome', p_outcome, 'items_seen', p_items_seen, 'items_selected', p_items_selected, 'items_captured', p_items_captured,
                                  'rejected', v_rejected, 'spend_usd', v_spend, 'credits', v_credits);
  ctx := verification.chain_begin('api.settle_attention_sweep', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid; v_mission := (ctx ->> 'mission_id')::uuid; v_budget := (ctx ->> 'mission_budget_usd')::numeric;

  select * into sw from acquisition.attention_sweep s where s.id = p_sweep_id and s.tenant_id = v_tenant for update;
  if not found then
    perform verification.chain_fail('SWEEP_NOT_FOUND', 'P0002', format('no attention sweep %s in this tenant', coalesce(p_sweep_id::text, '(null)')));
  end if;
  if sw.ended_at is not null then
    perform verification.chain_fail('SWEEP_ALREADY_SETTLED', '23514', format('sweep %s was settled at %s (%s); a sweep is settled once', sw.id, sw.ended_at, sw.outcome));
  end if;
  if sw.mission_id is distinct from v_mission then
    perform verification.chain_fail('SWEEP_MISSION_MISMATCH', '23514', 'a sweep is settled under the mission that opened it, or under none when none did');
  end if;
  if p_outcome is null or p_outcome not in ('completed', 'partial', 'failed', 'budget_stopped') or jsonb_typeof(v_rejected) <> 'object' then
    perform verification.chain_fail('SWEEP_INVALID', '22023', 'outcome is completed, partial, failed or budget_stopped; rejected is an object of reasons');
  end if;
  if p_items_seen is null or p_items_selected is null or p_items_captured is null or p_items_seen < 0 or p_items_selected < 0 or p_items_captured < 0
     or p_items_selected > p_items_seen or p_items_captured > p_items_selected or v_spend < 0 or v_credits < 0 then
    perform verification.chain_fail('SWEEP_COUNTS_INVALID', '22023', 'captured <= selected <= seen, none negative; spend and credits are not negative');
  end if;
  select * into pol from acquisition.attention_policy p where p.id = sw.policy_id;
  if v_mission is not null then
    select coalesce(sum(s.spend_usd), 0) + v_spend into v_spent from acquisition.attention_sweep s where s.tenant_id = v_tenant and s.mission_id = v_mission and s.id <> sw.id;
  end if;

  v_result := verification.chain_record('api.settle_attention_sweep', ctx, v_request,
    jsonb_strip_nulls(jsonb_build_object('sweep_id', sw.id, 'policy', pol.slug, 'outcome', p_outcome, 'settled', true,
      'over_budget_usd', v_spend > pol.budget_usd_per_run, 'over_budget_credits', v_credits > pol.budget_credits_per_run,
      'mission_spent_usd', v_spent, 'mission_budget_usd', v_budget, 'mission_budget_exhausted', case when v_mission is not null and v_budget is not null then v_spent >= v_budget end)),
    jsonb_build_array(jsonb_build_object('schema', 'acquisition', 'table', 'attention_sweep', 'id', sw.id)));
  v_receipt := (v_result ->> 'receipt_id')::uuid;
  update acquisition.attention_sweep
     set ended_at = clock_timestamp(), items_seen = p_items_seen, items_selected = p_items_selected, items_captured = p_items_captured,
         rejected = v_rejected, spend_usd = v_spend, credits = v_credits, outcome = p_outcome
   where id = sw.id and ended_at is null;
  perform verification.chain_target(ctx, v_receipt, 'acquisition', 'attention_sweep', sw.id, 'subject', 'updated');
  return v_result;
end $fn$;
comment on function api.settle_attention_sweep(text, uuid, text, integer, integer, integer, jsonb, numeric, integer, jsonb) is
  'Governed write: settle an open sweep once, with what it saw, selected and captured, the rejections by reason, and what it spent. Spend is recorded as reported; the result says whether it exceeds the policy''s per-run budget and whether the mission''s budget is now exhausted. Idempotent on p_idempotency_key. Returns {sweep_id, policy, outcome, settled, over_budget_usd, over_budget_credits, mission_spent_usd, mission_budget_usd, mission_budget_exhausted, receipt_id, intent_id, replayed}. Errors: the common ones, SWEEP_NOT_FOUND, SWEEP_ALREADY_SETTLED, SWEEP_MISSION_MISMATCH, SWEEP_INVALID, SWEEP_COUNTS_INVALID.';

-- ------------------------------------------------------------------ 5. grants: each function to the bounded roles that hold the table write today
-- PostgreSQL grants EXECUTE on a new function to PUBLIC; the api surface is closed by default (20261116120000), and the
-- helpers must not be callable by a role that holds USAGE on schema verification.
revoke all on function verification.chain_fail(text, text, text), verification.chain_sha(text), verification.chain_norm(text), verification.chain_uuid(text, text),
  verification.chain_begin(text, text, jsonb, jsonb), verification.chain_record(text, jsonb, jsonb, jsonb, jsonb),
  verification.chain_target(jsonb, uuid, text, text, uuid, text, text, uuid), verification.chain_anchor(uuid, jsonb, text), verification.guard_human_judgment()
  from public, anon, authenticated, service_role;
revoke all on function
  api.record_claim(text, text, text, jsonb, jsonb, jsonb, jsonb, jsonb),
  api.restate_claim(text, uuid, text, boolean, text, jsonb, jsonb),
  api.register_probe(text, text, text, text, text, jsonb, uuid[], jsonb, jsonb, jsonb, text, numeric, jsonb),
  api.record_probe_run(text, uuid, text, text, timestamptz, jsonb, jsonb, jsonb, jsonb, jsonb, uuid, jsonb),
  api.propose_verdict(text, uuid, uuid, text, jsonb, text, jsonb),
  api.record_triage(text, uuid, text, text, text, numeric, jsonb, uuid, uuid, jsonb),
  api.record_source_assessment(text, uuid, text, uuid, text, text, text, text, jsonb),
  api.raise_attention_sweep(text, text, text, jsonb, text, timestamptz, timestamptz, jsonb),
  api.settle_attention_sweep(text, uuid, text, integer, integer, integer, jsonb, numeric, integer, jsonb)
  from public, anon, authenticated, service_role;
-- claims are written by the roles that hold INSERT on evidence.claim: the proposing agent and the ingestion executor
grant execute on function api.record_claim(text, text, text, jsonb, jsonb, jsonb, jsonb, jsonb), api.restate_claim(text, uuid, text, boolean, text, jsonb, jsonb)
  to pipeline_agent, executor_service;
-- probes, runs, verdicts, triage and assessments by the roles that hold INSERT on those tables
grant execute on function
  api.register_probe(text, text, text, text, text, jsonb, uuid[], jsonb, jsonb, jsonb, text, numeric, jsonb),
  api.record_probe_run(text, uuid, text, text, timestamptz, jsonb, jsonb, jsonb, jsonb, jsonb, uuid, jsonb),
  api.propose_verdict(text, uuid, uuid, text, jsonb, text, jsonb),
  api.record_triage(text, uuid, text, text, text, numeric, jsonb, uuid, uuid, jsonb),
  api.record_source_assessment(text, uuid, text, uuid, text, text, text, text, jsonb)
  to pipeline_agent, verifier_agent, control_plane;
-- sweeps by the roles that hold INSERT and UPDATE on acquisition.attention_sweep
grant execute on function
  api.raise_attention_sweep(text, text, text, jsonb, text, timestamptz, timestamptz, jsonb),
  api.settle_attention_sweep(text, uuid, text, integer, integer, integer, jsonb, numeric, integer, jsonb)
  to pipeline_agent, control_plane;

-- ------------------------------------------------------------------ 6. the product owner's row policies
-- product_api_owner (the owner of the product functions; no BYPASSRLS, named by no policy) held SELECT on 18 row-secured
-- tables it could read no row of. Its functions read two of them:
--   - evidence.claim: product.insert_revision checks a cited shared claim (a statement citing one was refused NOT_FOUND
--     while a claim binding, checked only by its foreign key, passed); product.support_detail shows a claim support;
--   - evidence.source_capture: product.restricted resolves a capture to its source to find a source-level restriction
--     (with no row visible, a restriction placed on the source did not reach its captures).
-- Those two get a SELECT policy scoped to the product's tenant. The other 16 are read by no product function, trigger or
-- policy (the retrieval writes go through retrieval.index_text_item, a definer function); the unused grant is revoked.
drop policy if exists product_api_owner_read on evidence.claim;
create policy product_api_owner_read on evidence.claim for select to product_api_owner using (tenant_id = product.tenant());
drop policy if exists product_api_owner_read on evidence.source_capture;
create policy product_api_owner_read on evidence.source_capture for select to product_api_owner using (tenant_id = product.tenant());
revoke select on evidence.locator, catalog.entity, guidance.item, acquisition.fetch,
  ranking.leaderboard, ranking.leaderboard_edition,
  retrieval.projection_procedure, retrieval.vector_space, retrieval.vector_space_version,
  content.document_kind_assignment, content.structure_census, content.refresh_check, content.unit_change, content.unit_entity_role, content.document_digest, content.digest_item
  from product_api_owner;

commit;
