begin;

create or replace function evidence.enforce_verification_run_lifecycle() returns trigger
language plpgsql
set search_path=''
as $$
begin
  if tg_op='DELETE' then
    raise exception 'verification runs are append-only'
      using errcode='restrict_violation';
  end if;
  if old.id=new.id
     and old.work_item_id is not distinct from new.work_item_id
     and old.verifier_attempt_id=new.verifier_attempt_id
     and old.policy_version=new.policy_version
     and old.started_at=new.started_at
     and old.ended_at is null
     and new.ended_at is not null
     and new.ended_at>=new.started_at then
    return new;
  end if;
  raise exception 'verification run permits only one ended_at finalization update'
    using errcode='restrict_violation';
end;
$$;
create trigger verification_run_identity_immutable
  before update or delete on evidence.verification_run
  for each row execute function evidence.enforce_verification_run_lifecycle();

-- Independence is keyed to the deployment recorded by the producing/verifying
-- attempts. Freeze those identity columns while leaving outcome, end time, cost,
-- latency, tokens, event IDs, and remote child telemetry updateable.
create trigger attempt_identity_immutable
  before update of work_item_id,attempt_no,agent_deployment_id,agent_session_id,started_at
  on orchestration.attempt
  for each row execute function util.reject_mutation();

comment on function evidence.enforce_verification_run_lifecycle() is
  'Makes verifier identity/policy immutable and permits exactly one completion timestamp transition.';

commit;
