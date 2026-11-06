begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_structured_extraction_failure','Signed captured producer failure custody; no candidate or verification-quality claim')
on conflict(code) do update set description=excluded.description;

create table orchestration.verification_structured_extraction_failure (
 tenant_id uuid not null,
 operation_id uuid not null,
 failure_code text not null check(failure_code in('PROVIDER_HTTP_FAILURE','PROVIDER_RESPONSE_TOO_LARGE','PROVIDER_RESPONSE_INVALID','PROVIDER_RESPONSE_SCHEMA_INVALID')),
 status text not null default 'preparing' check(status in('preparing','published')),
 completed_at timestamptz not null default date_trunc('milliseconds',clock_timestamp()),
 failure_artifact_id uuid,
 failure_sha256 text check(failure_sha256 is null or failure_sha256 ~ '^[0-9a-f]{64}$'),
 seal_payload_sha256 text check(seal_payload_sha256 is null or seal_payload_sha256 ~ '^[0-9a-f]{64}$'),
 provider_call_sha256 text check(provider_call_sha256 is null or provider_call_sha256 ~ '^[0-9a-f]{64}$'),
 primary key(tenant_id,operation_id),
 foreign key(tenant_id,operation_id) references orchestration.verification_structured_extraction(tenant_id,operation_id),
 foreign key(tenant_id,operation_id) references orchestration.verification_structured_extraction_execution(tenant_id,operation_id),
 foreign key(tenant_id,failure_artifact_id) references orchestration.artifact(tenant_id,id),
 check((status='preparing' and failure_artifact_id is null and failure_sha256 is null and seal_payload_sha256 is null and provider_call_sha256 is null)
  or(status='published' and failure_artifact_id is not null and failure_sha256 is not null and seal_payload_sha256 is not null and provider_call_sha256 is not null))
);

create function orchestration.guard_structured_extraction_failure()
returns trigger language plpgsql set search_path='' as $$
declare claim jsonb; operation knowledge_service.operation%rowtype;
 lifecycle orchestration.verification_structured_extraction%rowtype;
 execution orchestration.verification_structured_extraction_execution%rowtype;
 provider orchestration.verification_provider_attempt%rowtype;
 parents uuid[]; signature text; call_signature text;
