-- Keep the database checkpoint boundary aligned with the retained plan even
-- when a caller bypasses the TypeScript adapter.
begin;
create or replace function evaluation.validate_verification_benchmark_checkpoint() returns trigger
language plpgsql set search_path='' as $$
declare run_row evaluation.verification_benchmark_run%rowtype; planned jsonb;
begin
 select * into run_row from evaluation.verification_benchmark_run r where r.tenant_id=new.tenant_id and r.id=new.benchmark_run_id and r.status='running';
 if run_row.id is null then raise exception 'benchmark checkpoint is outside its immutable running plan' using errcode='foreign_key_violation'; end if;
 select item into planned from jsonb_array_elements(run_row.checkpoint_plan) item where item->>'checkpointContextDigest'='sha256:'||new.checkpoint_context_sha256;
 if planned is null or new.result->>'runId' is distinct from run_row.id::text or new.result->>'checkpointContextDigest' is distinct from 'sha256:'||new.checkpoint_context_sha256 or new.result->>'caseId' is distinct from planned->>'caseId' or new.result->>'armId' is distinct from planned->>'armId' or new.result->>'repetition' is distinct from planned->>'repetition' then raise exception 'benchmark checkpoint result is outside its immutable plan' using errcode='foreign_key_violation'; end if;
 if coalesce(new.result->>'completedAt','') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z$' or new.completed_at<run_row.started_at or new.completed_at>clock_timestamp() or (new.result->>'completedAt')::timestamptz<>new.completed_at then raise exception 'benchmark checkpoint timestamp invalid' using errcode='check_violation'; end if;
 return new;
end $$;
commit;
