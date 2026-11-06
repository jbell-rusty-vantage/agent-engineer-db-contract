-- 20261024010100_research_report_v2_projection
-- Sprint V (SV-08, plan section 3 rows A3/A4; design sections 7 and 9): the AI Engineer domain side of research-report.v2.
--
-- Authority split (one owner per object):
--   * knowledge_verification.* (component @aiengineer/knowledge-db-contract, installed FIRST by its own installer) owns
--     the operational verification truth: report revisions, custody, runs and seals, assertions, use decisions,
--     admission (admit_exact_use), revocation epochs, effect receipts and the dispatch outbox. Nothing here copies or
--     alters that DDL, and no foreign key crosses into that schema: references are validated by functions/triggers
--     that read the component under the caller's tenant (forced RLS), so the component stays the single owner.
--   * research.* / orchestration.* (this repository) own the AI Engineer domain projection: which sealed revision an
--     AI Engineer report identity points at, its assertion projection, the ingestion link keyed by use decision, the
--     native-transaction admission record and the receipt binding columns.
--
-- Native use guards: research.assert_admitted_use(...) runs INSIDE the ingestion transaction (the KS executor's
-- applyOnce client, role executor_service). It calls knowledge_verification.admit_exact_use under the component's
-- epoch lock and records research.use_admission for the CURRENT transaction id; deferred constraint triggers refuse
-- to commit a receipt (or a canonical knowledge/corpus/evidence row created by it) that declares a use decision
-- without an admission recorded in the same transaction.
--
-- Typed errors (message = K01 ProtocolErrorCode; custom SQLSTATE class KS so callers never confuse them with the
-- generic 23xxx / P0001 classes the ingestion executor already maps):
--   KSA01 STALE_DECISION, KSA02 REVIEW_REQUIRED, KSA03 EFFECT_CONFLICT, KSA04 UNRESOLVED_EFFECT,
--   KSA05 EXACT_REVISION_UNAVAILABLE, KSA06 ADMISSION_REQUIRED (native refusal; K01 mapping UNRESOLVED_EFFECT),
--   KSA07 REPORT_PROJECTION_MISMATCH (a projection row disagrees with the component record).
begin;
set local lock_timeout = '15s';

do $$
begin
  if to_regclass('knowledge_service.verification_component_binding') is null then
    raise exception 'KNOWLEDGE_COMPONENT_BINDING_REQUIRED'
      using hint = 'apply 20261024010000_knowledge_component_binding.sql (after knowledge-db install) first';
  end if;
end $$;

-- ---------------------------------------------------------------------------------------------------------------
-- 1. Receipt binding: a native receipt that applies an admitted use names the exact decision and bound effect digest.
--    Naming a decision IS the declaration that the receipt's writes require admission (both set together).
-- ---------------------------------------------------------------------------------------------------------------
alter table orchestration.operation_receipt
  add column requires_admission boolean not null default false,
  add column use_decision_id text,
  add column bound_effect_digest text,
  add constraint operation_receipt_admission_pair check ((use_decision_id is null) = (bound_effect_digest is null)),
  add constraint operation_receipt_admission_declared check (requires_admission = (use_decision_id is not null)),
  add constraint operation_receipt_bound_effect_digest check (bound_effect_digest is null or bound_effect_digest ~ '^sha256:[0-9a-f]{64}$');
comment on column orchestration.operation_receipt.requires_admission is
  'True exactly when the receipt names a use decision: its commit (and every canonical row it creates) requires research.use_admission in the same transaction.';
comment on column orchestration.operation_receipt.use_decision_id is
  'knowledge_verification.use_decision.use_decision_id admitted for this receipt (validated by function, no cross-schema FK).';
comment on column orchestration.operation_receipt.bound_effect_digest is
  'The exact K01 bound effect digest the decision admitted; set together with use_decision_id.';
create index operation_receipt_use_decision_idx on orchestration.operation_receipt (use_decision_id) where use_decision_id is not null;

