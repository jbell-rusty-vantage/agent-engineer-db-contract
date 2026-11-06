-- Bind verification.v1 dataset versions to a same-tenant, content-matching
-- dataset-manifest artifact while preserving every legacy row and insert path.
begin;

insert into orchestration.artifact_type(code,description) values
 ('evaluation_dataset_manifest','Frozen evaluation dataset-version manifest')
on conflict(code) do update set description=excluded.description;

create or replace function evaluation.validate_verification_dataset_manifest()
returns trigger language plpgsql set search_path=pg_catalog,public,orchestration,evaluation as $$
begin
 if new.contract_version is distinct from 'verification.v1' then
  return new;
 end if;
 if not exists(
  select 1 from orchestration.artifact a
  where a.tenant_id=new.tenant_id
    and a.id=new.manifest_artifact_id
    and a.artifact_type='evaluation_dataset_manifest'
    and a.sha256=new.manifest_sha256
    and a.storage_state='available'
 ) then
  raise exception 'verification dataset version requires an available same-tenant dataset manifest artifact with matching digest'
   using errcode='foreign_key_violation';
 end if;
 return new;
end $$;

drop trigger if exists eval_dataset_version_manifest_binding on evaluation.eval_dataset_version;
create trigger eval_dataset_version_manifest_binding
before insert or update on evaluation.eval_dataset_version
for each row execute function evaluation.validate_verification_dataset_manifest();

commit;
