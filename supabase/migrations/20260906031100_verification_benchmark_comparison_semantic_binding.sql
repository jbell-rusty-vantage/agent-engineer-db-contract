begin;
create function evaluation.validate_verification_benchmark_comparison_semantic_binding() returns trigger
language plpgsql set search_path='' as $$
declare parents uuid[]; expected text; binding text[];
begin
 if new.runtime ? 'dirtyStateArtifact' and not coalesce((new.runtime #>> '{dirtyStateArtifact,digest}') ~ '^sha256:[0-9a-f]{64}$',false) then
  raise exception 'benchmark comparison runtime artifact digest required' using errcode='foreign_key_violation';
 end if;
 if new.status='running' then return new; end if;
 parents:=array[new.profile_artifact_id,new.baseline_publication_artifact_id,new.candidate_publication_artifact_id];
 expected:=encode(extensions.digest(convert_to(array_to_string(array['verification-benchmark-comparison-artifact.v2','verification_benchmark_comparison_result','sha256:'||new.result_sha256]||parents::text[]||array['sha256:'||new.result_digest_sha256],'|'),'UTF8'),'sha256'),'hex');
 if not exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=new.result_artifact_id and m.transformation_signature=expected) then
  raise exception 'benchmark comparison result semantic binding mismatch' using errcode='foreign_key_violation';
 end if;
 if new.status='sealed' then
  parents:=parents||array[new.result_artifact_id];
  if new.runtime ? 'dirtyStateArtifact' and not (new.runtime #>> '{dirtyStateArtifact,artifactId}')::uuid=any(parents) then parents:=parents||array[(new.runtime #>> '{dirtyStateArtifact,artifactId}')::uuid]; end if;
  binding:=array[new.tenant_id::text,new.operation_id::text,new.id::text,new.baseline_run_id::text,'sha256:'||new.baseline_payload_sha256,new.candidate_run_id::text,'sha256:'||new.candidate_payload_sha256,new.profile_id,'sha256:'||new.runtime_sha256,to_char(new.started_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),to_char(new.completed_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),'sha256:'||new.result_digest_sha256,new.engineering_gate_outcome];
  expected:=encode(extensions.digest(convert_to(array_to_string(array['verification-benchmark-comparison-artifact.v2','verification_benchmark_comparison_publication','sha256:'||new.publication_sha256]||parents::text[]||array['sha256:'||new.publication_payload_sha256]||binding,'|'),'UTF8'),'sha256'),'hex');
  if not exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=new.publication_artifact_id and m.transformation_signature=expected) then
   raise exception 'benchmark comparison publication semantic binding mismatch' using errcode='foreign_key_violation';
  end if;
 end if;
 return new;
end $$;
create trigger verification_benchmark_comparison_semantic_binding before insert or update on evaluation.verification_benchmark_comparison
 for each row execute function evaluation.validate_verification_benchmark_comparison_semantic_binding();
commit;