-- ---------------------------------------------------------------------------------------------------------------
-- 2. Native-transaction admission record. A row exists only if admit_exact_use admitted the exact decision/effect
--    digest in the inserting transaction (the BEFORE INSERT trigger performs the check; direct inserts cannot fake it).
-- ---------------------------------------------------------------------------------------------------------------
create table research.use_admission (
  tenant_id uuid not null default util.current_tenant_id(),
  use_decision_id text not null check (btrim(use_decision_id) <> ''),
  bound_effect_digest text not null check (bound_effect_digest ~ '^sha256:[0-9a-f]{64}$'),
  xact_id bigint not null,
  processed_epoch bigint not null check (processed_epoch >= 0),
  authoritative_epoch bigint not null check (authoritative_epoch >= 0),
  effect_key text not null,
  admitted_at timestamptz not null default now(),
  -- One row per (decision, effect digest, transaction, authoritative epoch): a re-check after an epoch advance inside
  -- the same transaction records the newer authoritative epoch instead of collapsing into the earlier row.
  primary key (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch),
  check (processed_epoch >= authoritative_epoch)
);
comment on table research.use_admission is
  'AI Engineer native admission record: knowledge_verification.admit_exact_use admitted (decision, bound effect digest) inside transaction xact_id. Written only through research.assert_admitted_use; append-only.';

-- Shared checker: one call to the component authority, outcome mapped to typed errors. SECURITY INVOKER on purpose:
-- the caller must itself hold knowledge_verification_writer (executor_service does through the binding).
create function research.require_admitted_use(
  p_tenant uuid, p_use_decision_id text, p_bound_effect_digest text, p_processed_epoch bigint
) returns table (authoritative_epoch bigint, effect_key text)
language plpgsql volatile set search_path = '' as $$
declare r record; v_effect_key text;
begin
  if p_tenant is null or coalesce(btrim(p_use_decision_id), '') = '' or p_bound_effect_digest is null or p_processed_epoch is null then
    raise exception 'UNRESOLVED_EFFECT' using errcode = 'KSA04',
      detail = 'tenant, use decision id, bound effect digest and processed epoch are all required';
  end if;
  perform knowledge_verification.assert_tenant(p_tenant);
  select a.outcome, a.reason, a.authoritative_epoch into r
    from knowledge_verification.admit_exact_use(p_tenant, p_use_decision_id, p_bound_effect_digest, p_processed_epoch) a;
  if r.outcome is distinct from 'admitted' then
    if r.reason in ('STALE_DECISION', 'REVOCATION_EPOCH_STALE', 'INVALIDATION_CLOSURE_INCOMPLETE', 'DECISION_EXPIRED', 'DECISION_INVALIDATED') then
      raise exception 'STALE_DECISION' using errcode = 'KSA01',
        detail = format('admit_exact_use %s/%s; authoritative epoch %s, processed %s', r.outcome, r.reason, r.authoritative_epoch, p_processed_epoch);
    elsif r.reason = 'EFFECT_DIGEST_MISMATCH' then
      raise exception 'EFFECT_CONFLICT' using errcode = 'KSA03',
        detail = 'the decision admits a different bound effect digest than the one presented';
    elsif r.reason = 'DECISION_NOT_FOUND' then
      raise exception 'UNRESOLVED_EFFECT' using errcode = 'KSA04',
        detail = format('no use decision %s in this tenant', p_use_decision_id);
    else
      raise exception 'REVIEW_REQUIRED' using errcode = 'KSA02',
        detail = format('admit_exact_use %s/%s', coalesce(r.outcome, '<none>'), coalesce(r.reason, '<none>'));
    end if;
  end if;
  -- Admitted digest must name a bound effect (bind_effect ran for this exact digest in this tenant).
  select e.effect_key into v_effect_key from knowledge_verification.effect e
   where e.tenant_id = p_tenant and e.bound_effect_digest = p_bound_effect_digest
   order by e.created_at, e.effect_key limit 1;
  if v_effect_key is null then
    raise exception 'UNRESOLVED_EFFECT' using errcode = 'KSA04',
      detail = 'the admitted bound effect digest has no knowledge_verification.effect row; bind_effect first';
  end if;
  return query select r.authoritative_epoch, v_effect_key;
end $$;
comment on function research.require_admitted_use(uuid, text, text, bigint) is
  'Internal checker shared by assert_admitted_use and the use_admission insert trigger: knowledge_verification.admit_exact_use outcome -> typed errors KSA01..KSA04.';

