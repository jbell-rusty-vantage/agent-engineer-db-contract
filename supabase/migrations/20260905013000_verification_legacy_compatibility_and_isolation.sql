-- Make verification.v1 hardening opt-in for legacy rows while preserving strict
-- requirements for every new verification-managed record.
begin;

alter table orchestration.artifact alter column media_type drop not null;
alter table orchestration.artifact alter column size_bytes drop not null;
alter table orchestration.artifact drop constraint verification_bucket_cas_path_ck;
alter table orchestration.artifact add constraint verification_bucket_cas_path_ck check(
 verification_contract_version is null
 or (storage_bucket='ai-engineer-cloud-bucket'
     and object_path ~ ('^'||tenant_id::text||'/[0-9a-f]{2}/[0-9a-f]{64}$')
     and split_part(object_path,'/',2)=left(sha256,2)
     and split_part(object_path,'/',3)=sha256
     and media_type is not null and btrim(media_type)<>''
     and size_bytes is not null and size_bytes>=0)
);

alter table evidence.locator
 add column if not exists verification_contract_version text,
 alter column tenant_id drop not null,
 alter column tenant_id drop default,
 alter column representation_artifact_id drop not null,
 alter column selector_sha256 drop not null,
 alter column selected_size_bytes drop not null,
 alter column occurrence_count drop not null,
 alter column resolution_state drop not null,
 alter column normalization_policy drop not null,
 alter column resolution_version drop not null,
 drop constraint locator_resolution_cardinality_ck;
alter table evidence.locator add constraint locator_verification_contract_version_ck
 check(verification_contract_version is null or verification_contract_version='verification.v1');
alter table evidence.locator add constraint locator_resolution_cardinality_ck check(
 verification_contract_version is null or (
  tenant_id is not null and representation_artifact_id is not null and selector_sha256 is not null
  and selected_size_bytes is not null and normalization_policy is not null and resolution_version is not null
  and resolution_state is not null and occurrence_count is not null
  and ((resolution_state='resolved' and occurrence_count=1)
    or (resolution_state='ambiguous' and occurrence_count>1)
    or (resolution_state in('not_found','invalid','parse_error') and occurrence_count=0))
  )
);

alter table evidence.extraction_signature
 add column if not exists verification_contract_version text,
 alter column tenant_id drop not null,
 alter column tenant_id drop default;
alter table evidence.extraction_signature drop constraint if exists extraction_signature_verification_tenant_ck;
alter table evidence.extraction_signature add constraint extraction_signature_verification_contract_version_ck
 check(verification_contract_version is null or verification_contract_version='verification.v1');
alter table evidence.extraction_signature add constraint extraction_signature_verification_tenant_ck
 check(verification_contract_version is null or tenant_id is not null);

alter table evidence.claim_evidence_link
 add column if not exists verification_contract_version text,
 alter column tenant_id drop not null,
 alter column tenant_id drop default;
alter table evidence.claim_evidence_link drop constraint if exists claim_evidence_link_verification_tenant_ck;
alter table evidence.claim_evidence_link add constraint claim_evidence_link_verification_contract_version_ck
 check(verification_contract_version is null or verification_contract_version='verification.v1');
alter table evidence.claim_evidence_link add constraint claim_evidence_link_verification_tenant_ck
 check(verification_contract_version is null or tenant_id is not null);

alter table evidence.verification_run
 alter column tenant_id drop not null,
 alter column tenant_id drop default,
 alter column producer_attempt_id drop not null,
 alter column contract_version drop not null,
 alter column contract_version drop default,
 alter column bundle_artifact_id drop not null,
 alter column deterministic_result_artifact_id drop not null,
 alter column policy_artifact_id drop not null,
 alter column policy_artifact_sha256 drop not null,
 alter column run_manifest_artifact_id drop not null,
 alter column manifest_sha256 drop not null,
 alter column status drop not null,
 alter column status drop default,
 drop constraint verification_run_attempts_distinct_ck,
 drop constraint verification_run_terminal_ck;
alter table evidence.verification_run add constraint verification_run_attempts_distinct_ck
 check(contract_version is null or producer_attempt_id<>verifier_attempt_id);
alter table evidence.verification_run add constraint verification_run_terminal_ck check(
 contract_version is null or (
  tenant_id is not null and producer_attempt_id is not null and bundle_artifact_id is not null
  and deterministic_result_artifact_id is not null and policy_artifact_id is not null
  and policy_artifact_sha256 is not null and run_manifest_artifact_id is not null and manifest_sha256 is not null
  and status is not null
  and ((status='running' and ended_at is null)
    or (status<>'running' and ended_at is not null and ended_at>=started_at))
 )
);

alter table evidence.verification_finding
 add column if not exists verification_contract_version text,
 alter column tenant_id drop not null,
 alter column tenant_id drop default,
 alter column judge_kind drop not null,
 alter column judge_kind drop default,
 alter column grader_version drop not null,
 alter column grader_version drop default,
 alter column output_schema_sha256 drop not null,
 alter column output_schema_sha256 drop default,
 alter column blinded_input_artifact_sha256 drop not null,
 alter column blinded_input_artifact_sha256 drop default,
 alter column properties drop not null,
 alter column properties drop default,
 alter column supporting_fragment_ids drop not null,
 alter column supporting_fragment_ids drop default,
 alter column contradicting_fragment_ids drop not null,
 alter column contradicting_fragment_ids drop default,
 alter column unsupported_facets drop not null,
 alter column unsupported_facets drop default,
 alter column public_rationale drop not null,
 alter column public_rationale drop default,
 alter column latency_ms drop not null,
 alter column latency_ms drop default,
 alter column retries drop not null,
 alter column retries drop default;
