begin;
set local lock_timeout = '15s';

insert into orchestration.artifact_type(code, description) values
  ('content_summary_text', 'Deterministic retained admitted-statement summary output awaiting independent representation review'),
  ('content_summary_preparation_receipt', 'Actual deterministic summary transformation, input/output custody and pending representation receipt')
on conflict (code) do update set description = excluded.description;

-- No-op ingestion still reconciles against one locked knowledge clock.
create function temporal.lock_knowledge_head(p_expected_head bigint)
returns bigint language plpgsql security definer set search_path = '' as $$
declare
  current_head temporal.knowledge_head;
  tenant uuid := util.current_tenant_id();
begin
  if p_expected_head is null or p_expected_head < 0 then
    raise exception 'expected knowledge head required' using errcode = '22023';
  end if;
  insert into temporal.knowledge_head(tenant_id) values(tenant) on conflict do nothing;
  select * into strict current_head from temporal.knowledge_head where tenant_id = tenant for update;
  if current_head.open_xid is not null then
    raise exception 'knowledge batch already open';
  end if;
  if current_head.knowledge_seq <> p_expected_head then
    raise exception 'rebase_required' using errcode = '40001';
  end if;
  return current_head.knowledge_seq;
end;
$$;

revoke all on function temporal.lock_knowledge_head(bigint) from public, anon, authenticated, service_role,
  app_reader, pipeline_agent, verifier_agent, control_plane;
grant execute on function temporal.lock_knowledge_head(bigint) to executor_service;
comment on function temporal.lock_knowledge_head(bigint) is
  'Lock the current tenant knowledge clock through transaction end without opening or advancing a batch; exact expected head required.';
commit;
