begin;
alter table orchestration.verification_provider_attempt add column dispatch_fence uuid;
create unique index verification_provider_attempt_dispatch_fence_idx on orchestration.verification_provider_attempt(tenant_id,dispatch_fence) where dispatch_fence is not null;
create or replace function orchestration.verification_provider_attempt_guard() returns trigger language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE' then raise exception 'verification provider attempts are append-only' using errcode = 'restrict_violation'; end if;
  if new.tenant_id <> old.tenant_id or new.budget_id <> old.budget_id or new.request_sha256 <> old.request_sha256 or new.attempt_ordinal <> old.attempt_ordinal or new.provider_id <> old.provider_id or new.model <> old.model or new.reservation_cost_micros <> old.reservation_cost_micros or new.created_at <> old.created_at then raise exception 'verification provider attempt immutable identity' using errcode = 'restrict_violation'; end if;
  if old.state = 'reserved' and new.state = 'dispatched' and old.dispatched_at is null and new.dispatched_at is not null and new.reconciled_at is null and new.actual_cost_micros is null and new.dispatch_fence is not null then return new; end if;
  if old.state = 'dispatched' and new.state = 'uncertain' and new.dispatched_at = old.dispatched_at and new.reconciled_at is null and new.actual_cost_micros is null and new.dispatch_fence = old.dispatch_fence then return new; end if;
  if old.state in ('dispatched','uncertain') and new.state = 'settled' and new.dispatched_at = old.dispatched_at and new.reconciled_at is not null and new.actual_cost_micros is not null and new.dispatch_fence = old.dispatch_fence then return new; end if;
  raise exception 'verification provider attempt state transition invalid' using errcode = 'restrict_violation';
end;
$$;
commit;
