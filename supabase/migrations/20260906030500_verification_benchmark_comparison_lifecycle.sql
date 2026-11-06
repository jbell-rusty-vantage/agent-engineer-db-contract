begin;

create table evaluation.verification_benchmark_comparison (
 id uuid primary key default util.uuidv7(),
 tenant_id uuid not null default util.default_tenant_id(),
 operation_id uuid not null,
 baseline_run_id uuid not null,
 candidate_run_id uuid not null check(candidate_run_id<>baseline_run_id),
 baseline_publication_artifact_id uuid not null,
 baseline_publication_sha256 text not null check(baseline_publication_sha256 ~ '^[0-9a-f]{64}$'),
 baseline_payload_sha256 text not null check(baseline_payload_sha256 ~ '^[0-9a-f]{64}$'),
 candidate_publication_artifact_id uuid not null check(candidate_publication_artifact_id<>baseline_publication_artifact_id),
 candidate_publication_sha256 text not null check(candidate_publication_sha256 ~ '^[0-9a-f]{64}$'),
 candidate_payload_sha256 text not null check(candidate_payload_sha256 ~ '^[0-9a-f]{64}$'),
 profile_id text not null check(profile_id in('paired_default','regression_gate')),
 profile_artifact_id uuid not null,
 profile_sha256 text not null check(profile_sha256 ~ '^[0-9a-f]{64}$'),
 runtime jsonb not null check(jsonb_typeof(runtime)='object' and octet_length(runtime::text)<=131072),
 runtime_sha256 text not null check(runtime_sha256 ~ '^[0-9a-f]{64}$'),
 status text not null default 'running' check(status in('running','completed','sealed')),
 started_at timestamptz not null default clock_timestamp(),
 completed_at timestamptz,
 result_artifact_id uuid,
 result_sha256 text check(result_sha256 ~ '^[0-9a-f]{64}$'),
 result_digest_sha256 text check(result_digest_sha256 ~ '^[0-9a-f]{64}$'),
 engineering_gate_outcome text check(engineering_gate_outcome in('not_requested','pass','fail')),
 publication_artifact_id uuid,
 publication_sha256 text check(publication_sha256 ~ '^[0-9a-f]{64}$'),
 publication_payload_sha256 text check(publication_payload_sha256 ~ '^[0-9a-f]{64}$'),
 unique(tenant_id,id),
 unique(tenant_id,operation_id),
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
 foreign key(tenant_id,baseline_run_id) references evaluation.verification_benchmark_run(tenant_id,id) on delete restrict,
 foreign key(tenant_id,candidate_run_id) references evaluation.verification_benchmark_run(tenant_id,id) on delete restrict,
 foreign key(tenant_id,baseline_publication_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,candidate_publication_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,profile_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,result_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,publication_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 check (
  (status='running' and completed_at is null and result_artifact_id is null and result_sha256 is null and result_digest_sha256 is null and engineering_gate_outcome is null and publication_artifact_id is null and publication_sha256 is null and publication_payload_sha256 is null)
  or (status='completed' and completed_at>=started_at and result_artifact_id is not null and result_sha256 is not null and result_digest_sha256 is not null and engineering_gate_outcome is not null and publication_artifact_id is null and publication_sha256 is null and publication_payload_sha256 is null)
  or (status='sealed' and completed_at>=started_at and result_artifact_id is not null and result_sha256 is not null and result_digest_sha256 is not null and engineering_gate_outcome is not null and publication_artifact_id is not null and publication_sha256 is not null and publication_payload_sha256 is not null)
 )
);

create function evaluation.validate_verification_benchmark_comparison() returns trigger
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
 if new.status='sealed' and not orchestration.verification_artifact_is_admitted(new.tenant_id,new.publication_artifact_id,'verification_run_manifest',new.publication_sha256) then
  raise exception 'benchmark comparison publication artifact binding mismatch' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_benchmark_comparison_validate before insert or update on evaluation.verification_benchmark_comparison
 for each row execute function evaluation.validate_verification_benchmark_comparison();

create function evaluation.enforce_verification_benchmark_comparison_lifecycle() returns trigger
language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'benchmark comparisons are append-only' using errcode='restrict_violation'; end if;
 if old.status='running' and new.status='completed'
  and (to_jsonb(new)-array['status','completed_at','result_artifact_id','result_sha256','result_digest_sha256','engineering_gate_outcome'])=(to_jsonb(old)-array['status','completed_at','result_artifact_id','result_sha256','result_digest_sha256','engineering_gate_outcome']) then return new; end if;
 if old.status='completed' and new.status='sealed'
  and (to_jsonb(new)-array['status','publication_artifact_id','publication_sha256','publication_payload_sha256'])=(to_jsonb(old)-array['status','publication_artifact_id','publication_sha256','publication_payload_sha256']) then return new; end if;
 raise exception 'benchmark comparison permits only complete then seal transitions' using errcode='restrict_violation';
end $$;
create trigger verification_benchmark_comparison_immutable before update or delete on evaluation.verification_benchmark_comparison
 for each row execute function evaluation.enforce_verification_benchmark_comparison_lifecycle();

alter table evaluation.verification_benchmark_comparison enable row level security;
create policy bounded_role_access on evaluation.verification_benchmark_comparison for all to control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert,update on evaluation.verification_benchmark_comparison to control_plane;
commit;
