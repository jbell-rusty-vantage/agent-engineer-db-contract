-- A SQL CHECK must reject NULL explicitly; timestamp ordering alone is unknown.
begin;
alter table evaluation.verification_benchmark_comparison
 add constraint verification_benchmark_comparison_completion_required
 check(status='running' or completed_at is not null);
commit;
