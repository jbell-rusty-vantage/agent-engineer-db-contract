begin;
create function evaluation.validate_verification_benchmark_comparison_claim() returns trigger
language plpgsql set search_path='' as $$
declare claim jsonb; operation_status text;
begin
 select status into operation_status from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id for update;
 if operation_status is distinct from 'running' then raise exception 'benchmark comparison operation not active' using errcode='check_violation'; end if;
 claim:=nullif(current_setting('verification.comparison_claim',true),'')::jsonb;
 if claim is null or not exists(
  select 1 from knowledge_service.operation_step step join knowledge_service.lease lease on lease.tenant_id=step.tenant_id and lease.operation_step_id=step.id
  where step.tenant_id=new.tenant_id and step.operation_id=new.operation_id and step.id::text=claim->>'stepId'
   and step.status='running' and step.step_key='compare_registered_and_publish'
   and lease.lease_token::text=claim->>'leaseToken' and lease.fencing_token::text=claim->>'fencingToken'
   and lease.holder_identity=claim->>'holderIdentity' and lease.released_at is null and lease.expires_at>clock_timestamp()
 ) then raise exception 'benchmark comparison active lease claim required' using errcode='check_violation'; end if;
 return new;
end $$;
create trigger verification_benchmark_comparison_claim before insert or update on evaluation.verification_benchmark_comparison
 for each row execute function evaluation.validate_verification_benchmark_comparison_claim();
commit;
