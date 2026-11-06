-- Converge already-migrated development databases without merging legacy custody.
begin;
set local lock_timeout='10s';
set local statement_timeout='120s';
lock table orchestration.artifact in access exclusive mode;
alter table orchestration.artifact drop constraint if exists artifact_tenant_digest_type_uq;
alter table orchestration.artifact drop constraint if exists artifact_sha256_artifact_type_key;
create unique index if not exists artifact_verification_tenant_digest_type_uq
 on orchestration.artifact(tenant_id,sha256,artifact_type)
 where verification_contract_version='verification.v1';
comment on index orchestration.artifact_verification_tenant_digest_type_uq is
 'Only explicitly admitted verification artifacts deduplicate by tenant/digest/type. Legacy custody identities and immutable object paths remain unchanged.';
commit;
