-- Logical identity remains orchestration.artifact.id; bytes remain tenant-addressed CAS.
begin;
set local lock_timeout='10s';
lock table orchestration.artifact, orchestration.verification_artifact_metadata in access exclusive mode;
alter table orchestration.verification_artifact_metadata add column logical_object_key text
 check(logical_object_key is null or (length(logical_object_key) between 1 and 4096));
comment on column orchestration.verification_artifact_metadata.logical_object_key is
 'Original immutable executor handle key. Null preserves historical CAS handles. Remote custody address remains artifact.storage_bucket/object_path.';
drop index orchestration.artifact_verification_tenant_digest_type_uq;
alter table orchestration.artifact drop constraint artifact_storage_bucket_object_path_key;
create unique index artifact_legacy_storage_object_uq on orchestration.artifact(storage_bucket,object_path)
 where verification_contract_version is null;
create index artifact_verification_blob_references_idx on orchestration.artifact(tenant_id,storage_bucket,object_path)
 where verification_contract_version='verification.v1';

-- Serialize admission of aliases so legacy objects never acquire verification aliases.
create function orchestration.guard_artifact_blob_alias() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(new.storage_bucket||'/'||new.object_path,0));
 if exists(select 1 from orchestration.artifact a where a.storage_bucket=new.storage_bucket and a.object_path=new.object_path
  and a.id<>new.id and (a.verification_contract_version is null or new.verification_contract_version is null
   or a.tenant_id<>new.tenant_id or a.sha256<>new.sha256 or a.size_bytes is distinct from new.size_bytes)) then
  raise exception 'artifact blob address custody collision' using errcode='unique_violation';
 end if;
 return new;
end $$;
revoke all on function orchestration.guard_artifact_blob_alias() from public;
create trigger artifact_blob_alias_guard before insert on orchestration.artifact
 for each row execute function orchestration.guard_artifact_blob_alias();

