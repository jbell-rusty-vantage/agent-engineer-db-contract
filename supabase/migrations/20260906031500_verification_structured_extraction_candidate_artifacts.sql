begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_extraction_candidate','Schema-valid structured extraction output; unverified candidate'),
 ('verification_structured_extraction_provenance','Immutable unverified candidate and captured provider ancestry')
on conflict(code) do update set description=excluded.description;

-- Candidate storage does not establish canonical extraction completion. Keep
-- direct SQL terminal writes closed until the reviewed lifecycle/receipt guard
-- replaces this function. Existing captured responses remain replayable.
create function orchestration.verification_structured_extraction_completion_guard()
returns trigger language plpgsql set search_path='' as $$
declare extraction_operation boolean;
begin
 if tg_table_name='operation' then
  extraction_operation:=new.operation_kind='verification_structured_extraction';
 else
  select o.operation_kind='verification_structured_extraction' into extraction_operation
   from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id;
 end if;
 if extraction_operation and new.status='succeeded' then
  raise exception 'structured extraction terminal lifecycle not configured' using errcode='check_violation';
 end if;
 return new;
end $$;
create trigger verification_structured_extraction_completion_guard
 before insert or update on knowledge_service.operation for each row
 execute function orchestration.verification_structured_extraction_completion_guard();
create trigger verification_structured_extraction_completion_guard
 before insert or update on knowledge_service.operation_step for each row
 execute function orchestration.verification_structured_extraction_completion_guard();

commit;
