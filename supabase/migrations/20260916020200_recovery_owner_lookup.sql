-- Qualify lookup variables independently of generated owner-table column names.
create or replace function knowledge_service.check_recovery_original_authority() returns trigger
language plpgsql set search_path='' as $$
declare binding_source_id uuid; binding_source_kind text; owner_case text;
begin
  binding_source_id := coalesce(new.original_operation_id,new.original_intent_id);
  binding_source_kind := case when new.original_operation_id is not null then 'native' else 'intent' end;
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
  where owner.tenant_id=new.tenant_id and owner.source_kind=binding_source_kind
    and owner.source_id=binding_source_id and owner.input_digest=new.original_input_digest;
  if owner_case is distinct from new.case_id then
    raise exception 'recovery original binding already belongs to another case' using errcode='23505';
  end if;
  return new;
end $$;
