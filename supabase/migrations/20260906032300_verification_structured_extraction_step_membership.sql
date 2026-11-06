begin;
create function orchestration.guard_structured_extraction_step_membership()
returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='UPDATE' and new.tenant_id=old.tenant_id and new.operation_id=old.operation_id and new.id=old.id then return new; end if;
 if exists(select 1 from orchestration.verification_structured_extraction_execution e
  where e.tenant_id=new.tenant_id and e.operation_id=new.operation_id and e.operation_step_id<>new.id) then
  raise exception 'structured extraction bound step membership is immutable' using errcode='restrict_violation';
 end if;
 return new;
end $$;
create trigger verification_structured_extraction_step_membership before insert or update on knowledge_service.operation_step
 for each row execute function orchestration.guard_structured_extraction_step_membership();
commit;
