-- Packet-bound adjudication decisions.  This migration deliberately creates no
-- policy override, admission, or human-gold pathway.
begin;
set local lock_timeout = '10s';
set local statement_timeout = '120s';

-- The canonical artifact vocabulary was introduced in 20260907010000.  Keep a
-- fresh-install assertion here so this decision ledger cannot silently become
-- detached from the verification artifact allowlist.
do $$ begin
  if not exists (select 1 from orchestration.artifact_type where code='verification_adjudication_decision') then
    raise exception 'verification_adjudication_decision artifact type is required before packet review';
  end if;
end $$;

-- Explicit custody for human-origin decisions.  No application writer is
-- granted by this migration: a future separately-authorized control-plane
-- grant flow must create these rows.  Synthetic engineering review never uses
-- this table and cannot become human-origin through an actor header.
create table evidence.verification_adjudication_reviewer_grant (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  subject_id uuid not null,
  reviewer_actor_id uuid not null,
  reviewer_role text not null check (reviewer_role ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$' and char_length(reviewer_role)<=128),
  expires_at timestamptz,
  created_at timestamptz not null default clock_timestamp(),
  unique (tenant_id,id),
  unique (tenant_id,subject_id,reviewer_actor_id,reviewer_role),
  foreign key (tenant_id,subject_id) references evidence.verification_adjudication_subject(tenant_id,id) on delete restrict,
  check (expires_at is null or expires_at>created_at)
);
create trigger evidence_verification_adjudication_reviewer_grant_immutable before update or delete on evidence.verification_adjudication_reviewer_grant for each row execute function util.reject_mutation();
alter table evidence.verification_adjudication_reviewer_grant enable row level security;
revoke all on evidence.verification_adjudication_reviewer_grant from public,anon,authenticated,pipeline_agent,verifier_agent,app_reader,executor_service,control_plane;
create policy tenant_grant_read on evidence.verification_adjudication_reviewer_grant for select to executor_service,control_plane using (tenant_id=util.current_tenant_id());
grant select on evidence.verification_adjudication_reviewer_grant to executor_service,control_plane;
comment on table evidence.verification_adjudication_reviewer_grant is 'Reserved immutable explicit human reviewer grant. This migration grants no writer and does not authorize synthetic engineering review or human policy authority.';

create table evidence.verification_adjudication_decision (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  subject_id uuid not null,
  decision_operation_id uuid not null,
  decision_step_id uuid not null,
  decision_lease_token uuid not null,
  decision_fencing_token bigint not null check (decision_fencing_token>0),
  packet_artifact_id uuid not null,
  packet_sha256 text not null check (packet_sha256 ~ '^[0-9a-f]{64}$'),
  decision_artifact_id uuid not null,
  decision_sha256 text not null check (decision_sha256 ~ '^[0-9a-f]{64}$'),
  decision text not null check (decision in ('affirm','reject','defer')),
  rationale_sha256 text not null check (rationale_sha256 ~ '^[0-9a-f]{64}$'),
  reviewer_actor_id uuid not null,
  reviewer_actor_kind text not null check (reviewer_actor_kind in ('human','service')),
  reviewer_service_identity text,
  reviewer_role text not null check (reviewer_role ~ '^[A-Za-z0-9][A-Za-z0-9._:-]*$' and char_length(reviewer_role)<=128),
  reviewer_provenance text not null check (reviewer_provenance in ('human_origin','synthetic_engineering')),
  created_at timestamptz not null default clock_timestamp(),
  unique (tenant_id,id), unique (tenant_id,decision_operation_id), unique (tenant_id,subject_id,reviewer_actor_id),
  foreign key (tenant_id,subject_id) references evidence.verification_adjudication_subject(tenant_id,id) on delete restrict,
  foreign key (tenant_id,decision_operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
  foreign key (tenant_id,decision_step_id) references knowledge_service.operation_step(tenant_id,id) on delete restrict,
  foreign key (tenant_id,packet_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
  foreign key (tenant_id,decision_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
  check ((reviewer_provenance='human_origin' and reviewer_actor_kind='human' and reviewer_service_identity is null) or (reviewer_provenance='synthetic_engineering' and reviewer_actor_kind='service' and reviewer_service_identity='human_reviewer'))
);
create index verification_adjudication_decision_subject_idx on evidence.verification_adjudication_decision(tenant_id,subject_id,created_at);

create or replace function evidence.validate_verification_adjudication_decision() returns trigger
language plpgsql set search_path='' as $$
declare subject_row evidence.verification_adjudication_subject%rowtype;
begin
  new.created_at:=clock_timestamp();
  select * into subject_row from evidence.verification_adjudication_subject where tenant_id=new.tenant_id and id=new.subject_id;
  if not found then raise exception 'adjudication decision subject is not available in tenant' using errcode='foreign_key_violation'; end if;
  if subject_row.expires_at is not null and subject_row.expires_at<=new.created_at then raise exception 'adjudication decision subject has expired' using errcode='check_violation'; end if;
  if new.packet_artifact_id<>subject_row.packet_artifact_id or new.packet_sha256<>subject_row.packet_sha256 then raise exception 'adjudication decision must bind the subject exact packet artifact and digest' using errcode='foreign_key_violation'; end if;
  if not new.reviewer_role=any(subject_row.eligible_reviewer_roles) then raise exception 'adjudication reviewer role is not eligible for subject' using errcode='foreign_key_violation'; end if;
  if new.rationale_sha256 is distinct from encode(extensions.digest(convert_to((select s.input #>> '{operationInput,request,rationale}' from knowledge_service.operation_step s where s.tenant_id=new.tenant_id and s.id=new.decision_step_id),'UTF8'),'sha256'),'hex') then raise exception 'adjudication rationale digest differs from exact durable decision input' using errcode='check_violation'; end if;
  if not exists(
    select 1 from knowledge_service.operation o join knowledge_service.operation_step s on s.tenant_id=o.tenant_id and s.operation_id=o.id join knowledge_service.lease l on l.tenant_id=s.tenant_id and l.operation_step_id=s.id
    where o.tenant_id=new.tenant_id and o.id=new.decision_operation_id and o.operation_kind='verification_adjudication_decision' and o.status='running'
      and o.request->>'schemaVersion'='knowledge-operation-request/v1' and o.request->>'kind'='verification_adjudication_decision'
      and o.request #>> '{input,schemaVersion}'='verification-service-request.v1' and o.request #>> '{input,useCase}'='recordAdjudicationDecision'
      and o.request #>> '{input,request,verificationContractVersion}'='verification.v1'
      and o.request #>> '{input,request,subjectId}'=new.subject_id::text
      and o.request #>> '{input,request,packetArtifact,artifactId}'=new.packet_artifact_id::text
      and o.request #>> '{input,request,packetArtifact,digest}'='sha256:'||new.packet_sha256
      and o.request #>> '{input,request,decision}'=new.decision
      and o.request #>> '{authenticatedContext,tenantId}'=new.tenant_id::text and o.request #>> '{authenticatedContext,operationId}'=new.decision_operation_id::text
      and o.request #>> '{authenticatedContext,actor,kind}'=new.reviewer_actor_kind and o.request #>> '{authenticatedContext,actor,id}'=new.reviewer_actor_id::text
      and (o.request #>> '{authenticatedContext,actor,serviceIdentity}') is not distinct from new.reviewer_service_identity
      and o.actor_identity=new.reviewer_actor_kind||':'||new.reviewer_actor_id::text
      and s.id=new.decision_step_id and s.step_key='record_packet_bound_decision' and s.step_kind='record_packet_bound_decision' and s.status='running'
      and s.input->'operationInput'=o.request->'input' and s.input->'expectedVersions'=o.request->'expectedVersions' and s.input->'context'=o.request->'authenticatedContext'
      and l.lease_token=new.decision_lease_token and l.fencing_token=new.decision_fencing_token and l.released_at is null and l.expires_at>clock_timestamp()
  ) then raise exception 'adjudication decision requires exact admitted operation, current step lease, and fencing token' using errcode='foreign_key_violation'; end if;
  if new.reviewer_provenance='human_origin' and not exists(select 1 from evidence.verification_adjudication_reviewer_grant g where g.tenant_id=new.tenant_id and g.subject_id=new.subject_id and g.reviewer_actor_id=new.reviewer_actor_id and g.reviewer_role=new.reviewer_role and (g.expires_at is null or g.expires_at>new.created_at)) then raise exception 'human adjudication decision requires an active explicit reviewer grant' using errcode='foreign_key_violation'; end if;
  if not orchestration.verification_artifact_is_admitted(new.tenant_id,new.packet_artifact_id,'verification_adjudication_packet',new.packet_sha256) or not orchestration.verification_artifact_is_admitted(new.tenant_id,new.decision_artifact_id,'verification_adjudication_decision',new.decision_sha256) then raise exception 'adjudication decision artifacts must be admitted with exact type and digest' using errcode='foreign_key_violation'; end if;
  if not exists(select 1 from orchestration.verification_artifact_metadata m where m.tenant_id=new.tenant_id and m.artifact_id=new.decision_artifact_id and m.parent_artifact_ids=array[new.packet_artifact_id]) then raise exception 'adjudication decision artifact must have exactly the sealed packet as its sole parent' using errcode='foreign_key_violation'; end if;
  return new;
end $$;
create trigger verification_adjudication_decision_validate before insert on evidence.verification_adjudication_decision for each row execute function evidence.validate_verification_adjudication_decision();
revoke all on function evidence.validate_verification_adjudication_decision() from public;
create trigger evidence_verification_adjudication_decision_immutable before update or delete on evidence.verification_adjudication_decision for each row execute function util.reject_mutation();
alter table evidence.verification_adjudication_decision enable row level security;
create policy bounded_role_access on evidence.verification_adjudication_decision for all to executor_service,control_plane using (tenant_id=util.current_tenant_id()) with check (tenant_id=util.current_tenant_id());
grant select,insert on evidence.verification_adjudication_decision to executor_service,control_plane;
revoke all on evidence.verification_adjudication_decision from public,anon,authenticated,pipeline_agent,verifier_agent,app_reader;
revoke update,delete on evidence.verification_adjudication_decision from executor_service,control_plane;
comment on table evidence.verification_adjudication_decision is 'Immutable packet-bound reviewer decision. It records human-origin or synthetic-engineering provenance but does not change policy admission, policy outcome, or human-gold status.';

-- Evaluate the current ledger when read, rather than persisting a racy quorum
-- snapshot in an insert trigger. Underlying tenant RLS applies to the caller.
create view evidence.verification_adjudication_review_state with (security_invoker=true) as
select s.tenant_id,s.id as subject_id,s.quorum_required,
  count(d.id) filter (where d.reviewer_provenance='human_origin' and d.decision='affirm') as human_affirmed,
  count(d.id) filter (where d.reviewer_provenance='human_origin' and d.decision='reject') as human_rejected,
  count(d.id) filter (where d.reviewer_provenance='human_origin' and d.decision='defer') as human_deferred,
  count(d.id) filter (where d.reviewer_provenance='synthetic_engineering') as synthetic_recorded,
  (count(d.id) filter (where d.reviewer_provenance='human_origin' and d.decision='affirm')>=s.quorum_required
   and count(d.id) filter (where d.reviewer_provenance='human_origin' and d.decision='reject')=0
   and (s.expires_at is null or s.expires_at>statement_timestamp())) as quorum_reached
from evidence.verification_adjudication_subject s
left join evidence.verification_adjudication_decision d on d.tenant_id=s.tenant_id and d.subject_id=s.id
group by s.tenant_id,s.id,s.quorum_required,s.expires_at;
revoke all on evidence.verification_adjudication_review_state from public,anon,authenticated,pipeline_agent,verifier_agent,app_reader;
grant select on evidence.verification_adjudication_review_state to executor_service,control_plane;
comment on view evidence.verification_adjudication_review_state is 'Read-time review counts only. Synthetic records never count toward human quorum; rejection or expiry withholds quorum. No admission or gold-label effect.';
commit;
