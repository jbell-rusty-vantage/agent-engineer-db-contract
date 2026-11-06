-- Retained sealed profile files have a different role from an offline run definition.
begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_benchmark_profile_file','Immutable retained file in a sealed verification benchmark replay profile')
on conflict(code) do update set description=excluded.description;
commit;
