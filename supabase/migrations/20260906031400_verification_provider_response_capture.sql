begin;
insert into orchestration.artifact_type(code,description) values ('verification_provider_transport_response','Canonical hash-bound provider transport response custody') on conflict(code) do update set description=excluded.description;
create table orchestration.verification_provider_response_capture(
 tenant_id uuid not null,provider_attempt_id uuid not null,operation_id uuid not null,operation_step_id uuid not null,profile_artifact_id uuid not null,profile_sha256 text not null check(profile_sha256~'^[0-9a-f]{64}$'),dispatch_fencing_token bigint not null check(dispatch_fencing_token>0),http_status integer not null check(http_status between 200 and 599),response_envelope_artifact_id uuid not null,transport_artifact_id uuid not null,transport_sha256 text not null check(transport_sha256~'^[0-9a-f]{64}$'),captured_at timestamptz not null default clock_timestamp(),primary key(tenant_id,provider_attempt_id),
 foreign key(tenant_id,provider_attempt_id) references orchestration.verification_provider_attempt(tenant_id,id),foreign key(tenant_id,transport_artifact_id) references orchestration.artifact(tenant_id,id));
alter table orchestration.verification_provider_response_capture
 add foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id),
 add foreign key(tenant_id,operation_step_id) references knowledge_service.operation_step(tenant_id,id),
 add foreign key(tenant_id,profile_artifact_id) references orchestration.artifact(tenant_id,id),
 add foreign key(tenant_id,response_envelope_artifact_id) references orchestration.artifact(tenant_id,id);
create or replace function orchestration.verification_provider_response_capture_guard() returns trigger language plpgsql set search_path='' as $$
declare claim jsonb; provider_row orchestration.verification_provider_attempt%rowtype; raw_id uuid; raw_sha text; expected_signature text;
begin
 if tg_op<>'INSERT' then raise exception 'provider response capture append-only' using errcode='restrict_violation'; end if;
 new.captured_at:=clock_timestamp();
 claim:=nullif(current_setting('verification.provider_claim',true),'')::jsonb;
 if claim is null then raise exception 'provider response capture active claim required' using errcode='check_violation';end if;
 perform 1 from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id and o.operation_kind='verification_structured_extraction' and o.status='running' for update;
 if not found then raise exception 'provider response capture active claim required' using errcode='check_violation';end if;
 perform step.id from knowledge_service.operation_step step join knowledge_service.lease l on l.tenant_id=step.tenant_id and l.operation_step_id=step.id where step.tenant_id=new.tenant_id and step.id=new.operation_step_id and step.operation_id=new.operation_id and step.step_key='extract_and_register' and step.status='running' and step.id::text=claim->>'stepId' and l.lease_token::text=claim->>'leaseToken' and l.fencing_token::text=claim->>'fencingToken' and l.holder_identity=claim->>'holderIdentity' and l.released_at is null and l.expires_at>clock_timestamp() for update of step,l;
 if not found then raise exception 'provider response capture stale claim' using errcode='check_violation';end if;
 select * into provider_row from orchestration.verification_provider_attempt where tenant_id=new.tenant_id and id=new.provider_attempt_id for update;
 if not exists(select 1 from orchestration.verification_provider_attempt p where p.tenant_id=new.tenant_id and p.id=new.provider_attempt_id and p.operation_id=new.operation_id and p.operation_step_id=new.operation_step_id and p.profile_artifact_id=new.profile_artifact_id and p.profile_sha256=new.profile_sha256 and p.dispatch_fencing_token=new.dispatch_fencing_token and p.state in ('dispatched','uncertain','settled') and (p.response_artifact_id is null or p.response_artifact_id=new.response_envelope_artifact_id) and orchestration.verification_provider_artifacts_are_admitted(p.tenant_id,p.request_artifact_id,p.request_sha256,new.response_envelope_artifact_id)) then raise exception 'provider response capture ledger binding mismatch' using errcode='foreign_key_violation';end if;
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.transport_artifact_id,'verification_provider_transport_response',new.transport_sha256) then raise exception 'provider response capture transport artifact inadmissible' using errcode='foreign_key_violation';end if;
 select m.parent_artifact_ids[2],a.sha256 into raw_id,raw_sha
 from orchestration.verification_artifact_metadata m join orchestration.artifact a on a.tenant_id=m.tenant_id and a.id=m.parent_artifact_ids[2]
 where m.tenant_id=new.tenant_id and m.artifact_id=new.response_envelope_artifact_id;
 expected_signature:=encode(extensions.digest(convert_to(array_to_string(array[
 'verification-provider-transport-binding.v1','sha256:'||new.transport_sha256,new.tenant_id::text,new.operation_id::text,new.operation_step_id::text,new.provider_attempt_id::text,
 new.profile_artifact_id::text,'sha256:'||new.profile_sha256,new.dispatch_fencing_token::text,new.http_status::text,new.response_envelope_artifact_id::text,
 raw_id::text,'sha256:'||raw_sha,'sha256:'||provider_row.request_sha256],'|'),'UTF8'),'sha256'),'hex');
 if not exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=new.transport_artifact_id
  and m.parent_artifact_ids=array[new.response_envelope_artifact_id,new.profile_artifact_id] and m.transformation_signature=expected_signature) then
  raise exception 'provider response capture transport semantic binding mismatch' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_provider_response_capture_guard before insert or update or delete on orchestration.verification_provider_response_capture for each row execute function orchestration.verification_provider_response_capture_guard();
alter table orchestration.verification_provider_response_capture enable row level security;
create policy verification_provider_response_capture_tenant_worker on orchestration.verification_provider_response_capture for all to executor_service,verifier_agent,control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy verification_provider_response_capture_tenant_reader on orchestration.verification_provider_response_capture for select to app_reader using(tenant_id=util.current_tenant_id());
revoke all on orchestration.verification_provider_response_capture from public,anon,authenticated;
grant select,insert on orchestration.verification_provider_response_capture to executor_service,verifier_agent,control_plane;
grant select on orchestration.verification_provider_response_capture to app_reader;
commit;
