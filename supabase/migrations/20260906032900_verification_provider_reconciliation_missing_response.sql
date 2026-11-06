begin;
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
  -- A reconciled supplier decision does not fabricate a missing response envelope.
  if current_setting('verification.provider_reconciliation',true)=new.id::text
     and old.state in('dispatched','uncertain') and new.state='settled'
     and (to_jsonb(new)-array['state','actual_cost_micros','reconciled_at'])=(to_jsonb(old)-array['state','actual_cost_micros','reconciled_at'])
     and exists(select 1 from orchestration.verification_provider_reconciliation r where r.tenant_id=new.tenant_id and r.provider_attempt_id=new.id
       and r.operation_id=new.operation_id and r.body->>'originalState'=old.state
       and new.actual_cost_micros=(r.body#>>'{decision,actualCostMicros}')::bigint and new.reconciled_at=r.applied_at)
  then return new;end if;
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

commit;
