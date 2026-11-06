-- Provenance sprint 2026-10-31 (OVE-204): origin digest + Mission Control coordinates on the native ledger, normalized
-- receipt targets, claim producer origin and orchestration.mission_run_effects
-- (20261031010000_operation_receipt_targets.sql).
-- Run as the database owner (postgres) on a DISPOSABLE project. Every block raises on failure; a silent run is a pass;
-- the whole file rolls back.
\set ON_ERROR_STOP on
begin;
set local role postgres;
select set_config('app.tenant_id', '00000000-0000-7000-8000-0000000004a1', true);
create function pg_temp.d(t text) returns text language sql immutable as $$ select 'sha256:' || encode(sha256(convert_to(t, 'UTF8')), 'hex') $$;
create function pg_temp.t() returns uuid language sql stable as $$ select current_setting('app.tenant_id')::uuid $$;

-- T1 coordinate constraints: digest and kind come together; mission_invocation iff all required coordinates.
do $$
begin
  begin
    insert into orchestration.operation_intent (tenant_id, intent_type, payload, idempotency_key, approval_state, origin_digest)
    values (pg_temp.t(), 'knowledge_ingestion', '{}', 'ort-t1-a', 'approved', pg_temp.d('origin-a'));
    raise exception 'T1 origin digest without kind accepted';
  exception when check_violation then null;
  end;
  begin
    insert into orchestration.operation_intent (tenant_id, intent_type, payload, idempotency_key, approval_state, origin_digest, origin_kind, mc_run_id)
    values (pg_temp.t(), 'knowledge_ingestion', '{}', 'ort-t1-b', 'approved', pg_temp.d('origin-a'), 'mission_invocation', 'run-1');
    raise exception 'T1 mission_invocation with partial coordinates accepted';
  exception when check_violation then null;
  end;
  begin
    insert into orchestration.operation_intent (tenant_id, intent_type, payload, idempotency_key, approval_state, origin_digest, origin_kind,
      mc_mission_id, mc_run_id, mc_operation_id, mc_operation_attempt, mc_execution_generation, mc_lane)
    values (pg_temp.t(), 'knowledge_ingestion', '{}', 'ort-t1-c', 'approved', pg_temp.d('origin-a'), 'standalone',
      'mission-1', 'run-1', 'op-1', 1, 0, 'knowledge');
    raise exception 'T1 standalone origin with mission coordinates accepted';
  exception when check_violation then null;
  end;
end $$;

-- Fixture: one mission intent, its receipt, an entity and a claim (owner inserts; deferred receipt FKs never fire: rollback).
insert into orchestration.operation_intent (id, tenant_id, intent_type, payload, idempotency_key, approval_state, origin_digest, origin_kind,
  mc_mission_id, mc_run_id, mc_activation_id, mc_operation_id, mc_operation_attempt, mc_execution_generation, mc_lane)
values ('00000000-0000-7000-8000-0000000004b1', pg_temp.t(), 'knowledge_ingestion', '{}', 'ort-mission', 'approved', pg_temp.d('origin-m'), 'mission_invocation',
  'mission-ort', 'run-ort', null, 'op-ort', 1, 0, 'knowledge');
insert into orchestration.operation_receipt (id, intent_id, executor_version, outcome, origin_digest)
values ('00000000-0000-7000-8000-0000000004c1', '00000000-0000-7000-8000-0000000004b1', 'test', 'applied', pg_temp.d('origin-m'));
insert into corpus.entity (id, tenant_id, kind, display_name, slug, created_by_receipt_id)
values ('00000000-0000-7000-8000-0000000004d1', pg_temp.t(), 'organization', 'ORT Org', 'ort-org', '00000000-0000-7000-8000-0000000004c1');
-- Another tenant's intent and receipt (for the tenant guard).
insert into orchestration.operation_intent (id, tenant_id, intent_type, payload, idempotency_key, approval_state)
values ('00000000-0000-7000-8000-0000000004b2', '00000000-0000-7000-8000-0000000004a2', 'knowledge_ingestion', '{}', 'ort-other', 'approved');
insert into orchestration.operation_receipt (id, intent_id, executor_version, outcome)
values ('00000000-0000-7000-8000-0000000004c2', '00000000-0000-7000-8000-0000000004b2', 'test', 'applied');

