-- Checkpoints are immutable execution facts and cannot be appended after the
-- lifecycle has frozen completion. Keep applied 06029000 unchanged.
begin;
create or replace function evaluation.validate_verification_benchmark_checkpoint() returns trigger
language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from evaluation.verification_benchmark_run r
  where r.tenant_id=new.tenant_id and r.id=new.benchmark_run_id and r.status='running'
   and exists(select 1 from jsonb_array_elements(r.checkpoint_plan) item
      where item->>'checkpointContextDigest'='sha256:'||new.checkpoint_context_sha256)) then
  raise exception 'benchmark checkpoint is outside its immutable running plan' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
commit;
