-- Close SQL NULL three-valued-logic gaps and make legacy finalization preserve
-- every field except ended_at.
begin;

alter table evidence.locator drop constraint locator_resolution_cardinality_ck;
alter table evidence.locator add constraint locator_resolution_cardinality_ck check(
 verification_contract_version is null or (
  tenant_id is not null and representation_artifact_id is not null and selector_sha256 is not null
  and selected_size_bytes is not null and normalization_policy is not null and resolution_version is not null
  and resolution_state is not null and occurrence_count is not null
  and ((resolution_state='resolved' and occurrence_count=1)
    or (resolution_state='ambiguous' and occurrence_count>1)
    or (resolution_state in('not_found','invalid','parse_error') and occurrence_count=0))
 )
);

alter table evidence.verification_run drop constraint verification_run_terminal_ck;
alter table evidence.verification_run add constraint verification_run_terminal_ck check(
 contract_version is null or (
  tenant_id is not null and producer_attempt_id is not null and bundle_artifact_id is not null
  and deterministic_result_artifact_id is not null and policy_artifact_id is not null
  and policy_artifact_sha256 is not null and run_manifest_artifact_id is not null and manifest_sha256 is not null
  and status is not null
  and ((status='running' and ended_at is null)
    or (status<>'running' and ended_at is not null and ended_at>=started_at))
 )
);

create or replace function evidence.enforce_verification_run_lifecycle() returns trigger
language plpgsql set search_path='' as $$
begin
 if tg_op='DELETE' then raise exception 'verification runs are append-only' using errcode='restrict_violation'; end if;
 if old.contract_version is distinct from 'verification.v1' then
  if (to_jsonb(new)-'ended_at') is not distinct from (to_jsonb(old)-'ended_at')
    and old.ended_at is null and new.ended_at is not null and new.ended_at>=new.started_at then return new; end if;
  raise exception 'legacy verification run permits only ended_at finalization' using errcode='restrict_violation';
 end if;
 if (to_jsonb(new)-array['status','ended_at']) is distinct from (to_jsonb(old)-array['status','ended_at'])
  or old.status<>'running' or new.status='running' or old.ended_at is not null
  or new.ended_at is null or new.ended_at<new.started_at then
  raise exception 'verification run permits one terminal status transition' using errcode='restrict_violation';
 end if;
 return new;
end $$;

commit;
