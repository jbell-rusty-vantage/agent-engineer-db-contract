begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_component_drift_observation','Immutable five-component drift observation derived from two signed verification run manifests')
on conflict(code) do nothing;
do $$ begin
 if exists(select 1 from orchestration.artifact_type where code='verification_component_drift_observation'
  and description<>'Immutable five-component drift observation derived from two signed verification run manifests') then
  raise exception 'component drift artifact vocabulary collision';
 end if;
end $$;

create table orchestration.verification_component_drift_observation (
  tenant_id uuid not null default util.default_tenant_id(),
  observation_artifact_id uuid not null,
  observation_sha256 text not null check(observation_sha256 ~ '^[0-9a-f]{64}$'),
  payload_sha256 text not null check(payload_sha256 ~ '^[0-9a-f]{64}$'),
  baseline_run_id uuid not null,
  baseline_audit_artifact_id uuid not null,
  baseline_audit_sha256 text not null check(baseline_audit_sha256 ~ '^[0-9a-f]{64}$'),
  candidate_run_id uuid not null,
  candidate_audit_artifact_id uuid not null,
  candidate_audit_sha256 text not null check(candidate_audit_sha256 ~ '^[0-9a-f]{64}$'),
  source_operation_id uuid not null,
  dimensions text[] not null check(cardinality(dimensions) between 1 and 5 and dimensions <@ array['provider','model','parser','grader','policy']::text[]),
  idempotency_key text not null check(length(btrim(idempotency_key)) between 1 and 256),
  created_at timestamptz not null default clock_timestamp(),
  primary key(tenant_id,observation_artifact_id), unique(tenant_id,idempotency_key),
  foreign key(tenant_id,observation_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
  foreign key(tenant_id,baseline_run_id) references evidence.verification_run(tenant_id,id) on delete restrict,
  foreign key(tenant_id,candidate_run_id) references evidence.verification_run(tenant_id,id) on delete restrict,
  foreign key(tenant_id,baseline_audit_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
  foreign key(tenant_id,candidate_audit_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
  foreign key(tenant_id,source_operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
  check(baseline_run_id<>candidate_run_id and baseline_audit_artifact_id<>candidate_audit_artifact_id)
);
create function orchestration.verification_component_drift_observation_immutable() returns trigger
language plpgsql set search_path='' as $$ begin raise exception 'component drift observations are immutable' using errcode='restrict_violation'; end $$;
create trigger verification_component_drift_observation_immutable before update or delete on orchestration.verification_component_drift_observation
for each row execute function orchestration.verification_component_drift_observation_immutable();
alter table orchestration.verification_component_drift_observation enable row level security;
create policy verification_component_drift_observation_worker on orchestration.verification_component_drift_observation for select to executor_service,control_plane using(tenant_id=util.current_tenant_id());
create policy verification_component_drift_observation_reader on orchestration.verification_component_drift_observation for select to app_reader using(tenant_id=util.current_tenant_id());

-- One immutable observation has one durable action.  This deliberately does not
-- manufacture a provider call: policy may only request a human review alert.
create table orchestration.verification_drift_revalidation_outbox (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  observation_artifact_id uuid not null,
  observation_sha256 text not null check(observation_sha256 ~ '^[0-9a-f]{64}$'),
  source_operation_id uuid not null,
  idempotency_key text not null check(length(btrim(idempotency_key)) between 1 and 256),
  dimensions text[] not null check(cardinality(dimensions) between 1 and 5 and dimensions <@ array['provider','model','parser','grader','policy']::text[]),
  disposition text not null check(disposition in ('revalidate','review_required')),
  review_reason text check(review_reason is null or length(review_reason) between 1 and 256),
  state text not null default 'pending' check(state in ('pending','claimed','published','archived')),
  claim_owner text, claim_token uuid, claimed_at timestamptz, visibility_expires_at timestamptz,
  delivery_attempts integer not null default 0 check(delivery_attempts between 0 and 1000),
  available_at timestamptz not null default clock_timestamp(), published_at timestamptz, archived_at timestamptz, last_error text,
  created_at timestamptz not null default clock_timestamp(),
  unique(tenant_id,id), unique(tenant_id,observation_artifact_id), unique(tenant_id,idempotency_key),
  foreign key(tenant_id,observation_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
  foreign key(tenant_id,source_operation_id) references knowledge_service.operation(tenant_id,id) on delete restrict,
  check((disposition='revalidate' and review_reason is null) or (disposition='review_required' and review_reason is not null)),
  check((state='claimed' and claim_owner is not null and claim_token is not null and claimed_at is not null and visibility_expires_at is not null and visibility_expires_at>claimed_at) or (state<>'claimed' and claim_owner is null and claim_token is null and claimed_at is null and visibility_expires_at is null)),
  check(last_error is null or last_error ~ '^[A-Z0-9_]{1,128}$'),
  check(published_at is null or state='published'), check(archived_at is null or state='archived')
);
create index verification_drift_revalidation_claimable_idx on orchestration.verification_drift_revalidation_outbox(tenant_id,available_at,created_at,id) where state='pending';
alter table orchestration.verification_drift_revalidation_outbox enable row level security;
create policy verification_drift_revalidation_worker on orchestration.verification_drift_revalidation_outbox for select to executor_service,control_plane using(tenant_id=util.current_tenant_id());

create function orchestration.plan_verification_drift_revalidation(p_observation uuid,p_observation_sha256 text,p_source_operation uuid,p_idempotency text,p_dimensions text[],p_disposition text,p_review_reason text default null)
returns boolean language plpgsql volatile security definer set search_path='' as $$
declare v_tenant uuid:=util.current_tenant_id(); v_id uuid;
begin
 if v_tenant is null or p_observation is null or p_observation_sha256 !~ '^[0-9a-f]{64}$' or p_source_operation is null or p_idempotency is null or p_dimensions is null or p_disposition is null then raise exception 'invalid drift plan input' using errcode='invalid_parameter_value'; end if;
 if not exists(select 1 from orchestration.verification_semantic_response_observation o where o.tenant_id=v_tenant and o.observation_artifact_id=p_observation and o.observation_sha256=p_observation_sha256 and o.operation_id=p_source_operation and o.revalidation_required) then raise exception 'drift plan observation lineage invalid' using errcode='foreign_key_violation'; end if;
 insert into orchestration.verification_drift_revalidation_outbox(tenant_id,observation_artifact_id,observation_sha256,source_operation_id,idempotency_key,dimensions,disposition,review_reason)
 values(v_tenant,p_observation,p_observation_sha256,p_source_operation,p_idempotency,(select array_agg(distinct d order by d) from unnest(p_dimensions) d),p_disposition,p_review_reason)
 on conflict(tenant_id,observation_artifact_id) do nothing returning id into v_id;
 if v_id is null and not exists(select 1 from orchestration.verification_drift_revalidation_outbox where tenant_id=v_tenant and observation_artifact_id=p_observation and observation_sha256=p_observation_sha256 and source_operation_id=p_source_operation and idempotency_key=p_idempotency and dimensions=(select array_agg(distinct d order by d) from unnest(p_dimensions) d) and disposition=p_disposition and review_reason is not distinct from p_review_reason) then raise exception 'drift revalidation idempotency conflict' using errcode='unique_violation'; end if;
 return v_id is not null;
end $$;

create function orchestration.publish_verification_component_drift_observation(
 p_observation uuid,p_observation_sha256 text,p_payload_sha256 text,
 p_baseline_run uuid,p_baseline_audit uuid,p_baseline_audit_sha256 text,
 p_candidate_run uuid,p_candidate_audit uuid,p_candidate_audit_sha256 text,
 p_dimensions text[],p_idempotency text)
returns boolean language plpgsql volatile security definer set search_path='' as $$
declare
 v_tenant uuid:=util.current_tenant_id();
 v_source_operation uuid;
 v_custody_id uuid;
 v_outbox_id uuid;
 v_dimensions text[];
begin
 if v_tenant is null or p_observation is null or p_baseline_run is null or p_candidate_run is null
  or p_baseline_audit is null or p_candidate_audit is null or p_observation_sha256 !~ '^[0-9a-f]{64}$'
  or p_payload_sha256 !~ '^[0-9a-f]{64}$' or p_baseline_audit_sha256 !~ '^[0-9a-f]{64}$'
  or p_candidate_audit_sha256 !~ '^[0-9a-f]{64}$' or coalesce(length(btrim(p_idempotency)),0) not between 1 and 256
  or p_baseline_run=p_candidate_run or p_baseline_audit=p_candidate_audit then
  raise exception 'invalid component drift publication input' using errcode='invalid_parameter_value';
 end if;
 select array_agg(dimension order by ordinal) into v_dimensions
 from unnest(array['provider','model','parser','grader','policy']::text[]) with ordinality ordered(dimension,ordinal)
 where dimension=any(p_dimensions);
 if v_dimensions is null or p_dimensions is distinct from v_dimensions then raise exception 'component drift dimensions are not canonical' using errcode='invalid_parameter_value'; end if;
 select candidate.operation_id into v_source_operation
 from evidence.verification_run baseline
 join evidence.verification_run candidate on candidate.tenant_id=baseline.tenant_id
 join knowledge_service.operation source on source.tenant_id=candidate.tenant_id and source.id=candidate.operation_id
 where baseline.tenant_id=v_tenant and baseline.id=p_baseline_run and candidate.id=p_candidate_run
  and baseline.contract_version='verification.v1' and candidate.contract_version='verification.v1'
  and baseline.status<>'running' and candidate.status<>'running' and baseline.ended_at is not null and candidate.ended_at is not null
  and baseline.run_manifest_artifact_id=p_baseline_audit and baseline.manifest_sha256=p_baseline_audit_sha256
  and candidate.run_manifest_artifact_id=p_candidate_audit and candidate.manifest_sha256=p_candidate_audit_sha256
  and source.status='succeeded' and source.operation_kind in('verification_claims','verification_report','verification_benchmark','verification_structured_extraction');
 if v_source_operation is null
  or not orchestration.verification_artifact_is_admitted(v_tenant,p_baseline_audit,'verification_run_manifest',p_baseline_audit_sha256)
  or not orchestration.verification_artifact_is_admitted(v_tenant,p_candidate_audit,'verification_run_manifest',p_candidate_audit_sha256) then
  raise exception 'component drift signed run lineage invalid' using errcode='foreign_key_violation';
 end if;
 if not exists(
  select 1 from orchestration.artifact artifact
  join orchestration.verification_artifact_metadata metadata on metadata.tenant_id=artifact.tenant_id and metadata.artifact_id=artifact.id
  where artifact.tenant_id=v_tenant and artifact.id=p_observation and artifact.sha256=p_observation_sha256
   and artifact.artifact_type='verification_component_drift_observation' and artifact.bucket_class='ledger' and artifact.storage_state='available'
   and metadata.data_classification='restricted' and metadata.parent_artifact_ids=array[p_baseline_audit,p_candidate_audit]::uuid[]
   and metadata.transformation_signature is not null
 ) or (select count(*) from orchestration.artifact_lineage lineage where lineage.tenant_id=v_tenant and lineage.from_artifact_id=p_observation
       and lineage.to_artifact_id=any(array[p_baseline_audit,p_candidate_audit]::uuid[]) and lineage.relation_kind='generated'
       and lineage.transformation_signature is not null)<>2 then
  raise exception 'component drift observation artifact lineage invalid' using errcode='foreign_key_violation';
 end if;
 insert into orchestration.verification_component_drift_observation(tenant_id,observation_artifact_id,observation_sha256,payload_sha256,
  baseline_run_id,baseline_audit_artifact_id,baseline_audit_sha256,candidate_run_id,candidate_audit_artifact_id,candidate_audit_sha256,
  source_operation_id,dimensions,idempotency_key)
 values(v_tenant,p_observation,p_observation_sha256,p_payload_sha256,p_baseline_run,p_baseline_audit,p_baseline_audit_sha256,
  p_candidate_run,p_candidate_audit,p_candidate_audit_sha256,v_source_operation,v_dimensions,p_idempotency)
 on conflict(tenant_id,observation_artifact_id) do nothing returning observation_artifact_id into v_custody_id;
 if v_custody_id is null and not exists(select 1 from orchestration.verification_component_drift_observation observation
  where observation.tenant_id=v_tenant and observation.observation_artifact_id=p_observation and observation.observation_sha256=p_observation_sha256
   and observation.payload_sha256=p_payload_sha256 and observation.baseline_run_id=p_baseline_run and observation.baseline_audit_artifact_id=p_baseline_audit
   and observation.baseline_audit_sha256=p_baseline_audit_sha256 and observation.candidate_run_id=p_candidate_run
   and observation.candidate_audit_artifact_id=p_candidate_audit and observation.candidate_audit_sha256=p_candidate_audit_sha256
   and observation.source_operation_id=v_source_operation and observation.dimensions=v_dimensions and observation.idempotency_key=p_idempotency) then
  raise exception 'component drift custody idempotency conflict' using errcode='unique_violation';
 end if;
 insert into orchestration.verification_drift_revalidation_outbox(tenant_id,observation_artifact_id,observation_sha256,source_operation_id,idempotency_key,dimensions,disposition,review_reason)
 values(v_tenant,p_observation,p_observation_sha256,v_source_operation,p_idempotency,v_dimensions,'review_required','COMPONENT_DRIFT_REVIEW_REQUIRED')
 on conflict(tenant_id,observation_artifact_id) do nothing returning id into v_outbox_id;
 if v_outbox_id is null and not exists(select 1 from orchestration.verification_drift_revalidation_outbox queue
  where queue.tenant_id=v_tenant and queue.observation_artifact_id=p_observation and queue.observation_sha256=p_observation_sha256
   and queue.source_operation_id=v_source_operation and queue.idempotency_key=p_idempotency and queue.dimensions=v_dimensions
   and queue.disposition='review_required' and queue.review_reason='COMPONENT_DRIFT_REVIEW_REQUIRED') then
  raise exception 'component drift outbox idempotency conflict' using errcode='unique_violation';
 end if;
 return v_outbox_id is not null;
end $$;

create function orchestration.claim_verification_drift_revalidation(p_owner text,p_limit integer default 25,p_visibility_timeout_ms integer default 30000)
returns setof orchestration.verification_drift_revalidation_outbox language plpgsql volatile security definer set search_path='' as $$
declare v_tenant uuid:=util.current_tenant_id();
begin
 if v_tenant is null then raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege'; end if;
 if coalesce(length(btrim(p_owner)),0)=0 or length(p_owner)>256 or p_limit is null or p_visibility_timeout_ms is null or p_limit not between 1 and 100 or p_visibility_timeout_ms not between 1000 and 900000 then raise exception 'invalid drift outbox claim' using errcode='invalid_parameter_value'; end if;
 update orchestration.verification_drift_revalidation_outbox set state='archived',archived_at=clock_timestamp(),last_error=coalesce(last_error,'DELIVERY_ATTEMPTS_EXHAUSTED'),claim_owner=null,claim_token=null,claimed_at=null,visibility_expires_at=null where tenant_id=v_tenant and state in('pending','claimed') and delivery_attempts>=1000 and (state='pending' or visibility_expires_at<=clock_timestamp());
 update orchestration.verification_drift_revalidation_outbox set state='pending',claim_owner=null,claim_token=null,claimed_at=null,visibility_expires_at=null where tenant_id=v_tenant and state='claimed' and visibility_expires_at<=clock_timestamp() and delivery_attempts<1000;
 return query with picked as (select id from orchestration.verification_drift_revalidation_outbox where tenant_id=v_tenant and state='pending' and available_at<=clock_timestamp() order by available_at,created_at,id for update skip locked limit p_limit)
 update orchestration.verification_drift_revalidation_outbox q set state='claimed',claim_owner=p_owner,claim_token=gen_random_uuid(),claimed_at=clock_timestamp(),visibility_expires_at=clock_timestamp()+make_interval(secs=>p_visibility_timeout_ms::double precision/1000.0),delivery_attempts=q.delivery_attempts+1 from picked where q.id=picked.id returning q.*;
end $$;

create function orchestration.ack_verification_drift_revalidation(p_id uuid,p_owner text,p_token uuid)
returns boolean language plpgsql volatile security definer set search_path='' as $$
declare v_tenant uuid:=util.current_tenant_id(); begin
 if v_tenant is null or p_id is null or coalesce(length(btrim(p_owner)),0)=0 or p_token is null then raise exception 'invalid drift outbox acknowledgement' using errcode='invalid_parameter_value'; end if;
 update orchestration.verification_drift_revalidation_outbox set state='published',published_at=clock_timestamp(),claim_owner=null,claim_token=null,claimed_at=null,visibility_expires_at=null,last_error=null where tenant_id=v_tenant and id=p_id and state='claimed' and claim_owner=p_owner and claim_token=p_token and visibility_expires_at>clock_timestamp();
 if not found then raise exception 'stale or foreign drift outbox claim' using errcode='object_not_in_prerequisite_state'; end if; return true;
end $$;

revoke all on function orchestration.plan_verification_drift_revalidation(uuid,text,uuid,text,text[],text,text) from public,anon,authenticated;
revoke all on function orchestration.publish_verification_component_drift_observation(uuid,text,text,uuid,uuid,text,uuid,uuid,text,text[],text) from public,anon,authenticated;
revoke all on function orchestration.claim_verification_drift_revalidation(text,integer,integer) from public,anon,authenticated;
revoke all on function orchestration.ack_verification_drift_revalidation(uuid,text,uuid) from public,anon,authenticated;
revoke all on table orchestration.verification_drift_revalidation_outbox from public,anon,authenticated,executor_service,control_plane;
revoke all on table orchestration.verification_component_drift_observation from public,anon,authenticated,executor_service,control_plane,app_reader;
-- Runtime discovery and the private alert inbox use tenant-filtered reads.
-- RLS applies to these roles; writes remain available only through fenced RPCs.
grant select on table orchestration.verification_drift_revalidation_outbox to executor_service,control_plane;
grant select on table orchestration.verification_component_drift_observation to executor_service,control_plane,app_reader;
grant execute on function orchestration.plan_verification_drift_revalidation(uuid,text,uuid,text,text[],text,text) to executor_service,control_plane;
grant execute on function orchestration.publish_verification_component_drift_observation(uuid,text,text,uuid,uuid,text,uuid,uuid,text,text[],text) to executor_service,control_plane;
grant execute on function orchestration.claim_verification_drift_revalidation(text,integer,integer) to executor_service,control_plane;
grant execute on function orchestration.ack_verification_drift_revalidation(uuid,text,uuid) to executor_service,control_plane;
commit;
