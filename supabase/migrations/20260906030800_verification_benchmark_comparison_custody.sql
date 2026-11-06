begin;
create function evaluation.validate_verification_benchmark_comparison_custody() returns trigger
language plpgsql set search_path='' as $$
declare result_parents uuid[]; publication_parents uuid[]; dirty_id uuid;
begin
 result_parents:=array[new.profile_artifact_id,new.baseline_publication_artifact_id,new.candidate_publication_artifact_id];
 if new.status<>'running' and not exists(select 1 from orchestration.verification_artifact_metadata m
  where m.tenant_id=new.tenant_id and m.artifact_id=new.result_artifact_id and m.parent_artifact_ids=result_parents) then
  raise exception 'benchmark comparison result custody mismatch' using errcode='foreign_key_violation';
 end if;
 if new.runtime->>'dirty'='true' and new.runtime #>> '{dirtyStateArtifact,artifactId}' is null then
  raise exception 'benchmark comparison dirty runtime source custody required' using errcode='foreign_key_violation';
 end if;
 if new.runtime ? 'dirtyStateArtifact' then
  dirty_id:=(new.runtime #>> '{dirtyStateArtifact,artifactId}')::uuid;
  if new.runtime #>> '{dirtyStateArtifact,tenantId}' is distinct from new.tenant_id::text
   or not orchestration.verification_artifact_is_admitted(new.tenant_id,dirty_id,null,substring(new.runtime #>> '{dirtyStateArtifact,digest}' from 8)) then
   raise exception 'benchmark comparison runtime artifact custody mismatch' using errcode='foreign_key_violation';
  end if;
 end if;
 if new.status='sealed' then
  publication_parents:=result_parents||array[new.result_artifact_id];
  if dirty_id is not null and not dirty_id=any(publication_parents) then publication_parents:=publication_parents||array[dirty_id]; end if;
  if not exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=new.publication_artifact_id and m.parent_artifact_ids=publication_parents) then
   raise exception 'benchmark comparison publication custody mismatch' using errcode='foreign_key_violation';
  end if;
 end if;
 return new;
end $$;
create trigger verification_benchmark_comparison_custody before insert or update on evaluation.verification_benchmark_comparison
 for each row execute function evaluation.validate_verification_benchmark_comparison_custody();
commit;
