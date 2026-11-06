-- Promoted from tested R17; native receipt35b43d5a verifies 114 controls.
-- Adds closed claims/report semantic custody and accounting reconciliation; preserves extraction v1.
begin;
create or replace function orchestration.verification_provider_attempt_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE' then raise exception 'verification provider attempts are append-only' using errcode = 'restrict_violation'; end if;
  if new.id <> old.id or new.tenant_id <> old.tenant_id or new.budget_id <> old.budget_id
     or new.request_sha256 <> old.request_sha256 or new.attempt_ordinal <> old.attempt_ordinal
     or new.provider_id <> old.provider_id or new.model <> old.model
     or new.reservation_cost_micros <> old.reservation_cost_micros
     or new.estimated_cost_micros is distinct from old.estimated_cost_micros
     or new.request_artifact_id is distinct from old.request_artifact_id
     or new.created_at <> old.created_at then
    raise exception 'verification provider attempt immutable identity' using errcode = 'restrict_violation';
  end if;
  if old.response_artifact_id is not null and new.response_artifact_id is distinct from old.response_artifact_id then
    raise exception 'verification provider response evidence immutable' using errcode = 'restrict_violation';
  end if;
  if current_setting('verification.provider_reconciliation',true)=new.id::text then
    if old.state in('dispatched','uncertain') and new.state='settled'
     and (to_jsonb(new)-array['state','actual_cost_micros','reconciled_at'])=(to_jsonb(old)-array['state','actual_cost_micros','reconciled_at'])
     and exists(select 1 from orchestration.verification_provider_reconciliation r where r.tenant_id=new.tenant_id and r.provider_attempt_id=new.id
       and r.operation_id=new.operation_id and r.body->>'originalState'=old.state
       and new.actual_cost_micros=(r.body#>>'{decision,actualCostMicros}')::bigint and new.reconciled_at=r.applied_at)
    then return new;end if;
    raise exception 'provider reconciliation settlement transition mismatch' using errcode='check_violation';
  end if;
  if old.state = 'reserved' and new.state = 'dispatched'
     and old.dispatched_at is null and new.dispatched_at is not null and new.reconciled_at is null
     and new.actual_cost_micros is null and new.response_artifact_id is null and new.dispatch_fence is not null then return new; end if;
  if old.state = 'dispatched' and new.state = 'uncertain'
     and new.dispatched_at = old.dispatched_at and new.reconciled_at is null
     and new.actual_cost_micros is null and new.dispatch_fence = old.dispatch_fence then return new; end if;
  if old.state in ('dispatched','uncertain') and new.state = 'settled'
     and new.dispatched_at = old.dispatched_at and new.reconciled_at is not null
     and new.actual_cost_micros is not null and new.response_artifact_id is not null
     and new.dispatch_fence = old.dispatch_fence then return new; end if;
  raise exception 'verification provider attempt state transition invalid' using errcode = 'restrict_violation';
end;
$$;

grant usage on schema extensions to executor_service,verifier_agent,control_plane;
grant execute on function extensions.digest(bytea,text) to executor_service,verifier_agent,control_plane;

insert into orchestration.artifact_type(code,description) values
 ('verification_semantic_judge_profile','Immutable server-owned semantic judge profile'),
 ('verification_semantic_blinded_input','Immutable blinded authorized semantic judge input'),
 ('verification_semantic_response_observation','Immutable semantic provider response observation bound to raw response custody')
on conflict(code) do nothing;

do $$ begin
 if exists(select 1 from orchestration.artifact_type where code='verification_semantic_judge_profile' and description<>'Immutable server-owned semantic judge profile')
 or exists(select 1 from orchestration.artifact_type where code='verification_semantic_blinded_input' and description<>'Immutable blinded authorized semantic judge input')
 or exists(select 1 from orchestration.artifact_type where code='verification_semantic_response_observation' and description<>'Immutable semantic provider response observation bound to raw response custody') then raise exception 'semantic artifact vocabulary collision'; end if;
end $$;

create or replace function orchestration.verification_provider_scope_tuple_is_live(p_tenant uuid,p_operation uuid,p_step uuid,p_profile uuid,p_profile_sha text,p_claim jsonb) returns boolean
language plpgsql security definer set search_path='' as $$
begin
 perform 1 from knowledge_service.operation o join knowledge_service.operation_step s on s.tenant_id=o.tenant_id and s.operation_id=o.id join knowledge_service.lease l on l.tenant_id=s.tenant_id and l.operation_step_id=s.id
 where o.tenant_id=p_tenant and o.id=p_operation and s.id=p_step and o.status='running' and s.status='running'
 and s.id::text=p_claim->>'stepId' and s.step_kind=s.step_key and l.lease_token::text=p_claim->>'leaseToken' and l.fencing_token::text=p_claim->>'fencingToken' and l.holder_identity=p_claim->>'holderIdentity' and l.released_at is null and l.expires_at>clock_timestamp()
 and ((o.operation_kind='verification_structured_extraction' and s.step_key='extract_and_register' and orchestration.verification_artifact_is_admitted(p_tenant,p_profile,'verification_structured_extraction_profile',p_profile_sha))
   or (o.operation_kind='verification_claims' and s.step_key='verify_claims_and_register' and orchestration.verification_artifact_is_admitted(p_tenant,p_profile,'verification_semantic_judge_profile',p_profile_sha))
   or (o.operation_kind='verification_report' and s.step_key='verify_report_and_register' and orchestration.verification_artifact_is_admitted(p_tenant,p_profile,'verification_semantic_judge_profile',p_profile_sha)) ) for update of o,s,l;
 if not found then return false; end if;
 return exists(select 1 from knowledge_service.operation o
 join knowledge_service.operation_step s on s.tenant_id=o.tenant_id and s.operation_id=o.id
 join knowledge_service.lease l on l.tenant_id=s.tenant_id and l.operation_step_id=s.id
 where o.tenant_id=p_tenant and o.id=p_operation and o.status='running'
 and s.id=p_step and s.status='running' and s.step_kind=s.step_key
 and s.id::text=p_claim->>'stepId' and l.lease_token::text=p_claim->>'leaseToken'
 and l.fencing_token::text=p_claim->>'fencingToken' and l.holder_identity=p_claim->>'holderIdentity'
 and l.released_at is null and l.expires_at>clock_timestamp());
end $$;
revoke all on function orchestration.verification_provider_scope_tuple_is_live(uuid,uuid,uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function orchestration.verification_provider_scope_tuple_is_live(uuid,uuid,uuid,uuid,text,jsonb) to executor_service,verifier_agent,control_plane;

create or replace function orchestration.verification_provider_operation_claim() returns trigger language plpgsql set search_path='' as $$
declare claim jsonb;
begin
 if tg_op='UPDATE' and old.operation_id is not null and new.operation_id is null then raise exception 'provider attempt operation scope cannot be removed' using errcode='restrict_violation'; end if;
 if new.operation_id is null then return new; end if;
 if tg_op='INSERT' and new.state<>'reserved' then raise exception 'scoped provider attempt must begin reserved' using errcode='check_violation'; end if;

  if tg_op='UPDATE' and current_setting('verification.provider_reconciliation',true)=new.id::text then
    if old.state in('dispatched','uncertain') and new.state='settled'
      and (to_jsonb(new)-array['state','actual_cost_micros','reconciled_at'])=(to_jsonb(old)-array['state','actual_cost_micros','reconciled_at'])
      and exists(select 1 from orchestration.verification_provider_reconciliation r where r.tenant_id=new.tenant_id and r.provider_attempt_id=new.id
        and r.operation_id=new.operation_id and r.body->>'originalState'=old.state
        and new.actual_cost_micros=(r.body#>>'{decision,actualCostMicros}')::bigint and new.reconciled_at=r.applied_at)
    then return new;end if;
    raise exception 'provider reconciliation settlement transition mismatch' using errcode='check_violation';
  end if;
 claim:=nullif(current_setting('verification.provider_claim',true),'')::jsonb;
 if claim is null or not orchestration.verification_provider_scope_tuple_is_live(new.tenant_id,new.operation_id,new.operation_step_id,new.profile_artifact_id,new.profile_sha256,claim) then raise exception 'provider attempt active closed-scope lease claim required' using errcode='check_violation'; end if;
 if not orchestration.verification_provider_artifacts_are_admitted(new.tenant_id,new.request_artifact_id,new.request_sha256,new.response_artifact_id) then raise exception 'provider attempt provider artifact binding is inadmissible' using errcode='foreign_key_violation'; end if;
 if tg_op='INSERT' and new.reserved_fencing_token is distinct from (claim->>'fencingToken')::bigint then raise exception 'provider attempt reservation fence mismatch' using errcode='check_violation'; end if;
 if tg_op='UPDATE' and old.state='reserved' and new.state='dispatched' and new.dispatch_fencing_token is distinct from (claim->>'fencingToken')::bigint then raise exception 'provider attempt dispatch fence mismatch' using errcode='check_violation'; end if;
 return new;
end $$;

create table orchestration.verification_semantic_response_observation(
 tenant_id uuid not null,producer_attempt_id uuid not null,provider_attempt_id uuid not null,operation_id uuid not null,operation_step_id uuid not null,profile_artifact_id uuid not null,profile_sha256 text not null check(profile_sha256~'^[0-9a-f]{64}$'),dispatch_fencing_token bigint not null check(dispatch_fencing_token>0),
 blinded_input_artifact_id uuid not null,blinded_input_sha256 text not null check(blinded_input_sha256~'^[0-9a-f]{64}$'),request_artifact_id uuid not null,request_sha256 text not null check(request_sha256~'^[0-9a-f]{64}$'),raw_response_artifact_id uuid not null,raw_response_sha256 text not null check(raw_response_sha256~'^[0-9a-f]{64}$'),response_envelope_artifact_id uuid not null,response_envelope_sha256 text not null check(response_envelope_sha256~'^[0-9a-f]{64}$'),observation_artifact_id uuid not null,observation_sha256 text not null check(observation_sha256~'^[0-9a-f]{64}$'),
 requested_model text not null check(requested_model~'^[A-Za-z0-9_./:-]{1,255}$'),observed_model text check(observed_model is null or observed_model~'^[A-Za-z0-9_./:-]{1,255}$'),model_status text not null check(model_status in('matched','missing','mismatch')),revalidation_required boolean not null,prompt_tokens integer check(prompt_tokens is null or prompt_tokens between 0 and 2000000),completion_tokens integer check(completion_tokens is null or completion_tokens between 0 and 2000000),total_tokens integer check(total_tokens is null or total_tokens between 0 and 4000000),reported_cost_status text not null check(reported_cost_status in('reported','unknown')),reported_cost_micros bigint check(reported_cost_micros is null or reported_cost_micros between 0 and 2000000000),recorded_at timestamptz not null default clock_timestamp(),
 check(producer_attempt_id<>provider_attempt_id),check(profile_artifact_id<>blinded_input_artifact_id and profile_artifact_id<>request_artifact_id and profile_artifact_id<>raw_response_artifact_id and profile_artifact_id<>response_envelope_artifact_id and profile_artifact_id<>observation_artifact_id and blinded_input_artifact_id<>request_artifact_id and blinded_input_artifact_id<>raw_response_artifact_id and blinded_input_artifact_id<>response_envelope_artifact_id and blinded_input_artifact_id<>observation_artifact_id and request_artifact_id<>raw_response_artifact_id and request_artifact_id<>response_envelope_artifact_id and request_artifact_id<>observation_artifact_id and raw_response_artifact_id<>response_envelope_artifact_id and raw_response_artifact_id<>observation_artifact_id and response_envelope_artifact_id<>observation_artifact_id),primary key(tenant_id,provider_attempt_id),foreign key(tenant_id,producer_attempt_id) references orchestration.attempt(tenant_id,id),foreign key(tenant_id,provider_attempt_id) references orchestration.verification_provider_attempt(tenant_id,id),foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id),foreign key(tenant_id,operation_step_id) references knowledge_service.operation_step(tenant_id,id),foreign key(tenant_id,profile_artifact_id) references orchestration.artifact(tenant_id,id),foreign key(tenant_id,blinded_input_artifact_id) references orchestration.artifact(tenant_id,id),foreign key(tenant_id,request_artifact_id) references orchestration.artifact(tenant_id,id),foreign key(tenant_id,raw_response_artifact_id) references orchestration.artifact(tenant_id,id),foreign key(tenant_id,response_envelope_artifact_id) references orchestration.artifact(tenant_id,id),foreign key(tenant_id,observation_artifact_id) references orchestration.artifact(tenant_id,id),
 check((model_status='matched' and observed_model is not null and observed_model=requested_model and not revalidation_required)or(model_status='missing' and observed_model is null and revalidation_required)or(model_status='mismatch' and observed_model is not null and observed_model<>requested_model and revalidation_required)),check((reported_cost_status='reported' and reported_cost_micros is not null)or(reported_cost_status='unknown' and reported_cost_micros is null)),check(total_tokens is null or ((prompt_tokens is null or total_tokens>=prompt_tokens) and (completion_tokens is null or total_tokens>=completion_tokens) and (prompt_tokens is null or completion_tokens is null or total_tokens>=prompt_tokens+completion_tokens))));

create or replace function orchestration.verification_semantic_response_observation_guard() returns trigger language plpgsql set search_path='' as $$
declare c jsonb; p orchestration.verification_provider_attempt%rowtype;
begin
 if tg_op<>'INSERT' then raise exception 'semantic observations append-only' using errcode='restrict_violation'; end if; new.recorded_at:=clock_timestamp(); c:=nullif(current_setting('verification.provider_claim',true),'')::jsonb;
 if c is null or not exists(select 1 from knowledge_service.operation o join knowledge_service.operation_step s on s.tenant_id=o.tenant_id and s.operation_id=o.id where o.tenant_id=new.tenant_id and o.id=new.operation_id and s.id=new.operation_step_id and ((o.operation_kind='verification_claims' and s.step_key='verify_claims_and_register') or (o.operation_kind='verification_report' and s.step_key='verify_report_and_register'))) or not orchestration.verification_provider_scope_tuple_is_live(new.tenant_id,new.operation_id,new.operation_step_id,new.profile_artifact_id,new.profile_sha256,c) then raise exception 'semantic observation stale closed-scope lease' using errcode='check_violation'; end if;
 select * into p from orchestration.verification_provider_attempt where tenant_id=new.tenant_id and id=new.provider_attempt_id for update;
 if not exists(select 1 from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id and o.attempt_id=new.producer_attempt_id) or not exists(select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=new.observation_artifact_id and a.producer_attempt_id=new.producer_attempt_id) then raise exception 'semantic observation producer attempt binding mismatch' using errcode='foreign_key_violation'; end if;
 if not found or p.operation_id is null or p.operation_step_id is null or p.profile_artifact_id is null or p.profile_sha256 is null or p.dispatch_fencing_token is null or p.request_artifact_id is null or p.request_sha256 is null or p.operation_id is distinct from new.operation_id or p.operation_step_id is distinct from new.operation_step_id or p.profile_artifact_id is distinct from new.profile_artifact_id or p.profile_sha256 is distinct from new.profile_sha256 or p.dispatch_fencing_token is distinct from new.dispatch_fencing_token or p.request_artifact_id is distinct from new.request_artifact_id or p.request_sha256 is distinct from new.request_sha256 or p.model is distinct from new.requested_model or p.state not in('dispatched','uncertain','settled') then raise exception 'semantic observation provider attempt binding mismatch' using errcode='foreign_key_violation'; end if;
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.blinded_input_artifact_id,'verification_semantic_blinded_input',new.blinded_input_sha256) or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.observation_artifact_id,'verification_semantic_response_observation',new.observation_sha256) then raise exception 'semantic observation artifact inadmissible' using errcode='foreign_key_violation'; end if;
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.request_artifact_id,'verification_provider_request',new.request_sha256)
 or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.response_envelope_artifact_id,'verification_provider_response_envelope',new.response_envelope_sha256)
 or not exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=new.request_artifact_id and m.parent_artifact_ids=array[new.blinded_input_artifact_id])
 then raise exception 'semantic observation exact blinded-input request closure mismatch' using errcode='foreign_key_violation'; end if;
 if not exists(select 1 from orchestration.verification_provider_response_capture c where c.tenant_id=new.tenant_id and c.provider_attempt_id=new.provider_attempt_id and c.operation_id=new.operation_id and c.operation_step_id=new.operation_step_id and c.profile_artifact_id=new.profile_artifact_id and c.profile_sha256=new.profile_sha256 and c.dispatch_fencing_token=new.dispatch_fencing_token and c.response_envelope_artifact_id=new.response_envelope_artifact_id) or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.raw_response_artifact_id,'verification_provider_raw_response',new.raw_response_sha256) or not exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id where a.tenant_id=new.tenant_id and a.id=new.response_envelope_artifact_id and a.sha256=new.response_envelope_sha256 and a.artifact_type='verification_provider_response_envelope' and m.parent_artifact_ids=array[new.request_artifact_id,new.raw_response_artifact_id]) or not exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=new.observation_artifact_id and m.parent_artifact_ids=array[new.blinded_input_artifact_id,new.response_envelope_artifact_id,new.profile_artifact_id]) then raise exception 'semantic observation exact response-envelope closure mismatch' using errcode='foreign_key_violation'; end if;
 return new;
