-- Tighten durable benchmark validation without rewriting applied lifecycle DDL.
begin;
create or replace function evaluation.validate_verification_benchmark_run() returns trigger
language plpgsql set search_path='' as $$
declare operation_request jsonb;
begin
 if jsonb_typeof(new.checkpoint_plan) is distinct from 'array' or jsonb_array_length(new.checkpoint_plan) is distinct from new.expected_checkpoint_count then raise exception 'benchmark checkpoint plan shape mismatch' using errcode='check_violation'; end if;
 if exists(select 1 from jsonb_array_elements(new.checkpoint_plan) item where jsonb_typeof(item) is distinct from 'object' or item->>'checkpointContextDigest' !~ '^sha256:[0-9a-f]{64}$' or nullif(item->>'caseId','') is null or nullif(item->>'armId','') is null or coalesce(item->>'repetition','') !~ '^[0-9]+$') then raise exception 'benchmark checkpoint plan entry invalid' using errcode='check_violation'; end if;
 if (select count(*) from jsonb_array_elements(new.checkpoint_plan))<>(select count(distinct item->>'checkpointContextDigest') from jsonb_array_elements(new.checkpoint_plan) item) then raise exception 'benchmark checkpoint plan duplicate key' using errcode='unique_violation'; end if;
 select request into operation_request from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id;
 if operation_request is null or operation_request->>'kind' is distinct from 'verification_benchmark' or operation_request #>> '{input,useCase}' is distinct from 'runBenchmark' or operation_request #>> '{input,request,executionMode}' is distinct from 'offline_recorded' or operation_request #>> '{input,request,dataset,artifactId}' is distinct from new.dataset_artifact_id::text or operation_request #>> '{input,request,dataset,digest}' is distinct from 'sha256:'||new.dataset_sha256 or operation_request #>> '{input,request,experimentDefinition,artifactId}' is distinct from new.experiment_artifact_id::text or operation_request #>> '{input,request,experimentDefinition,digest}' is distinct from 'sha256:'||new.experiment_sha256 then raise exception 'benchmark operation admitted input binding mismatch' using errcode='foreign_key_violation'; end if;
 if not exists(select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=new.dataset_artifact_id and a.sha256=new.dataset_sha256 and a.storage_state='available' and a.artifact_type='evaluation_dataset_manifest') then raise exception 'benchmark dataset artifact binding mismatch' using errcode='foreign_key_violation'; end if;
 if not exists(select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=new.experiment_artifact_id and a.sha256=new.experiment_sha256 and a.storage_state='available' and a.artifact_type='verification_benchmark_experiment') then raise exception 'benchmark experiment artifact binding mismatch' using errcode='foreign_key_violation'; end if;
 if new.run_manifest_artifact_id is not null and not exists(select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=new.run_manifest_artifact_id and a.sha256=new.run_manifest_sha256 and a.storage_state='available' and a.artifact_type='verification_benchmark_run_manifest') then raise exception 'benchmark run manifest artifact binding mismatch' using errcode='foreign_key_violation'; end if;
 return new;
end $$;
commit;
