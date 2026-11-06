begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_benchmark_summary','Immutable orthogonal benchmark statistics bound to a completed runner manifest'),
 ('verification_benchmark_provenance','Immutable registered replay and source-import provenance for a benchmark publication')
on conflict(code) do update set description=excluded.description;
commit;
