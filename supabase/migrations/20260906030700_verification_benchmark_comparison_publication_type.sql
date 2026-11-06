begin;
insert into orchestration.artifact_type(code,description) values ('verification_benchmark_comparison_publication','Signed comparison publication with exact registered profile, inputs, result and durable lifecycle') on conflict(code) do update set description=excluded.description;
create or replace function evaluation.validate_verification_benchmark_comparison() returns trigger
language plpgsql set search_path='' as $$
declare operation knowledge_service.operation%rowtype; side record;
begin
 select * into operation from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id;
 if operation.id is null or operation.status is distinct from 'running' or operation.operation_kind is distinct from 'verification_benchmark_compare'
  or operation.request->>'kind' is distinct from 'verification_benchmark_compare'
  or operation.request #>> '{input,schemaVersion}' is distinct from 'verification-service-request.v1'
  or operation.request #>> '{input,useCase}' is distinct from 'compareBenchmarkRuns'
  or operation.request #>> '{input,request,verificationContractVersion}' is distinct from 'verification.v1'
  or operation.request #>> '{input,request,baselineRunId}' is distinct from new.baseline_run_id::text
  or operation.request #>> '{input,request,candidateRunId}' is distinct from new.candidate_run_id::text
  or operation.request #>> '{input,request,comparisonProfile}' is distinct from new.profile_id
  or operation.attempt_id is null or new.runtime->>'attemptId' is distinct from operation.attempt_id::text then
  raise exception 'benchmark comparison canonical operation binding mismatch' using errcode='foreign_key_violation';
 end if;
 if new.started_at<operation.created_at or new.started_at>clock_timestamp() or new.completed_at>clock_timestamp() then
  raise exception 'benchmark comparison lifecycle timestamp invalid' using errcode='check_violation';
 end if;
 if tg_op='INSERT' and new.status<>'running' then raise exception 'benchmark comparison must initialize running' using errcode='check_violation'; end if;
 for side in select * from (values
  (new.baseline_run_id,new.baseline_publication_artifact_id,new.baseline_publication_sha256,new.baseline_payload_sha256),
  (new.candidate_run_id,new.candidate_publication_artifact_id,new.candidate_publication_sha256,new.candidate_payload_sha256)
 ) as inputs(run_id,artifact_id,artifact_sha256,payload_sha256) loop
  if not exists(
   select 1 from evaluation.verification_benchmark_run benchmark
   join knowledge_service.operation producer on producer.tenant_id=benchmark.tenant_id and producer.id=benchmark.operation_id
   join knowledge_service.receipt receipt on receipt.tenant_id=producer.tenant_id and receipt.operation_id=producer.id
   join knowledge_service.operation_step step on step.tenant_id=receipt.tenant_id and step.id=receipt.step_id and step.operation_id=producer.id
   where benchmark.tenant_id=new.tenant_id and benchmark.id=side.run_id and benchmark.status='sealed'
    and producer.status='succeeded' and producer.operation_kind='verification_benchmark'
    and receipt.receipt_kind='replay_recorded_and_register.succeeded' and receipt.outcome='succeeded'
    and step.status='succeeded' and step.step_key='replay_recorded_and_register'
    and receipt.body->>'schemaVersion'='verification-operation-result.v1' and receipt.body->>'useCase'='runBenchmark'
    and receipt.body->>'operationId'=producer.id::text
    and receipt.body #>> '{output,benchmarkRunId}'=side.run_id::text
    and receipt.body #>> '{output,manifestDigest}'='sha256:'||side.payload_sha256
    and receipt.body #>> '{resultArtifact,artifactId}'=side.artifact_id::text
    and receipt.body #>> '{resultArtifact,digest}'='sha256:'||side.artifact_sha256
  ) or not exists(select 1 from evaluation.verification_benchmark_arm_publication p where p.tenant_id=new.tenant_id and p.benchmark_run_id=side.run_id and p.publication_manifest_artifact_id=side.artifact_id and p.publication_manifest_sha256=side.artifact_sha256)
   or exists(select 1 from evaluation.verification_benchmark_arm_publication p where p.tenant_id=new.tenant_id and p.benchmark_run_id=side.run_id and (p.publication_manifest_artifact_id<>side.artifact_id or p.publication_manifest_sha256<>side.artifact_sha256))
   or not orchestration.verification_artifact_is_admitted(new.tenant_id,side.artifact_id,'verification_run_manifest',side.artifact_sha256) then
   raise exception 'benchmark comparison requires exact completed input publications' using errcode='foreign_key_violation';
  end if;
 end loop;
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.profile_artifact_id,'verification_benchmark_comparison_profile',new.profile_sha256) then
  raise exception 'benchmark comparison profile artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 if new.status<>'running' and (not orchestration.verification_artifact_is_admitted(new.tenant_id,new.result_artifact_id,'verification_benchmark_comparison_result',new.result_sha256)
  or (new.profile_id='paired_default' and new.engineering_gate_outcome<>'not_requested')
  or (new.profile_id='regression_gate' and new.engineering_gate_outcome='not_requested')) then
  raise exception 'benchmark comparison result artifact or gate binding mismatch' using errcode='foreign_key_violation';
 end if;
 if new.status='sealed' and not orchestration.verification_artifact_is_admitted(new.tenant_id,new.publication_artifact_id,'verification_benchmark_comparison_publication',new.publication_sha256) then
  raise exception 'benchmark comparison publication artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
commit;
