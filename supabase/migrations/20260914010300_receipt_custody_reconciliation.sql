-- Final receipts are inserted once after apply effects are known, before batch commit.
begin;
set local lock_timeout='10s';
alter table corpus.entity alter constraint entity_created_by_receipt_id_fkey deferrable initially immediate;
alter table staging.resolution_decision alter constraint resolution_decision_receipt_id_fkey deferrable initially immediate;
alter table evidence.claim alter constraint claim_created_by_receipt_id_fkey deferrable initially immediate;
drop trigger entity_receipt_tenant on corpus.entity;
create constraint trigger entity_receipt_tenant after insert or update on corpus.entity
 deferrable initially immediate for each row execute function corpus.check_receipt_tenant();

-- The trusted artifact ledger verifies remote bytes before invoking this bounded transition.
-- Verification artifacts retain their separate operation-lease fencing path.
create function orchestration.reconcile_legacy_artifact_custody(p_id uuid,p_sha256 text,p_size bigint,p_bucket text,p_tenant uuid)
returns void language plpgsql security definer set search_path='' as $$
declare a orchestration.artifact%rowtype;
begin
 if p_tenant is distinct from util.current_tenant_id() then raise exception 'artifact tenant mismatch' using errcode='42501'; end if;
 select * into a from orchestration.artifact where tenant_id=p_tenant and id=p_id for update;
 if not found or a.verification_contract_version is not null or a.sha256 is distinct from p_sha256 or a.size_bytes is distinct from p_size
  or a.storage_bucket is distinct from p_bucket or a.object_path is distinct from (p_tenant::text||'/'||left(p_sha256,2)||'/'||p_sha256) then
  raise exception 'artifact reconciliation identity mismatch' using errcode='23514';
 end if;
 if a.storage_state in('pending','failed') then
  update orchestration.artifact set storage_state='available',available_at=clock_timestamp(),registration_error_class=null where id=a.id;
 elsif a.storage_state<>'available' then
  raise exception 'artifact reconciliation state invalid' using errcode='23514';
 end if;
end $$;
revoke all on function orchestration.reconcile_legacy_artifact_custody(uuid,text,bigint,text,uuid) from public,anon,authenticated,service_role,pipeline_agent,verifier_agent,app_reader;
grant execute on function orchestration.reconcile_legacy_artifact_custody(uuid,text,bigint,text,uuid) to executor_service;
commit;
