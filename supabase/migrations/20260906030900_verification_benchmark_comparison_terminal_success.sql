begin;

-- completeStep changes the step first, appends its success event and receipt,
-- then reconciles the operation. These guards follow that order while making
-- the sealed comparison the required durable predecessor throughout.
create function evaluation.guard_verification_benchmark_comparison_step_success() returns trigger
language plpgsql set search_path='' as $$
declare operation_kind text;
begin
 select o.operation_kind into operation_kind from knowledge_service.operation o
  where o.tenant_id=new.tenant_id and o.id=new.operation_id;
 if operation_kind is distinct from 'verification_benchmark_compare' or new.status is distinct from 'succeeded' then return new; end if;
 if new.step_key is distinct from 'compare_registered_and_publish'
  or not exists(select 1 from evaluation.verification_benchmark_comparison comparison
   where comparison.tenant_id=new.tenant_id and comparison.operation_id=new.operation_id and comparison.status='sealed') then
  raise exception 'benchmark comparison step success requires sealed comparison' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_benchmark_comparison_step_success
 before insert or update on knowledge_service.operation_step for each row
 execute function evaluation.guard_verification_benchmark_comparison_step_success();

create function evaluation.guard_verification_benchmark_comparison_success_receipt() returns trigger
language plpgsql set search_path='' as $$
declare operation_kind text; comparison evaluation.verification_benchmark_comparison%rowtype;
begin
 select o.operation_kind into operation_kind from knowledge_service.operation o
  where o.tenant_id=new.tenant_id and o.id=new.operation_id;
 if operation_kind is distinct from 'verification_benchmark_compare' or new.outcome is distinct from 'succeeded' then return new; end if;
 select * into comparison from evaluation.verification_benchmark_comparison c
  where c.tenant_id=new.tenant_id and c.operation_id=new.operation_id and c.status='sealed';
 if comparison.id is null
  or new.receipt_kind is distinct from 'compare_registered_and_publish.succeeded'
  or new.step_id is null
  or new.output_sha256 is null
  or new.body->>'schemaVersion' is distinct from 'verification-operation-result.v1'
  or new.body->>'operationId' is distinct from new.operation_id::text
  or new.body->>'useCase' is distinct from 'compareBenchmarkRuns'
  or new.body #>> '{output,comparisonId}' is distinct from comparison.id::text
  or new.body #>> '{output,baselineRunId}' is distinct from comparison.baseline_run_id::text
  or new.body #>> '{output,candidateRunId}' is distinct from comparison.candidate_run_id::text
  or new.body #>> '{output,manifestDigest}' is distinct from 'sha256:'||comparison.publication_payload_sha256
  or new.body #>> '{output,resultDigest}' is distinct from 'sha256:'||comparison.result_digest_sha256
  or new.body #>> '{output,engineeringGateOutcome}' is distinct from comparison.engineering_gate_outcome
  or new.body #>> '{output,qualityClaims,humanGoldValidated}' is distinct from 'false'
  or new.body #>> '{output,qualityClaims,sourceAuthorityAssessed}' is distinct from 'false'
  or new.body #>> '{output,qualityClaims,calibrated}' is distinct from 'false'
  or new.body #>> '{resultArtifact,artifactId}' is distinct from comparison.publication_artifact_id::text
  or new.body #>> '{resultArtifact,digest}' is distinct from 'sha256:'||comparison.publication_sha256
  or coalesce(new.body->>'fencingToken','') !~ '^[1-9][0-9]*$'
  or coalesce(new.body->>'eventId','') !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
  or not exists(select 1 from knowledge_service.operation_step step
   where step.tenant_id=new.tenant_id and step.id=new.step_id and step.operation_id=new.operation_id
    and step.step_key='compare_registered_and_publish' and step.status='succeeded' and step.input_sha256=new.input_sha256)
  or not exists(select 1 from knowledge_service.operation_event event
   where event.tenant_id=new.tenant_id and event.id::text=new.body->>'eventId'
    and event.operation_id=new.operation_id and event.step_id=new.step_id
    and event.event_kind='step.succeeded' and event.to_state='succeeded'
    and event.guarded_sha256=new.output_sha256
    and event.payload->>'outputSha256'=new.output_sha256
    and event.payload->>'fencingToken'=new.body->>'fencingToken')
  or exists(select 1 from knowledge_service.receipt prior
   where prior.tenant_id=new.tenant_id and prior.operation_id=new.operation_id
    and prior.step_id=new.step_id and prior.outcome='succeeded') then
  raise exception 'benchmark comparison success receipt binding mismatch' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_benchmark_comparison_success_receipt
 before insert on knowledge_service.receipt for each row
 execute function evaluation.guard_verification_benchmark_comparison_success_receipt();

create function evaluation.guard_verification_benchmark_comparison_operation_success() returns trigger
language plpgsql set search_path='' as $$
declare matches bigint;
begin
 if new.operation_kind is distinct from 'verification_benchmark_compare' or new.status is distinct from 'succeeded' then return new; end if;
 select count(*) into matches
 from evaluation.verification_benchmark_comparison comparison
 join knowledge_service.operation_step step on step.tenant_id=comparison.tenant_id and step.operation_id=comparison.operation_id
 join knowledge_service.receipt receipt on receipt.tenant_id=step.tenant_id and receipt.operation_id=step.operation_id and receipt.step_id=step.id
 where comparison.tenant_id=new.tenant_id and comparison.operation_id=new.id and comparison.status='sealed'
  and step.step_key='compare_registered_and_publish' and step.status='succeeded'
  and receipt.receipt_kind='compare_registered_and_publish.succeeded' and receipt.outcome='succeeded'
  and receipt.body->>'schemaVersion'='verification-operation-result.v1'
  and receipt.body->>'operationId'=new.id::text and receipt.body->>'useCase'='compareBenchmarkRuns'
  and receipt.body #>> '{output,comparisonId}'=comparison.id::text
  and receipt.body #>> '{output,baselineRunId}'=comparison.baseline_run_id::text
  and receipt.body #>> '{output,candidateRunId}'=comparison.candidate_run_id::text
  and receipt.body #>> '{output,manifestDigest}'='sha256:'||comparison.publication_payload_sha256
  and receipt.body #>> '{output,resultDigest}'='sha256:'||comparison.result_digest_sha256
  and receipt.body #>> '{output,engineeringGateOutcome}'=comparison.engineering_gate_outcome
  and receipt.body #>> '{output,qualityClaims,humanGoldValidated}'='false'
  and receipt.body #>> '{output,qualityClaims,sourceAuthorityAssessed}'='false'
  and receipt.body #>> '{output,qualityClaims,calibrated}'='false'
  and receipt.body #>> '{resultArtifact,artifactId}'=comparison.publication_artifact_id::text
  and receipt.body #>> '{resultArtifact,digest}'='sha256:'||comparison.publication_sha256;
 if matches is distinct from 1 then
  raise exception 'benchmark comparison operation success requires one exact sealed receipt' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_benchmark_comparison_operation_success
 before insert or update on knowledge_service.operation for each row
 execute function evaluation.guard_verification_benchmark_comparison_operation_success();

commit;
