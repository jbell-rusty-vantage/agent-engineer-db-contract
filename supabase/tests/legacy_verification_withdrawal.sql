-- Sprint V SV-17: rollback-only proof for 20261025010000_withdraw_legacy_verification_truth.sql.
-- Run as the database owner (postgres) on a DISPOSABLE project where `knowledge-db install --application ai-engineer`
-- (component >= 2.3.0) preceded `db:migrate`. Every block raises on failure; a silent run is a pass; the file rolls back.
\set ON_ERROR_STOP on
begin;
set local role postgres;

-- W1 withdrawn relations and functions are gone; the component owns their replacements.
do $$
begin
  if to_regclass('evidence.verification_run') is not null or to_regclass('evidence.verification_finding') is not null
     or to_regclass('evidence.executable_verification') is not null or to_regclass('evidence.claim_evidence_assessment') is not null
     or to_regclass('evidence.verification_case_run') is not null or to_regclass('evidence.verification_case_evidence') is not null
     or to_regclass('evidence.verification_adjudication_subject') is not null
     or to_regclass('evidence.verification_adjudication_reviewer_grant') is not null
     or to_regclass('evidence.verification_adjudication_decision') is not null
     or to_regclass('evidence.verification_adjudication_review_state') is not null
     or to_regclass('orchestration.verification_component_drift_observation') is not null
     or to_regclass('orchestration.verification_drift_revalidation_outbox') is not null
     or to_regclass('research.report_package_seal') is not null or to_regclass('research.report_assessment') is not null
     or to_regclass('research.report_ingestion_link') is not null
     or to_regclass('knowledge_service.recovery_case') is not null or to_regclass('knowledge_service.recovery_original') is not null
     or to_regclass('knowledge_service.recovery_revision') is not null or to_regclass('knowledge_service.recovery_execution') is not null
     or to_regclass('knowledge_service.recovery_artifact_reference') is not null
     or to_regclass('knowledge_service.recovery_binding_owner') is not null
     or to_regclass('knowledge_service.recovery_dependency_claim') is not null then
    raise exception 'W1 a withdrawn relation survived';
  end if;
  if to_regprocedure('orchestration.claim_verification_drift_revalidation(text,integer,integer)') is not null
     or to_regprocedure('orchestration.publish_verification_component_drift_observation(uuid,text,text,uuid,uuid,text,uuid,uuid,text,text[],text)') is not null
     or to_regprocedure('evidence.validate_verification_run()') is not null
     or to_regprocedure('knowledge_service.check_recovery_original_authority()') is not null
     or to_regprocedure('research.guard_report_seal()') is not null then
    raise exception 'W1 a withdrawn function survived';
  end if;
  if exists (select 1 from pg_attribute where attrelid = 'evidence.claim_evidence_link'::regclass and attname = 'verified_by_run_id' and not attisdropped) then
    raise exception 'W1 claim_evidence_link.verified_by_run_id survived';
  end if;
  -- Owners of the replacements.
  if to_regclass('knowledge_verification.verification_run') is null or to_regclass('knowledge_verification.observation') is null
     or to_regclass('knowledge_verification.adjudication') is null or to_regclass('knowledge_verification.dispatch_outbox') is null
     or to_regclass('knowledge_verification.effect_receipt') is null or to_regclass('knowledge_verification.report_assessment') is null
     or to_regclass('knowledge_verification.protocol_receipt') is null or to_regclass('research.report_v2_revision') is null then
    raise exception 'W1 a component/v2 replacement is missing';
  end if;
  -- Kept on purpose (provider accounting, extraction, benchmark and lineage guards still use it).
  if to_regclass('orchestration.verification_artifact_metadata') is null or to_regclass('orchestration.verification_provider_attempt') is null then
    raise exception 'W1 a retained verification-adjacent relation was dropped';
  end if;
end $$;

-- W2 no role keeps a privilege on a withdrawn name (the grants went with the objects), and the redefined functions are not PUBLIC.
do $$
begin
  if exists (select 1 from information_schema.role_table_grants
              where (table_schema, table_name) in (('evidence','verification_run'),('research','report_package_seal'),('knowledge_service','recovery_case'))) then
    raise exception 'W2 a grant on a withdrawn relation survived';
  end if;
  if has_function_privilege('anon', 'evidence.enforce_verified_claim_gate()', 'execute')
     or has_function_privilege('anon', 'research.guard_report_projection()', 'execute') then
    raise exception 'W2 a redefined guard is executable by anon';
  end if;
end $$;

-- W6 the research admission/projection tables force row level security (20261025010100, review finding F12).
do $$
begin
  if exists (select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
              where n.nspname = 'research' and c.relname in ('use_admission', 'report_v2_revision', 'report_v2_assertion', 'report_v2_ingestion')
                and not (c.relrowsecurity and c.relforcerowsecurity)) then
    raise exception 'W6 a research table does not force row level security';
  end if;
end $$;

