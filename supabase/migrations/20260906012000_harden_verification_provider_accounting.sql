begin;

alter table orchestration.verification_provider_attempt
  drop constraint if exists verification_provider_attempt_request_artifact_id_fkey,
  drop constraint if exists verification_provider_attempt_response_artifact_id_fkey;
alter table orchestration.verification_provider_attempt
  add constraint verification_provider_attempt_request_artifact_tenant_fkey foreign key (tenant_id,request_artifact_id) references orchestration.artifact(tenant_id,id),
  add constraint verification_provider_attempt_response_artifact_tenant_fkey foreign key (tenant_id,response_artifact_id) references orchestration.artifact(tenant_id,id);

create or replace function orchestration.verification_provider_attempt_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE' then raise exception 'verification provider attempts are append-only' using errcode = 'restrict_violation'; end if;
  if new.tenant_id <> old.tenant_id or new.budget_id <> old.budget_id or new.request_sha256 <> old.request_sha256
     or new.attempt_ordinal <> old.attempt_ordinal or new.provider_id <> old.provider_id or new.model <> old.model
     or new.reservation_cost_micros <> old.reservation_cost_micros or new.created_at <> old.created_at then
    raise exception 'verification provider attempt immutable identity' using errcode = 'restrict_violation';
  end if;
  if old.state = 'reserved' and new.state = 'dispatched' and old.dispatched_at is null and new.dispatched_at is not null and new.reconciled_at is null and new.actual_cost_micros is null then return new; end if;
  if old.state = 'dispatched' and new.state = 'uncertain' and new.dispatched_at = old.dispatched_at and new.reconciled_at is null and new.actual_cost_micros is null then return new; end if;
  if old.state in ('dispatched','uncertain') and new.state = 'settled' and new.dispatched_at = old.dispatched_at and new.reconciled_at is not null and new.actual_cost_micros is not null then return new; end if;
  raise exception 'verification provider attempt state transition invalid' using errcode = 'restrict_violation';
end;
$$;

create or replace function orchestration.verification_provider_budget_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE' then raise exception 'verification provider budgets are append-only' using errcode = 'restrict_violation'; end if;
  if new.id <> old.id or new.tenant_id <> old.tenant_id or new.budget_key <> old.budget_key or new.ceiling_cost_micros <> old.ceiling_cost_micros then raise exception 'verification provider budget immutable identity' using errcode = 'restrict_violation'; end if;
  return new;
end;
$$;
create trigger verification_provider_budget_immutable before update or delete on orchestration.verification_provider_budget for each row execute function orchestration.verification_provider_budget_guard();

alter table orchestration.verification_provider_budget enable row level security;
alter table orchestration.verification_provider_attempt enable row level security;
create policy verification_provider_budget_tenant_isolation on orchestration.verification_provider_budget using (tenant_id = current_setting('app.tenant_id', true)::uuid) with check (tenant_id = current_setting('app.tenant_id', true)::uuid);
create policy verification_provider_attempt_tenant_isolation on orchestration.verification_provider_attempt using (tenant_id = current_setting('app.tenant_id', true)::uuid) with check (tenant_id = current_setting('app.tenant_id', true)::uuid);

commit;
