-- An immutable experiment definition is distinct from an individual arm.
begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_benchmark_experiment','Immutable registered offline verification benchmark experiment definition')
on conflict(code) do update set description=excluded.description;

commit;
