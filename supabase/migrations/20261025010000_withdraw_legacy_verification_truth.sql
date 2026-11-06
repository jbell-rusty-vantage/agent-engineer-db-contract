-- 20261025010000_withdraw_legacy_verification_truth
-- Sprint V SV-17 (clean cutover): withdraw the AIDB-owned verification, report-seal and recovery truth that the common
-- knowledge_verification component (KS packages/knowledge-db-contract, >= 2.3.0) now owns. One owner per object:
-- verification runs/observations, adjudication, revalidation outbox, report seals/assessments and receipt-first
-- recovery live only in schema knowledge_verification; the AIDB keeps its domain rows and the research.report_v2_*
-- projections and native admission guard (20261024010100, 20261024010200).
--
-- Data: the withdrawn tables hold disposable/fixture rows only (owner decisions SV-D8 and SV-D11). Nothing is copied
-- or backfilled; their grants disappear with them. Dropped without CASCADE so an unknown dependent fails this
-- migration instead of being removed silently; a closing check refuses if any withdrawn object survives or if a kept
-- function body still names one.
--
-- Withdrawn (component owner now):
--   evidence.verification_run, verification_finding, executable_verification, claim_evidence_assessment
--     (component verification_run, observation, support_set) and evidence.claim_evidence_link.verified_by_run_id;
--   evidence.verification_case_run, verification_case_evidence (verification_run, fragment);
--   evidence.verification_adjudication_subject, _reviewer_grant, _decision and view _review_state
--     (adjudication, reviewer_grant);
--   orchestration.verification_component_drift_observation, verification_drift_revalidation_outbox and their
--     publish/plan/claim/ack functions (invalidation, dispatch_outbox);
--   research.report_package_seal, report_assessment, report_ingestion_link (run_manifest/seal_run, report_assessment,
--     research.report_v2_ingestion + effect_receipt);
--   knowledge_service.recovery_case, recovery_original, recovery_revision, recovery_execution,
--     recovery_artifact_reference, recovery_binding_owner, recovery_dependency_claim (effect, effect_receipt).
-- Kept on purpose: orchestration.verification_artifact_metadata (artifact admission for the retained provider
-- accounting, structured extraction, benchmark, lineage, tombstone and source-selection guards), the provider and
-- benchmark tables, evaluation freeze guards.
--
-- Redefined kept functions:
--   evidence.enforce_verified_claim_gate: status `verified` now requires the claim's creating receipt to be bound to
--     an admitted exact-use decision (orchestration.operation_receipt.requires_admission, 20261024010100); that
--     receipt's deferred guard already refuses commit without a same-transaction research.use_admission.
--   retrieval.history_claim_authorized: authorized = verified/superseded claim created under such a receipt with a
--     recorded research.use_admission for the same decision and bound effect digest.
--   research.guard_report_projection: v1 report packages had no seal authority left, so the v1 projection is closed
--     for new rows (REPORT_V1_WITHDRAWN); existing v1 rows stay readable and immutable. New reports are component
--     report revisions projected through research.report_v2_revision/assertion/ingestion.
begin;
set local lock_timeout = '15s';

do $$
begin
  if to_regprocedure('knowledge_verification.admit_exact_use(uuid,text,text,bigint,timestamptz,text)') is null
     or to_regclass('knowledge_verification.protocol_receipt') is null then
    raise exception 'KNOWLEDGE_VERIFICATION_COMPONENT_2_3_REQUIRED'
      using hint = 'install @aiengineer/knowledge-db-contract 2.3.0 (knowledge-db install --application ai-engineer) before this migration';
  end if;
  if to_regclass('research.use_admission') is null then
    raise exception 'RESEARCH_ADMISSION_GUARD_REQUIRED' using hint = 'apply 20261024010100 and 20261024010200 first';
  end if;
end $$;

-- 1. Kept functions first, so nothing that stays names a withdrawn object.
create or replace function evidence.enforce_verified_claim_gate() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.status <> 'verified' or (tg_op = 'UPDATE' and old.status = 'verified') then return new; end if;
  if new.created_by_receipt_id is null or not exists (
    select 1 from orchestration.operation_receipt r
     where r.id = new.created_by_receipt_id
       and r.requires_admission
       and r.use_decision_id is not null
       and r.bound_effect_digest is not null
  ) then
    raise exception 'VERIFIED_CLAIM_REQUIRES_ADMITTED_USE'
      using errcode = 'check_violation',
            hint = 'a verified claim is written under an operation receipt bound to an admitted knowledge_verification use decision (research.assert_admitted_use in the same transaction)';
  end if;
  return new;
end $$;
revoke all on function evidence.enforce_verified_claim_gate() from public, anon, authenticated;
comment on function evidence.enforce_verified_claim_gate() is
  'Status verified requires the creating receipt to be bound to an admitted exact-use decision of the knowledge_verification component (requires_admission, use_decision_id, bound_effect_digest); the receipt''s deferred guard requires the same-transaction research.use_admission. The legacy AIDB verification-run path was withdrawn in 20261025010000.';

create or replace function retrieval.history_claim_authorized(p_claim uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
      from evidence.claim c
      join orchestration.operation_receipt r on r.id = c.created_by_receipt_id
     where c.tenant_id = util.current_tenant_id() and c.id = p_claim
       and c.status::text in ('verified', 'superseded')
       and r.requires_admission and r.use_decision_id is not null
       and exists (
         select 1 from research.use_admission a
          where a.tenant_id = c.tenant_id
            and a.use_decision_id = r.use_decision_id
            and a.bound_effect_digest = r.bound_effect_digest))
