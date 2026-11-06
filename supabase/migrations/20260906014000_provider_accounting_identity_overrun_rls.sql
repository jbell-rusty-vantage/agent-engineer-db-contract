begin;

-- A settled supplier charge may legitimately exceed its reservation. Preserve the
-- evidence and let subsequent reservations fail against the shared pilot ceiling.
do $$ declare constraint_name text; begin
  select conname into constraint_name from pg_constraint
   where conrelid='orchestration.verification_provider_budget'::regclass and contype='c'
     and pg_get_constraintdef(oid) like '%reserved_cost_micros + settled_cost_micros%';
  if constraint_name is not null then execute format('alter table orchestration.verification_provider_budget drop constraint %I', constraint_name); end if;
end $$;
alter table orchestration.verification_provider_budget
  add constraint verification_provider_budget_reservation_ceiling_ck check (reserved_cost_micros <= ceiling_cost_micros);

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

alter table orchestration.verification_provider_budget enable row level security;
alter table orchestration.verification_provider_attempt enable row level security;
drop policy if exists verification_provider_budget_tenant_isolation on orchestration.verification_provider_budget;
drop policy if exists verification_provider_attempt_tenant_isolation on orchestration.verification_provider_attempt;
create policy verification_provider_budget_bounded_role_access on orchestration.verification_provider_budget
  for all to executor_service,verifier_agent,control_plane
  using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());
create policy verification_provider_attempt_bounded_role_access on orchestration.verification_provider_attempt
  for all to executor_service,verifier_agent,control_plane
  using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());
create policy verification_provider_budget_reader_access on orchestration.verification_provider_budget
  for select to app_reader using (tenant_id=util.current_tenant_id());
create policy verification_provider_attempt_reader_access on orchestration.verification_provider_attempt
  for select to app_reader using (tenant_id=util.current_tenant_id());
revoke all on orchestration.verification_provider_budget,orchestration.verification_provider_attempt from public,anon,authenticated;
grant select,insert,update on orchestration.verification_provider_budget,orchestration.verification_provider_attempt to executor_service,verifier_agent,control_plane;
grant select on orchestration.verification_provider_budget,orchestration.verification_provider_attempt to app_reader;

commit;