create function research.guard_use_admission() returns trigger
language plpgsql set search_path = '' as $$
declare c record;
begin
  if new.tenant_id is distinct from util.current_tenant_id() then
    raise exception 'TENANT_MISMATCH' using errcode = 'insufficient_privilege';
  end if;
  select * into c from research.require_admitted_use(new.tenant_id, new.use_decision_id, new.bound_effect_digest, new.processed_epoch);
  new.xact_id := pg_current_xact_id()::text::bigint;
  new.authoritative_epoch := c.authoritative_epoch;
  new.effect_key := c.effect_key;
  new.admitted_at := now();
  return new;
end $$;
create trigger use_admission_guard before insert on research.use_admission
  for each row execute function research.guard_use_admission();
create trigger use_admission_immutable before update or delete on research.use_admission
  for each row execute function util.reject_mutation();

-- The guard executable inside the ingestion transaction.
create function research.assert_admitted_use(
  p_tenant uuid, p_use_decision_id text, p_bound_effect_digest text, p_processed_epoch bigint
) returns research.use_admission
language plpgsql volatile set search_path = '' as $$
declare row_ research.use_admission;
begin
  insert into research.use_admission (tenant_id, use_decision_id, bound_effect_digest, xact_id, processed_epoch, authoritative_epoch, effect_key)
  values (p_tenant, p_use_decision_id, p_bound_effect_digest, 0, p_processed_epoch, 0, '')
  on conflict (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch) do nothing
  returning * into row_;
  if row_ is null then
    -- Repeated in the same transaction at the same authoritative epoch: the trigger re-checked the authority before the
    -- conflict was detected; return the row already recorded for that epoch.
    select * into row_ from research.use_admission a
     where a.tenant_id = p_tenant and a.use_decision_id = p_use_decision_id and a.bound_effect_digest = p_bound_effect_digest
       and a.xact_id = pg_current_xact_id()::text::bigint
     order by a.authoritative_epoch desc limit 1;
  end if;
  return row_;
end $$;
comment on function research.assert_admitted_use(uuid, text, text, bigint) is
  'Native exact-use guard (design section 7): call inside the ingestion transaction before canonical writes. Calls knowledge_verification.admit_exact_use under its epoch lock (held to commit) and records research.use_admission for this transaction; raises STALE_DECISION (KSA01), REVIEW_REQUIRED (KSA02), EFFECT_CONFLICT (KSA03) or UNRESOLVED_EFFECT (KSA04).';

-- Deferred commit checks: a receipt naming a decision, and every canonical row created by such a receipt, commit only
-- with an admission recorded in the SAME transaction (a receipt from another transaction cannot be reused).
create function research.require_receipt_admission() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_receipt uuid; v_tenant uuid; rc record;
begin
  if tg_table_schema = 'orchestration' and tg_table_name = 'operation_receipt' then
    v_receipt := new.id;
    select i.tenant_id into v_tenant from orchestration.operation_intent i where i.id = new.intent_id;
  else
    v_receipt := new.created_by_receipt_id;
    v_tenant := new.tenant_id;
  end if;
  if v_receipt is null then
    return null;
  end if;
  select r.requires_admission, r.use_decision_id, r.bound_effect_digest into rc
    from orchestration.operation_receipt r where r.id = v_receipt;
  if not found or not rc.requires_admission then
    return null;
  end if;
  if not exists (
    select 1 from research.use_admission a
     where a.tenant_id = v_tenant and a.use_decision_id = rc.use_decision_id
       and a.bound_effect_digest = rc.bound_effect_digest and a.xact_id = pg_current_xact_id()::text::bigint
  ) then
    raise exception 'ADMISSION_REQUIRED' using errcode = 'KSA06',
      detail = format('%s.%s row bound to receipt %s (use decision %s) has no research.use_admission in this transaction',
                      tg_table_schema, tg_table_name, v_receipt, rc.use_decision_id),
      hint = 'call research.assert_admitted_use(...) inside the ingestion transaction before commit';
  end if;
  return null;
end $$;
comment on function research.require_receipt_admission() is
  'Deferred commit guard on orchestration.operation_receipt, corpus.entity, knowledge.record and evidence.claim: writes under a receipt that declares requires_admission need an admission in the same transaction (KSA06 ADMISSION_REQUIRED).';

