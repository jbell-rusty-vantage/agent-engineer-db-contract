-- A unique owner survives snapshot isolation; a post-lock SELECT alone does not.
create table knowledge_service.recovery_binding_owner (
  tenant_id uuid not null,
  original_operation_id uuid,
  original_intent_id uuid,
  source_kind text generated always as
    (case when original_operation_id is not null then 'native' else 'intent' end) stored,
  source_id uuid generated always as (coalesce(original_operation_id,original_intent_id)) stored,
  input_digest text not null check(input_digest ~ '^sha256:[a-f0-9]{64}$'),
  case_id text not null,
  primary key(tenant_id,source_kind,source_id,input_digest),
  check((original_operation_id is null) <> (original_intent_id is null)),
  foreign key(tenant_id,original_operation_id) references knowledge_service.operation(tenant_id,id),
  foreign key(tenant_id,original_intent_id) references orchestration.operation_intent(tenant_id,id),
  foreign key(tenant_id,case_id) references knowledge_service.recovery_case(tenant_id,case_id)
);

insert into knowledge_service.recovery_binding_owner
  (tenant_id,original_operation_id,original_intent_id,input_digest,case_id)
select distinct tenant_id,original_operation_id,original_intent_id,original_input_digest,case_id
from knowledge_service.recovery_original;

alter table knowledge_service.recovery_binding_owner enable row level security;
create policy recovery_binding_owner_tenant on knowledge_service.recovery_binding_owner for all to executor_service
  using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert on knowledge_service.recovery_binding_owner to executor_service;
create trigger recovery_binding_owner_immutable before update or delete on knowledge_service.recovery_binding_owner
  for each row execute function util.reject_mutation();

create or replace function knowledge_service.check_recovery_original_authority() returns trigger
language plpgsql set search_path='' as $$
declare source_id uuid; source_kind text; owner_case text;
begin
  source_id := coalesce(new.original_operation_id,new.original_intent_id);
  source_kind := case when new.original_operation_id is not null then 'native' else 'intent' end;
  if new.original_intent_id is not null and not exists (
    select 1 from orchestration.operation_intent i
    where i.tenant_id=new.tenant_id and i.id=new.original_intent_id and i.intent_type='verify_claim'
  ) then
    raise exception 'recovery original requires a tenant-scoped verification intent' using errcode='23514';
  end if;
  if (new.original_operation_id is null) = (new.original_intent_id is null) then
    raise exception 'recovery original requires exactly one authority' using errcode='23514';
  end if;
  insert into knowledge_service.recovery_binding_owner
    (tenant_id,original_operation_id,original_intent_id,input_digest,case_id)
  values(new.tenant_id,new.original_operation_id,new.original_intent_id,new.original_input_digest,new.case_id)
  on conflict do nothing;
  select owner.case_id into owner_case from knowledge_service.recovery_binding_owner owner
  where owner.tenant_id=new.tenant_id and owner.source_kind=source_kind
    and owner.source_id=source_id and owner.input_digest=new.original_input_digest;
  if owner_case is distinct from new.case_id then
    raise exception 'recovery original binding already belongs to another case' using errcode='23505';
  end if;
  return new;
end $$;
