begin;
-- Prototype internal sealed rows remain retained, but cannot become successful
-- operations after the dedicated comparison publication type was introduced.
create function evaluation.guard_verification_benchmark_comparison_terminal_artifact() returns trigger
language plpgsql set search_path='' as $$
begin
 if new.status='succeeded' and exists(select 1 from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id and o.operation_kind='verification_benchmark_compare')
  and not exists(select 1 from evaluation.verification_benchmark_comparison c where c.tenant_id=new.tenant_id and c.operation_id=new.operation_id and c.status='sealed'
   and orchestration.verification_artifact_is_admitted(c.tenant_id,c.publication_artifact_id,'verification_benchmark_comparison_publication',c.publication_sha256)) then
  raise exception 'benchmark comparison terminal success requires dedicated publication artifact' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_benchmark_comparison_terminal_artifact before insert or update on knowledge_service.operation_step
 for each row execute function evaluation.guard_verification_benchmark_comparison_terminal_artifact();
commit;