create constraint trigger receipt_requires_admission after insert on orchestration.operation_receipt
  deferrable initially deferred for each row execute function research.require_receipt_admission();
create constraint trigger entity_requires_admission after insert or update of created_by_receipt_id on corpus.entity
  deferrable initially deferred for each row execute function research.require_receipt_admission();
create constraint trigger record_requires_admission after insert or update of created_by_receipt_id on knowledge.record
  deferrable initially deferred for each row execute function research.require_receipt_admission();
create constraint trigger claim_requires_admission after insert or update of created_by_receipt_id on evidence.claim
  deferrable initially deferred for each row execute function research.require_receipt_admission();

-- ---------------------------------------------------------------------------------------------------------------
-- 3. Report revision projection: which sealed component revision an AI Engineer report identity points at.
-- ---------------------------------------------------------------------------------------------------------------
create table research.report_v2_revision (
  tenant_id uuid not null default util.current_tenant_id(),
  report_id text not null check (btrim(report_id) <> ''),
  revision integer not null check (revision >= 1),
  report_revision_id text not null,
  report_revision_digest text not null check (report_revision_digest ~ '^sha256:[0-9a-f]{64}$'),
  run_id uuid not null,
  verification_snapshot_digest text not null check (verification_snapshot_digest ~ '^sha256:[0-9a-f]{64}$'),
  report_kind text not null,
  body_digest text not null check (body_digest ~ '^sha256:[0-9a-f]{64}$'),
  domain_report_id uuid,
  projected_at timestamptz not null default now(),
  primary key (tenant_id, report_id, revision),
  unique (tenant_id, report_revision_id),
  foreign key (tenant_id, domain_report_id) references research.report (tenant_id, id) on delete restrict
);
comment on table research.report_v2_revision is
  'AI Engineer projection of one sealed knowledge_verification.report_revision (research-report.v2), keyed (tenant_id, report_id, revision) and bound to its run (tenant_id, run_id) and verification snapshot. Validated against the component by trigger; the component remains the owner of the revision, custody and seal.';

create function research.guard_report_v2_revision() returns trigger
language plpgsql set search_path = '' as $$
declare rr record; run_state text;
begin
  if new.tenant_id is distinct from util.current_tenant_id() then
    raise exception 'TENANT_MISMATCH' using errcode = 'insufficient_privilege';
  end if;
  select r.report_revision_id, r.digest, r.run_id, r.report_kind, r.body_digest into rr
    from knowledge_verification.report_revision r
   where r.tenant_id = new.tenant_id and r.report_id = new.report_id and r.revision = new.revision;
  if not found then
    raise exception 'EXACT_REVISION_UNAVAILABLE' using errcode = 'KSA05',
      detail = format('no knowledge_verification.report_revision %s revision %s in this tenant', new.report_id, new.revision);
  end if;
  if rr.report_revision_id <> new.report_revision_id or rr.digest <> new.report_revision_digest or rr.run_id <> new.run_id
     or rr.report_kind <> new.report_kind or rr.body_digest <> new.body_digest then
    raise exception 'REPORT_PROJECTION_MISMATCH' using errcode = 'KSA07',
      detail = 'report_v2_revision must restate the component revision id, digest, run, kind and body digest exactly';
  end if;
  select v.state into run_state from knowledge_verification.verification_run v where v.tenant_id = new.tenant_id and v.run_id = new.run_id;
  if run_state is distinct from 'sealed' then
    raise exception 'EXACT_REVISION_UNAVAILABLE' using errcode = 'KSA05',
      detail = format('run %s is %s, not sealed', new.run_id, coalesce(run_state, '<missing>'));
  end if;
  if not exists (
    select 1 from knowledge_verification.run_manifest m
     where m.tenant_id = new.tenant_id and m.run_id = new.run_id and m.manifest_kind = 'verification_snapshot'
       and m.manifest_digest = new.verification_snapshot_digest
  ) then
    raise exception 'REPORT_PROJECTION_MISMATCH' using errcode = 'KSA07',
      detail = 'verification_snapshot_digest must name the run''s sealed verification_snapshot manifest';
  end if;
  return new;
end $$;
create trigger report_v2_revision_guard before insert on research.report_v2_revision
  for each row execute function research.guard_report_v2_revision();
