begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_structured_extraction_execution','Immutable original structured extraction execution and code custody'),
 ('verification_structured_extraction_publication','Final structured extraction custody publication; output remains unverified')
on conflict(code) do update set description=excluded.description;

create table orchestration.verification_structured_extraction_execution (
 tenant_id uuid not null,
 operation_id uuid not null,
 operation_step_id uuid not null,
 producer_attempt_id uuid not null,
 request_sha256 text not null check(request_sha256 ~ '^[0-9a-f]{64}$'),
 step_input_sha256 text not null check(step_input_sha256 ~ '^[0-9a-f]{64}$'),
 profile_artifact_id uuid not null,
 profile_sha256 text not null check(profile_sha256 ~ '^[0-9a-f]{64}$'),
 execution_artifact_id uuid not null,
 execution_sha256 text not null check(execution_sha256 ~ '^[0-9a-f]{64}$'),
 runtime_sha256 text not null check(runtime_sha256 ~ '^[0-9a-f]{64}$'),
 execution_mode text not null check(execution_mode in('synthetic_transport','live_provider')),
 dirty_artifact_id uuid,
 dirty_sha256 text check(dirty_sha256 is null or dirty_sha256 ~ '^[0-9a-f]{64}$'),
 execution_created_at timestamptz not null,
 bound_at timestamptz not null default clock_timestamp(),
 primary key(tenant_id,operation_id),
 check((dirty_artifact_id is null)=(dirty_sha256 is null)),
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id),
 foreign key(tenant_id,operation_step_id) references knowledge_service.operation_step(tenant_id,id),
 foreign key(tenant_id,producer_attempt_id) references orchestration.attempt(tenant_id,id),
 foreign key(tenant_id,profile_artifact_id) references orchestration.artifact(tenant_id,id),
 foreign key(tenant_id,execution_artifact_id) references orchestration.artifact(tenant_id,id),
 foreign key(tenant_id,dirty_artifact_id) references orchestration.artifact(tenant_id,id)
);

