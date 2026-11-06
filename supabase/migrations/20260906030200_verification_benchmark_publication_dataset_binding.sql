-- The evaluation dataset version must be the exact registered dataset artifact
-- already admitted by the durable benchmark run, not merely a same-tenant version.
begin;

create or replace function evaluation.validate_verification_benchmark_arm_publication() returns trigger
language plpgsql set search_path='' as $$
declare benchmark evaluation.verification_benchmark_run%rowtype; operation knowledge_service.operation%rowtype;
begin
 select * into benchmark from evaluation.verification_benchmark_run where tenant_id=new.tenant_id and id=new.benchmark_run_id;
 if benchmark.id is null or benchmark.status<>'sealed' or benchmark.operation_id<>new.operation_id then raise exception 'benchmark arm publication requires its exact sealed benchmark operation' using errcode='foreign_key_violation'; end if;
 select * into operation from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id;
 if operation.id is null then raise exception 'benchmark arm publication operation missing' using errcode='foreign_key_violation'; end if;
 if not exists(select 1 from jsonb_array_elements(benchmark.checkpoint_plan) item where item->>'armId'=new.benchmark_arm_id) then raise exception 'benchmark arm publication is outside the persisted checkpoint plan' using errcode='foreign_key_violation'; end if;
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.publication_manifest_artifact_id,'verification_run_manifest',new.publication_manifest_sha256)
  or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.configuration_artifact_id,'evaluation_arm_manifest',new.configuration_sha256)
  or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.policy_artifact_id,'verification_policy',new.policy_sha256) then raise exception 'benchmark arm publication artifact binding mismatch' using errcode='foreign_key_violation'; end if;
 if not exists(
  select 1 from evaluation.eval_run r
  join evaluation.experiment_arm arm on arm.tenant_id=r.tenant_id and arm.id=r.experiment_arm_id
  join evaluation.experiment experiment on experiment.tenant_id=arm.tenant_id and experiment.id=arm.experiment_id
  join evaluation.eval_dataset_version version on version.tenant_id=experiment.tenant_id and version.id=experiment.dataset_version_id
  where r.tenant_id=new.tenant_id and r.id=new.eval_run_id and r.verification_contract_version='verification.v1'
   and r.dataset_id=version.dataset_id and r.dataset_version_id=version.id and r.experiment_arm_id=new.experiment_arm_id
   and version.contract_version='verification.v1' and version.manifest_artifact_id=benchmark.dataset_artifact_id and version.manifest_sha256=benchmark.dataset_sha256
   and arm.configuration_artifact_id=new.configuration_artifact_id and arm.configuration_sha256=new.configuration_sha256 and arm.configuration->>'armId'=new.benchmark_arm_id
   and r.run_manifest_artifact_id=new.publication_manifest_artifact_id and r.policy_artifact_id=new.policy_artifact_id
   and r.target_code_ref=new.target_code_ref and r.target_kind='code_ref' and r.status=new.terminal_status
   and r.mission_id is not distinct from operation.mission_id and r.work_item_id is not distinct from operation.work_item_id and r.attempt_id is not distinct from operation.attempt_id
   and r.started_at=benchmark.started_at and r.ended_at=benchmark.completed_at
 ) then raise exception 'benchmark arm publication eval run binding mismatch' using errcode='foreign_key_violation'; end if;
 return new;
end $$;
commit;