end $$;
create trigger verification_semantic_response_observation_guard before insert or update or delete on orchestration.verification_semantic_response_observation for each row execute function orchestration.verification_semantic_response_observation_guard();
alter table orchestration.verification_semantic_response_observation enable row level security;
create policy verification_semantic_response_observation_worker on orchestration.verification_semantic_response_observation for all to executor_service,verifier_agent,control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
create policy verification_semantic_response_observation_reader on orchestration.verification_semantic_response_observation for select to app_reader using(tenant_id=util.current_tenant_id());
revoke all on orchestration.verification_semantic_response_observation from public,anon,authenticated;
grant select,insert on orchestration.verification_semantic_response_observation to executor_service,verifier_agent,control_plane;
grant select on orchestration.verification_semantic_response_observation to app_reader;
create or replace function orchestration.verification_provider_response_capture_guard() returns trigger language plpgsql set search_path='' as $$
declare claim jsonb; provider_row orchestration.verification_provider_attempt%rowtype; raw_id uuid; raw_sha text; expected_signature text;
begin
 if tg_op<>'INSERT' then raise exception 'provider response capture append-only' using errcode='restrict_violation'; end if;
 new.captured_at:=clock_timestamp();
 claim:=nullif(current_setting('verification.provider_claim',true),'')::jsonb;
 if claim is null then raise exception 'provider response capture active claim required' using errcode='check_violation';end if;
 perform 1 from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id and o.status='running' and ((o.operation_kind='verification_structured_extraction' and exists(select 1 from knowledge_service.operation_step x where x.tenant_id=o.tenant_id and x.id=new.operation_step_id and x.step_key='extract_and_register')) or (o.operation_kind='verification_claims' and exists(select 1 from knowledge_service.operation_step x where x.tenant_id=o.tenant_id and x.id=new.operation_step_id and x.step_key='verify_claims_and_register')) or (o.operation_kind='verification_report' and exists(select 1 from knowledge_service.operation_step x where x.tenant_id=o.tenant_id and x.id=new.operation_step_id and x.step_key='verify_report_and_register'))) for update;
 if not found then raise exception 'provider response capture active claim required' using errcode='check_violation';end if;
 perform step.id from knowledge_service.operation_step step join knowledge_service.operation o on o.tenant_id=step.tenant_id and o.id=step.operation_id join knowledge_service.lease l on l.tenant_id=step.tenant_id and l.operation_step_id=step.id where step.tenant_id=new.tenant_id and step.id=new.operation_step_id and step.operation_id=new.operation_id and ((o.operation_kind='verification_structured_extraction' and step.step_key='extract_and_register') or (o.operation_kind='verification_claims' and step.step_key='verify_claims_and_register') or (o.operation_kind='verification_report' and step.step_key='verify_report_and_register')) and step.status='running' and step.id::text=claim->>'stepId' and l.lease_token::text=claim->>'leaseToken' and l.fencing_token::text=claim->>'fencingToken' and l.holder_identity=claim->>'holderIdentity' and l.released_at is null and l.expires_at>clock_timestamp() for update of step,l;
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