create function orchestration.guard_verification_structured_extraction_execution()
returns trigger language plpgsql set search_path='' as $$
declare claim jsonb; operation knowledge_service.operation%rowtype; parents uuid[]; signature text;
begin
 if tg_op<>'INSERT' then raise exception 'structured extraction execution is immutable' using errcode='restrict_violation'; end if;
 claim:=nullif(current_setting('verification.structured_extraction_claim',true),'')::jsonb;
 if claim is null then raise exception 'structured extraction execution active claim required' using errcode='check_violation'; end if;
 select * into operation from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id for update;
 if operation.id is null or operation.operation_kind is distinct from 'verification_structured_extraction' or operation.status is distinct from 'running'
  or operation.attempt_id is distinct from new.producer_attempt_id or operation.request_sha256 is distinct from new.request_sha256
  or operation.request->>'kind' is distinct from 'verification_structured_extraction'
  or operation.request #>> '{input,useCase}' is distinct from 'extractStructuredData'
  or operation.request #>> '{authenticatedContext,tenantId}' is distinct from new.tenant_id::text
  or operation.request #>> '{authenticatedContext,operationId}' is distinct from new.operation_id::text
  or operation.request #>> '{authenticatedContext,attemptId}' is distinct from new.producer_attempt_id::text then
  raise exception 'structured extraction execution canonical operation mismatch' using errcode='foreign_key_violation';
 end if;
 perform s.id from knowledge_service.operation_step s join knowledge_service.lease l on l.tenant_id=s.tenant_id and l.operation_step_id=s.id
  where s.tenant_id=new.tenant_id and s.id=new.operation_step_id and s.operation_id=new.operation_id
   and s.step_key='extract_and_register' and s.step_kind='extract_and_register' and s.status='running' and s.input_sha256=new.step_input_sha256
   and s.input->'operationInput'=operation.request->'input' and s.input->'context'=operation.request->'authenticatedContext'
   and s.id::text=claim->>'stepId' and l.lease_token::text=claim->>'leaseToken' and l.fencing_token::text=claim->>'fencingToken'
   and l.holder_identity=claim->>'holderIdentity' and l.released_at is null and l.expires_at>clock_timestamp() for update of s,l;
 if not found then raise exception 'structured extraction execution stale lease' using errcode='check_violation'; end if;
 -- Operation-scoped provider reservation uses the same operation-first lock.
 -- Binding after reservation, even before dispatch, cannot establish original code custody.
 if exists(select 1 from orchestration.verification_provider_attempt p where p.tenant_id=new.tenant_id and p.operation_id=new.operation_id) then
  raise exception 'structured extraction execution must precede provider reservation' using errcode='check_violation';
 end if;
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.profile_artifact_id,'verification_structured_extraction_profile',new.profile_sha256)
  or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.execution_artifact_id,'verification_structured_extraction_execution',new.execution_sha256) then
  raise exception 'structured extraction execution artifact inadmissible' using errcode='foreign_key_violation';
 end if;
 if new.dirty_artifact_id is not null and not exists(select 1 from orchestration.artifact a
  where a.tenant_id=new.tenant_id and a.id=new.dirty_artifact_id and a.sha256=new.dirty_sha256
   and a.storage_state='available' and a.verification_contract_version='verification.v1') then
  raise exception 'structured extraction dirty source artifact inadmissible' using errcode='foreign_key_violation';
 end if;
 if new.execution_created_at<>date_trunc('milliseconds',new.execution_created_at)
  or new.execution_created_at<date_trunc('milliseconds',operation.created_at) or new.execution_created_at>clock_timestamp() then
  raise exception 'structured extraction execution timestamp invalid' using errcode='check_violation';
 end if;
 parents:=array[new.profile_artifact_id]||case when new.dirty_artifact_id is null then '{}'::uuid[] else array[new.dirty_artifact_id] end;
 signature:=encode(extensions.digest(convert_to(array_to_string(array[
  'verification-structured-extraction-execution-artifact.v1','sha256:'||new.execution_sha256,
  new.tenant_id::text,new.operation_id::text,new.operation_step_id::text,new.producer_attempt_id::text,
  'sha256:'||new.request_sha256,'sha256:'||new.step_input_sha256,'sha256:'||new.profile_sha256,'sha256:'||new.runtime_sha256,
  new.execution_mode,to_char(new.execution_created_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
 ]||parents::text[],'|'),'UTF8'),'sha256'),'hex');
 if not exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
  where a.tenant_id=new.tenant_id and a.id=new.execution_artifact_id and a.producer_attempt_id=new.producer_attempt_id
   and a.created_at=new.execution_created_at and m.created_at=new.execution_created_at
   and m.parent_artifact_ids=parents and m.transformation_signature=signature) then
  raise exception 'structured extraction execution semantic binding mismatch' using errcode='foreign_key_violation';
 end if;
 new.bound_at:=clock_timestamp();
 return new;
end $$;
create trigger verification_structured_extraction_execution_guard before insert or update or delete
 on orchestration.verification_structured_extraction_execution for each row
 execute function orchestration.guard_verification_structured_extraction_execution();

alter table orchestration.verification_structured_extraction_execution enable row level security;
create policy verification_structured_extraction_execution_worker on orchestration.verification_structured_extraction_execution
 for all to executor_service,verifier_agent,control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy verification_structured_extraction_execution_reader on orchestration.verification_structured_extraction_execution
 for select to app_reader using(tenant_id=util.current_tenant_id());
revoke all on orchestration.verification_structured_extraction_execution from public,anon,authenticated;
grant select,insert on orchestration.verification_structured_extraction_execution to executor_service,verifier_agent,control_plane;
grant select on orchestration.verification_structured_extraction_execution to app_reader;

commit;
