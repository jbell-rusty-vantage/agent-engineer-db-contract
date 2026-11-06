begin;
create or replace function orchestration.guard_provider_reconciliation() returns trigger language plpgsql set search_path='' as $$
declare p orchestration.verification_provider_attempt%rowtype; e orchestration.verification_structured_extraction_execution%rowtype;
 b jsonb; parents uuid[]; signature text; budget orchestration.verification_provider_budget%rowtype;
begin
 if tg_op<>'INSERT' then raise exception 'provider reconciliation is immutable' using errcode='restrict_violation';end if;
 b:=new.body;
 perform 1 from knowledge_service.operation where tenant_id=new.tenant_id and id=new.operation_id
  and operation_kind='verification_structured_extraction' and status in('succeeded','failed','cancelled') for update;
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
commit;
