begin;

create function orchestration.structured_extraction_failure_result_body(tenant uuid,operation uuid)
returns jsonb language sql stable strict set search_path='' as $$
 select jsonb_build_object(
  'schemaVersion','verification-operation-result.v1','operationId',l.operation_id,'useCase','extractStructuredData','requestDigest','sha256:'||l.request_sha256,
  'output',jsonb_build_object('status','failed','code',p.failure_code,
   'category',case when p.failure_code='PROVIDER_HTTP_FAILURE' then 'provider_http' else 'producer_contract' end,
   'automaticRetry',false,'candidateArtifact','null'::jsonb,
   'executionArtifact',jsonb_build_object('artifactId',e.execution_artifact_id,'digest','sha256:'||e.execution_sha256),
   'manifestDigest','sha256:'||p.seal_payload_sha256,'providerCallDigest','sha256:'||p.provider_call_sha256),
  'resultArtifact',jsonb_strip_nulls(jsonb_build_object(
   'artifactId',a.id,'tenantId',a.tenant_id,'digest','sha256:'||a.sha256,'mediaType',a.media_type,'byteLength',a.size_bytes,'objectKey',a.object_path,
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

-- Captured failures require an exact terminal chain. Pre-checkpoint infrastructure
-- errors retain their existing generic behavior; cancellation remains available.
create function orchestration.structured_extraction_failure_terminal_guard()
returns trigger language plpgsql set search_path='' as $$
declare extraction boolean; target_operation_id uuid; claim jsonb; expected jsonb; expected_sha text; matches bigint;
begin
 if tg_table_name='operation' then extraction:=new.operation_kind='verification_structured_extraction';target_operation_id:=new.id;
 else
  target_operation_id:=new.operation_id;
  select o.operation_kind='verification_structured_extraction' into extraction from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id;
 end if;
 if extraction is distinct from true then return new; end if;
 if not exists(select 1 from orchestration.verification_structured_extraction_failure f where f.tenant_id=new.tenant_id and f.operation_id=target_operation_id) then return new; end if;
 if new.status='queued' then raise exception 'captured extraction failure cannot requeue' using errcode='restrict_violation'; end if;
 if new.status is distinct from 'failed' then return new; end if;
 if (select count(*) from knowledge_service.operation_step s where s.tenant_id=new.tenant_id and s.operation_id=target_operation_id)<>1 then
  raise exception 'captured extraction failure requires exactly one step' using errcode='check_violation';
 end if;
 claim:=nullif(current_setting('verification.structured_extraction_failure_terminal_claim',true),'')::jsonb;
 expected:=orchestration.structured_extraction_failure_result_body(new.tenant_id,target_operation_id);
 if tg_op<>'UPDATE' or claim is null or expected is null or claim->>'operationId' is distinct from target_operation_id::text then
  raise exception 'structured extraction terminal requires published custody and active claim' using errcode='foreign_key_violation';
 end if;
 expected_sha:=encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(expected),'UTF8'),'sha256'),'hex');
 if claim->>'outputSha256' is distinct from expected_sha then raise exception 'structured extraction terminal output binding mismatch' using errcode='check_violation'; end if;
 if tg_table_name='operation_step' then
  if old.status is distinct from 'running' or new.step_key is distinct from 'extract_and_register' or new.step_kind is distinct from 'extract_and_register'
   or new.id::text is distinct from claim->>'stepId'
   or not exists(select 1 from knowledge_service.operation o join orchestration.verification_structured_extraction l on l.tenant_id=o.tenant_id and l.operation_id=o.id
    where o.tenant_id=new.tenant_id and o.id=target_operation_id and o.status='running' and l.operation_step_id=new.id and l.step_input_sha256=new.input_sha256) then
   raise exception 'structured extraction terminal step binding mismatch' using errcode='foreign_key_violation';
  end if;
  perform l.id from knowledge_service.lease l where l.tenant_id=new.tenant_id and l.operation_step_id=new.id
   and l.lease_token::text=claim->>'leaseToken' and l.fencing_token::text=claim->>'fencingToken' and l.holder_identity=claim->>'holderIdentity'
   and l.released_at is null and l.expires_at>clock_timestamp() for update;
  if not found then raise exception 'structured extraction terminal stale lease' using errcode='check_violation'; end if;
 else
  select count(*) into matches from knowledge_service.receipt r join knowledge_service.operation_step s on s.tenant_id=r.tenant_id and s.id=r.step_id
   where r.tenant_id=new.tenant_id and r.operation_id=target_operation_id and r.outcome='failed' and r.receipt_kind='extract_and_register.failed'
    and r.id::text=claim->>'receiptId' and r.idempotency_key=claim->>'idempotencyKey' and r.executor_identity=claim->>'executorIdentity'
    and s.operation_id=target_operation_id and s.step_key='extract_and_register' and s.status='failed' and s.id::text=claim->>'stepId'
    and r.input_sha256=s.input_sha256 and r.output_sha256=expected_sha and (r.body-array['eventId','fencingToken'])=expected;
  if matches<>1 then raise exception 'structured extraction operation failure requires one exact receipt' using errcode='foreign_key_violation'; end if;
 end if;
 return new;
end $$;

