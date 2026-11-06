-- 20261031010000_operation_receipt_targets
-- Provenance sprint 2026-10-31 (OVE-204, slice 3): answer "what did Mission Control run X produce, and from which
-- origin?" with one SELECT over the native ledger.
--
--   1. orchestration.operation_intent carries the originating origin digest and the Mission Control coordinates
--      (mission, run, activation, operation, attempt, generation, lane) that knowledge_verification.origin records for
--      the same digest. The existing mission_id column is a uuid FK to orchestration.mission and is NOT the Mission
--      Control mission id, so the coordinates get their own mc_* columns. No foreign key crosses into
--      knowledge_verification (the component stays the owner of origin); the columns restate it.
--   2. orchestration.operation_receipt carries the same origin digest; orchestration.operation_receipt_target holds one
--      row per native row the receipt created, reused, superseded or staged, written by the KS executor in the apply
--      transaction (affected_refs stays the K01 effect-receipt payload, unchanged).
--   3. evidence.claim.producer_attempt_id becomes optional: a claim is produced by an orchestration attempt OR by an
--      authenticated origin (producer_origin_digest); at least one is required.
--   4. orchestration.mission_run_effects: intent -> receipt -> target for intents that carry Mission Control
--      coordinates.
begin;
set local lock_timeout = '15s';

do $$
begin
  if to_regclass('research.report_v2_ingestion') is null or to_regclass('orchestration.operation_receipt') is null then
    raise exception 'RESEARCH_REPORT_V2_PROJECTION_REQUIRED'
      using hint = 'apply 20261024010100_research_report_v2_projection before this migration';
  end if;
end $$;

-- ---------------------------------------------------------------------------------------------------------------
-- 1. Origin digest and Mission Control coordinates on the native ledger.
-- ---------------------------------------------------------------------------------------------------------------
alter table orchestration.operation_intent
  add column origin_digest text check (origin_digest ~ '^sha256:[0-9a-f]{64}$'),
  add column origin_kind text check (origin_kind in ('mission_invocation', 'standalone', 'recovery', 'durable_worker')),
  add column mc_mission_id text,
  add column mc_run_id text,
  add column mc_activation_id text,
  add column mc_operation_id text,
  add column mc_operation_attempt integer check (mc_operation_attempt >= 0),
  add column mc_execution_generation integer check (mc_execution_generation >= 0),
  add column mc_lane text,
  add constraint operation_intent_origin_pair check ((origin_digest is null) = (origin_kind is null)),
  add constraint operation_intent_mission_coordinates check (
    (origin_kind is not distinct from 'mission_invocation') = (
      mc_mission_id is not null and mc_run_id is not null and mc_operation_id is not null
      and mc_operation_attempt is not null and mc_execution_generation is not null and mc_lane is not null));
comment on column orchestration.operation_intent.origin_digest is
  'Digest (K01 originDigest) of the originating origin the KS executor admitted; restates knowledge_verification.origin.origin_digest (no cross-schema FK). Null for intents without an exact-use origin.';
comment on column orchestration.operation_intent.mc_run_id is
  'Mission Control run id from the originating origin''s mission coordinates (text; not orchestration.mission). Present exactly when origin_kind = mission_invocation, with mc_mission_id, mc_operation_id, mc_operation_attempt, mc_execution_generation and mc_lane.';

create trigger operation_intent_origin_immutable
  before update of tenant_id, origin_digest, origin_kind, mc_mission_id, mc_run_id, mc_activation_id, mc_operation_id,
    mc_operation_attempt, mc_execution_generation, mc_lane on orchestration.operation_intent
  for each row execute function util.reject_mutation();
create index operation_intent_mc_run_idx on orchestration.operation_intent (tenant_id, mc_run_id) where mc_run_id is not null;
create index operation_intent_origin_idx on orchestration.operation_intent (tenant_id, origin_digest) where origin_digest is not null;

alter table orchestration.operation_receipt
  add column origin_digest text check (origin_digest ~ '^sha256:[0-9a-f]{64}$');
comment on column orchestration.operation_receipt.origin_digest is
  'The originating origin digest of the intent this receipt applied (same value as operation_intent.origin_digest).';

-- ---------------------------------------------------------------------------------------------------------------
-- 2. Normalized receipt targets: one row per native row the receipt created, reused, superseded or staged.
-- ---------------------------------------------------------------------------------------------------------------
create table orchestration.operation_receipt_target (
  tenant_id uuid not null default util.current_tenant_id(),
  receipt_id uuid not null references orchestration.operation_receipt (id),
  ordinal integer not null check (ordinal >= 0),
  target_schema text not null check (target_schema in ('corpus', 'staging', 'temporal', 'evidence', 'knowledge', 'ranking', 'research')),
  target_table text not null check (btrim(target_table) <> ''),
  target_id text not null check (btrim(target_id) <> ''),
  entity_id uuid,
  entity_kind text references taxonomy.entity_kind (code),
  role text not null check (role in ('subject', 'canonical', 'supporting', 'provenance', 'staging', 'projection')),
  action text not null check (action in ('created', 'reused', 'superseded', 'staged')),
  proposal_id text,
  claim_id uuid,
  primary key (tenant_id, receipt_id, ordinal),
  unique (tenant_id, receipt_id, target_schema, target_table, target_id, role),
  check ((entity_id is null) = (entity_kind is null)),
  foreign key (tenant_id, entity_id, entity_kind) references corpus.entity (tenant_id, id, kind),
  foreign key (tenant_id, claim_id) references evidence.claim (tenant_id, id)
);
comment on table orchestration.operation_receipt_target is
  'Normalized targets of one native operation receipt: each corpus/staging/temporal/evidence/knowledge/ranking/research row the apply created, reused (already present, not rewritten), superseded (closed) or staged, with its role, the proposal that touched it, the entity (id and kind) for corpus rows and the claim for evidence rows. target_id is text because some targets are composite JSON tuples. Written once by executor_service in the apply transaction; immutable.';
