-- Keep legacy upserts idempotent while preserving verification custody isolation.
begin;
set local lock_timeout='10s';
create or replace function orchestration.guard_artifact_blob_alias() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(new.storage_bucket||'/'||new.object_path,0));
 if exists(select 1 from orchestration.artifact a
  where a.storage_bucket=new.storage_bucket and a.object_path=new.object_path and a.id<>new.id
   and (
    (a.verification_contract_version is null)<>(new.verification_contract_version is null)
    or (a.verification_contract_version is not null and new.verification_contract_version is not null
     and (a.tenant_id<>new.tenant_id or a.sha256<>new.sha256 or a.size_bytes is distinct from new.size_bytes))
   )) then
  raise exception 'artifact blob address custody collision' using errcode='unique_violation';
 end if;
 -- Both legacy rows retain the original unique-index arbitration and ON CONFLICT behavior.
 return new;
end $$;
revoke all on function orchestration.guard_artifact_blob_alias() from public;
commit;