-- T2 claim producer identity: attempt or origin digest, never neither.
do $$
begin
  insert into evidence.claim (id, tenant_id, claim_type, statement, producer_origin_digest, created_by_receipt_id)
  values ('00000000-0000-7000-8000-0000000004e1', pg_temp.t(), 'attribute', 'ORT holds', pg_temp.d('origin-m'), '00000000-0000-7000-8000-0000000004c1');
  begin
    insert into evidence.claim (tenant_id, claim_type, statement, created_by_receipt_id)
    values (pg_temp.t(), 'attribute', 'ORT has no producer', '00000000-0000-7000-8000-0000000004c1');
    raise exception 'T2 claim without attempt or origin accepted';
  exception when check_violation then
    if sqlerrm not like '%claim_producer_identity%' then raise; end if;
  end;
  begin
    update evidence.claim set producer_origin_digest = pg_temp.d('other') where id = '00000000-0000-7000-8000-0000000004e1';
    raise exception 'T2 claim producer origin was mutable';
  exception when others then
    if sqlerrm like 'T2%' then raise; end if;
  end;
end $$;

-- T3 executor_service writes targets; constraints refuse inconsistent rows.
set local role executor_service;
insert into orchestration.operation_receipt_target (tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, entity_id, entity_kind, role, action, proposal_id, claim_id)
values (pg_temp.t(), '00000000-0000-7000-8000-0000000004c1', 0, 'corpus', 'entity', '00000000-0000-7000-8000-0000000004d1',
        '00000000-0000-7000-8000-0000000004d1', 'organization', 'subject', 'created', 'p-01', null),
       (pg_temp.t(), '00000000-0000-7000-8000-0000000004c1', 1, 'evidence', 'claim', '00000000-0000-7000-8000-0000000004e1',
        null, null, 'provenance', 'created', 'p-00', '00000000-0000-7000-8000-0000000004e1'),
       (pg_temp.t(), '00000000-0000-7000-8000-0000000004c1', 2, 'evidence', 'claim_subject',
        '["00000000-0000-7000-8000-0000000004e1","00000000-0000-7000-8000-0000000004d1","subject"]', null, null, 'provenance', 'reused', null,
        '00000000-0000-7000-8000-0000000004e1');
do $$
begin
  begin
    insert into orchestration.operation_receipt_target (tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, entity_id, entity_kind, role, action)
    values (pg_temp.t(), '00000000-0000-7000-8000-0000000004c1', 3, 'corpus', 'entity', '00000000-0000-7000-8000-0000000004d1',
            '00000000-0000-7000-8000-0000000004d1', 'person', 'canonical', 'reused');
    raise exception 'T3 wrong entity kind accepted';
  exception when foreign_key_violation then null;
  end;
  begin
    insert into orchestration.operation_receipt_target (tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, entity_id, role, action)
    values (pg_temp.t(), '00000000-0000-7000-8000-0000000004c1', 3, 'corpus', 'entity', 'x', '00000000-0000-7000-8000-0000000004d1', 'canonical', 'reused');
    raise exception 'T3 entity id without kind accepted';
  exception when check_violation then null;
  end;
  begin
    insert into orchestration.operation_receipt_target (tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, role, action)
    values (pg_temp.t(), '00000000-0000-7000-8000-0000000004c1', 3, 'evidence', 'claim', '00000000-0000-7000-8000-0000000004e1', 'provenance', 'reused');
    raise exception 'T3 duplicate (schema, table, id, role) accepted';
  exception when unique_violation then null;
  end;
  begin
    insert into orchestration.operation_receipt_target (tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, role, action)
    values (pg_temp.t(), '00000000-0000-7000-8000-0000000004c1', 3, 'orchestration', 'mission', 'x', 'canonical', 'created');
    raise exception 'T3 unknown target schema accepted';
  exception when check_violation then null;
  end;
  begin
    insert into orchestration.operation_receipt_target (tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, role, action)
    values (pg_temp.t(), '00000000-0000-7000-8000-0000000004c1', 3, 'corpus', 'entity', 'x', 'canonical', 'deleted');
    raise exception 'T3 unknown action accepted';
  exception when check_violation then null;
  end;
  -- T4 tenant guard: a receipt of another tenant's intent.
  begin
    insert into orchestration.operation_receipt_target (tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, role, action)
    values (pg_temp.t(), '00000000-0000-7000-8000-0000000004c2', 0, 'corpus', 'entity', 'x', 'canonical', 'created');
    raise exception 'T4 cross-tenant receipt target accepted';
  exception when insufficient_privilege then
    if sqlerrm <> 'RECEIPT_TARGET_TENANT_MISMATCH' then raise; end if;
  end;
  -- T5 immutability.
  begin
    update orchestration.operation_receipt_target set action = 'reused' where receipt_id = '00000000-0000-7000-8000-0000000004c1' and ordinal = 0;
    raise exception 'T5 receipt target updated';
  exception when others then
    if sqlerrm like 'T5%' then raise; end if;
  end;
  begin
    delete from orchestration.operation_receipt_target where receipt_id = '00000000-0000-7000-8000-0000000004c1';
    raise exception 'T5 receipt target deleted';
  exception when others then
    if sqlerrm like 'T5%' then raise; end if;
  end;