create index operation_receipt_target_lookup
  on orchestration.operation_receipt_target (tenant_id, target_schema, target_table, target_id);
create index operation_receipt_target_entity on orchestration.operation_receipt_target (tenant_id, entity_id) where entity_id is not null;

create function orchestration.guard_receipt_target() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.tenant_id is distinct from util.current_tenant_id() or not exists (
    select 1 from orchestration.operation_receipt r join orchestration.operation_intent i on i.id = r.intent_id
     where r.id = new.receipt_id and i.tenant_id = new.tenant_id
  ) then
    raise exception 'RECEIPT_TARGET_TENANT_MISMATCH' using errcode = 'insufficient_privilege',
      detail = 'a receipt target must belong to a receipt of an intent in the current tenant';
  end if;
  return new;
end $$;
create trigger receipt_target_guard before insert on orchestration.operation_receipt_target
  for each row execute function orchestration.guard_receipt_target();
create trigger receipt_target_immutable before update or delete on orchestration.operation_receipt_target
  for each row execute function util.reject_mutation();

alter table orchestration.operation_receipt_target enable row level security;
alter table orchestration.operation_receipt_target force row level security;
create policy bounded_role_access on orchestration.operation_receipt_target for all
  to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id()) with check (tenant_id = util.current_tenant_id());
revoke all on orchestration.operation_receipt_target from public, anon, authenticated;
grant select on orchestration.operation_receipt_target to executor_service, pipeline_agent, control_plane;
grant insert on orchestration.operation_receipt_target to executor_service;
revoke all on function orchestration.guard_receipt_target() from public, anon, authenticated;

-- ---------------------------------------------------------------------------------------------------------------
-- 3. Claim producer origin: the attempt becomes optional, one producer identity stays required.
-- ---------------------------------------------------------------------------------------------------------------
alter table evidence.claim
  add column producer_origin_digest text check (producer_origin_digest ~ '^sha256:[0-9a-f]{64}$'),
  alter column producer_attempt_id drop not null,
  add constraint claim_producer_identity check (producer_attempt_id is not null or producer_origin_digest is not null);
comment on column evidence.claim.producer_origin_digest is
  'Originating origin digest (K01 originDigest) of the authenticated invocation that produced this claim when no orchestration attempt did; restates knowledge_verification.origin (no cross-schema FK). claim_producer_identity requires it or producer_attempt_id.';
drop trigger claim_content_provenance_immutable on evidence.claim;
create trigger claim_content_provenance_immutable
  before update of tenant_id, claim_type, statement, structured, composite, atomized_from_id, producer_attempt_id,
    producer_origin_digest, created_by_receipt_id, created_at on evidence.claim
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------------------------------------------
-- 4. Forward view: everything a Mission Control run produced, as one SELECT.
-- ---------------------------------------------------------------------------------------------------------------
create view orchestration.mission_run_effects with (security_invoker = true) as
select i.tenant_id, i.mc_run_id, i.mc_mission_id, i.mc_activation_id, i.mc_operation_id, i.mc_operation_attempt,
       i.mc_execution_generation, i.mc_lane, i.origin_digest, i.id as intent_id, r.id as receipt_id,
       r.outcome as receipt_outcome, r.applied_at, r.use_decision_id, t.ordinal, t.target_schema, t.target_table,
       t.target_id, t.entity_id, t.entity_kind, t.role, t.action, t.proposal_id, t.claim_id
  from orchestration.operation_intent i
  join orchestration.operation_receipt r on r.intent_id = i.id
  join orchestration.operation_receipt_target t on t.tenant_id = i.tenant_id and t.receipt_id = r.id
 where i.mc_run_id is not null;
comment on view orchestration.mission_run_effects is
  'Native effects by Mission Control run: intent (with its mc_* coordinates and origin digest) -> receipt -> receipt targets, for intents that carry mission coordinates. security_invoker: the caller''s grants and tenant policies on the three tables apply, so only roles that can read operation_receipt (executor_service, control_plane) can read it.';
revoke all on orchestration.mission_run_effects from public, anon, authenticated;
grant select on orchestration.mission_run_effects to executor_service, control_plane;

do $$
declare missing text;
begin
  select string_agg(x, ', ') into missing from (values
    ('orchestration.operation_intent.mc_run_id'), ('orchestration.operation_receipt.origin_digest'),
    ('evidence.claim.producer_origin_digest')) v(x)
   where not exists (
     select 1 from information_schema.columns c
      where c.table_schema || '.' || c.table_name || '.' || c.column_name = v.x);
  if missing is not null then raise exception 'OPERATION_RECEIPT_TARGETS_INCOMPLETE: %', missing; end if;
  if not (select c.relrowsecurity and c.relforcerowsecurity from pg_catalog.pg_class c
           where c.oid = 'orchestration.operation_receipt_target'::regclass) then
    raise exception 'OPERATION_RECEIPT_TARGETS_INCOMPLETE: row level security not forced';
  end if;
  if exists (select 1 from information_schema.columns
              where table_schema = 'evidence' and table_name = 'claim' and column_name = 'producer_attempt_id' and is_nullable = 'NO') then
    raise exception 'OPERATION_RECEIPT_TARGETS_INCOMPLETE: evidence.claim.producer_attempt_id is still not null';
  end if;
end $$;

commit;
