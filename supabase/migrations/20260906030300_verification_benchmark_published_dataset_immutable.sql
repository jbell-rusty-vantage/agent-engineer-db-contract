-- A dataset whose version participates in a published benchmark cannot drift:
-- its slug and purpose are part of the publisher's exact catalog identity.
begin;

create or replace function evaluation.guard_benchmark_publication_dependency() returns trigger
language plpgsql set search_path='' as $$
begin
 if tg_table_name='eval_run' and exists(select 1 from evaluation.verification_benchmark_arm_publication p where p.tenant_id=old.tenant_id and p.eval_run_id=old.id) then
  raise exception 'published benchmark evaluation runs are immutable' using errcode='restrict_violation';
 end if;
 if tg_table_name='eval_dataset_version' and exists(select 1 from evaluation.verification_benchmark_arm_publication p join evaluation.eval_run r on r.tenant_id=p.tenant_id and r.id=p.eval_run_id where r.tenant_id=old.tenant_id and r.dataset_version_id=old.id) then
  raise exception 'published benchmark dataset versions are immutable' using errcode='restrict_violation';
 end if;
 if tg_table_name='experiment' and exists(select 1 from evaluation.verification_benchmark_arm_publication p join evaluation.experiment_arm a on a.tenant_id=p.tenant_id and a.id=p.experiment_arm_id where a.tenant_id=old.tenant_id and a.experiment_id=old.id) then
  raise exception 'published benchmark experiments are immutable' using errcode='restrict_violation';
 end if;
 if tg_table_name='eval_dataset' and exists(select 1 from evaluation.verification_benchmark_arm_publication p join evaluation.eval_run r on r.tenant_id=p.tenant_id and r.id=p.eval_run_id where r.tenant_id=old.tenant_id and r.dataset_id=old.id) then
  raise exception 'published benchmark datasets are immutable' using errcode='restrict_violation';
 end if;
 return coalesce(new,old);
end $$;

create trigger eval_dataset_benchmark_publication_immutable before update or delete on evaluation.eval_dataset
 for each row execute function evaluation.guard_benchmark_publication_dependency();
commit;
