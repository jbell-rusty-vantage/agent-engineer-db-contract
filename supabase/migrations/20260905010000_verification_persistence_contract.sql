-- Knowledge Verification v1: tenant-safe provenance, immutable manifests,
-- append-only judgments, evaluation freezes, and private CAS storage.
begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_bundle','Canonical verification input bundle'),
 ('deterministic_verification_result','Deterministic verification result'),
 ('verification_run_manifest','Sealed public verification run manifest'),
 ('verification_signature','Detached verification manifest signature'),
 ('verification_policy','Versioned verification admission policy'),
 ('verification_policy_decision','Replayable verification policy decision'),
 ('evaluation_case_input','Frozen evaluation case input manifest'),
 ('evaluation_gold_label','Frozen evaluation gold label'),
 ('evaluation_arm_manifest','Frozen evaluation variant manifest'),
 ('grader_manifest','Frozen grader definition manifest')
on conflict(code) do update set description=excluded.description;

insert into evidence.claim_type(code,description) values
 ('temporal','A time-bounded or ordered assertion'),
 ('causal','A causal assertion'),
 ('comparative','A comparison between explicit subjects'),
 ('methodological','An assertion about a method or procedure'),
 ('other','A typed assertion outside the currently enumerated families')
on conflict(code) do update set description=excluded.description;

-- Verification artifact identity is tenant-scoped. Legacy parallel-source records
-- may legitimately share digest/type while retaining distinct custody identities.
alter table orchestration.artifact drop constraint if exists artifact_sha256_artifact_type_key;
alter table orchestration.mission add constraint mission_tenant_id_uq unique(tenant_id,id);
-- Legacy shared-bucket rows keep their original identities. Verification writers
-- must opt into the immutable marker; metadata admission enforces it independently.
alter table orchestration.artifact add column verification_contract_version text
 check(verification_contract_version is null or verification_contract_version='verification.v1');
create unique index artifact_verification_tenant_digest_type_uq
 on orchestration.artifact(tenant_id,sha256,artifact_type)
 where verification_contract_version='verification.v1';
alter table orchestration.artifact add constraint verification_bucket_cas_path_ck check(
 verification_contract_version is null
 or (storage_bucket='ai-engineer-cloud-bucket'
     and object_path ~ ('^'||tenant_id::text||'/[0-9a-f]{2}/[0-9a-f]{64}$')
     and split_part(object_path,'/',2)=left(sha256,2)
     and split_part(object_path,'/',3)=sha256
     and media_type is not null and btrim(media_type)<>''
     and size_bytes is not null and size_bytes>=0)
);

alter table orchestration.artifact_lineage
 drop constraint artifact_lineage_relation_kind_check,
 add constraint artifact_lineage_relation_kind_check check(relation_kind in(
  'derived_from','supersedes','corrects','produced_by','consumed_by',
  'used','generated','quoted_from','revision_of','primary_source_for'
 )),
 add column activity_id text,
 add column activity_version text,
 add column transformation_signature text check(
  transformation_signature is null or transformation_signature ~ '^[0-9a-f]{64}$'
 );
alter table orchestration.artifact_lineage add constraint artifact_lineage_activity_ck check(
 relation_kind not in('derived_from','generated','quoted_from')
 or (relation_kind='derived_from' and transformation_run_id is not null)
 or (activity_id is not null and btrim(activity_id)<>'' and activity_version is not null
     and btrim(activity_version)<>'' and transformation_signature is not null)
);

-- Refuse ambiguous legacy ownership before composite foreign keys are added.
-- Operators can repair the named rows in place and rerun; no row is deleted or
-- assigned to a tenant by inference.
do $$
begin
 if exists(
  select 1 from evidence.source_capture c left join evidence.source s on s.id=c.source_id
   left join orchestration.artifact a on a.id=c.artifact_id
   where s.id is null or a.id is null or c.tenant_id<>s.tenant_id or c.tenant_id<>a.tenant_id
 ) then raise exception 'verification migration preflight: source_capture has missing or cross-tenant source/artifact ownership'
  using hint='Repair evidence.source_capture tenant_id/source_id/artifact_id ownership before applying 20260905010000.'; end if;
 if exists(
  select 1 from evidence.source_capture c join orchestration.attempt a on a.id=c.produced_by_attempt_id
   where c.produced_by_attempt_id is not null and c.tenant_id<>a.tenant_id
 ) then raise exception 'verification migration preflight: source_capture producer attempt crosses tenant ownership'
  using hint='Repair produced_by_attempt_id ownership before applying 20260905010000.'; end if;
 if exists(
  select 1 from evidence.claim c join orchestration.attempt a on a.id=c.producer_attempt_id
   where c.producer_attempt_id is not null and c.tenant_id<>a.tenant_id
 ) then raise exception 'verification migration preflight: claim producer attempt crosses tenant ownership'
  using hint='Repair producer_attempt_id ownership before applying 20260905010000.'; end if;