create trigger report_v2_revision_immutable before update or delete on research.report_v2_revision
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------------------------------------------
-- 4. Assertion projection, keyed by assertion ref digest within the exact revision.
-- ---------------------------------------------------------------------------------------------------------------
create table research.report_v2_assertion (
  tenant_id uuid not null default util.current_tenant_id(),
  report_id text not null,
  revision integer not null,
  assertion_ref_digest text not null check (assertion_ref_digest ~ '^sha256:[0-9a-f]{64}$'),
  assertion_id text not null,
  assertion_kind text not null,
  projected_at timestamptz not null default now(),
  primary key (tenant_id, report_id, revision, assertion_ref_digest),
  unique (tenant_id, report_id, revision, assertion_id),
  foreign key (tenant_id, report_id, revision) references research.report_v2_revision (tenant_id, report_id, revision) on delete restrict
);
comment on table research.report_v2_assertion is
  'Assertions cited by a projected v2 revision, keyed by the assertion Ref digest listed in the component revision''s assertion_refs; the component assertion record is the owner.';

create function research.guard_report_v2_assertion() returns trigger
language plpgsql set search_path = '' as $$
declare a record;
begin
  if new.tenant_id is distinct from util.current_tenant_id() then
    raise exception 'TENANT_MISMATCH' using errcode = 'insufficient_privilege';
  end if;
  select x.assertion_id, x.kind into a from knowledge_verification.assertion x
   where x.tenant_id = new.tenant_id and x.digest = new.assertion_ref_digest;
  if not found or a.assertion_id <> new.assertion_id or a.kind <> new.assertion_kind then
    raise exception 'REPORT_PROJECTION_MISMATCH' using errcode = 'KSA07',
      detail = 'assertion_ref_digest must name a component assertion with the same id and kind';
  end if;
  if not exists (
    select 1 from knowledge_verification.report_revision r, jsonb_array_elements(r.assertion_refs) ref
     where r.tenant_id = new.tenant_id and r.report_id = new.report_id and r.revision = new.revision
       and ref ->> 'digest' = new.assertion_ref_digest and ref ->> 'id' = new.assertion_id
  ) then
    raise exception 'REPORT_PROJECTION_MISMATCH' using errcode = 'KSA07',
      detail = 'the assertion is not cited by this exact revision''s assertion_refs';
  end if;
  return new;
end $$;
create trigger report_v2_assertion_guard before insert on research.report_v2_assertion
  for each row execute function research.guard_report_v2_assertion();
create trigger report_v2_assertion_immutable before update or delete on research.report_v2_assertion
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------------------------------------------
-- 5. Ingestion projection keyed by use decision: which native receipt applied the admitted exact use.
-- ---------------------------------------------------------------------------------------------------------------
create table research.report_v2_ingestion (
  tenant_id uuid not null default util.current_tenant_id(),
  use_decision_id text not null,
  bound_effect_digest text not null check (bound_effect_digest ~ '^sha256:[0-9a-f]{64}$'),
  report_id text not null,
  revision integer not null,
  assertion_ref_digest text,
  intent_id uuid not null references orchestration.operation_intent (id),
  receipt_id uuid not null references orchestration.operation_receipt (id),
  outcome text not null check (outcome in ('applied', 'rejected', 'noop', 'partial')),
  recorded_at timestamptz not null default now(),
  primary key (tenant_id, use_decision_id),
  unique (receipt_id),
  foreign key (tenant_id, report_id, revision) references research.report_v2_revision (tenant_id, report_id, revision) on delete restrict,
  foreign key (tenant_id, report_id, revision, assertion_ref_digest)
    references research.report_v2_assertion (tenant_id, report_id, revision, assertion_ref_digest) on delete restrict
);
comment on table research.report_v2_ingestion is
  'Ingestion result of one admitted exact use (keyed by component use_decision_id): the decision''s subject (report revision or assertion) and the native operation receipt that names the same decision and bound effect digest.';

