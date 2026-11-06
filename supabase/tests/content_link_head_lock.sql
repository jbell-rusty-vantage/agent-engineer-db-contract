begin;
select set_config('app.tenant_id', util.uuidv7()::text, true);

do $$
begin
  if not has_function_privilege('executor_service', 'temporal.lock_knowledge_head(bigint)', 'execute') then
    raise exception 'executor head lock grant missing';
  end if;
  if has_function_privilege('pipeline_agent', 'temporal.lock_knowledge_head(bigint)', 'execute')
    or has_function_privilege('app_reader', 'temporal.lock_knowledge_head(bigint)', 'execute') then
    raise exception 'reader may lock the knowledge clock';
  end if;
end;
$$;

set local role executor_service;
do $$
begin
  if temporal.lock_knowledge_head(0) <> 0 then raise exception 'new tenant head changed'; end if;
  if exists(select 1 from temporal.knowledge_head where tenant_id = util.current_tenant_id()
      and (knowledge_seq <> 0 or open_xid is not null or open_k is not null)) then
    raise exception 'head lock opened or advanced a batch';
  end if;
  if temporal.lock_knowledge_head(0) <> 0 then raise exception 'head lock is not repeatable'; end if;
  begin
    perform temporal.lock_knowledge_head(1);
    raise exception 'stale knowledge clock accepted';
  exception when serialization_failure then null;
  end;
  begin
    perform temporal.lock_knowledge_head(null);
    raise exception 'missing knowledge clock accepted';
  exception when invalid_parameter_value then null;
  end;
end;
$$;
rollback;
