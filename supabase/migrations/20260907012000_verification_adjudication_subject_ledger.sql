-- Reviewed requestAdjudication subject/packet slice; local native behavior is verified separately.
-- This intentionally excludes reviewer grants, decisions, and policy overrides.
begin;
set local lock_timeout = '10s';
set local statement_timeout = '120s';

create table evidence.verification_adjudication_subject (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  request_operation_id uuid not null,
  request_step_id uuid not null,
  request_lease_token uuid not null,
  request_fencing_token bigint not null check (request_fencing_token > 0),
  request_operation_sha256 text not null check (request_operation_sha256 ~ '^[0-9a-f]{64}$'),
  request_step_input_sha256 text not null check (request_step_input_sha256 ~ '^[0-9a-f]{64}$'),
  request_payload_sha256 text not null check (request_payload_sha256 ~ '^[0-9a-f]{64}$'),
  target_kind text not null check (target_kind in ('assertion', 'evidence', 'run')),
  target_id text not null check (btrim(target_id) <> '' and char_length(target_id) <= 255),
  target_object_sha256 text not null check (target_object_sha256 ~ '^[0-9a-f]{64}$'),
  reason text not null check (reason in ('ambiguous_evidence', 'conflicting_evidence', 'policy_review', 'quality_failure', 'appeal')),
  requester_actor_id uuid not null,
  requester_actor_kind text not null check (requester_actor_kind in ('human', 'service', 'model')),
  requester_note text check (requester_note is null or char_length(requester_note) <= 1000),
  eligible_reviewer_roles text[] not null,
  quorum_required integer not null default 1 check (quorum_required > 0 and quorum_required <= 16),
  verification_run_id uuid not null,
  run_kind text not null check (run_kind in ('claims', 'report')),
  run_manifest_artifact_id uuid not null,
  run_manifest_sha256 text not null check (run_manifest_sha256 ~ '^[0-9a-f]{64}$'),
  run_manifest_payload_sha256 text not null check (run_manifest_payload_sha256 ~ '^[0-9a-f]{64}$'),
  bundle_artifact_id uuid not null,
  bundle_sha256 text not null check (bundle_sha256 ~ '^[0-9a-f]{64}$'),
  deterministic_result_artifact_id uuid not null,
  deterministic_result_sha256 text not null check (deterministic_result_sha256 ~ '^[0-9a-f]{64}$'),
  policy_artifact_id uuid not null,
  policy_artifact_sha256 text not null check (policy_artifact_sha256 ~ '^[0-9a-f]{64}$'),
  recorded_policy_inputs_artifact_id uuid not null,
  recorded_policy_inputs_sha256 text not null check (recorded_policy_inputs_sha256 ~ '^[0-9a-f]{64}$'),
  policy_decision_artifact_id uuid not null,
  policy_decision_sha256 text not null check (policy_decision_sha256 ~ '^[0-9a-f]{64}$'),
  original_policy_outcome text not null check (original_policy_outcome in ('pass', 'pass_with_warnings', 'review', 'fail', 'abstain')),
  audit_payload_sha256 text not null check (audit_payload_sha256 ~ '^[0-9a-f]{64}$'),
  report_gate_artifact_id uuid,
  report_gate_sha256 text check (report_gate_sha256 is null or report_gate_sha256 ~ '^[0-9a-f]{64}$'),
  packet_artifact_id uuid not null,
  packet_sha256 text not null check (packet_sha256 ~ '^[0-9a-f]{64}$'),
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  unique (tenant_id, id), unique (tenant_id, request_operation_id),
  foreign key (tenant_id, request_operation_id) references knowledge_service.operation(tenant_id, id) on delete restrict,
  foreign key (tenant_id, request_step_id) references knowledge_service.operation_step(tenant_id, id) on delete restrict,
  foreign key (tenant_id, verification_run_id) references evidence.verification_run(tenant_id, id) on delete restrict,
  foreign key (tenant_id, run_manifest_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, bundle_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, deterministic_result_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, policy_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, recorded_policy_inputs_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, policy_decision_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, report_gate_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  foreign key (tenant_id, packet_artifact_id) references orchestration.artifact(tenant_id, id) on delete restrict,
  check ((report_gate_artifact_id is null) = (report_gate_sha256 is null)),
  check ((run_kind = 'report') = (report_gate_artifact_id is not null)),
  check (expires_at is null or expires_at > created_at)
);

create index verification_adjudication_subject_queue_idx on evidence.verification_adjudication_subject (tenant_id, created_at)
  where expires_at is null or expires_at > created_at;

create or replace function evidence.validate_verification_adjudication_subject() returns trigger
language plpgsql set search_path='' as $$
declare expected_parents uuid[];
begin
  new.created_at := clock_timestamp();
  if new.expires_at is not null and new.expires_at <= new.created_at then raise exception 'adjudication subject expiry must be future' using errcode='check_violation'; end if;
  if cardinality(new.eligible_reviewer_roles) is null or cardinality(new.eligible_reviewer_roles)=0
     or cardinality(new.eligible_reviewer_roles)>16
     or exists(select 1 from unnest(new.eligible_reviewer_roles) role where role is null or role<>btrim(role) or char_length(role)>128 or role !~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$')
     or cardinality(new.eligible_reviewer_roles)<>(select count(distinct role) from unnest(new.eligible_reviewer_roles) role) then
    raise exception 'adjudication subject reviewer roles must be nonempty, normalized, and distinct' using errcode='check_violation';
  end if;
  if not exists(
    select 1 from knowledge_service.operation o join knowledge_service.operation_step s on s.tenant_id=o.tenant_id and s.operation_id=o.id
    where o.tenant_id=new.tenant_id and o.id=new.request_operation_id and o.operation_kind='verification_adjudication' and o.status='running'
      and o.request_sha256=new.request_operation_sha256 and o.actor_identity=new.requester_actor_kind||':'||new.requester_actor_id::text
      and o.request->>'schemaVersion'='knowledge-operation-request/v1' and o.request->>'kind'='verification_adjudication'
      and o.request #>> '{input,schemaVersion}'='verification-service-request.v1' and o.request #>> '{input,useCase}'='requestAdjudication'
      and o.request #>> '{input,request,verificationContractVersion}'='verification.v1'
      and o.request #> '{input,request,target}'=case new.target_kind when 'assertion' then jsonb_build_object('kind','assertion','assertionId',new.target_id) when 'evidence' then jsonb_build_object('kind','evidence','evidenceId',new.target_id) else jsonb_build_object('kind','run','runId',new.target_id) end
      and o.request #>> '{input,request,reason}'=new.reason
      and o.request #> '{input,request,evidencePacket}'=jsonb_build_object('artifactId',new.run_manifest_artifact_id::text,'digest','sha256:'||new.run_manifest_sha256)
      and o.request #> '{input,request,requesterNote}' is not distinct from case when new.requester_note is null then null else to_jsonb(new.requester_note) end
      and o.request #>> '{authenticatedContext,tenantId}'=new.tenant_id::text and o.request #>> '{authenticatedContext,operationId}'=new.request_operation_id::text
      and o.request #>> '{authenticatedContext,actor,kind}'=new.requester_actor_kind and o.request #>> '{authenticatedContext,actor,id}'=new.requester_actor_id::text
      and s.id=new.request_step_id and s.step_key='request_adjudication_and_register' and s.step_kind='request_adjudication_and_register' and s.status='running' and s.input_sha256=new.request_step_input_sha256
      and s.input->'operationInput'=o.request->'input' and s.input->'expectedVersions'=o.request->'expectedVersions' and s.input->'context'=o.request->'authenticatedContext'
      and exists(select 1 from knowledge_service.lease l where l.tenant_id=s.tenant_id and l.operation_step_id=s.id and l.lease_token=new.request_lease_token and l.fencing_token=new.request_fencing_token and l.released_at is null and l.expires_at>clock_timestamp())
  ) then raise exception 'adjudication subject requires its exact admitted request, step, and active lease' using errcode='foreign_key_violation'; end if;
  if new.target_kind='run' and new.target_id<>new.verification_run_id::text then raise exception 'run adjudication target must match sealed run' using errcode='foreign_key_violation'; end if;
  if not exists(select 1 from evidence.verification_run r join knowledge_service.operation producer on producer.tenant_id=r.tenant_id and producer.id=r.operation_id where r.tenant_id=new.tenant_id and r.id=new.verification_run_id and r.contract_version='verification.v1' and r.status<>'running' and r.ended_at is not null and producer.status='succeeded' and producer.operation_kind=case new.run_kind when 'claims' then 'verification_claims' else 'verification_report' end and r.run_manifest_artifact_id=new.run_manifest_artifact_id and r.manifest_sha256=new.run_manifest_sha256 and r.bundle_artifact_id=new.bundle_artifact_id and r.deterministic_result_artifact_id=new.deterministic_result_artifact_id and r.policy_artifact_id=new.policy_artifact_id and r.policy_artifact_sha256=new.policy_artifact_sha256) then raise exception 'adjudication subject run binding mismatch' using errcode='foreign_key_violation'; end if;
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.run_manifest_artifact_id,'verification_run_manifest',new.run_manifest_sha256)
     or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.bundle_artifact_id,'verification_bundle',new.bundle_sha256)
     or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.deterministic_result_artifact_id,'deterministic_verification_result',new.deterministic_result_sha256)
     or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.policy_artifact_id,'verification_policy',new.policy_artifact_sha256)
     or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.recorded_policy_inputs_artifact_id,'verification_policy_inputs',new.recorded_policy_inputs_sha256)
     or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.policy_decision_artifact_id,'verification_policy_decision',new.policy_decision_sha256)
     or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.packet_artifact_id,'verification_adjudication_packet',new.packet_sha256)
     or (new.report_gate_artifact_id is not null and not orchestration.verification_artifact_is_admitted(new.tenant_id,new.report_gate_artifact_id,'verification_report_result',new.report_gate_sha256)) then raise exception 'adjudication subject artifact is not admitted with its exact type and digest' using errcode='foreign_key_violation'; end if;
  expected_parents:=array[new.run_manifest_artifact_id,new.bundle_artifact_id,new.deterministic_result_artifact_id,new.policy_artifact_id,new.recorded_policy_inputs_artifact_id,new.policy_decision_artifact_id]||case when new.report_gate_artifact_id is null then '{}'::uuid[] else array[new.report_gate_artifact_id] end;
  if cardinality(expected_parents)<>(select count(distinct parent_id) from unnest(expected_parents) parent_id) then raise exception 'adjudication packet expected parent closure is not normalized' using errcode='check_violation'; end if;
  if not exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=new.packet_artifact_id and cardinality(m.parent_artifact_ids)=cardinality(expected_parents) and cardinality(m.parent_artifact_ids)=(select count(distinct parent_id) from unnest(m.parent_artifact_ids) parent_id) and m.parent_artifact_ids @> expected_parents and expected_parents @> m.parent_artifact_ids) then raise exception 'adjudication packet parent closure differs from exact sealed-run inputs' using errcode='foreign_key_violation'; end if;
  return new;
end $$;
create trigger verification_adjudication_subject_validate before insert on evidence.verification_adjudication_subject for each row execute function evidence.validate_verification_adjudication_subject();
revoke all on function evidence.validate_verification_adjudication_subject() from public;
create trigger evidence_verification_adjudication_subject_immutable before update or delete on evidence.verification_adjudication_subject for each row execute function util.reject_mutation();
alter table evidence.verification_adjudication_subject enable row level security;
create policy bounded_role_access on evidence.verification_adjudication_subject for all to executor_service,control_plane using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());
grant select,insert on evidence.verification_adjudication_subject to executor_service,control_plane;
revoke all on evidence.verification_adjudication_subject from public,anon,authenticated,pipeline_agent,verifier_agent,app_reader;
revoke update,delete on evidence.verification_adjudication_subject from executor_service,control_plane;
comment on table evidence.verification_adjudication_subject is 'Immutable tenant-scoped requestAdjudication subject and server-composed packet binding. It establishes no human decision, authority grant, policy override, admission outcome, or human-gold status.';
commit;
