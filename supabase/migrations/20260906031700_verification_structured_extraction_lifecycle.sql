begin;

create table orchestration.verification_structured_extraction (
 id uuid not null default util.uuidv7(),
 tenant_id uuid not null default util.default_tenant_id(),
 operation_id uuid not null,
 operation_step_id uuid not null,
 producer_attempt_id uuid not null,
 identity_sha256 text not null check(identity_sha256 ~ '^[0-9a-f]{64}$'),
 request_sha256 text not null check(request_sha256 ~ '^[0-9a-f]{64}$'),
 step_input_sha256 text not null check(step_input_sha256 ~ '^[0-9a-f]{64}$'),
 capture_id uuid not null,
 profile_artifact_id uuid not null,
 profile_sha256 text not null check(profile_sha256 ~ '^[0-9a-f]{64}$'),
 schema_artifact_id uuid not null,
 schema_artifact_sha256 text not null check(schema_artifact_sha256 ~ '^[0-9a-f]{64}$'),
 source_artifact_id uuid not null,
 source_sha256 text not null check(source_sha256 ~ '^[0-9a-f]{64}$'),
 representation_artifact_id uuid not null,
 representation_sha256 text not null check(representation_sha256 ~ '^[0-9a-f]{64}$'),
 transformation_artifact_id uuid not null,
 transformation_sha256 text not null check(transformation_sha256 ~ '^[0-9a-f]{64}$'),
 prompt_sha256 text not null check(prompt_sha256 ~ '^[0-9a-f]{64}$'),
 schema_digest_sha256 text not null check(schema_digest_sha256 ~ '^[0-9a-f]{64}$'),
 status text not null default 'running' check(status in('running','retaining','retained')),
 started_at timestamptz not null default date_trunc('milliseconds',clock_timestamp()),
 retention_started_at timestamptz,
 completed_at timestamptz,
 provider_attempt_id uuid,
 original_dispatch_fencing_token bigint check(original_dispatch_fencing_token is null or original_dispatch_fencing_token>0),
 http_status integer check(http_status is null or http_status between 200 and 599),
 captured_at timestamptz,
 provider_request_artifact_id uuid,
 provider_request_sha256 text check(provider_request_sha256 is null or provider_request_sha256 ~ '^[0-9a-f]{64}$'),
 raw_response_artifact_id uuid,
 raw_response_sha256 text check(raw_response_sha256 is null or raw_response_sha256 ~ '^[0-9a-f]{64}$'),
 response_envelope_artifact_id uuid,
 response_envelope_sha256 text check(response_envelope_sha256 is null or response_envelope_sha256 ~ '^[0-9a-f]{64}$'),
 transport_artifact_id uuid,
 transport_sha256 text check(transport_sha256 is null or transport_sha256 ~ '^[0-9a-f]{64}$'),
 candidate_artifact_id uuid,
 candidate_sha256 text check(candidate_sha256 is null or candidate_sha256 ~ '^[0-9a-f]{64}$'),
 precontext_artifact_id uuid,
 precontext_sha256 text check(precontext_sha256 is null or precontext_sha256 ~ '^[0-9a-f]{64}$'),
 provenance_artifact_id uuid,
 provenance_sha256 text check(provenance_sha256 is null or provenance_sha256 ~ '^[0-9a-f]{64}$'),
 primary key(tenant_id,operation_id),
 unique(tenant_id,id),
 unique(tenant_id,provider_attempt_id),
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
 foreign key(tenant_id,operation_step_id) references knowledge_service.operation_step(tenant_id,id) on delete restrict,
 foreign key(tenant_id,producer_attempt_id) references orchestration.attempt(tenant_id,id) on delete restrict,
 foreign key(tenant_id,capture_id) references evidence.source_capture(tenant_id,id) on delete restrict,
 foreign key(tenant_id,provider_attempt_id) references orchestration.verification_provider_attempt(tenant_id,id) on delete restrict,
 foreign key(tenant_id,profile_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,schema_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,source_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,representation_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,transformation_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,provider_request_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,raw_response_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,response_envelope_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,transport_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,candidate_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,precontext_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,provenance_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 check((precontext_artifact_id is null)=(precontext_sha256 is null)),
 check(
  (status='running' and retention_started_at is null and completed_at is null and provider_attempt_id is null
   and original_dispatch_fencing_token is null and http_status is null and captured_at is null
   and provider_request_artifact_id is null and provider_request_sha256 is null and raw_response_artifact_id is null and raw_response_sha256 is null
   and response_envelope_artifact_id is null and response_envelope_sha256 is null and transport_artifact_id is null and transport_sha256 is null
   and candidate_artifact_id is null and candidate_sha256 is null and precontext_artifact_id is null and precontext_sha256 is null
   and provenance_artifact_id is null and provenance_sha256 is null)
  or
  (status='retaining' and retention_started_at is not null and retention_started_at>=started_at and retention_started_at>=captured_at and completed_at is null
   and provider_attempt_id is not null and original_dispatch_fencing_token is not null and http_status is not null and captured_at is not null
   and provider_request_artifact_id is not null and provider_request_sha256 is not null and raw_response_artifact_id is not null and raw_response_sha256 is not null
   and response_envelope_artifact_id is not null and response_envelope_sha256 is not null and transport_artifact_id is not null and transport_sha256 is not null
   and candidate_artifact_id is null and candidate_sha256 is null and precontext_artifact_id is null and precontext_sha256 is null
   and provenance_artifact_id is null and provenance_sha256 is null)
  or
  (status='retained' and retention_started_at is not null and retention_started_at>=started_at and retention_started_at>=captured_at
   and completed_at is not null and completed_at>=retention_started_at
   and provider_attempt_id is not null and original_dispatch_fencing_token is not null and http_status is not null and captured_at is not null
   and provider_request_artifact_id is not null and provider_request_sha256 is not null and raw_response_artifact_id is not null and raw_response_sha256 is not null
   and response_envelope_artifact_id is not null and response_envelope_sha256 is not null and transport_artifact_id is not null and transport_sha256 is not null
   and candidate_artifact_id is not null and candidate_sha256 is not null and provenance_artifact_id is not null and provenance_sha256 is not null)
 )
);

create function orchestration.verification_structured_extraction_signature(
 lifecycle orchestration.verification_structured_extraction,
 artifact_type text,
 artifact_sha256 text,
 parents uuid[]
) returns text language sql immutable set search_path='' as $$
 select encode(extensions.digest(convert_to(array_to_string(array[
  'verification-structured-extraction-artifact.v1',artifact_type,'sha256:'||artifact_sha256,
  lifecycle.tenant_id::text,lifecycle.operation_id::text,lifecycle.provider_attempt_id::text,
  lifecycle.original_dispatch_fencing_token::text,lifecycle.profile_artifact_id::text,'sha256:'||lifecycle.profile_sha256,
  'sha256:'||lifecycle.prompt_sha256,'sha256:'||lifecycle.schema_digest_sha256
 ]||parents::text[],'|'),'UTF8'),'sha256'),'hex')
$$;

create function orchestration.guard_verification_structured_extraction_lifecycle() returns trigger
language plpgsql set search_path='' as $$
declare
 claim jsonb;
 operation knowledge_service.operation%rowtype;
 step knowledge_service.operation_step%rowtype;
 provider orchestration.verification_provider_attempt%rowtype;
 capture orchestration.verification_provider_response_capture%rowtype;
 envelope_parents uuid[];
 candidate_parents uuid[];
 precontext_parents uuid[];
 provenance_parents uuid[];
 raw_sha text;
 envelope_sha text;
 expected_signature text;
 canonical_now timestamptz;
begin
 if tg_op='DELETE' then raise exception 'structured extraction lifecycle cannot be deleted' using errcode='restrict_violation'; end if;
 claim:=nullif(current_setting('verification.structured_extraction_claim',true),'')::jsonb;
 if claim is null then raise exception 'structured extraction lifecycle active claim required' using errcode='check_violation'; end if;
 select * into operation from knowledge_service.operation o
  where o.tenant_id=new.tenant_id and o.id=new.operation_id for update;
 if operation.id is null or operation.operation_kind is distinct from 'verification_structured_extraction' or operation.status is distinct from 'running'
  or operation.attempt_id is distinct from new.producer_attempt_id or operation.request_sha256 is distinct from new.request_sha256
  or operation.request->>'kind' is distinct from 'verification_structured_extraction'
  or operation.request #>> '{input,schemaVersion}' is distinct from 'verification-service-request.v1'
  or operation.request #>> '{input,useCase}' is distinct from 'extractStructuredData'
  or operation.request #>> '{input,request,verificationContractVersion}' is distinct from 'verification.v1'
  or operation.request #>> '{input,request,captureId}' is distinct from new.capture_id::text
  or operation.request #>> '{input,request,representation,artifactId}' is distinct from new.representation_artifact_id::text
  or operation.request #>> '{input,request,representation,digest}' is distinct from 'sha256:'||new.representation_sha256
  or operation.request #>> '{input,request,extractionSchema,artifactId}' is distinct from new.schema_artifact_id::text
  or operation.request #>> '{input,request,extractionSchema,digest}' is distinct from 'sha256:'||new.schema_artifact_sha256
  or operation.request #>> '{input,request,extractionProfile}' is distinct from 'registered_default'
  or operation.request #>> '{authenticatedContext,tenantId}' is distinct from new.tenant_id::text
  or operation.request #>> '{authenticatedContext,operationId}' is distinct from new.operation_id::text
  or operation.request #>> '{authenticatedContext,attemptId}' is distinct from new.producer_attempt_id::text then
  raise exception 'structured extraction canonical operation identity mismatch' using errcode='foreign_key_violation';
 end if;
 select s.* into step from knowledge_service.operation_step s
  join knowledge_service.lease l on l.tenant_id=s.tenant_id and l.operation_step_id=s.id
  where s.tenant_id=new.tenant_id and s.id=new.operation_step_id and s.operation_id=new.operation_id
   and s.step_key='extract_and_register' and s.step_kind='extract_and_register' and s.status='running' and s.input_sha256=new.step_input_sha256
   and s.id::text=claim->>'stepId' and l.lease_token::text=claim->>'leaseToken' and l.fencing_token::text=claim->>'fencingToken'
   and l.holder_identity=claim->>'holderIdentity' and l.released_at is null and l.expires_at>clock_timestamp()
  for update of s,l;
 if step.id is null or step.input->>'kind' is distinct from 'verification_structured_extraction'
  or step.input #>> '{operationInput,schemaVersion}' is distinct from 'verification-service-request.v1'
  or step.input #>> '{operationInput,useCase}' is distinct from 'extractStructuredData'
  or step.input->'operationInput' is distinct from operation.request->'input'
  or step.input->'expectedVersions' is distinct from operation.request->'expectedVersions'
  or step.input->'context' is distinct from operation.request->'authenticatedContext'
  or step.input #>> '{step,name}' is distinct from 'extract_and_register' or step.input #>> '{step,ordinal}' is distinct from '0' then
  raise exception 'structured extraction live step identity mismatch' using errcode='check_violation';
 end if;
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.profile_artifact_id,'verification_structured_extraction_profile',new.profile_sha256)
  or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.schema_artifact_id,'verification_bundle',new.schema_artifact_sha256)
  or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.source_artifact_id,'source_capture',new.source_sha256)
  or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.representation_artifact_id,'verification_canonical_projection',new.representation_sha256)
  or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.transformation_artifact_id,'verification_transformation_envelope',new.transformation_sha256)
  or not exists(select 1 from evidence.source_capture c where c.tenant_id=new.tenant_id and c.id=new.capture_id and c.artifact_id=new.source_artifact_id and c.content_sha256=new.source_sha256)
  or not exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=new.transformation_artifact_id
   and cardinality(m.parent_artifact_ids)=3 and m.parent_artifact_ids[1]=new.source_artifact_id and m.parent_artifact_ids[3]=new.representation_artifact_id
   and orchestration.verification_artifact_is_admitted(new.tenant_id,m.parent_artifact_ids[2],'verification_parser_native_output',null)) then
  raise exception 'structured extraction source/profile/schema admission mismatch' using errcode='foreign_key_violation';
 end if;
 if tg_op='INSERT' then
  if new.status<>'running' then raise exception 'structured extraction lifecycle must initialize running' using errcode='check_violation'; end if;
  canonical_now:=date_trunc('milliseconds',clock_timestamp());
  new.started_at:=canonical_now;
  return new;
 end if;
 if new.id is distinct from old.id or new.tenant_id is distinct from old.tenant_id or new.operation_id is distinct from old.operation_id
  or new.operation_step_id is distinct from old.operation_step_id or new.producer_attempt_id is distinct from old.producer_attempt_id
  or new.identity_sha256 is distinct from old.identity_sha256 or new.request_sha256 is distinct from old.request_sha256
  or new.step_input_sha256 is distinct from old.step_input_sha256 or new.capture_id is distinct from old.capture_id
  or new.profile_artifact_id is distinct from old.profile_artifact_id or new.profile_sha256 is distinct from old.profile_sha256
  or new.schema_artifact_id is distinct from old.schema_artifact_id or new.schema_artifact_sha256 is distinct from old.schema_artifact_sha256
  or new.source_artifact_id is distinct from old.source_artifact_id or new.source_sha256 is distinct from old.source_sha256
  or new.representation_artifact_id is distinct from old.representation_artifact_id or new.representation_sha256 is distinct from old.representation_sha256
  or new.transformation_artifact_id is distinct from old.transformation_artifact_id or new.transformation_sha256 is distinct from old.transformation_sha256
  or new.prompt_sha256 is distinct from old.prompt_sha256 or new.schema_digest_sha256 is distinct from old.schema_digest_sha256
  or new.started_at is distinct from old.started_at then
  raise exception 'structured extraction lifecycle immutable identity' using errcode='restrict_violation';
 end if;
 if old.status='running' and new.status='retaining' then
  select * into provider from orchestration.verification_provider_attempt p
   where p.tenant_id=new.tenant_id and p.id=new.provider_attempt_id for update;
  select * into capture from orchestration.verification_provider_response_capture c
   where c.tenant_id=new.tenant_id and c.provider_attempt_id=new.provider_attempt_id for update;
  if provider.id is null or capture.provider_attempt_id is null or provider.operation_id is distinct from new.operation_id
   or provider.operation_step_id is distinct from new.operation_step_id or provider.profile_artifact_id is distinct from new.profile_artifact_id
   or provider.profile_sha256 is distinct from new.profile_sha256 or provider.dispatch_fencing_token is distinct from capture.dispatch_fencing_token
   or provider.state not in('dispatched','uncertain','settled') or capture.operation_id is distinct from new.operation_id
   or capture.operation_step_id is distinct from new.operation_step_id or capture.profile_artifact_id is distinct from new.profile_artifact_id
   or capture.profile_sha256 is distinct from new.profile_sha256 or (provider.response_artifact_id is not null and capture.response_envelope_artifact_id is distinct from provider.response_artifact_id)
   or capture.transport_sha256 is null then
   raise exception 'structured extraction original capture binding mismatch' using errcode='foreign_key_violation';
  end if;
  select m.parent_artifact_ids,a.sha256 into envelope_parents,envelope_sha
   from orchestration.verification_artifact_metadata m join orchestration.artifact a on a.tenant_id=m.tenant_id and a.id=m.artifact_id
   where m.tenant_id=new.tenant_id and m.artifact_id=capture.response_envelope_artifact_id;
  if cardinality(envelope_parents)<>2 or envelope_parents[1] is distinct from provider.request_artifact_id
   or not orchestration.verification_provider_artifacts_are_admitted(new.tenant_id,provider.request_artifact_id,provider.request_sha256,capture.response_envelope_artifact_id) then
   raise exception 'structured extraction response ancestry mismatch' using errcode='foreign_key_violation';
  end if;
  select a.sha256 into raw_sha from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=envelope_parents[2];
  new.original_dispatch_fencing_token:=capture.dispatch_fencing_token;
  new.http_status:=capture.http_status;
  new.captured_at:=capture.captured_at;
  new.provider_request_artifact_id:=provider.request_artifact_id;
  new.provider_request_sha256:=provider.request_sha256;
  new.raw_response_artifact_id:=envelope_parents[2];
  new.raw_response_sha256:=raw_sha;
  new.response_envelope_artifact_id:=capture.response_envelope_artifact_id;
  new.response_envelope_sha256:=envelope_sha;
  new.transport_artifact_id:=capture.transport_artifact_id;
  new.transport_sha256:=capture.transport_sha256;
  canonical_now:=date_trunc('milliseconds',clock_timestamp());
  if canonical_now<capture.captured_at then canonical_now:=date_trunc('milliseconds',capture.captured_at)+interval '1 millisecond'; end if;
  new.retention_started_at:=canonical_now;
  if (to_jsonb(new)-array['status','retention_started_at','provider_attempt_id','original_dispatch_fencing_token','http_status','captured_at','provider_request_artifact_id','provider_request_sha256','raw_response_artifact_id','raw_response_sha256','response_envelope_artifact_id','response_envelope_sha256','transport_artifact_id','transport_sha256'])
   is distinct from (to_jsonb(old)-array['status','retention_started_at','provider_attempt_id','original_dispatch_fencing_token','http_status','captured_at','provider_request_artifact_id','provider_request_sha256','raw_response_artifact_id','raw_response_sha256','response_envelope_artifact_id','response_envelope_sha256','transport_artifact_id','transport_sha256']) then
   raise exception 'structured extraction retaining transition changes immutable state' using errcode='restrict_violation';
  end if;
  return new;
 end if;
 if old.status='retaining' and new.status='retained' then
  candidate_parents:=array[new.profile_artifact_id,new.schema_artifact_id,new.source_artifact_id,new.representation_artifact_id,new.transformation_artifact_id,new.transport_artifact_id,new.response_envelope_artifact_id,new.provider_request_artifact_id,new.raw_response_artifact_id];
  precontext_parents:=array[new.transport_artifact_id,new.response_envelope_artifact_id,new.provider_request_artifact_id,new.raw_response_artifact_id,new.profile_artifact_id];
  provenance_parents:=array[new.candidate_artifact_id]||case when new.precontext_artifact_id is null then '{}'::uuid[] else array[new.precontext_artifact_id] end||candidate_parents;
  expected_signature:=orchestration.verification_structured_extraction_signature(new,'verification_extraction_candidate',new.candidate_sha256,candidate_parents);
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.candidate_artifact_id,'verification_extraction_candidate',new.candidate_sha256)
   or not exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
    where a.tenant_id=new.tenant_id and a.id=new.candidate_artifact_id and a.producer_attempt_id=new.producer_attempt_id
     and a.created_at=new.retention_started_at and m.created_at=new.retention_started_at and m.parent_artifact_ids=candidate_parents and m.transformation_signature=expected_signature) then
   raise exception 'structured extraction candidate semantic binding mismatch' using errcode='foreign_key_violation';
  end if;
  if new.precontext_artifact_id is not null then
   expected_signature:=orchestration.verification_structured_extraction_signature(new,'verification_structured_extraction_precontext',new.precontext_sha256,precontext_parents);
   if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.precontext_artifact_id,'verification_structured_extraction_precontext',new.precontext_sha256)
    or not exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
     where a.tenant_id=new.tenant_id and a.id=new.precontext_artifact_id and a.producer_attempt_id=new.producer_attempt_id
      and a.created_at=new.retention_started_at and m.created_at=new.retention_started_at and m.parent_artifact_ids=precontext_parents and m.transformation_signature=expected_signature) then
    raise exception 'structured extraction precontext semantic binding mismatch' using errcode='foreign_key_violation';
   end if;
  end if;
  expected_signature:=orchestration.verification_structured_extraction_signature(new,'verification_structured_extraction_provenance',new.provenance_sha256,provenance_parents);
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.provenance_artifact_id,'verification_structured_extraction_provenance',new.provenance_sha256)
   or not exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
    where a.tenant_id=new.tenant_id and a.id=new.provenance_artifact_id and a.producer_attempt_id=new.producer_attempt_id
     and a.created_at=new.retention_started_at and m.created_at=new.retention_started_at and m.parent_artifact_ids=provenance_parents and m.transformation_signature=expected_signature) then
   raise exception 'structured extraction provenance semantic binding mismatch' using errcode='foreign_key_violation';
  end if;
  canonical_now:=date_trunc('milliseconds',clock_timestamp());
  new.completed_at:=greatest(canonical_now,new.retention_started_at);
  if (to_jsonb(new)-array['status','completed_at','candidate_artifact_id','candidate_sha256','precontext_artifact_id','precontext_sha256','provenance_artifact_id','provenance_sha256'])
   is distinct from (to_jsonb(old)-array['status','completed_at','candidate_artifact_id','candidate_sha256','precontext_artifact_id','precontext_sha256','provenance_artifact_id','provenance_sha256']) then
   raise exception 'structured extraction retained transition changes immutable state' using errcode='restrict_violation';
  end if;
  return new;
 end if;
 raise exception 'structured extraction lifecycle transition invalid' using errcode='restrict_violation';
end $$;

create trigger verification_structured_extraction_lifecycle_guard
 before insert or update or delete on orchestration.verification_structured_extraction
 for each row execute function orchestration.guard_verification_structured_extraction_lifecycle();

alter table orchestration.verification_structured_extraction enable row level security;
create policy verification_structured_extraction_tenant_worker on orchestration.verification_structured_extraction
 for all to executor_service,verifier_agent,control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy verification_structured_extraction_tenant_reader on orchestration.verification_structured_extraction
 for select to app_reader using(tenant_id=util.current_tenant_id());
revoke all on orchestration.verification_structured_extraction from public,anon,authenticated;
grant select,insert,update on orchestration.verification_structured_extraction to executor_service,verifier_agent,control_plane;
grant select on orchestration.verification_structured_extraction to app_reader;

revoke all on function orchestration.verification_structured_extraction_signature(orchestration.verification_structured_extraction,text,text,uuid[]) from public,anon,authenticated;
grant execute on function orchestration.verification_structured_extraction_signature(orchestration.verification_structured_extraction,text,text,uuid[]) to executor_service,verifier_agent,control_plane;

commit;
