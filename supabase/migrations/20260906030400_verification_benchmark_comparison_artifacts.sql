begin;
insert into orchestration.artifact_type(code,description) values
 ('verification_benchmark_comparison_profile','Immutable operator-granted arm pairs, statistical family and observed engineering regression threshold'),
 ('verification_benchmark_comparison_result','Immutable paired engineering comparison of two signed completed benchmark runs')
on conflict(code) do update set description=excluded.description;
commit;