alter table orchestration.verification_provider_attempt add column semantic_request_sha256 text
 check(semantic_request_sha256 is null or (operation_id is not null and semantic_request_sha256=request_sha256));
do $$ begin
 if exists(select 1 from orchestration.verification_provider_attempt p join knowledge_service.operation o on o.tenant_id=p.tenant_id and o.id=p.operation_id where o.operation_kind in('verification_claims','verification_report')) then
  raise exception 'existing semantic attempts require reviewed identity backfill';
 end if;
end $$;
create function orchestration.verification_provider_semantic_identity() returns trigger
language plpgsql security definer set search_path='' as $$
declare semantic_host boolean;
begin
 if tg_op='UPDATE' then
  if new.semantic_request_sha256 is distinct from old.semantic_request_sha256 then raise exception 'semantic provider logical identity immutable' using errcode='restrict_violation';end if;
  return new;
 end if;
 select o.operation_kind in('verification_claims','verification_report') into semantic_host from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id for share;
 if semantic_host is true then
  if new.semantic_request_sha256 is not null and new.semantic_request_sha256<>new.request_sha256 then raise exception 'semantic provider logical request mismatch' using errcode='check_violation';end if;
  new.semantic_request_sha256:=new.request_sha256;
 elsif new.semantic_request_sha256 is not null then
  raise exception 'nonsemantic provider cannot choose semantic identity' using errcode='check_violation';
 end if;
 return new;