create trigger verification_structured_extraction_failure_operation before insert or update on knowledge_service.operation
 for each row execute function orchestration.structured_extraction_failure_terminal_guard();
create trigger verification_structured_extraction_failure_step before insert or update on knowledge_service.operation_step
 for each row execute function orchestration.structured_extraction_failure_terminal_guard();

create function orchestration.guard_structured_extraction_failure_receipt()
returns trigger language plpgsql set search_path='' as $$
declare kind text; claim jsonb; expected jsonb; expected_sha text;
begin
 select o.operation_kind into kind from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id;
 if kind is distinct from 'verification_structured_extraction' or new.outcome is distinct from 'failed' then return new; end if;
 if not exists(select 1 from orchestration.verification_structured_extraction_failure f where f.tenant_id=new.tenant_id and f.operation_id=new.operation_id) then
  if new.receipt_kind='extract_and_register.failed' then raise exception 'captured failure receipt requires checkpoint' using errcode='foreign_key_violation'; end if;
  return new;
 end if;
 claim:=nullif(current_setting('verification.structured_extraction_failure_terminal_claim',true),'')::jsonb;
 expected:=orchestration.structured_extraction_failure_result_body(new.tenant_id,new.operation_id);
 expected_sha:=encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(expected),'UTF8'),'sha256'),'hex');
 if claim is null or expected is null or new.receipt_kind is distinct from 'extract_and_register.failed' or new.step_id is null
  or new.id::text is distinct from claim->>'receiptId' or new.idempotency_key is distinct from claim->>'idempotencyKey'
  or new.executor_identity is distinct from claim->>'executorIdentity' or new.operation_id::text is distinct from claim->>'operationId'
  or new.step_id::text is distinct from claim->>'stepId' or new.output_sha256 is distinct from expected_sha
  or (new.body-array['eventId','fencingToken']) is distinct from expected
  or jsonb_typeof(new.body->'fencingToken') is distinct from 'number' or new.body->>'fencingToken' is distinct from claim->>'fencingToken'
  or coalesce(new.body->>'eventId','') !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
  or not exists(select 1 from knowledge_service.operation_step s join knowledge_service.lease l on l.tenant_id=s.tenant_id and l.operation_step_id=s.id
   where s.tenant_id=new.tenant_id and s.id=new.step_id and s.operation_id=new.operation_id and s.status='failed' and s.step_key='extract_and_register'
    and s.input_sha256=new.input_sha256 and l.lease_token::text=claim->>'leaseToken' and l.fencing_token::text=claim->>'fencingToken'
    and l.holder_identity=claim->>'holderIdentity' and l.released_at is not null and l.expires_at>clock_timestamp())
  or not exists(select 1 from knowledge_service.operation_event e where e.tenant_id=new.tenant_id and e.id::text=new.body->>'eventId'
   and e.operation_id=new.operation_id and e.step_id=new.step_id and e.event_kind='step.failed' and e.from_state='running' and e.to_state='failed'
   and e.actor_identity=new.executor_identity and e.guarded_sha256=expected_sha and e.payload->>'outputSha256'=expected_sha
   and e.payload->>'fencingToken'=claim->>'fencingToken' and (e.payload-array['outputSha256','fencingToken'])='{}'::jsonb)
  or exists(select 1 from knowledge_service.receipt r where r.tenant_id=new.tenant_id and r.operation_id=new.operation_id and r.step_id=new.step_id and r.outcome='failed') then
  raise exception 'structured extraction failure receipt binding mismatch' using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_structured_extraction_failure_receipt before insert on knowledge_service.receipt
 for each row execute function orchestration.guard_structured_extraction_failure_receipt();

-- completeStep changes the step before inserting its event/receipt. Require the
-- whole terminal chain by transaction end, including for direct SQL writes.
create function orchestration.guard_structured_extraction_failure_terminal_commit()
returns trigger language plpgsql set search_path='' as $$
declare expected jsonb; matches bigint;
begin
 if new.status is distinct from 'failed' or not exists(select 1 from knowledge_service.operation o where o.tenant_id=new.tenant_id and o.id=new.operation_id and o.operation_kind='verification_structured_extraction') then return null; end if;
 if not exists(select 1 from orchestration.verification_structured_extraction_failure f where f.tenant_id=new.tenant_id and f.operation_id=new.operation_id) then return null; end if;
 expected:=orchestration.structured_extraction_failure_result_body(new.tenant_id,new.operation_id);
 select count(*) into matches from knowledge_service.operation o join knowledge_service.receipt r on r.tenant_id=o.tenant_id and r.operation_id=o.id
  where o.tenant_id=new.tenant_id and o.id=new.operation_id and o.status='failed' and r.step_id=new.id
   and r.outcome='failed' and r.receipt_kind='extract_and_register.failed' and (r.body-array['eventId','fencingToken'])=expected;
 if expected is null or matches<>1 then raise exception 'structured extraction terminal transaction requires exact receipt and operation' using errcode='foreign_key_violation'; end if;
 return null;
end $$;
create constraint trigger verification_structured_extraction_failure_terminal_commit after insert or update on knowledge_service.operation_step
 deferrable initially deferred for each row execute function orchestration.guard_structured_extraction_failure_terminal_commit();
commit;