$$;
comment on function retrieval.history_claim_authorized(uuid) is
  'A historical claim is authorized for retrieval when it is verified (or superseded after verification) and was created under a receipt bound to a knowledge_verification use decision with a recorded research.use_admission. Admission is separate from belief.';

create or replace function research.guard_report_projection() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  raise exception 'REPORT_V1_WITHDRAWN'
    using errcode = '55000',
          hint = 'research report v1 packages are read-only history; register a component report revision and project it through research.report_v2_revision';
end $$;
revoke all on function research.guard_report_projection() from public, anon, authenticated;
comment on function research.guard_report_projection() is
  'Closes the v1 report projection (report_package and its section/assertion/artifact/question rows) for new rows since 20261025010000: v1 seals, assessments and ingestion links were withdrawn in favour of the knowledge_verification report revision and research.report_v2_* projections.';

-- 2. Withdrawn objects, dependents first.
drop view evidence.verification_adjudication_review_state;
drop table evidence.verification_adjudication_decision;
drop table evidence.verification_adjudication_reviewer_grant;
drop table evidence.verification_adjudication_subject;
drop table evidence.verification_case_evidence;
drop table evidence.verification_case_run;

drop function orchestration.publish_verification_component_drift_observation(uuid, text, text, uuid, uuid, text, uuid, uuid, text, text[], text);
drop function orchestration.plan_verification_drift_revalidation(uuid, text, uuid, text, text[], text, text);
drop function orchestration.claim_verification_drift_revalidation(text, integer, integer);
drop function orchestration.ack_verification_drift_revalidation(uuid, text, uuid);
drop table orchestration.verification_drift_revalidation_outbox;
drop table orchestration.verification_component_drift_observation;

drop table research.report_ingestion_link;
drop table research.report_assessment;
drop table research.report_package_seal;

drop table knowledge_service.recovery_execution;
drop table knowledge_service.recovery_binding_owner;
drop table knowledge_service.recovery_original;
drop table knowledge_service.recovery_revision;
drop table knowledge_service.recovery_dependency_claim;
drop table knowledge_service.recovery_artifact_reference;
drop table knowledge_service.recovery_case;

drop table evidence.claim_evidence_assessment;
drop table evidence.verification_finding;
drop table evidence.executable_verification;
alter table evidence.claim_evidence_link drop column verified_by_run_id;
drop table evidence.verification_run;

-- Trigger functions of the withdrawn tables (no longer attached anywhere).
drop function evidence.enforce_producer_not_verifier();
drop function evidence.enforce_assessment_producer_not_verifier();
drop function evidence.enforce_claim_evidence_finalization();
drop function evidence.enforce_verification_run_lifecycle();
drop function evidence.validate_verification_run();
drop function evidence.validate_verification_case_run();
drop function evidence.validate_verification_case_evidence();
drop function evidence.validate_verification_adjudication_subject();
drop function evidence.validate_verification_adjudication_decision();
drop function orchestration.verification_component_drift_observation_immutable();
drop function research.guard_report_seal();
drop function research.guard_report_assessment();
drop function research.guard_report_ingestion_link();
drop function knowledge_service.guard_recovery_case();
drop function knowledge_service.guard_recovery_original();
drop function knowledge_service.guard_recovery_execution();
drop function knowledge_service.guard_recovery_revision_artifact();
drop function knowledge_service.check_recovery_original_authority();

-- 3. Closing check: nothing withdrawn survives, and no kept AIDB function body names a withdrawn relation.
do $$
declare survivors text; namers text;
begin
  select string_agg(n.nspname || '.' || c.relname, ', ') into survivors
    from pg_catalog.pg_class c join pg_catalog.pg_namespace n on n.oid = c.relnamespace
   where (n.nspname, c.relname) in (
     ('evidence', 'verification_run'), ('evidence', 'verification_finding'), ('evidence', 'executable_verification'),
     ('evidence', 'claim_evidence_assessment'), ('evidence', 'verification_case_run'), ('evidence', 'verification_case_evidence'),
     ('evidence', 'verification_adjudication_subject'), ('evidence', 'verification_adjudication_reviewer_grant'),
     ('evidence', 'verification_adjudication_decision'), ('evidence', 'verification_adjudication_review_state'),
     ('orchestration', 'verification_component_drift_observation'), ('orchestration', 'verification_drift_revalidation_outbox'),
     ('research', 'report_package_seal'), ('research', 'report_assessment'), ('research', 'report_ingestion_link'),
     ('knowledge_service', 'recovery_case'), ('knowledge_service', 'recovery_original'), ('knowledge_service', 'recovery_revision'),
     ('knowledge_service', 'recovery_execution'), ('knowledge_service', 'recovery_artifact_reference'),
     ('knowledge_service', 'recovery_binding_owner'), ('knowledge_service', 'recovery_dependency_claim'));
  if survivors is not null then raise exception 'LEGACY_VERIFICATION_OBJECT_SURVIVED: %', survivors; end if;

  select string_agg(p.oid::regprocedure::text, ', ') into namers
    from pg_catalog.pg_proc p join pg_catalog.pg_namespace n on n.oid = p.pronamespace
   where n.nspname in ('api', 'corpus', 'evaluation', 'evidence', 'knowledge', 'knowledge_service', 'orchestration', 'research', 'retrieval', 'util')
     and p.prosrc ~ '(evidence\.(verification_run|verification_finding|executable_verification|claim_evidence_assessment|verification_case_|verification_adjudication_)|verification_component_drift_observation|verification_drift_revalidation_outbox|report_package_seal|research\.report_assessment|report_ingestion_link|knowledge_service\.recovery_|verified_by_run_id)';
  if namers is not null then raise exception 'KEPT_FUNCTION_NAMES_WITHDRAWN_OBJECT: %', namers; end if;
end $$;

commit;
