begin;
create function orchestration.guard_structured_extraction_owner_custody()
returns trigger language plpgsql set search_path='' as $$
begin
 if tg_table_name='operation' then
  if old.operation_kind='verification_structured_extraction' and exists(select 1 from orchestration.verification_structured_extraction_execution e where e.tenant_id=old.tenant_id and e.operation_id=old.id)
   and (new.ownership_mode is distinct from old.ownership_mode or new.external_run_id is distinct from old.external_run_id
    or new.capability_version_id is distinct from old.capability_version_id or new.created_at is distinct from old.created_at) then
   raise exception 'structured extraction bound owner and creation identity is immutable' using errcode='restrict_violation';
  end if;
 else
  if exists(select 1 from orchestration.verification_structured_extraction_execution e where e.tenant_id=old.tenant_id and e.operation_step_id=old.id)
   and (new.created_at is distinct from old.created_at or new.max_attempts is distinct from old.max_attempts) then
   raise exception 'structured extraction bound step creation and retry limit is immutable' using errcode='restrict_violation';
  end if;
 end if;
 return new;
end $$;
create trigger verification_structured_extraction_owner_custody before update on knowledge_service.operation
 for each row execute function orchestration.guard_structured_extraction_owner_custody();
create trigger verification_structured_extraction_owner_custody before update on knowledge_service.operation_step
 for each row execute function orchestration.guard_structured_extraction_owner_custody();
commit;