end $$;
revoke all on function orchestration.verification_provider_semantic_identity() from public;
create trigger verification_provider_semantic_identity before insert or update on orchestration.verification_provider_attempt for each row execute function orchestration.verification_provider_semantic_identity();
drop index orchestration.verification_provider_attempt_scoped_operation_ordinal_uq;
create unique index verification_provider_attempt_scoped_operation_ordinal_uq on orchestration.verification_provider_attempt(tenant_id,operation_id,attempt_ordinal) where operation_id is not null and semantic_request_sha256 is null;
create unique index verification_provider_attempt_semantic_request_ordinal_uq on orchestration.verification_provider_attempt(tenant_id,operation_id,semantic_request_sha256,attempt_ordinal) where semantic_request_sha256 is not null;

alter table orchestration.verification_provider_attempt
 add column semantic_dispatch_lease_token uuid,
 add column semantic_dispatch_holder_identity text,
 add constraint semantic_dispatch_context_complete check (
   (semantic_dispatch_lease_token is null and semantic_dispatch_holder_identity is null and (semantic_request_sha256 is null or state='reserved'))
   or (semantic_request_sha256 is not null and state<>'reserved' and semantic_dispatch_lease_token is not null and semantic_dispatch_holder_identity is not null and length(semantic_dispatch_holder_identity)>0));
