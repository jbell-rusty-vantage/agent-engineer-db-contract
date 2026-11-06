-- Reconcile the modeled vector-store lifecycle with the earlier blanket
-- append-only trigger. Identity/configuration remain immutable; only this
-- control-plane, tenant-scoped transition function may change lifecycle.
begin;

drop trigger vector_store_immutable on retrieval.vector_store;

create table retrieval.vector_store_lifecycle_event (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  vector_store_id uuid not null,
  actor_identity text not null,
  reason text not null check(length(btrim(reason)) between 1 and 2000),
  previous_lifecycle text not null,
  new_lifecycle text not null,
  occurred_at timestamptz not null default now(),
  unique(tenant_id,id),
  foreign key(tenant_id,vector_store_id) references retrieval.vector_store(tenant_id,id) on delete restrict
);

create trigger vector_store_lifecycle_event_immutable before update or delete
  on retrieval.vector_store_lifecycle_event for each row execute function util.reject_mutation();

create trigger vector_store_configuration_immutable before update of
  name,purpose,visibility,quota_profile,retention_policy,deletion_policy,
  created_by_attempt_id,supersedes_id,created_at
on retrieval.vector_store for each row execute function retrieval.reject_vector_store_identity_mutation();

create function retrieval.guard_vector_store_lifecycle_transition() returns trigger
language plpgsql set search_path='' as $$
begin
  if current_user <> 'control_plane'
     or current_setting('app.vector_store_lifecycle_transition',true) <> 'authorized' then
    raise exception 'vector store lifecycle transition requires the control-plane function'
      using errcode='insufficient_privilege';
  end if;
  if not (
    (old.lifecycle='active' and new.lifecycle in ('suspended','superseded','deleted'))
    or (old.lifecycle='suspended' and new.lifecycle in ('active','superseded','deleted'))
  ) then
    raise exception 'illegal vector store lifecycle transition % -> %',old.lifecycle,new.lifecycle
      using errcode='object_not_in_prerequisite_state';
  end if;
  return new;
end $$;

create trigger vector_store_lifecycle_guard before update of lifecycle
  on retrieval.vector_store for each row
  execute function retrieval.guard_vector_store_lifecycle_transition();

create function retrieval.require_active_vector_store_reference() returns trigger
language plpgsql set search_path='' as $$
begin
  if not exists(select 1 from retrieval.vector_store s
    where s.tenant_id=new.tenant_id and s.id=new.vector_store_id and s.lifecycle='active') then
    raise exception 'active vector store is required' using errcode='object_not_in_prerequisite_state';
  end if;
  return new;
end $$;
create trigger vector_store_document_active_parent before insert
  on retrieval.vector_store_document for each row
  execute function retrieval.require_active_vector_store_reference();
create trigger vector_store_ingestion_active_parent before insert
  on retrieval.vector_store_ingestion_run for each row
  execute function retrieval.require_active_vector_store_reference();

create function retrieval.transition_vector_store_lifecycle(
  p_vector_store_id uuid,
  p_target_lifecycle text,
  p_actor_identity text,
  p_reason text,
  p_successor_id uuid default null
) returns uuid
language plpgsql security invoker set search_path='' as $$
declare
  v_tenant uuid := util.current_tenant_id();
  v_store retrieval.vector_store%rowtype;
  v_event_id uuid := util.uuidv7();
  v_minimum_days integer;
begin
  if current_user <> 'control_plane' then
    raise exception 'control_plane role is required' using errcode='insufficient_privilege';
  end if;
  if v_tenant is null then
    raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege';
  end if;
  if nullif(btrim(p_actor_identity),'') is null or nullif(btrim(p_reason),'') is null then
    raise exception 'actor identity and reason are required' using errcode='invalid_parameter_value';
  end if;
  if p_target_lifecycle not in ('active','suspended','superseded','deleted') then
    raise exception 'invalid vector store lifecycle target' using errcode='invalid_parameter_value';
  end if;

  select * into v_store from retrieval.vector_store
    where tenant_id=v_tenant and id=p_vector_store_id for update;
  if v_store.id is null then raise exception 'vector store not found' using errcode='no_data_found'; end if;

  if p_target_lifecycle='superseded' and not exists(
    select 1 from retrieval.vector_store successor
    where successor.tenant_id=v_tenant and successor.id=p_successor_id
      and successor.supersedes_id=v_store.id and successor.store_class=v_store.store_class
      and successor.owner_identity=v_store.owner_identity and successor.lifecycle='active'
  ) then
    raise exception 'compatible active successor is required' using errcode='object_not_in_prerequisite_state';
  end if;
  if p_target_lifecycle<>'superseded' and p_successor_id is not null then
    raise exception 'successor is only valid for supersession' using errcode='invalid_parameter_value';
  end if;

  if p_target_lifecycle='deleted' then
    v_minimum_days := coalesce((v_store.deletion_policy->>'minimumRetentionDays')::integer,0);
    if now() < v_store.created_at + make_interval(days=>v_minimum_days) then
      raise exception 'minimum retention period has not elapsed' using errcode='object_not_in_prerequisite_state';
    end if;
    if v_store.deletion_policy->>'mode' <> 'tombstone_only' then
      raise exception 'review-required deletion is not admitted by this control-plane slice'
        using errcode='object_not_in_prerequisite_state';
    end if;
  end if;

  perform set_config('app.vector_store_lifecycle_transition','authorized',true);
  update retrieval.vector_store set lifecycle=p_target_lifecycle
    where tenant_id=v_tenant and id=v_store.id;
  insert into retrieval.vector_store_lifecycle_event
    (id,tenant_id,vector_store_id,actor_identity,reason,previous_lifecycle,new_lifecycle)
  values(v_event_id,v_tenant,v_store.id,p_actor_identity,p_reason,v_store.lifecycle,p_target_lifecycle);
  return v_event_id;
end $$;

alter table retrieval.vector_store_lifecycle_event enable row level security;
alter table retrieval.vector_store_lifecycle_event force row level security;
create policy control_plane_access on retrieval.vector_store_lifecycle_event
  for all to control_plane using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());

revoke all on function retrieval.transition_vector_store_lifecycle(uuid,text,text,text,uuid) from public,anon,authenticated,executor_service,service_role;
grant usage on schema retrieval to control_plane;
grant select on retrieval.vector_store to control_plane;
grant update(lifecycle) on retrieval.vector_store to control_plane;
grant execute on function retrieval.transition_vector_store_lifecycle(uuid,text,text,text,uuid) to control_plane;
grant select,insert on retrieval.vector_store_lifecycle_event to control_plane;
revoke update,delete on retrieval.vector_store_lifecycle_event from control_plane;

commit;