create function research.guard_report_v2_ingestion() returns trigger
language plpgsql set search_path = '' as $$
declare d record; rr record; rc record;
begin
  if new.tenant_id is distinct from util.current_tenant_id() then
    raise exception 'TENANT_MISMATCH' using errcode = 'insufficient_privilege';
  end if;
  select r.intent_id, r.outcome, r.use_decision_id, r.bound_effect_digest, i.tenant_id into rc
    from orchestration.operation_receipt r join orchestration.operation_intent i on i.id = r.intent_id where r.id = new.receipt_id;
  if not found or rc.intent_id <> new.intent_id or rc.tenant_id <> new.tenant_id or rc.outcome <> new.outcome
     or rc.use_decision_id is distinct from new.use_decision_id or rc.bound_effect_digest is distinct from new.bound_effect_digest then
    raise exception 'REPORT_PROJECTION_MISMATCH' using errcode = 'KSA07',
      detail = 'the receipt must belong to this intent/tenant and name the same use decision, bound effect digest and outcome';
  end if;
  select u.subject_kind, u.subject_id, u.subject_digest, u.bound_effect_digest, u.disposition into d
    from knowledge_verification.use_decision u where u.tenant_id = new.tenant_id and u.use_decision_id = new.use_decision_id;
  if not found then
    raise exception 'UNRESOLVED_EFFECT' using errcode = 'KSA04', detail = 'no such component use decision';
  end if;
  if d.disposition <> 'admitted' or d.bound_effect_digest <> new.bound_effect_digest then
    raise exception 'REPORT_PROJECTION_MISMATCH' using errcode = 'KSA07',
      detail = 'only an admitted decision for the same bound effect digest can be projected as ingested';
  end if;
  select r.report_revision_id, r.digest into rr from knowledge_verification.report_revision r
   where r.tenant_id = new.tenant_id and r.report_id = new.report_id and r.revision = new.revision;
  if d.subject_kind = 'report' then
    if new.assertion_ref_digest is not null or d.subject_id <> rr.report_revision_id or d.subject_digest <> rr.digest then
      raise exception 'REPORT_PROJECTION_MISMATCH' using errcode = 'KSA07',
        detail = 'a report-subject decision must name this exact revision and carry no assertion';
    end if;
  elsif new.assertion_ref_digest is null or d.subject_digest <> new.assertion_ref_digest then
    raise exception 'REPORT_PROJECTION_MISMATCH' using errcode = 'KSA07',
      detail = 'an assertion-subject decision must name the projected assertion digest';
  end if;
  return new;
end $$;
create trigger report_v2_ingestion_guard before insert on research.report_v2_ingestion
  for each row execute function research.guard_report_v2_ingestion();
create trigger report_v2_ingestion_immutable before update or delete on research.report_v2_ingestion
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------------------------------------------
-- 6. Exact package read: the exact revision only (never "latest"), sealed run only.
-- ---------------------------------------------------------------------------------------------------------------
create function research.read_report_package(p_tenant uuid, p_report_id text, p_revision integer)
returns table (
  report_id text, revision integer, report_revision_id text, report_revision_digest text, schema_version text,
  report_kind text, task_id text, run_id uuid, run_head_digest text, renderer_version text,
  structured_body jsonb, body jsonb, ledger jsonb, assertion_refs jsonb, manifest_index jsonb, domain_report_id uuid
)
language plpgsql stable security definer set search_path = '' as $$
declare rr knowledge_verification.report_revision; run_ knowledge_verification.verification_run;
begin
  perform knowledge_verification.assert_tenant(p_tenant);
  if p_report_id is null or p_revision is null then
    raise exception 'EXACT_REVISION_UNAVAILABLE' using errcode = 'KSA05', detail = 'an exact report id and revision are required';
  end if;
  select * into rr from knowledge_verification.report_revision r
   where r.tenant_id = p_tenant and r.report_id = p_report_id and r.revision = p_revision;
  if not found then
    raise exception 'EXACT_REVISION_UNAVAILABLE' using errcode = 'KSA05',
      detail = format('report %s revision %s is not registered in this tenant', p_report_id, p_revision);
  end if;
  select * into run_ from knowledge_verification.verification_run v where v.tenant_id = p_tenant and v.run_id = rr.run_id;
  if run_.state is distinct from 'sealed' then
    raise exception 'EXACT_REVISION_UNAVAILABLE' using errcode = 'KSA05',
      detail = format('report %s revision %s belongs to run %s in state %s, not sealed', p_report_id, p_revision, rr.run_id, coalesce(run_.state, '<missing>'));
  end if;
  return query
  select rr.report_id, rr.revision, rr.report_revision_id, rr.digest, rr.schema_version, rr.report_kind, rr.task_id, rr.run_id,
         run_.head_digest, rr.renderer_version,
         (select jsonb_build_object('artifactId', a.artifact_id, 'digest', a.digest, 'byteLength', a.byte_length, 'mediaType', a.media_type,
                                    'custodyKind', a.custody_kind, 'custodyUri', a.custody_uri)
            from knowledge_verification.artifact_custody a where a.tenant_id = p_tenant and a.artifact_id = rr.structured_body_artifact_id),
         (select jsonb_build_object('artifactId', a.artifact_id, 'digest', a.digest, 'byteLength', a.byte_length, 'mediaType', a.media_type,
                                    'custodyKind', a.custody_kind, 'custodyUri', a.custody_uri)
            from knowledge_verification.artifact_custody a where a.tenant_id = p_tenant and a.artifact_id = rr.body_artifact_id),
         (select jsonb_build_object('artifactId', a.artifact_id, 'digest', a.digest, 'byteLength', a.byte_length, 'mediaType', a.media_type,
                                    'custodyKind', a.custody_kind, 'custodyUri', a.custody_uri)
            from knowledge_verification.artifact_custody a where a.tenant_id = p_tenant and a.artifact_id = rr.ledger_artifact_id),
         rr.assertion_refs,
         coalesce((select jsonb_agg(jsonb_build_object('sequence', m.sequence, 'manifestKind', m.manifest_kind, 'manifestDigest', m.manifest_digest,
                                                       'predecessorDigest', m.predecessor_digest, 'sealedAt', m.sealed_at) order by m.sequence)
                     from knowledge_verification.run_manifest m where m.tenant_id = p_tenant and m.run_id = rr.run_id), '[]'::jsonb),
         (select p.domain_report_id from research.report_v2_revision p
           where p.tenant_id = p_tenant and p.report_id = rr.report_id and p.revision = rr.revision);