begin
 if tg_op='DELETE' then raise exception 'structured extraction failure is immutable' using errcode='restrict_violation'; end if;
 if tg_op='UPDATE' and (old.status<>'preparing' or new.status<>'published'
  or (to_jsonb(new)-array['status','failure_artifact_id','failure_sha256','seal_payload_sha256','provider_call_sha256'])
   is distinct from (to_jsonb(old)-array['status','failure_artifact_id','failure_sha256','seal_payload_sha256','provider_call_sha256'])) then
  raise exception 'structured extraction failure identity is immutable' using errcode='restrict_violation';
 end if;
 if tg_op='INSERT' and new.status<>'preparing' then raise exception 'structured extraction failure must initialize first' using errcode='check_violation'; end if;
 claim:=nullif(current_setting('verification.structured_extraction_claim',true),'')::jsonb;
 if claim is null then raise exception 'structured extraction failure active claim required' using errcode='check_violation'; end if;
 select * into operation from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id for update;
 if operation.id is null or operation.operation_kind is distinct from 'verification_structured_extraction' or operation.status is distinct from 'running' then
  raise exception 'structured extraction failure operation not active' using errcode='check_violation';
 end if;
 perform s.id from knowledge_service.operation_step s join knowledge_service.lease l on l.tenant_id=s.tenant_id and l.operation_step_id=s.id
  where s.tenant_id=new.tenant_id and s.operation_id=new.operation_id and s.step_key='extract_and_register' and s.status='running'
   and s.id::text=claim->>'stepId' and l.lease_token::text=claim->>'leaseToken' and l.fencing_token::text=claim->>'fencingToken'
   and l.holder_identity=claim->>'holderIdentity' and l.released_at is null and l.expires_at>clock_timestamp() for update of s,l;
 if not found then raise exception 'structured extraction failure stale lease' using errcode='check_violation'; end if;
 select * into execution from orchestration.verification_structured_extraction_execution e where e.tenant_id=new.tenant_id and e.operation_id=new.operation_id for update;
 select * into lifecycle from orchestration.verification_structured_extraction l where l.tenant_id=new.tenant_id and l.operation_id=new.operation_id for update;
 if execution.operation_id is null or lifecycle.operation_id is null or lifecycle.status is distinct from 'retaining'
  or lifecycle.operation_step_id is distinct from execution.operation_step_id or lifecycle.operation_step_id::text is distinct from claim->>'stepId'
  or lifecycle.producer_attempt_id is distinct from execution.producer_attempt_id or lifecycle.producer_attempt_id is distinct from operation.attempt_id
  or lifecycle.request_sha256 is distinct from execution.request_sha256 or lifecycle.request_sha256 is distinct from operation.request_sha256
  or lifecycle.step_input_sha256 is distinct from execution.step_input_sha256
  or lifecycle.profile_artifact_id is distinct from execution.profile_artifact_id or lifecycle.profile_sha256 is distinct from execution.profile_sha256
  or execution.execution_created_at>lifecycle.started_at
  or (new.failure_code='PROVIDER_HTTP_FAILURE') is distinct from (lifecycle.http_status>=300)
  or exists(select 1 from orchestration.verification_structured_extraction_publication p where p.tenant_id=new.tenant_id and p.operation_id=new.operation_id) then
  raise exception 'structured extraction failure lifecycle or classification mismatch' using errcode='foreign_key_violation';
 end if;
 if execution.dirty_artifact_id is not null and not orchestration.verification_artifact_is_admitted(new.tenant_id,execution.dirty_artifact_id,'verification_structured_extraction_source_custody',execution.dirty_sha256) then
  raise exception 'structured extraction failure typed source required' using errcode='foreign_key_violation';
 end if;
 if tg_op='INSERT' then new.completed_at:=greatest(date_trunc('milliseconds',clock_timestamp()),lifecycle.retention_started_at);return new;end if;
 select * into provider from orchestration.verification_provider_attempt p where p.tenant_id=new.tenant_id and p.id=lifecycle.provider_attempt_id for update;
 if provider.id is null or provider.operation_id is distinct from new.operation_id or provider.operation_step_id is distinct from lifecycle.operation_step_id
  or provider.profile_artifact_id is distinct from lifecycle.profile_artifact_id or provider.profile_sha256 is distinct from lifecycle.profile_sha256
  or provider.dispatch_fencing_token is distinct from lifecycle.original_dispatch_fencing_token
  or provider.request_artifact_id is distinct from lifecycle.provider_request_artifact_id or provider.request_sha256 is distinct from lifecycle.provider_request_sha256
  or provider.state not in('dispatched','uncertain','settled')
  or provider.response_artifact_id is not null and provider.response_artifact_id is distinct from lifecycle.response_envelope_artifact_id
  or position('|' in provider.provider_id)>0 or position('|' in provider.model)>0 then
  raise exception 'structured extraction failure provider mismatch' using errcode='foreign_key_violation';
 end if;
 call_signature:=encode(extensions.digest(convert_to(array_to_string(array[
  'verification-structured-extraction-provider-call.v1',provider.id::text,provider.budget_id::text,provider.provider_id,provider.model,
  provider.attempt_ordinal::text,provider.reservation_cost_micros::text,provider.state,coalesce(provider.actual_cost_micros::text,'unknown'),
  case when execution.execution_mode='synthetic_transport' then 'synthetic_transport' else 'provider_reported_response' end,
  lifecycle.raw_response_artifact_id::text,'sha256:'||lifecycle.raw_response_sha256,'false'
 ],'|'),'UTF8'),'sha256'),'hex');
 if new.provider_call_sha256<>call_signature then raise exception 'structured extraction failure accounting drift' using errcode='check_violation'; end if;
 parents:=array[execution.execution_artifact_id,lifecycle.profile_artifact_id]
  ||case when execution.dirty_artifact_id is null then '{}'::uuid[] else array[execution.dirty_artifact_id] end
  ||array[lifecycle.schema_artifact_id,lifecycle.source_artifact_id,lifecycle.representation_artifact_id,lifecycle.transformation_artifact_id,
   lifecycle.transport_artifact_id,lifecycle.response_envelope_artifact_id,lifecycle.provider_request_artifact_id,lifecycle.raw_response_artifact_id];
 signature:=encode(extensions.digest(convert_to(array_to_string(array[
  'verification-structured-extraction-failure-artifact.v1','sha256:'||new.failure_sha256,'sha256:'||new.seal_payload_sha256,
  new.tenant_id::text,new.operation_id::text,lifecycle.operation_step_id::text,lifecycle.producer_attempt_id::text,
  'sha256:'||execution.execution_sha256,'sha256:'||new.provider_call_sha256,new.failure_code,lifecycle.original_dispatch_fencing_token::text,
  to_char(lifecycle.started_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
  to_char(lifecycle.retention_started_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
  to_char(new.completed_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
 ]||parents::text[],'|'),'UTF8'),'sha256'),'hex');
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.failure_artifact_id,'verification_structured_extraction_failure',new.failure_sha256)
  or not exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
   where a.tenant_id=new.tenant_id and a.id=new.failure_artifact_id and a.producer_attempt_id=lifecycle.producer_attempt_id
    and a.created_at=new.completed_at and m.created_at=new.completed_at and m.parent_artifact_ids=parents and m.transformation_signature=signature) then
  raise exception 'structured extraction failure publication semantic mismatch' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_structured_extraction_failure_guard before insert or update or delete
 on orchestration.verification_structured_extraction_failure for each row execute function orchestration.guard_structured_extraction_failure();

create function orchestration.guard_structured_extraction_failure_exclusion()
returns trigger language plpgsql set search_path='' as $$
begin
 if new.status='retained' and exists(select 1 from orchestration.verification_structured_extraction_failure f where f.tenant_id=new.tenant_id and f.operation_id=new.operation_id) then
  raise exception 'structured extraction failure forbids candidate retention' using errcode='restrict_violation';
 end if;
 return new;
end $$;
create trigger verification_structured_extraction_failure_exclusion before update on orchestration.verification_structured_extraction
 for each row execute function orchestration.guard_structured_extraction_failure_exclusion();

alter table orchestration.verification_structured_extraction_failure enable row level security;
create policy verification_structured_extraction_failure_worker on orchestration.verification_structured_extraction_failure
 for all to executor_service,verifier_agent,control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy verification_structured_extraction_failure_reader on orchestration.verification_structured_extraction_failure
 for select to app_reader using(tenant_id=util.current_tenant_id());
revoke all on orchestration.verification_structured_extraction_failure from public,anon,authenticated;
grant select,insert,update on orchestration.verification_structured_extraction_failure to executor_service,verifier_agent,control_plane;
grant select on orchestration.verification_structured_extraction_failure to app_reader;
commit;