-- Fixtures: one tenant, mission, attempt.
select set_config('app.tenant_id', '00000000-0000-7000-8000-0000000017a1', true);
insert into orchestration.mission (id, tenant_id, goal)
values ('00000000-0000-7000-8000-0000000017b1', current_setting('app.tenant_id')::uuid, 'SV-17 withdrawal proof');
insert into orchestration.work_item (id, tenant_id, mission_id, kind)
values ('00000000-0000-7000-8000-0000000017b2', current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-0000000017b1', 'build_vectors');
insert into orchestration.attempt (id, tenant_id, work_item_id, attempt_no, agent_deployment_id)
values ('00000000-0000-7000-8000-0000000017b3', current_setting('app.tenant_id')::uuid, '00000000-0000-7000-8000-0000000017b2', 1, 'sv17-withdrawal');
-- A legacy receipt (names no use decision) and an admission-bound receipt.
insert into orchestration.operation_intent (id, tenant_id, intent_type, payload, idempotency_key, approval_state)
values ('00000000-0000-7000-8000-0000000017c1', current_setting('app.tenant_id')::uuid, 'verify_claim', '{"sv17":"legacy"}', 'sv17-legacy', 'approved'),
       ('00000000-0000-7000-8000-0000000017c2', current_setting('app.tenant_id')::uuid, 'verify_claim', '{"sv17":"bound"}', 'sv17-bound', 'approved');
insert into orchestration.operation_receipt (id, intent_id, executor_version, outcome)
values ('00000000-0000-7000-8000-0000000017d1', '00000000-0000-7000-8000-0000000017c1', 'sv17-test', 'applied');
insert into orchestration.operation_receipt (id, intent_id, executor_version, outcome, requires_admission, use_decision_id, bound_effect_digest)
values ('00000000-0000-7000-8000-0000000017d2', '00000000-0000-7000-8000-0000000017c2', 'sv17-test', 'applied', true, 'ud-sv17',
        'sha256:' || encode(sha256(convert_to('sv17-bound', 'UTF8')), 'hex'));

-- W3 status verified without a receipt, or under a legacy receipt, refuses VERIFIED_CLAIM_REQUIRES_ADMITTED_USE.
do $$
begin
  begin
    insert into evidence.claim (tenant_id, claim_type, statement, status, producer_attempt_id)
    select current_setting('app.tenant_id')::uuid, code, 'unbound verified claim', 'verified', '00000000-0000-7000-8000-0000000017b3'
      from evidence.claim_type order by code limit 1;
    raise exception 'W3 verified claim without a receipt accepted';
  exception when check_violation then
    if sqlerrm <> 'VERIFIED_CLAIM_REQUIRES_ADMITTED_USE' then raise; end if;
  end;
  begin
    insert into evidence.claim (tenant_id, claim_type, statement, status, producer_attempt_id, created_by_receipt_id)
    select current_setting('app.tenant_id')::uuid, code, 'legacy verified claim', 'verified', '00000000-0000-7000-8000-0000000017b3',
           '00000000-0000-7000-8000-0000000017d1'
      from evidence.claim_type order by code limit 1;
    raise exception 'W3 verified claim under a legacy receipt accepted';
  exception when check_violation then
    if sqlerrm <> 'VERIFIED_CLAIM_REQUIRES_ADMITTED_USE' then raise; end if;
  end;
  -- A proposed claim under a legacy receipt is unaffected, and promoting it to verified refuses.
  insert into evidence.claim (id, tenant_id, claim_type, statement, status, producer_attempt_id, created_by_receipt_id)
  select '00000000-0000-7000-8000-0000000017e1', current_setting('app.tenant_id')::uuid, code, 'proposed claim', 'proposed',
         '00000000-0000-7000-8000-0000000017b3', '00000000-0000-7000-8000-0000000017d1'
    from evidence.claim_type order by code limit 1;
  begin
    update evidence.claim set status = 'verified' where id = '00000000-0000-7000-8000-0000000017e1';
    raise exception 'W3 legacy claim promoted to verified';
  exception when check_violation then
    if sqlerrm <> 'VERIFIED_CLAIM_REQUIRES_ADMITTED_USE' then raise; end if;
  end;
  if retrieval.history_claim_authorized('00000000-0000-7000-8000-0000000017e1') then
    raise exception 'W3 an unadmitted claim was authorized for retrieval';
  end if;
end $$;

-- W4 under an admission-bound receipt the gate passes, and commit still requires the same-transaction admission
--    (the receipt's deferred guard from 20261024010100 raises ADMISSION_REQUIRED, KSA06).
do $$
begin
  insert into evidence.claim (tenant_id, claim_type, statement, status, producer_attempt_id, created_by_receipt_id)
  select current_setting('app.tenant_id')::uuid, code, 'bound verified claim', 'verified', '00000000-0000-7000-8000-0000000017b3',
         '00000000-0000-7000-8000-0000000017d2'
    from evidence.claim_type order by code limit 1;
  set constraints all immediate;
  raise exception 'W4 a verified claim under a bound receipt committed without admission';
exception when sqlstate 'KSA06' then
  if sqlerrm <> 'ADMISSION_REQUIRED' then raise; end if;
end $$;
set constraints all deferred;

-- W5 the v1 report projection is closed for new rows.
do $$
begin
  insert into research.report_package (tenant_id, report_id, report_version_id) values (current_setting('app.tenant_id')::uuid, util.uuidv7(), util.uuidv7());
  raise exception 'W5 a v1 report package row was accepted';
exception
  when sqlstate '55000' then if sqlerrm <> 'REPORT_V1_WITHDRAWN' then raise; end if;
  when not_null_violation or foreign_key_violation then raise exception 'W5 v1 insert reached constraints before the closed guard: %', sqlerrm;
end $$;

rollback;