end $$;
comment on function research.read_report_package(uuid, text, integer) is
  'Exact research-report.v2 package read: custody refs and digests of the structured body, exact body bytes and ledger, the revision''s assertion refs and its run manifest index, for the exact (report_id, revision) only and only once the run is sealed; otherwise EXACT_REVISION_UNAVAILABLE (KSA05). Bytes are fetched from custody by digest, never through this function. SECURITY DEFINER so app_reader (no util/table access by design) reads through it: p_tenant must equal app.tenant_id (knowledge_verification.assert_tenant) and every query filters by that tenant.';

-- ---------------------------------------------------------------------------------------------------------------
-- 7. Row-level security and grants (bounded roles only; PUBLIC, anon and authenticated get nothing).
-- ---------------------------------------------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['use_admission', 'report_v2_revision', 'report_v2_assertion', 'report_v2_ingestion'] loop
    execute format('alter table research.%I enable row level security', t);
    execute format('create policy bounded_role_access on research.%I for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader using (tenant_id = util.current_tenant_id()) with check (tenant_id = util.current_tenant_id())', t);
    execute format('revoke all on research.%I from public, anon, authenticated', t);
  end loop;
end $$;

-- app_reader has no util usage (api/functions only), so it reads through research.read_report_package, not the tables.
grant select on research.report_v2_revision, research.report_v2_assertion, research.report_v2_ingestion
  to executor_service, pipeline_agent, control_plane;
grant insert on research.report_v2_revision, research.report_v2_assertion, research.report_v2_ingestion to executor_service;
grant select on research.use_admission to executor_service, control_plane;
grant insert on research.use_admission to executor_service;

revoke all on function research.require_admitted_use(uuid, text, text, bigint),
  research.assert_admitted_use(uuid, text, text, bigint),
  research.read_report_package(uuid, text, integer),
  research.guard_use_admission(), research.require_receipt_admission(),
  research.guard_report_v2_revision(), research.guard_report_v2_assertion(), research.guard_report_v2_ingestion()
  from public, anon, authenticated;
grant execute on function research.assert_admitted_use(uuid, text, text, bigint),
  research.require_admitted_use(uuid, text, text, bigint) to executor_service;
grant execute on function research.read_report_package(uuid, text, integer)
  to executor_service, pipeline_agent, app_reader, control_plane;

commit;