create function orchestration.verification_semantic_dispatch_context() returns trigger
language plpgsql set search_path='' as $$
declare claim jsonb;
begin
 if tg_op='INSERT' then
  if new.semantic_dispatch_lease_token is not null or new.semantic_dispatch_holder_identity is not null then
   raise exception 'semantic dispatch context cannot be supplied at reservation' using errcode='check_violation';
  end if;
  return new;
 end if;
 if new.semantic_dispatch_lease_token is distinct from old.semantic_dispatch_lease_token or new.semantic_dispatch_holder_identity is distinct from old.semantic_dispatch_holder_identity then
  raise exception 'semantic dispatch context immutable' using errcode='restrict_violation';
 end if;
 if new.semantic_request_sha256 is not null and old.state='reserved' and new.state='dispatched' then
  claim:=nullif(current_setting('verification.provider_claim',true),'')::jsonb;
  if claim is null or not orchestration.verification_provider_scope_tuple_is_live(new.tenant_id,new.operation_id,new.operation_step_id,new.profile_artifact_id,new.profile_sha256,claim) then
   raise exception 'semantic dispatch context requires live lease' using errcode='check_violation';
  end if;
  new.semantic_dispatch_lease_token:=(claim->>'leaseToken')::uuid;
  new.semantic_dispatch_holder_identity:=claim->>'holderIdentity';
 end if;
 return new;
end $$;
revoke all on function orchestration.verification_semantic_dispatch_context() from public;
create trigger z_verification_semantic_dispatch_context before insert or update on orchestration.verification_provider_attempt
 for each row execute function orchestration.verification_semantic_dispatch_context();


create or replace function orchestration.guard_provider_reconciliation() returns trigger language plpgsql set search_path='' as $$
declare
 p orchestration.verification_provider_attempt%rowtype;
 e orchestration.verification_structured_extraction_execution%rowtype;
 o knowledge_service.operation%rowtype;
 budget orchestration.verification_provider_budget%rowtype;
 capture orchestration.verification_provider_response_capture%rowtype;
 observation orchestration.verification_semantic_response_observation%rowtype;
 b jsonb; parents uuid[]; signature text; semantic_host text;
