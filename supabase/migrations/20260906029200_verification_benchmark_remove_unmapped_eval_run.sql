-- A benchmark is multi-arm, so no singular eval_run may be claimed until the
-- explicit benchmark_run_arm publication relation exists. This is defensive
-- for local databases that received an earlier draft.
begin;
alter table evaluation.verification_benchmark_run drop constraint if exists verification_benchmark_run_tenant_id_evaluation_run_id_key;
alter table evaluation.verification_benchmark_run drop constraint if exists verification_benchmark_run_tenant_id_evaluation_run_id_fkey;
alter table evaluation.verification_benchmark_run drop column if exists evaluation_run_id;
commit;