create or replace function orchestration.structured_extraction_result_body(tenant uuid,operation uuid)
returns jsonb language sql stable strict set search_path='' as $$
 select jsonb_build_object(
  'schemaVersion','verification-operation-result.v1','operationId',l.operation_id,'useCase','extractStructuredData','requestDigest','sha256:'||l.request_sha256,
  'output',jsonb_build_object('status','unverified_candidate','schemaValidation','shape_only',
   'candidateArtifact',jsonb_build_object('artifactId',l.candidate_artifact_id,'digest','sha256:'||l.candidate_sha256),
   'provenanceArtifact',jsonb_build_object('artifactId',l.provenance_artifact_id,'digest','sha256:'||l.provenance_sha256),
   'precontextArtifact',case when l.precontext_artifact_id is null then 'null'::jsonb else jsonb_build_object('artifactId',l.precontext_artifact_id,'digest','sha256:'||l.precontext_sha256) end,
   'executionArtifact',jsonb_build_object('artifactId',e.execution_artifact_id,'digest','sha256:'||e.execution_sha256),
   'manifestDigest','sha256:'||p.seal_payload_sha256,'providerCallDigest','sha256:'||p.provider_call_sha256),
  'resultArtifact',jsonb_strip_nulls(jsonb_build_object(
   'artifactId',a.id,'tenantId',a.tenant_id,'digest','sha256:'||a.sha256,'mediaType',a.media_type,'byteLength',a.size_bytes,'objectKey',coalesce(m.logical_object_key,a.object_path),
   'createdAt',to_char(a.created_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
   'producerActivityId',m.producer_activity_id,'producerVersion',m.producer_version,'encryptionClass',m.encryption_class,'retentionClass',m.retention_class,
   'dataClassification',m.data_classification,'parentArtifactIds',m.parent_artifact_ids,'transformationSignature','sha256:'||m.transformation_signature,
   'contentEncoding',nullif(m.content_encoding,''),'attestationArtifactId',m.attestation_artifact_id)))
 from orchestration.verification_structured_extraction l
 join orchestration.verification_structured_extraction_execution e on e.tenant_id=l.tenant_id and e.operation_id=l.operation_id
 join orchestration.verification_structured_extraction_publication p on p.tenant_id=l.tenant_id and p.operation_id=l.operation_id
 join orchestration.artifact a on a.tenant_id=p.tenant_id and a.id=p.publication_artifact_id and a.sha256=p.publication_sha256
 join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
 where l.tenant_id=tenant and l.operation_id=operation and l.status='retained'
  and a.storage_state='available' and a.verification_contract_version='verification.v1' and a.artifact_type='verification_structured_extraction_publication';
$$;

create or replace function orchestration.structured_extraction_failure_result_body(tenant uuid,operation uuid)
returns jsonb language sql stable strict set search_path='' as $$
 select jsonb_build_object(
  'schemaVersion','verification-operation-result.v1','operationId',l.operation_id,'useCase','extractStructuredData','requestDigest','sha256:'||l.request_sha256,
  'output',jsonb_build_object('status','failed','code',p.failure_code,
   'category',case when p.failure_code='PROVIDER_HTTP_FAILURE' then 'provider_http' else 'producer_contract' end,
   'automaticRetry',false,'candidateArtifact','null'::jsonb,
   'executionArtifact',jsonb_build_object('artifactId',e.execution_artifact_id,'digest','sha256:'||e.execution_sha256),
   'manifestDigest','sha256:'||p.seal_payload_sha256,'providerCallDigest','sha256:'||p.provider_call_sha256),
  'resultArtifact',jsonb_strip_nulls(jsonb_build_object(
   'artifactId',a.id,'tenantId',a.tenant_id,'digest','sha256:'||a.sha256,'mediaType',a.media_type,'byteLength',a.size_bytes,'objectKey',coalesce(m.logical_object_key,a.object_path),
   'createdAt',to_char(a.created_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
   'producerActivityId',m.producer_activity_id,'producerVersion',m.producer_version,'encryptionClass',m.encryption_class,'retentionClass',m.retention_class,
   'dataClassification',m.data_classification,'parentArtifactIds',m.parent_artifact_ids,'transformationSignature','sha256:'||m.transformation_signature,
   'contentEncoding',nullif(m.content_encoding,''),'attestationArtifactId',m.attestation_artifact_id)))
 from orchestration.verification_structured_extraction l
 join orchestration.verification_structured_extraction_execution e on e.tenant_id=l.tenant_id and e.operation_id=l.operation_id
 join orchestration.verification_structured_extraction_failure p on p.tenant_id=l.tenant_id and p.operation_id=l.operation_id
 join orchestration.artifact a on a.tenant_id=p.tenant_id and a.id=p.failure_artifact_id and a.sha256=p.failure_sha256
 join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
 where l.tenant_id=tenant and l.operation_id=operation and l.status='retaining' and p.status='published'
  and a.storage_state='available' and a.verification_contract_version='verification.v1' and a.artifact_type='verification_structured_extraction_failure';
$$;

create or replace function orchestration.provider_reconciliation_handle_matches(tenant uuid,handle jsonb) returns boolean
language sql stable set search_path='' as $$
 select coalesce(exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m
  on m.tenant_id=a.tenant_id and m.artifact_id=a.id where a.tenant_id=tenant and a.id=(handle->>'artifactId')::uuid
  and a.storage_state='available' and a.verification_contract_version='verification.v1'
  and handle=jsonb_build_object('artifactId',a.id,'tenantId',a.tenant_id,'digest','sha256:'||a.sha256,
   'mediaType',a.media_type,'byteLength',a.size_bytes,'objectKey',coalesce(m.logical_object_key,a.object_path),
   'createdAt',to_char(a.created_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
   'producerActivityId',m.producer_activity_id,'producerVersion',m.producer_version,
   'encryptionClass',m.encryption_class,'retentionClass',m.retention_class,'dataClassification',m.data_classification,'parentArtifactIds',m.parent_artifact_ids)
   ||case when m.content_encoding is null then '{}'::jsonb else jsonb_build_object('contentEncoding',m.content_encoding) end
   ||case when m.transformation_signature is null then '{}'::jsonb else jsonb_build_object('transformationSignature','sha256:'||m.transformation_signature) end
   ||case when m.attestation_artifact_id is null then '{}'::jsonb else jsonb_build_object('attestationArtifactId',m.attestation_artifact_id) end),false)
$$;

create function orchestration.guard_verification_blob_policy() returns trigger
language plpgsql set search_path='' as $$
begin
 if exists(select 1 from orchestration.artifact own
  join orchestration.artifact peer on peer.tenant_id=own.tenant_id and peer.storage_bucket=own.storage_bucket and peer.object_path=own.object_path and peer.id<>own.id
  join orchestration.verification_artifact_metadata m on m.tenant_id=peer.tenant_id and m.artifact_id=peer.id
  where own.tenant_id=new.tenant_id and own.id=new.artifact_id
   and (m.encryption_class<>new.encryption_class or m.data_classification<>new.data_classification
    or m.content_encoding is distinct from new.content_encoding)) then
  raise exception 'artifact blob policy mismatch' using errcode='check_violation';
 end if;
 return new;
end $$;
create trigger verification_blob_policy_guard before insert on orchestration.verification_artifact_metadata
 for each row execute function orchestration.guard_verification_blob_policy();
commit;
