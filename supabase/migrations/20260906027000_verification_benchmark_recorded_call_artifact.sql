begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_benchmark_recorded_call','Immutable retained verification benchmark provider call checkpoint for offline replay')
on conflict(code) do update set description=excluded.description;
commit;
