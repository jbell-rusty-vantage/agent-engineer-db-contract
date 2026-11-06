begin;
create table orchestration.verification_provider_reconciliation (
 tenant_id uuid not null,
 provider_attempt_id uuid not null,
 operation_id uuid not null,
 artifact_id uuid not null,
 artifact_sha256 text not null check(artifact_sha256 ~ '^[0-9a-f]{64}$'),
 body jsonb not null,
 applied_at timestamptz not null default clock_timestamp(),
 primary key(tenant_id,provider_attempt_id),
 unique(tenant_id,artifact_id),
 foreign key(tenant_id,provider_attempt_id) references orchestration.verification_provider_attempt(tenant_id,id),
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id),
 foreign key(tenant_id,artifact_id) references orchestration.artifact(tenant_id,id)
);

create function orchestration.provider_reconciliation_handle_matches(tenant uuid,handle jsonb) returns boolean
language sql stable set search_path='' as $$
 select coalesce(exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m
  on m.tenant_id=a.tenant_id and m.artifact_id=a.id where a.tenant_id=tenant and a.id=(handle->>'artifactId')::uuid
  and a.storage_state='available' and a.verification_contract_version='verification.v1'
  and handle=jsonb_build_object('artifactId',a.id,'tenantId',a.tenant_id,'digest','sha256:'||a.sha256,
   'mediaType',a.media_type,'byteLength',a.size_bytes,'objectKey',a.object_path,
   'createdAt',to_char(a.created_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
   'producerActivityId',m.producer_activity_id,'producerVersion',m.producer_version,
   'encryptionClass',m.encryption_class,'retentionClass',m.retention_class,'dataClassification',m.data_classification,'parentArtifactIds',m.parent_artifact_ids)
   ||case when m.content_encoding is null then '{}'::jsonb else jsonb_build_object('contentEncoding',m.content_encoding) end
   ||case when m.transformation_signature is null then '{}'::jsonb else jsonb_build_object('transformationSignature','sha256:'||m.transformation_signature) end
   ||case when m.attestation_artifact_id is null then '{}'::jsonb else jsonb_build_object('attestationArtifactId',m.attestation_artifact_id) end),false)
$$;

create function orchestration.guard_provider_reconciliation() returns trigger language plpgsql set search_path='' as $$
declare p orchestration.verification_provider_attempt%rowtype; e orchestration.verification_structured_extraction_execution%rowtype;
 b jsonb; parents uuid[]; signature text; budget orchestration.verification_provider_budget%rowtype;