alter table evidence.verification_finding drop constraint if exists verification_finding_v1_fields_ck;
alter table evidence.verification_finding add constraint verification_finding_verification_contract_version_ck
 check(verification_contract_version is null or verification_contract_version='verification.v1');
alter table evidence.verification_finding add constraint verification_finding_v1_fields_ck check(
 verification_contract_version is null or
 (tenant_id is not null and judge_kind is not null and grader_version is not null
  and output_schema_sha256 is not null and blinded_input_artifact_sha256 is not null
  and properties is not null and supporting_fragment_ids is not null and contradicting_fragment_ids is not null
  and unsupported_facets is not null and public_rationale is not null and latency_ms is not null and retries is not null)
);

alter table evidence.claim_evidence_assessment
 add column if not exists verification_contract_version text,
 alter column tenant_id drop not null,
 alter column tenant_id drop default,
 alter column properties drop not null,
 alter column properties drop default,
 alter column public_rationale drop not null,
 alter column public_rationale drop default;
alter table evidence.claim_evidence_assessment drop constraint if exists claim_evidence_assessment_v1_fields_ck;
alter table evidence.claim_evidence_assessment add constraint claim_evidence_assessment_verification_contract_version_ck
 check(verification_contract_version is null or verification_contract_version='verification.v1');
alter table evidence.claim_evidence_assessment add constraint claim_evidence_assessment_v1_fields_ck
 check(verification_contract_version is null or (tenant_id is not null and properties is not null and public_rationale is not null));

create or replace function evidence.validate_verification_run() returns trigger
language plpgsql set search_path='' as $$
declare producer_deployment text; verifier_deployment text; item_mission uuid;
begin
 if new.contract_version is distinct from 'verification.v1' then return new; end if;
 select agent_deployment_id into producer_deployment from orchestration.attempt
  where tenant_id=new.tenant_id and id=new.producer_attempt_id;
 select agent_deployment_id into verifier_deployment from orchestration.attempt
  where tenant_id=new.tenant_id and id=new.verifier_attempt_id;
 if producer_deployment is null or verifier_deployment is null or producer_deployment=verifier_deployment then
  raise exception 'producer and verifier deployments must be present and distinct' using errcode='restrict_violation';
 end if;
 if new.work_item_id is not null then
  select mission_id into item_mission from orchestration.work_item where tenant_id=new.tenant_id and id=new.work_item_id;
  if item_mission is null or (new.mission_id is not null and new.mission_id<>item_mission) then
   raise exception 'verification mission/work-item lineage mismatch' using errcode='foreign_key_violation';
  end if;
 end if;
 if not exists(select 1 from orchestration.artifact where tenant_id=new.tenant_id and id=new.policy_artifact_id
   and sha256=new.policy_artifact_sha256 and artifact_type='verification_policy' and storage_state='available') then
  raise exception 'verification policy artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if not exists(select 1 from orchestration.artifact where tenant_id=new.tenant_id and id=new.run_manifest_artifact_id
   and sha256=new.manifest_sha256 and artifact_type='verification_run_manifest' and storage_state='available') then
  raise exception 'verification manifest artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if not exists(select 1 from orchestration.artifact where tenant_id=new.tenant_id and id=new.bundle_artifact_id
   and artifact_type='verification_bundle' and storage_state='available')
  or not exists(select 1 from orchestration.artifact where tenant_id=new.tenant_id and id=new.deterministic_result_artifact_id
   and artifact_type='deterministic_verification_result' and storage_state='available') then
  raise exception 'verification bundle/result artifact registration missing' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;

create or replace function evidence.enforce_verification_run_lifecycle() returns trigger
language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'verification runs are append-only' using errcode='restrict_violation'; end if;
 if old.contract_version is distinct from 'verification.v1' then
  if (to_jsonb(new)-'ended_at') is not distinct from (to_jsonb(old)-'ended_at')
    and old.ended_at is null and new.ended_at is not null
    and new.ended_at>=new.started_at then return new; end if;
  raise exception 'legacy verification run permits only ended_at finalization' using errcode='restrict_violation';
 end if;
 if (to_jsonb(new)-array['status','ended_at']) is distinct from (to_jsonb(old)-array['status','ended_at'])
  or old.status<>'running' or new.status='running' or old.ended_at is not null
  or new.ended_at is null or new.ended_at<new.started_at then
  raise exception 'verification run permits one terminal status transition' using errcode='restrict_violation';
 end if;
 return new;
end $$;

create or replace function evidence.validate_locator_capture_lineage() returns trigger
language plpgsql set search_path='' as $$
declare capture_artifact uuid;
begin
 if new.verification_contract_version is distinct from 'verification.v1' then return new; end if;
 select artifact_id into capture_artifact from evidence.source_capture
  where tenant_id=new.tenant_id and id=new.capture_id;
 if capture_artifact is null then raise exception 'locator capture is not registered for tenant' using errcode='foreign_key_violation'; end if;
 if new.representation_artifact_id<>capture_artifact and not exists(
  select 1 from orchestration.artifact_lineage l
   where l.tenant_id=new.tenant_id and l.from_artifact_id=new.representation_artifact_id
    and l.to_artifact_id=capture_artifact and l.relation_kind in('derived_from','generated')
    and l.transformation_signature is not null
 ) then
  raise exception 'locator representation must descend from its capture artifact' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger locator_capture_lineage before insert on evidence.locator
 for each row execute function evidence.validate_locator_capture_lineage();

alter table evaluation.eval_score enable row level security;
drop policy if exists bounded_role_access on evaluation.eval_score;
create policy bounded_role_access on evaluation.eval_score for all
 to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader
 using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());

commit;
