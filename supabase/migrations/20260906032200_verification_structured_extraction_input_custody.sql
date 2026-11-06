begin;

create function orchestration.guard_structured_extraction_input_custody()
returns trigger language plpgsql set search_path='' as $$
declare kind text; bound boolean; step_count bigint;
begin
 if tg_table_name='operation' then
  if tg_op='INSERT' then return new; end if;
  if old.operation_kind is distinct from 'verification_structured_extraction' then return new; end if;
  select exists(select 1 from orchestration.verification_structured_extraction_execution e where e.tenant_id=old.tenant_id and e.operation_id=old.id) into bound;
  if bound and (new.id is distinct from old.id or new.tenant_id is distinct from old.tenant_id or new.operation_kind is distinct from old.operation_kind
   or new.request is distinct from old.request or new.request_sha256 is distinct from old.request_sha256 or new.attempt_id is distinct from old.attempt_id
   or new.mission_id is distinct from old.mission_id or new.work_item_id is distinct from old.work_item_id
   or new.idempotency_key is distinct from old.idempotency_key or new.correlation_id is distinct from old.correlation_id
   or new.causation_id is distinct from old.causation_id or new.actor_identity is distinct from old.actor_identity) then
   raise exception 'structured extraction bound operation input is immutable' using errcode='restrict_violation';
  end if;
  if new.status='succeeded' then
   select count(*) into step_count from knowledge_service.operation_step s where s.tenant_id=new.tenant_id and s.operation_id=new.id;
   if step_count<>1 then raise exception 'structured extraction terminal requires exactly one step' using errcode='check_violation'; end if;
  end if;
 else
  if tg_op='INSERT' then
   select o.operation_kind into kind from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id;
   if kind='verification_structured_extraction' and exists(select 1 from orchestration.verification_structured_extraction_execution e where e.tenant_id=new.tenant_id and e.operation_id=new.operation_id) then
    raise exception 'structured extraction bound step set is immutable' using errcode='restrict_violation';
   end if;
  else
   select exists(select 1 from orchestration.verification_structured_extraction_execution e where e.tenant_id=old.tenant_id and e.operation_step_id=old.id) into bound;
   if bound and (new.id is distinct from old.id or new.tenant_id is distinct from old.tenant_id or new.operation_id is distinct from old.operation_id
    or new.input is distinct from old.input or new.input_sha256 is distinct from old.input_sha256
    or new.step_key is distinct from old.step_key or new.step_kind is distinct from old.step_kind) then
    raise exception 'structured extraction bound step input is immutable' using errcode='restrict_violation';
   end if;
   if bound and new.status='succeeded' then
    select count(*) into step_count from knowledge_service.operation_step s where s.tenant_id=new.tenant_id and s.operation_id=new.operation_id;
    if step_count<>1 then raise exception 'structured extraction terminal requires exactly one step' using errcode='check_violation'; end if;
   end if;
  end if;
 end if;
 return new;
end $$;
create trigger verification_structured_extraction_input_custody before insert or update on knowledge_service.operation
 for each row execute function orchestration.guard_structured_extraction_input_custody();
create trigger verification_structured_extraction_input_custody before insert or update on knowledge_service.operation_step
 for each row execute function orchestration.guard_structured_extraction_input_custody();
commit;