begin
 if tg_op<>'INSERT' then raise exception 'provider reconciliation is immutable' using errcode='restrict_violation';end if;
 b:=new.body;
 perform 1 from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id
  and operation_kind='verification_structured_extraction' and status in('failed','cancelled') for update;
 if not found then raise exception 'provider reconciliation terminal operation required' using errcode='check_violation';end if;
 select * into p from orchestration.verification_provider_attempt where tenant_id=new.tenant_id and id=new.provider_attempt_id;
 if not found then raise exception 'provider reconciliation original attempt missing' using errcode='foreign_key_violation';end if;
 select * into budget from orchestration.verification_provider_budget where tenant_id=new.tenant_id and id=p.budget_id for update;
 select * into p from orchestration.verification_provider_attempt where tenant_id=new.tenant_id and id=new.provider_attempt_id for update;
 select * into e from orchestration.verification_structured_extraction_execution where tenant_id=new.tenant_id and operation_id=new.operation_id;
 if not coalesce(
  p.operation_id=new.operation_id and p.state in('dispatched','uncertain') and p.actual_cost_micros is null
  and b->>'schemaVersion'='verification-provider-reconciliation.v1' and b->>'tenantId'=new.tenant_id::text
  and b->>'operationId'=p.operation_id::text and b->>'operationStepId'=p.operation_step_id::text
  and b->>'providerAttemptId'=p.id::text and b->>'budgetId'=p.budget_id::text
  and b->>'providerId'=p.provider_id and b->>'model'=p.model and b->>'dispatchFence'=p.dispatch_fence::text
  and (b->>'dispatchFencingToken')::bigint=p.dispatch_fencing_token and b->>'requestDigest'='sha256:'||p.request_sha256
  and b->>'originalState'=p.state and (b->>'reservationCostMicros')::bigint=p.reservation_cost_micros
  and b#>>'{decision,action}'='settle_original_attempt' and b#>'{decision,redispatchAuthorized}'='false'::jsonb
  and (b#>>'{decision,actualCostMicros}')::bigint between 0 and 20000000
  and budget.reserved_cost_micros>=p.reservation_cost_micros
  and b#>>'{seal,purpose}'='provider_accounting_only' and b#>>'{seal,signature,algorithm}'='Ed25519'
  and (b->>'issuedAt')::timestamptz<=clock_timestamp() and (b->>'expiresAt')::timestamptz>clock_timestamp()
  and (b->>'expiresAt')::timestamptz>(b->>'issuedAt')::timestamptz
  and (b->>'expiresAt')::timestamptz<=(b->>'issuedAt')::timestamptz+interval '24 hours'
  and b#>>'{executionArtifact,artifactId}'=e.execution_artifact_id::text and b#>>'{executionArtifact,digest}'='sha256:'||e.execution_sha256
  and e.operation_step_id=p.operation_step_id and e.profile_artifact_id=p.profile_artifact_id and e.profile_sha256=p.profile_sha256
  and ((e.execution_mode='synthetic_transport' and b#>>'{decision,basis}'='synthetic_fixture') or (e.execution_mode='live_provider' and b#>>'{decision,basis}'='supplier_statement'))
  and b#>>'{requestArtifact,artifactId}'=p.request_artifact_id::text and b#>>'{requestArtifact,digest}'='sha256:'||p.request_sha256
  and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'executionArtifact')
  and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'requestArtifact')
  and orchestration.provider_reconciliation_handle_matches(new.tenant_id,b->'billingEvidenceArtifact'),false)
 then raise exception 'provider reconciliation original identity or authority mismatch' using errcode='check_violation';end if;
 if encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(b),'UTF8'),'sha256'),'hex')<>new.artifact_sha256
  or b#>>'{seal,payloadDigest}'<>'sha256:'||encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(b-'seal'),'UTF8'),'sha256'),'hex')
 then raise exception 'provider reconciliation canonical hash mismatch' using errcode='check_violation';end if;
 parents:=array[e.execution_artifact_id,p.request_artifact_id,(b#>>'{billingEvidenceArtifact,artifactId}')::uuid];
 signature:=encode(extensions.digest(convert_to(orchestration.structured_extraction_receipt_json(jsonb_build_object(
  'schemaVersion','verification-provider-reconciliation-artifact.v1','tenantId',new.tenant_id,'providerAttemptId',p.id,
  'payloadDigest',b#>>'{seal,payloadDigest}','parents',parents)),'UTF8'),'sha256'),'hex');
 if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.artifact_id,'verification_provider_reconciliation',new.artifact_sha256)
  or not exists(select 1 from orchestration.artifact a join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
   where a.tenant_id=new.tenant_id and a.id=new.artifact_id and a.created_at=(b->>'issuedAt')::timestamptz
   and m.producer_activity_id='verification-service:provider-reconciliation' and m.parent_artifact_ids=parents and m.transformation_signature=signature)
 then raise exception 'provider reconciliation registered artifact mismatch' using errcode='foreign_key_violation';end if;
 new.applied_at:=clock_timestamp();return new;
end $$;
create trigger guard_provider_reconciliation before insert or update or delete on orchestration.verification_provider_reconciliation
 for each row execute function orchestration.guard_provider_reconciliation();

create function orchestration.apply_provider_reconciliation() returns trigger language plpgsql set search_path='' as $$
begin
 perform set_config('verification.provider_reconciliation',new.provider_attempt_id::text,true);
 update orchestration.verification_provider_budget set
  reserved_cost_micros=reserved_cost_micros-(new.body->>'reservationCostMicros')::bigint,
  settled_cost_micros=settled_cost_micros+(new.body#>>'{decision,actualCostMicros}')::bigint
  where tenant_id=new.tenant_id and id=(new.body->>'budgetId')::uuid;
 update orchestration.verification_provider_attempt set state='settled',actual_cost_micros=(new.body#>>'{decision,actualCostMicros}')::bigint,reconciled_at=new.applied_at
  where tenant_id=new.tenant_id and id=new.provider_attempt_id;
 perform set_config('verification.provider_reconciliation','',true);
 return new;
end $$;
create trigger apply_provider_reconciliation after insert on orchestration.verification_provider_reconciliation
 for each row execute function orchestration.apply_provider_reconciliation();

alter table orchestration.verification_provider_reconciliation enable row level security;
create policy provider_reconciliation_control on orchestration.verification_provider_reconciliation for all to control_plane
 using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
revoke all on orchestration.verification_provider_reconciliation from public,anon,authenticated,executor_service,verifier_agent,app_reader;
grant select,insert on orchestration.verification_provider_reconciliation to control_plane;
-- The original worker claim guard is extended below with only the exact ledger-triggered settlement transition.

create or replace function orchestration.verification_provider_operation_claim() returns trigger
language plpgsql set search_path='' as $$
declare claim jsonb;
begin
  if tg_op='UPDATE' and old.operation_id is not null and new.operation_id is null then
    raise exception 'provider attempt operation scope cannot be removed' using errcode='restrict_violation';
  end if;
  if new.operation_id is null then return new; end if;
  if tg_op='INSERT' and new.state<>'reserved' then
    raise exception 'scoped provider attempt must begin reserved' using errcode='check_violation';
  end if;
  if tg_op='UPDATE' and current_setting('verification.provider_reconciliation',true)=new.id::text then
    if old.state in('dispatched','uncertain') and new.state='settled'
      and (to_jsonb(new)-array['state','actual_cost_micros','reconciled_at'])=(to_jsonb(old)-array['state','actual_cost_micros','reconciled_at'])
      and exists(select 1 from orchestration.verification_provider_reconciliation r where r.tenant_id=new.tenant_id and r.provider_attempt_id=new.id
        and r.operation_id=new.operation_id and r.body->>'originalState'=old.state
        and new.actual_cost_micros=(r.body#>>'{decision,actualCostMicros}')::bigint and new.reconciled_at=r.applied_at)
    then return new;end if;
    raise exception 'provider reconciliation settlement transition mismatch' using errcode='check_violation';
  end if;
  claim:=nullif(current_setting('verification.provider_claim',true),'')::jsonb;
  if claim is null then
    raise exception 'provider attempt active structured extraction lease claim required' using errcode='check_violation';
  end if;
  perform 1 from knowledge_service.operation operation
   where operation.tenant_id=new.tenant_id and operation.id=new.operation_id
     and operation.operation_kind='verification_structured_extraction' and operation.status='running'
   for update;
  if not found then
    raise exception 'provider attempt active structured extraction lease claim required' using errcode='check_violation';
  end if;
  perform step.id from knowledge_service.operation_step step
    join knowledge_service.lease lease on lease.tenant_id=step.tenant_id and lease.operation_step_id=step.id
    where step.tenant_id=new.tenant_id and step.operation_id=new.operation_id
      and step.id=new.operation_step_id and step.id::text=claim->>'stepId'
      and step.step_key='extract_and_register' and step.status='running'
      and lease.lease_token::text=claim->>'leaseToken' and lease.fencing_token::text=claim->>'fencingToken'
      and lease.holder_identity=claim->>'holderIdentity' and lease.released_at is null and lease.expires_at>clock_timestamp()
    for update of step,lease;
  if not found then raise exception 'provider attempt active structured extraction lease claim required' using errcode='check_violation'; end if;
  if not orchestration.verification_artifact_is_admitted(
    new.tenant_id,new.profile_artifact_id,'verification_structured_extraction_profile',new.profile_sha256)
    or not orchestration.verification_provider_artifacts_are_admitted(
      new.tenant_id,new.request_artifact_id,new.request_sha256,new.response_artifact_id) then
    raise exception 'provider attempt scoped profile or provider artifact binding is inadmissible' using errcode='foreign_key_violation';
  end if;
  if tg_op='INSERT' and new.reserved_fencing_token is distinct from (claim->>'fencingToken')::bigint then raise exception 'provider attempt reservation fence mismatch' using errcode='check_violation'; end if;
  if tg_op='UPDATE' and old.state='reserved' and new.state='dispatched' and new.dispatch_fencing_token is distinct from (claim->>'fencingToken')::bigint then raise exception 'provider attempt dispatch fence mismatch' using errcode='check_violation'; end if;
  return new;
end $$;

commit;