end $$;

-- T6 the forward view: everything run-ort produced, in one SELECT, as executor_service.
do $$
declare n int; kinds text;
begin
  select count(*), string_agg(target_table || ':' || action, ',' order by ordinal) into n, kinds
    from orchestration.mission_run_effects where mc_run_id = 'run-ort';
  if n <> 3 or kinds <> 'entity:created,claim:created,claim_subject:reused' then
    raise exception 'T6 mission_run_effects returned % rows (%)', n, kinds;
  end if;
  if exists (select 1 from orchestration.mission_run_effects where mc_run_id = 'run-ort'
              and (mc_mission_id <> 'mission-ort' or mc_operation_id <> 'op-ort' or origin_digest <> pg_temp.d('origin-m')
                   or intent_id <> '00000000-0000-7000-8000-0000000004b1')) then
    raise exception 'T6 mission_run_effects coordinates wrong';
  end if;
end $$;
reset role;

-- T7 grants: pipeline_agent reads targets but not the view (it cannot read receipts); app_reader reads neither.
set local role pipeline_agent;
do $$
begin
  if (select count(*) from orchestration.operation_receipt_target where receipt_id = '00000000-0000-7000-8000-0000000004c1') <> 3 then
    raise exception 'T7 pipeline_agent cannot read its tenant''s targets';
  end if;
  begin
    perform 1 from orchestration.mission_run_effects;
    raise exception 'T7 pipeline_agent read mission_run_effects';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into orchestration.operation_receipt_target (tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, role, action)
    values (pg_temp.t(), '00000000-0000-7000-8000-0000000004c1', 9, 'corpus', 'entity', 'y', 'canonical', 'created');
    raise exception 'T7 pipeline_agent inserted a target';
  exception when insufficient_privilege then null;
  end;
end $$;
reset role;
set local role app_reader;
do $$
begin
  perform 1 from orchestration.operation_receipt_target;
  raise exception 'T7 app_reader read receipt targets';
exception when insufficient_privilege then null;
end $$;
reset role;

-- T8 another tenant sees none of the targets (forced RLS), even through the view.
set local role control_plane;
select set_config('app.tenant_id', '00000000-0000-7000-8000-0000000004a2', true);
do $$
begin
  if exists (select 1 from orchestration.operation_receipt_target) or exists (select 1 from orchestration.mission_run_effects) then
    raise exception 'T8 cross-tenant targets visible';
  end if;
end $$;
reset role;
set local role postgres;
select set_config('app.tenant_id', '00000000-0000-7000-8000-0000000004a1', true);

-- T9 the coordinates are immutable once written.
do $$
begin
  update orchestration.operation_intent set mc_run_id = 'run-other' where id = '00000000-0000-7000-8000-0000000004b1';
  raise exception 'T9 intent coordinates updated';
exception when others then
  if sqlerrm like 'T9%' then raise; end if;
end $$;

rollback;