end $$;

-- Close the tenant gaps in the original evidence schema.
alter table evidence.source_capture
 add constraint source_capture_tenant_source_fk foreign key(tenant_id,source_id)
  references evidence.source(tenant_id,id) on delete restrict,
 add constraint source_capture_tenant_artifact_fk foreign key(tenant_id,artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint source_capture_tenant_attempt_fk foreign key(tenant_id,produced_by_attempt_id)
  references orchestration.attempt(tenant_id,id) on delete restrict;

alter table evidence.locator
 add column tenant_id uuid,
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column representation_artifact_id uuid,
 add column selector_sha256 text check(selector_sha256 is null or selector_sha256 ~ '^[0-9a-f]{64}$'),
 add column selected_size_bytes bigint check(selected_size_bytes is null or selected_size_bytes>=0),
 add column occurrence_count integer check(occurrence_count is null or occurrence_count>=0),
 add column resolution_state text check(resolution_state is null or resolution_state in('resolved','not_found','ambiguous','invalid','parse_error')),
 add column normalization_policy text,
 add column resolution_version text,
 add constraint locator_tenant_id_uq unique(tenant_id,id),
 add constraint locator_tenant_capture_fk foreign key(tenant_id,capture_id)
  references evidence.source_capture(tenant_id,id) on delete restrict,
 add constraint locator_tenant_representation_artifact_fk foreign key(tenant_id,representation_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint locator_resolution_cardinality_ck check(verification_contract_version is null or (
  tenant_id is not null and representation_artifact_id is not null and selector_sha256 is not null
  and selected_size_bytes is not null and normalization_policy is not null and resolution_version is not null
  and resolution_state is not null and occurrence_count is not null
  and ((resolution_state='resolved' and occurrence_count=1)
    or (resolution_state='ambiguous' and occurrence_count>1)
    or (resolution_state in('not_found','invalid','parse_error') and occurrence_count=0))
  )
 );

alter table evidence.extraction_signature
 add column tenant_id uuid,
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add constraint extraction_signature_tenant_id_uq unique(tenant_id,id),
 add constraint extraction_signature_tenant_locator_fk foreign key(tenant_id,locator_id)
  references evidence.locator(tenant_id,id) on delete restrict,
 add constraint extraction_signature_tenant_attempt_fk foreign key(tenant_id,produced_by_attempt_id)
  references orchestration.attempt(tenant_id,id) on delete restrict,
 add constraint extraction_signature_verification_tenant_ck check(verification_contract_version is null or tenant_id is not null);

alter table evidence.claim
 add constraint claim_tenant_attempt_fk foreign key(tenant_id,producer_attempt_id)
  references orchestration.attempt(tenant_id,id) on delete restrict,
 add constraint claim_tenant_atomized_from_fk foreign key(tenant_id,atomized_from_id)
  references evidence.claim(tenant_id,id) on delete restrict,
 add constraint claim_tenant_superseded_by_fk foreign key(tenant_id,superseded_by_id)
  references evidence.claim(tenant_id,id) on delete restrict;

alter table evidence.claim_evidence_link
 add column tenant_id uuid,
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add constraint claim_evidence_link_tenant_id_uq unique(tenant_id,id),
 add constraint claim_evidence_link_tenant_claim_fk foreign key(tenant_id,claim_id)
  references evidence.claim(tenant_id,id) on delete restrict,
 add constraint claim_evidence_link_tenant_locator_fk foreign key(tenant_id,locator_id)
  references evidence.locator(tenant_id,id) on delete restrict,
 add constraint claim_evidence_link_verification_tenant_ck check(verification_contract_version is null or tenant_id is not null);

alter table evidence.verification_run
 add column tenant_id uuid,
 add column producer_attempt_id uuid,
 add column mission_id uuid,
 add column operation_id uuid,
 add column contract_version text check(contract_version is null or contract_version='verification.v1'),
 add column bundle_artifact_id uuid,
 add column deterministic_result_artifact_id uuid,
 add column policy_artifact_id uuid,
 add column policy_artifact_sha256 text check(policy_artifact_sha256 is null or policy_artifact_sha256 ~ '^[0-9a-f]{64}$'),
 add column run_manifest_artifact_id uuid,
 add column manifest_sha256 text check(manifest_sha256 is null or manifest_sha256 ~ '^[0-9a-f]{64}$'),
 add column status text check(status is null or status in('running','succeeded','failed','review','abstained','cancelled')),
 add constraint verification_run_tenant_id_uq unique(tenant_id,id),
 add constraint verification_run_tenant_work_item_fk foreign key(tenant_id,work_item_id)
  references orchestration.work_item(tenant_id,id) on delete restrict,
 add constraint verification_run_tenant_producer_attempt_fk foreign key(tenant_id,producer_attempt_id)
  references orchestration.attempt(tenant_id,id) on delete restrict,
 add constraint verification_run_tenant_verifier_attempt_fk foreign key(tenant_id,verifier_attempt_id)
  references orchestration.attempt(tenant_id,id) on delete restrict,
 add constraint verification_run_tenant_mission_fk foreign key(tenant_id,mission_id)
  references orchestration.mission(tenant_id,id) on delete restrict,
 add constraint verification_run_tenant_operation_fk foreign key(tenant_id,operation_id)
  references knowledge_service.operation(tenant_id,id) on delete restrict,
 add constraint verification_run_bundle_artifact_fk foreign key(tenant_id,bundle_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint verification_run_result_artifact_fk foreign key(tenant_id,deterministic_result_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint verification_run_policy_artifact_fk foreign key(tenant_id,policy_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint verification_run_manifest_artifact_fk foreign key(tenant_id,run_manifest_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint verification_run_attempts_distinct_ck check(contract_version is null or producer_attempt_id<>verifier_attempt_id),
 add constraint verification_run_terminal_ck check(contract_version is null or (
  tenant_id is not null and producer_attempt_id is not null and bundle_artifact_id is not null
  and deterministic_result_artifact_id is not null and policy_artifact_id is not null
  and policy_artifact_sha256 is not null and run_manifest_artifact_id is not null and manifest_sha256 is not null
  and status is not null
  and ((status='running' and ended_at is null) or (status<>'running' and ended_at is not null and ended_at>=started_at))
  )
 );

alter table evidence.verification_finding
 add column tenant_id uuid,
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column judge_kind text
  check(judge_kind in('deterministic','nli','llm','human','policy','statistical')),
 add column grader_version text,
 add column output_schema_sha256 text check(output_schema_sha256 is null or output_schema_sha256 ~ '^[0-9a-f]{64}$'),
 add column blinded_input_artifact_sha256 text check(blinded_input_artifact_sha256 is null or blinded_input_artifact_sha256 ~ '^[0-9a-f]{64}$'),
 add column properties jsonb,
 add column supporting_fragment_ids text[],
 add column contradicting_fragment_ids text[],
 add column unsupported_facets text[],
 add column public_rationale text,
 add column calibrated_probability numeric(6,5) check(calibrated_probability between 0 and 1),
 add column latency_ms bigint check(latency_ms is null or latency_ms>=0),
 add column token_usage bigint check(token_usage is null or token_usage>=0),
 add column cost_micros bigint check(cost_micros is null or cost_micros>=0),
 add column retries integer check(retries is null or retries>=0),
 add column provider_response_id text,
 add column failure_category text,
 add constraint verification_finding_tenant_id_uq unique(tenant_id,id),
 add constraint verification_finding_tenant_run_fk foreign key(tenant_id,run_id)
  references evidence.verification_run(tenant_id,id) on delete restrict,
 add constraint verification_finding_tenant_claim_fk foreign key(tenant_id,claim_id)
  references evidence.claim(tenant_id,id) on delete restrict,
 add constraint verification_finding_v1_fields_ck check(verification_contract_version is null or
  (tenant_id is not null and judge_kind is not null and grader_version is not null
   and output_schema_sha256 is not null and blinded_input_artifact_sha256 is not null
   and properties is not null and supporting_fragment_ids is not null and contradicting_fragment_ids is not null
   and unsupported_facets is not null and public_rationale is not null and latency_ms is not null and retries is not null));

alter table evidence.claim_evidence_assessment
 add column tenant_id uuid,
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column properties jsonb,
 add column public_rationale text,
 add constraint claim_evidence_assessment_tenant_id_uq unique(tenant_id,id),
 add constraint claim_evidence_assessment_tenant_link_fk foreign key(tenant_id,claim_evidence_link_id)
  references evidence.claim_evidence_link(tenant_id,id) on delete restrict,
 add constraint claim_evidence_assessment_tenant_run_fk foreign key(tenant_id,run_id)
  references evidence.verification_run(tenant_id,id) on delete restrict,
 add constraint claim_evidence_assessment_v1_fields_ck check(verification_contract_version is null or
  (tenant_id is not null and properties is not null and public_rationale is not null));

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
  raise exception 'producer and verifier deployments must be present and distinct'
   using errcode='restrict_violation';
 end if;
 if new.work_item_id is not null then
  select mission_id into item_mission from orchestration.work_item
   where tenant_id=new.tenant_id and id=new.work_item_id;
  if item_mission is null or (new.mission_id is not null and new.mission_id<>item_mission) then
   raise exception 'verification mission/work-item lineage mismatch' using errcode='foreign_key_violation';
  end if;
 end if;
 if not exists(select 1 from orchestration.artifact where tenant_id=new.tenant_id
   and id=new.policy_artifact_id and sha256=new.policy_artifact_sha256 and artifact_type='verification_policy') then
  raise exception 'verification policy artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if not exists(select 1 from orchestration.artifact where tenant_id=new.tenant_id
   and id=new.run_manifest_artifact_id and sha256=new.manifest_sha256 and artifact_type='verification_run_manifest') then
  raise exception 'verification manifest artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if not exists(select 1 from orchestration.artifact where tenant_id=new.tenant_id
   and id=new.bundle_artifact_id and artifact_type='verification_bundle')
  or not exists(select 1 from orchestration.artifact where tenant_id=new.tenant_id
   and id=new.deterministic_result_artifact_id and artifact_type='deterministic_verification_result') then
  raise exception 'verification bundle/result artifact registration missing' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;

drop trigger verification_run_identity_immutable on evidence.verification_run;
create trigger verification_run_validate before insert on evidence.verification_run
 for each row execute function evidence.validate_verification_run();
create or replace function evidence.enforce_verification_run_lifecycle() returns trigger
language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'verification runs are append-only' using errcode='restrict_violation'; end if;
 if (to_jsonb(new)-array['status','ended_at']) is distinct from (to_jsonb(old)-array['status','ended_at'])
  or old.status<>'running' or new.status='running' or old.ended_at is not null
  or new.ended_at is null or new.ended_at<new.started_at then
  raise exception 'verification run permits one terminal status transition' using errcode='restrict_violation';
 end if;
 return new;
end $$;
create trigger verification_run_identity_immutable before update or delete on evidence.verification_run
 for each row execute function evidence.enforce_verification_run_lifecycle();

create or replace function evidence.validate_capture_artifact() returns trigger
language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id
   and a.id=new.artifact_id and a.sha256=new.content_sha256 and a.media_type=new.media_type
   and a.artifact_type='source_capture') then
  raise exception 'capture must bind a same-tenant registered source artifact with matching bytes'
   using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger source_capture_artifact_binding before insert on evidence.source_capture
 for each row execute function evidence.validate_capture_artifact();

-- Evaluation v1 rows opt into a strict, immutable artifact-backed contract.
alter table evaluation.eval_dataset_version
 add column contract_version text check(contract_version is null or contract_version='verification.v1'),
 add column manifest_artifact_id uuid,
 add column frozen_at timestamptz,
 add column label_provenance text check(label_provenance in('human_adjudicated','human_reviewed','synthetic','agent_generated')),
 add column case_count integer check(case_count is null or case_count>0),
 add constraint eval_dataset_version_manifest_artifact_fk foreign key(tenant_id,manifest_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint eval_dataset_version_verification_freeze_ck check(contract_version is null or
  (manifest_artifact_id is not null and frozen_at is not null and label_provenance is not null and case_count is not null));

alter table evaluation.eval_case
 add column dataset_version_id uuid,
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column input_manifest_artifact_id uuid,
 add column gold_artifact_id uuid,
 add column case_sha256 text check(case_sha256 is null or case_sha256 ~ '^[0-9a-f]{64}$'),
 add constraint eval_case_tenant_dataset_version_fk foreign key(tenant_id,dataset_version_id)
  references evaluation.eval_dataset_version(tenant_id,id) on delete restrict,
 add constraint eval_case_input_artifact_fk foreign key(tenant_id,input_manifest_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint eval_case_gold_artifact_fk foreign key(tenant_id,gold_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint eval_case_verification_freeze_ck check(verification_contract_version is null or
  (dataset_version_id is not null and input_manifest_artifact_id is not null and gold_artifact_id is not null and case_sha256 is not null));

alter table evaluation.eval_label
 add column tenant_id uuid,
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column label_artifact_id uuid,
 add column label_sha256 text check(label_sha256 is null or label_sha256 ~ '^[0-9a-f]{64}$'),
 add column provenance_class text check(provenance_class is null or provenance_class in('human_adjudicated','human_reviewed','synthetic','agent_generated')),
 add constraint eval_label_tenant_id_uq unique(tenant_id,id),
 add constraint eval_label_tenant_case_fk foreign key(tenant_id,case_id)
  references evaluation.eval_case(tenant_id,id) on delete restrict,
 add constraint eval_label_artifact_fk foreign key(tenant_id,label_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint eval_label_verification_freeze_ck check(verification_contract_version is null or
  (tenant_id is not null and label_artifact_id is not null and label_sha256 is not null and provenance_class is not null));

alter table evaluation.grader
 add column tenant_id uuid,
 drop constraint grader_slug_key,
 add constraint grader_tenant_slug_uq unique(tenant_id,slug),
 add constraint grader_tenant_id_uq unique(tenant_id,id);
alter table evaluation.grader_version
 add column tenant_id uuid,
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column manifest_artifact_id uuid,
 add column manifest_sha256 text check(manifest_sha256 is null or manifest_sha256 ~ '^[0-9a-f]{64}$'),
 add constraint grader_version_tenant_id_uq unique(tenant_id,id),
 add constraint grader_version_tenant_grader_fk foreign key(tenant_id,grader_id)
  references evaluation.grader(tenant_id,id) on delete restrict,
 add constraint grader_version_manifest_artifact_fk foreign key(tenant_id,manifest_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint grader_version_verification_freeze_ck check(verification_contract_version is null or
  (tenant_id is not null and manifest_artifact_id is not null and manifest_sha256 is not null));

alter table evaluation.experiment_arm
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column configuration_artifact_id uuid,
 add column configuration_sha256 text check(configuration_sha256 is null or configuration_sha256 ~ '^[0-9a-f]{64}$'),
 add constraint experiment_arm_configuration_artifact_fk foreign key(tenant_id,configuration_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint experiment_arm_verification_freeze_ck check(verification_contract_version is null or
  (configuration_artifact_id is not null and configuration_sha256 is not null));

alter table evaluation.eval_run
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column dataset_version_id uuid,
 add column experiment_arm_id uuid,
 add column mission_id uuid,
 add column work_item_id uuid,
 add column attempt_id uuid,
 add column run_manifest_artifact_id uuid,
 add column policy_artifact_id uuid,
 add column status text check(status is null or status in('running','succeeded','failed','review','abstained','cancelled')),
 add column started_at timestamptz,
 add column ended_at timestamptz,
 add constraint eval_run_dataset_version_fk foreign key(tenant_id,dataset_version_id)
  references evaluation.eval_dataset_version(tenant_id,id) on delete restrict,
 add constraint eval_run_experiment_arm_fk foreign key(tenant_id,experiment_arm_id)
  references evaluation.experiment_arm(tenant_id,id) on delete restrict,
 add constraint eval_run_mission_fk foreign key(tenant_id,mission_id)
  references orchestration.mission(tenant_id,id) on delete restrict,
 add constraint eval_run_work_item_fk foreign key(tenant_id,work_item_id)
  references orchestration.work_item(tenant_id,id) on delete restrict,
 add constraint eval_run_attempt_fk foreign key(tenant_id,attempt_id)
  references orchestration.attempt(tenant_id,id) on delete restrict,
 add constraint eval_run_manifest_artifact_fk foreign key(tenant_id,run_manifest_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint eval_run_policy_artifact_fk foreign key(tenant_id,policy_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint eval_run_verification_binding_ck check(verification_contract_version is null or
  (dataset_version_id is not null and experiment_arm_id is not null and attempt_id is not null
   and run_manifest_artifact_id is not null and policy_artifact_id is not null and status is not null
   and started_at is not null and ((status='running' and ended_at is null) or (status<>'running' and ended_at is not null))));

alter table evaluation.eval_score
 add column tenant_id uuid,
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column result_artifact_id uuid,
 add column result_sha256 text check(result_sha256 is null or result_sha256 ~ '^[0-9a-f]{64}$'),
 add constraint eval_score_tenant_run_fk foreign key(tenant_id,run_id)
  references evaluation.eval_run(tenant_id,id) on delete restrict,
 add constraint eval_score_tenant_case_fk foreign key(tenant_id,case_id)
  references evaluation.eval_case(tenant_id,id) on delete restrict,
 add constraint eval_score_result_artifact_fk foreign key(tenant_id,result_artifact_id)
  references orchestration.artifact(tenant_id,id) on delete restrict,
 add constraint eval_score_verification_binding_ck check(verification_contract_version is null or
  (tenant_id is not null and result_artifact_id is not null and result_sha256 is not null));

create or replace function evaluation.guard_verification_freeze() returns trigger
language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' and old.verification_contract_version='verification.v1' then
  raise exception 'frozen verification evaluation records are append-only' using errcode='restrict_violation';
 end if;
 if tg_op='UPDATE' and old.verification_contract_version='verification.v1' then
  raise exception 'frozen verification evaluation records are immutable' using errcode='restrict_violation';
 end if;
 return coalesce(new,old);
end $$;

create trigger eval_case_verification_freeze before update or delete on evaluation.eval_case
 for each row execute function evaluation.guard_verification_freeze();
create trigger eval_label_verification_freeze before update or delete on evaluation.eval_label
 for each row execute function evaluation.guard_verification_freeze();
create trigger grader_version_verification_freeze before update or delete on evaluation.grader_version
 for each row execute function evaluation.guard_verification_freeze();
create trigger experiment_arm_verification_freeze before update or delete on evaluation.experiment_arm
 for each row execute function evaluation.guard_verification_freeze();

-- Refresh tenant policies for tables that acquired tenant_id. Missing tenant
-- context remains fail-closed through util.current_tenant_id().
do $$ declare target text; parts text[]; begin
 foreach target in array array[
  'evidence.locator','evidence.extraction_signature','evidence.claim_evidence_link',
  'evidence.verification_run','evidence.verification_finding','evidence.claim_evidence_assessment',
  'evaluation.eval_label','evaluation.grader','evaluation.grader_version'
 ] loop
  parts:=string_to_array(target,'.');
  execute format('alter table %I.%I enable row level security',parts[1],parts[2]);
  execute format('drop policy if exists bounded_role_access on %I.%I',parts[1],parts[2]);
  execute format('create policy bounded_role_access on %I.%I for all to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id())',parts[1],parts[2]);
 end loop;
end $$;

grant select,insert on evidence.locator,evidence.extraction_signature,evidence.claim_evidence_link,
 evidence.verification_run,evidence.verification_finding,evidence.claim_evidence_assessment to verifier_agent;
grant select,insert on evaluation.eval_dataset_version,evaluation.eval_case,evaluation.eval_label,
 evaluation.grader,evaluation.grader_version,evaluation.experiment,evaluation.experiment_arm,
 evaluation.eval_run,evaluation.eval_run_case_output,evaluation.eval_score to control_plane;

-- One shared private verification bucket. Authenticated callers can only read or
-- create immutable CAS objects beneath their JWT tenant UUID prefix.
insert into storage.buckets(id,name,public,file_size_limit)
values('ai-engineer-cloud-bucket','ai-engineer-cloud-bucket',false,67108864)
on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit;

drop policy if exists ai_engineer_cloud_bucket_tenant_select on storage.objects;
drop policy if exists ai_engineer_cloud_bucket_tenant_insert on storage.objects;
create policy ai_engineer_cloud_bucket_tenant_select on storage.objects for select
 to authenticated using(
  bucket_id='ai-engineer-cloud-bucket'
  and (storage.foldername(name))[1]=coalesce(auth.jwt()->>'tenant_id','')
 );
create policy ai_engineer_cloud_bucket_tenant_insert on storage.objects for insert
 to authenticated with check(
  bucket_id='ai-engineer-cloud-bucket'
  and (storage.foldername(name))[1]=coalesce(auth.jwt()->>'tenant_id','')
  and name ~ ('^'||coalesce(auth.jwt()->>'tenant_id','')||'/[0-9a-f]{2}/[0-9a-f]{64}$')
 );

comment on table evidence.verification_run is
 'Artifact-backed verification.v1 run. Producer/verifier deployments are distinct and the run permits one terminal transition.';
comment on column evidence.verification_run.manifest_sha256 is
 'SHA-256 of the stored run-manifest artifact bytes. The inner signable manifest and detached seal payload use separate contract digests.';
comment on table evaluation.eval_dataset_version is
 'Immutable dataset version; verification.v1 rows require a frozen artifact-backed manifest and explicit label provenance.';

commit;