begin
 if tg_op<>'INSERT' then raise exception 'provider reconciliation is immutable' using errcode='restrict_violation'; end if;
 b:=new.body;

 if b->>'schemaVersion'='verification-provider-reconciliation.v1' then
  perform 1 from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id
   and operation_kind='verification_structured_extraction' and status in('succeeded','failed','cancelled') for update;
  if not found then raise exception 'provider reconciliation terminal operation required' using errcode='check_violation'; end if;
  select * into p from orchestration.verification_provider_attempt where tenant_id=new.tenant_id and id=new.provider_attempt_id;
  if not found then raise exception 'provider reconciliation original attempt missing' using errcode='foreign_key_violation'; end if;
  select * into budget from orchestration.verification_provider_budget where tenant_id=new.tenant_id and id=p.budget_id for update;
  select * into p from orchestration.verification_provider_attempt where tenant_id=new.tenant_id and id=new.provider_attempt_id for update;
  select * into e from orchestration.verification_structured_extraction_execution where tenant_id=new.tenant_id and operation_id=new.operation_id;
  if not coalesce(
   p.operation_id=new.operation_id and p.state in('dispatched','uncertain') and p.actual_cost_micros is null
   and b->>'tenantId'=new.tenant_id::text and b->>'operationId'=p.operation_id::text and b->>'operationStepId'=p.operation_step_id::text
   and b->>'providerAttemptId'=p.id::text and b->>'budgetId'=p.budget_id::text and b->>'providerId'=p.provider_id and b->>'model'=p.model
   and b->>'dispatchFence'=p.dispatch_fence::text and (b->>'dispatchFencingToken')::bigint=p.dispatch_fencing_token
   and b->>'requestDigest'='sha256:'||p.request_sha256 and b->>'originalState'=p.state and (b->>'reservationCostMicros')::bigint=p.reservation_cost_micros
   and b#>>'{decision,action}'='settle_original_attempt' and b#>'{decision,redispatchAuthorized}'='false'::jsonb
   and (b#>>'{decision,actualCostMicros}')::bigint between 0 and 20000000 and budget.reserved_cost_micros>=p.reservation_cost_micros
   and b#>>'{seal,purpose}'='provider_accounting_only' and b#>>'{seal,signature,algorithm}'='Ed25519'
   and (b->>'issuedAt')::timestamptz<=clock_timestamp() and (b->>'expiresAt')::timestamptz>clock_timestamp()
   and (b->>'expiresAt')::timestamptz>(b->>'issuedAt')::timestamptz and (b->>'expiresAt')::timestamptz<=(b->>'issuedAt')::timestamptz+interval '24 hours'
   and b#>>'{executionArtifact,artifactId}'=e.execution_artifact_id::text and b#>>'{executionArtifact,digest}'='sha256:'||e.execution_sha256
   and e.operation_step_id=p.operation_step_id and e.profile_artifact_id=p.profile_artifact_id and e.profile_sha256=p.profile_sha256
   and ((e.execution_mode='synthetic_transport' and b#>>'{decision,basis}'='synthetic_fixture') or (e.execution_mode='live_provider' and b#>>'{decision,basis}'='supplier_statement'))
   and b#>>'{requestArtifact,artifactId}'=p.request_artifact_id::text and b#>>'{requestArtifact,digest}'='sha256:'||p.request_sha256
   and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'executionArtifact')
   and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'requestArtifact')
   and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'billingEvidenceArtifact'),false)
  then raise exception 'provider reconciliation original identity or authority mismatch' using errcode='check_violation'; end if;
  if encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(b),'UTF8'),'sha256'),'hex')<>new.artifact_sha256
   or b#>>'{seal,payloadDigest}'<>'sha256:'||encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(b-'seal'),'UTF8'),'sha256'),'hex') then
   raise exception 'provider reconciliation canonical hash mismatch' using errcode='check_violation'; end if;
  parents:=array[e.execution_artifact_id,p.request_artifact_id,(b#>>'{billingEvidenceArtifact,artifactId}')::uuid];
  signature:=encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(jsonb_build_object(
   'schemaVersion','verification-provider-reconciliation-artifact.v1','tenantId',new.tenant_id,'providerAttemptId',p.id,
   'payloadDigest',b#>>'{seal,payloadDigest}','parents',parents)),'UTF8'),'sha256'),'hex');
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.artifact_id,'verification_provider_reconciliation',new.artifact_sha256)
   or not exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
    where a.tenant_id=new.tenant_id and a.id=new.artifact_id and a.created_at=(b->>'issuedAt')::timestamptz
    and m.producer_activity_id='verification-service:provider-reconciliation' and m.parent_artifact_ids=parents and m.transformation_signature=signature)
  then raise exception 'provider reconciliation registered artifact mismatch' using errcode='foreign_key_violation'; end if;
  new.applied_at:=clock_timestamp(); return new;
 end if;

 if b->>'schemaVersion' is distinct from 'verification-semantic-provider-reconciliation.v1' then
  raise exception 'unknown provider reconciliation schema' using errcode='check_violation';
 end if;
 select * into o from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id
  and operation_kind in('verification_claims','verification_report') and status in('succeeded','failed','cancelled') for update;
 if not found then raise exception 'semantic provider reconciliation terminal operation required' using errcode='check_violation'; end if;
 semantic_host:=case o.operation_kind when 'verification_claims' then 'claims' else 'report' end;
 select * into budget from orchestration.verification_provider_budget where tenant_id=new.tenant_id and id=(b->>'budgetId')::uuid for update;
 select * into p from orchestration.verification_provider_attempt where tenant_id=new.tenant_id and id=new.provider_attempt_id for update;
 if not found then raise exception 'semantic provider reconciliation original attempt missing' using errcode='foreign_key_violation'; end if;

 if not coalesce(
  p.tenant_id is not distinct from new.tenant_id and p.operation_id is not distinct from o.id and p.operation_step_id is not distinct from (b->>'operationStepId')::uuid
  and p.state in('dispatched','uncertain') and p.actual_cost_micros is null and p.budget_id is not distinct from budget.id
  and p.semantic_request_sha256 is not distinct from p.request_sha256
  and b->>'tenantId'=new.tenant_id::text and b->>'operationId'=o.id::text and b->>'providerAttemptId'=p.id::text and b->>'budgetId'=p.budget_id::text
  and b->>'host'=semantic_host and b->>'providerId'='gateway' and p.provider_id='gateway' and b->>'model'=p.model
  and b->>'dispatchFence'=p.dispatch_fence::text and b->>'dispatchLeaseToken'=p.semantic_dispatch_lease_token::text
  and b->>'dispatchHolderIdentity'=p.semantic_dispatch_holder_identity and (b->>'dispatchFencingToken')::bigint=p.dispatch_fencing_token
  and b->>'requestDigest'='sha256:'||p.request_sha256 and b->>'originalState'=p.state
  and (b->>'reservationCostMicros')::bigint=p.reservation_cost_micros and budget.reserved_cost_micros>=p.reservation_cost_micros
  and b#>>'{decision,action}'='settle_original_attempt' and b#>'{decision,redispatchAuthorized}'='false'::jsonb
  and (b#>>'{decision,actualCostMicros}')::bigint between 0 and 20000000
  and b#>>'{seal,purpose}'='provider_accounting_only' and b#>>'{seal,signature,algorithm}'='Ed25519'
  and b->>'issuedAt'=to_char((b->>'issuedAt')::timestamptz at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
  and b->>'expiresAt'=to_char((b->>'expiresAt')::timestamptz at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
  and (b->>'issuedAt')::timestamptz<=clock_timestamp() and (b->>'expiresAt')::timestamptz>clock_timestamp()
  and (b->>'expiresAt')::timestamptz>(b->>'issuedAt')::timestamptz and (b->>'expiresAt')::timestamptz<=(b->>'issuedAt')::timestamptz+interval '24 hours'
  and exists(select 1 from knowledge_service.operation_step s where s.tenant_id=o.tenant_id and s.id=p.operation_step_id and s.operation_id=o.id and s.step_kind=s.step_key
   and ((o.operation_kind='verification_claims' and s.step_key='verify_claims_and_register') or (o.operation_kind='verification_report' and s.step_key='verify_report_and_register')))
  and exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=p.request_artifact_id and m.parent_artifact_ids=array[(b#>>'{blindedInputArtifact,artifactId}')::uuid])
  and jsonb_typeof(b)='object' and b ?& array['schemaVersion','tenantId','operationId','operationStepId','providerAttemptId','budgetId','host','providerId','model','dispatchFence','dispatchLeaseToken','dispatchHolderIdentity','dispatchFencingToken','requestDigest','profileArtifact','blindedInputArtifact','requestArtifact','billingEvidenceArtifact','originalState','reservationCostMicros','decision','operatorId','ticketId','issuedAt','expiresAt','seal']
  and b-array['schemaVersion','tenantId','operationId','operationStepId','providerAttemptId','budgetId','host','providerId','model','dispatchFence','dispatchLeaseToken','dispatchHolderIdentity','dispatchFencingToken','requestDigest','profileArtifact','blindedInputArtifact','requestArtifact','billingEvidenceArtifact','capture','observationArtifact','originalState','reservationCostMicros','decision','operatorId','ticketId','issuedAt','expiresAt','seal']='{}'::jsonb
  and length(b->>'model') between 1 and 255 and length(b->>'dispatchHolderIdentity') between 1 and 255
  and b->>'operatorId'~'^[A-Za-z0-9][A-Za-z0-9._-]{0,119}$' and b->>'ticketId'~'^[A-Za-z0-9][A-Za-z0-9._-]{0,119}$'
  and jsonb_typeof(b->'decision')='object' and (b->'decision')-array['action','actualCostMicros','basis','redispatchAuthorized']='{}'::jsonb
  and b#>>'{decision,basis}' in('synthetic_fixture','supplier_statement')
  and jsonb_typeof(b->'seal')='object' and (b->'seal')-array['purpose','payloadDigest','signature']='{}'::jsonb
  and jsonb_typeof(b#>'{seal,signature}')='object' and (b#>'{seal,signature}')-array['algorithm','keyId','signatureBase64']='{}'::jsonb
  and b#>>'{seal,keyId}' is null and b#>>'{seal,signature,keyId}'~'^[A-Za-z0-9][A-Za-z0-9._-]{0,119}$' and b#>>'{seal,signature,signatureBase64}'~'^[A-Za-z0-9+/]{86}==$'
  and b#>>'{profileArtifact,artifactId}'=p.profile_artifact_id::text and b#>>'{profileArtifact,digest}'='sha256:'||p.profile_sha256
  and b#>>'{requestArtifact,artifactId}'=p.request_artifact_id::text and b#>>'{requestArtifact,digest}'='sha256:'||p.request_sha256
  and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'profileArtifact')
  and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'blindedInputArtifact')
  and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'requestArtifact')
  and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'billingEvidenceArtifact')
  and orchestration.verification_artifact_is_admitted(new.tenant_id,p.profile_artifact_id,'verification_semantic_judge_profile',p.profile_sha256)
  and orchestration.verification_artifact_is_admitted(new.tenant_id,(b#>>'{blindedInputArtifact,artifactId}')::uuid,'verification_semantic_blinded_input',substring(b#>>'{blindedInputArtifact,digest}' from 8))
  and orchestration.verification_artifact_is_admitted(new.tenant_id,p.request_artifact_id,'verification_provider_request',p.request_sha256),false)
 then raise exception 'semantic provider reconciliation original identity or authority mismatch' using errcode='check_violation'; end if;

 if b ? 'capture' then
  if not coalesce(jsonb_typeof(b->'capture')='object'
   and b->'capture' ?& array['transportArtifact','responseEnvelopeArtifact','rawResponseArtifact']
   and (b->'capture')-array['transportArtifact','responseEnvelopeArtifact','rawResponseArtifact']='{}'::jsonb
   and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b#>'{capture,transportArtifact}')
   and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b#>'{capture,responseEnvelopeArtifact}')
   and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b#>'{capture,rawResponseArtifact}'),false) then
   raise exception 'semantic provider reconciliation capture handle mismatch' using errcode='foreign_key_violation'; end if;
  select * into capture from orchestration.verification_provider_response_capture c where c.tenant_id=new.tenant_id and c.provider_attempt_id=p.id;
  if not coalesce(found and (p.response_artifact_id is null or p.response_artifact_id is not distinct from capture.response_envelope_artifact_id)
   and capture.operation_id is not distinct from o.id and capture.operation_step_id is not distinct from p.operation_step_id
   and capture.profile_artifact_id is not distinct from p.profile_artifact_id and capture.profile_sha256 is not distinct from p.profile_sha256
   and capture.dispatch_fencing_token is not distinct from p.dispatch_fencing_token
   and capture.transport_artifact_id is not distinct from (b#>>'{capture,transportArtifact,artifactId}')::uuid
   and capture.transport_sha256 is not distinct from substring(b#>>'{capture,transportArtifact,digest}' from 8)
   and capture.response_envelope_artifact_id is not distinct from (b#>>'{capture,responseEnvelopeArtifact,artifactId}')::uuid
   and exists(select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=capture.response_envelope_artifact_id and a.sha256=substring(b#>>'{capture,responseEnvelopeArtifact,digest}' from 8))
   and orchestration.verification_artifact_is_admitted(new.tenant_id,capture.transport_artifact_id,'verification_provider_transport_response',capture.transport_sha256)
   and orchestration.verification_artifact_is_admitted(new.tenant_id,capture.response_envelope_artifact_id,'verification_provider_response_envelope',substring(b#>>'{capture,responseEnvelopeArtifact,digest}' from 8))
   and orchestration.verification_artifact_is_admitted(new.tenant_id,(b#>>'{capture,rawResponseArtifact,artifactId}')::uuid,'verification_provider_raw_response',substring(b#>>'{capture,rawResponseArtifact,digest}' from 8))
   and exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=capture.response_envelope_artifact_id and m.parent_artifact_ids=array[p.request_artifact_id,(b#>>'{capture,rawResponseArtifact,artifactId}')::uuid]),false) then
   raise exception 'semantic provider reconciliation capture ledger mismatch' using errcode='foreign_key_violation'; end if;
  if b ? 'observationArtifact' then
   if not coalesce(orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'observationArtifact'),false) then raise exception 'semantic provider reconciliation observation handle mismatch' using errcode='foreign_key_violation'; end if;
   select * into observation from orchestration.verification_semantic_response_observation so where so.tenant_id=new.tenant_id and so.provider_attempt_id=p.id;
   if not coalesce(found and observation.operation_id is not distinct from o.id and observation.operation_step_id is not distinct from p.operation_step_id
    and observation.producer_attempt_id is not distinct from o.attempt_id and observation.profile_artifact_id is not distinct from p.profile_artifact_id and observation.profile_sha256 is not distinct from p.profile_sha256
    and observation.dispatch_fencing_token is not distinct from p.dispatch_fencing_token
    and observation.blinded_input_artifact_id is not distinct from (b#>>'{blindedInputArtifact,artifactId}')::uuid and observation.blinded_input_sha256 is not distinct from substring(b#>>'{blindedInputArtifact,digest}' from 8)
    and observation.request_artifact_id is not distinct from p.request_artifact_id and observation.request_sha256 is not distinct from p.request_sha256
    and observation.raw_response_artifact_id is not distinct from (b#>>'{capture,rawResponseArtifact,artifactId}')::uuid and observation.raw_response_sha256 is not distinct from substring(b#>>'{capture,rawResponseArtifact,digest}' from 8)
    and observation.response_envelope_artifact_id is not distinct from capture.response_envelope_artifact_id and observation.response_envelope_sha256 is not distinct from substring(b#>>'{capture,responseEnvelopeArtifact,digest}' from 8)
    and observation.observation_artifact_id is not distinct from (b#>>'{observationArtifact,artifactId}')::uuid and observation.observation_sha256 is not distinct from substring(b#>>'{observationArtifact,digest}' from 8)
    and orchestration.verification_artifact_is_admitted(new.tenant_id,observation.observation_artifact_id,'verification_semantic_response_observation',substring(b#>>'{observationArtifact,digest}' from 8)),false) then
    raise exception 'semantic provider reconciliation observation ledger mismatch' using errcode='foreign_key_violation'; end if;
  elsif exists(select 1 from orchestration.verification_semantic_response_observation so where so.tenant_id=new.tenant_id and so.provider_attempt_id=p.id) then
   raise exception 'semantic provider reconciliation omits existing observation' using errcode='foreign_key_violation';
  end if;
 elsif b ? 'observationArtifact' or p.response_artifact_id is not null
   or exists(select 1 from orchestration.verification_provider_response_capture c where c.tenant_id=new.tenant_id and c.provider_attempt_id=p.id)
   or exists(select 1 from orchestration.verification_semantic_response_observation so where so.tenant_id=new.tenant_id and so.provider_attempt_id=p.id) then
  raise exception 'semantic provider reconciliation custody state mismatch' using errcode='foreign_key_violation';
 end if;

 if encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(b),'UTF8'),'sha256'),'hex')<>new.artifact_sha256
  or b#>>'{seal,payloadDigest}'<>'sha256:'||encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(b-'seal'),'UTF8'),'sha256'),'hex') then
  raise exception 'semantic provider reconciliation canonical hash mismatch' using errcode='check_violation'; end if;
 parents:=array[(b#>>'{profileArtifact,artifactId}')::uuid,(b#>>'{blindedInputArtifact,artifactId}')::uuid,p.request_artifact_id,(b#>>'{billingEvidenceArtifact,artifactId}')::uuid]
   ||case when b ? 'capture' then array[(b#>>'{capture,transportArtifact,artifactId}')::uuid,(b#>>'{capture,responseEnvelopeArtifact,artifactId}')::uuid,(b#>>'{capture,rawResponseArtifact,artifactId}')::uuid] else array[]::uuid[] end
   ||case when b ? 'observationArtifact' then array[(b#>>'{observationArtifact,artifactId}')::uuid] else array[]::uuid[] end;
 if cardinality(parents)<>cardinality(array(select distinct x from unnest(parents) x)) then raise exception 'semantic provider reconciliation parent roles alias' using errcode='check_violation'; end if;
 signature:=encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(jsonb_build_object(
  'schemaVersion','verification-semantic-provider-reconciliation-artifact.v1','tenantId',new.tenant_id,'providerAttemptId',p.id,
  'payloadDigest',b#>>'{seal,payloadDigest}','parents',parents)),'UTF8'),'sha256'),'hex');
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.artifact_id,'verification_provider_reconciliation',new.artifact_sha256)
  or not exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
   where a.tenant_id=new.tenant_id and a.id=new.artifact_id and a.created_at=(b->>'issuedAt')::timestamptz
   and m.producer_activity_id='verification-service:semantic-provider-reconciliation' and m.parent_artifact_ids=parents and m.transformation_signature=signature)
 then raise exception 'semantic provider reconciliation registered artifact mismatch' using errcode='foreign_key_violation'; end if;
 if not coalesce((b->>'issuedAt')::timestamptz<=clock_timestamp()
  and (b->>'expiresAt')::timestamptz>clock_timestamp()
  and (b->>'expiresAt')::timestamptz>(b->>'issuedAt')::timestamptz
  and (b->>'expiresAt')::timestamptz<=(b->>'issuedAt')::timestamptz+interval '24 hours',false) then
  raise exception 'semantic provider reconciliation expired after custody reads' using errcode='check_violation'; end if;

 new.applied_at:=clock_timestamp(); return new;
end $$;

commit;
