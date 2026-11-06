begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_benchmark_source_import_manifest','Restricted imported source-preparation manifest retaining original provenance identities'),
 ('verification_benchmark_source_import_payload','Tenant-owned copy of restricted historical source artifact bytes for offline benchmark replay')
on conflict(code) do update set description=excluded.description;
commit;
