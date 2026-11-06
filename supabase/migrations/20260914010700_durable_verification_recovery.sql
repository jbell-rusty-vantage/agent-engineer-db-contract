-- Durable semantic repair accounting is separate from operational step attempts.
create table knowledge_service.recovery_case (
 tenant_id uuid not null, case_id text not null, initial_batch jsonb not null,
 authority_handle jsonb not null, authority_digest text not null,
 revision bigint not null default 1 check(revision>0), state text not null default 'ready' check(state in ('ready','active','waiting','complete')),
 active_plan_digest text, created_at timestamptz not null default clock_timestamp(),
 primary key(tenant_id,case_id),
 check(initial_batch->>'tenantId' is not distinct from tenant_id::text),
 check(initial_batch->>'caseId' is not distinct from case_id),
 check(authority_digest ~ '^sha256:[a-f0-9]{64}$')
);
create table knowledge_service.recovery_original (
 tenant_id uuid not null, case_id text not null, original_id text not null,
 original_operation_id uuid not null, original_input_digest text not null,
 used_rounds integer not null check(used_rounds between 0 and 2),
 attempted_input_digests jsonb not null default '[]', attempted_repair_digests jsonb not null default '[]',
 primary key(tenant_id,case_id,original_id), unique(tenant_id,original_operation_id,original_input_digest),
 foreign key(tenant_id,case_id) references knowledge_service.recovery_case(tenant_id,case_id),
 foreign key(tenant_id,original_operation_id) references knowledge_service.operation(tenant_id,id),
 check(original_input_digest ~ '^sha256:[a-f0-9]{64}$'),
 check(jsonb_typeof(attempted_input_digests)='array' and jsonb_typeof(attempted_repair_digests)='array')
);
create table knowledge_service.recovery_revision (
 tenant_id uuid not null, case_id text not null, revision bigint not null,
 kind text not null check(kind in ('batch','notification','failure_set','plan','invalidation','receipt','wait','resume')),
 idempotency_key text not null, artifact_id uuid not null, artifact_handle jsonb not null, payload jsonb not null,
 checkpoint_id uuid, recorded_at timestamptz not null default clock_timestamp(),
 primary key(tenant_id,case_id,revision), unique(tenant_id,case_id,kind,idempotency_key),
 foreign key(tenant_id,case_id) references knowledge_service.recovery_case(tenant_id,case_id),
 foreign key(tenant_id,artifact_id) references orchestration.artifact(tenant_id,id),
 foreign key(tenant_id,checkpoint_id) references knowledge_service.scoped_checkpoint(tenant_id,id),
 check(artifact_handle->>'artifactId' is not distinct from artifact_id::text),
 check(artifact_handle->>'tenantId' is not distinct from tenant_id::text),
 check((kind='wait')=(checkpoint_id is not null))
);
create table knowledge_service.recovery_execution (
 tenant_id uuid not null, execution_id uuid not null, case_id text not null, original_id text not null,
 plan_digest text not null, repair_digest text not null, input_digest text not null,
 planned_operation_id uuid not null, operation_id uuid, request_digest text,
 reservation_calls bigint not null check(reservation_calls>0), reservation_cost_micros bigint not null check(reservation_cost_micros>=0),
 usage_calls bigint check(usage_calls>=0), usage_cost_micros bigint check(usage_cost_micros>=0),
 state text not null check(state in ('authorized','linked','settled')),
 authorization_token uuid not null, claim_token uuid not null, claim_fence bigint not null check(claim_fence>0),
 primary key(tenant_id,execution_id), unique(tenant_id,case_id,original_id,repair_digest),
 unique(tenant_id,planned_operation_id),
 foreign key(tenant_id,case_id,original_id) references knowledge_service.recovery_original(tenant_id,case_id,original_id),
 foreign key(tenant_id,operation_id) references knowledge_service.operation(tenant_id,id),
 check(operation_id is null or operation_id=planned_operation_id),
 check((operation_id is null)=(request_digest is null)),
 check((state='authorized')=(operation_id is null)),
 check((usage_calls is null)=(usage_cost_micros is null)),
 check((state='settled')=(usage_calls is not null and usage_cost_micros is not null)),
 check(usage_calls is null or usage_calls<=reservation_calls),
 check(usage_cost_micros is null or usage_cost_micros<=reservation_cost_micros),
 check(plan_digest ~ '^sha256:[a-f0-9]{64}$' and repair_digest ~ '^sha256:[a-f0-9]{64}$' and input_digest ~ '^sha256:[a-f0-9]{64}$')
);
create sequence knowledge_service.recovery_claim_fence;
create table knowledge_service.recovery_dependency_claim (
 tenant_id uuid not null, dependency_key text not null, case_id text not null, plan_digest text not null,
 holder_identity text not null, claim_token uuid not null, fencing_token bigint not null,
 expires_at timestamptz not null, released_at timestamptz,
 primary key(tenant_id,dependency_key),
 foreign key(tenant_id,case_id) references knowledge_service.recovery_case(tenant_id,case_id),
 check(fencing_token>0 and length(holder_identity)>0)
);
create function knowledge_service.guard_recovery_case() returns trigger language plpgsql set search_path='' as $$
begin
 if new.tenant_id<>old.tenant_id or new.case_id<>old.case_id or new.initial_batch is distinct from old.initial_batch
 or new.authority_handle is distinct from old.authority_handle or new.created_at<>old.created_at or new.revision<old.revision then
  raise exception 'recovery original authority is immutable' using errcode='23514';
 end if;
 return new;
end $$;
create trigger recovery_case_guard before update on knowledge_service.recovery_case for each row execute function knowledge_service.guard_recovery_case();
create function knowledge_service.guard_recovery_original() returns trigger language plpgsql set search_path='' as $$
begin
 if (new.tenant_id,new.case_id,new.original_id,new.original_operation_id,new.original_input_digest) is distinct from
 (old.tenant_id,old.case_id,old.original_id,old.original_operation_id,old.original_input_digest) or new.used_rounds<old.used_rounds
 or not(new.attempted_input_digests @> old.attempted_input_digests) or not(new.attempted_repair_digests @> old.attempted_repair_digests) then
  raise exception 'recovery original counters cannot reset' using errcode='23514';
 end if;
 return new;
end $$;
create trigger recovery_original_guard before update on knowledge_service.recovery_original for each row execute function knowledge_service.guard_recovery_original();
create trigger recovery_revision_immutable before update or delete on knowledge_service.recovery_revision for each row execute function util.reject_mutation();
create trigger recovery_original_no_delete before delete on knowledge_service.recovery_original for each row execute function util.reject_mutation();
create trigger recovery_case_no_delete before delete on knowledge_service.recovery_case for each row execute function util.reject_mutation();
create trigger recovery_execution_no_delete before delete on knowledge_service.recovery_execution for each row execute function util.reject_mutation();
create function knowledge_service.guard_recovery_execution() returns trigger language plpgsql set search_path='' as $$
begin
 if (to_jsonb(new)-array['operation_id','request_digest','usage_calls','usage_cost_micros','state']) is distinct from
 (to_jsonb(old)-array['operation_id','request_digest','usage_calls','usage_cost_micros','state'])
 or (old.operation_id is not null and (new.operation_id,new.request_digest) is distinct from (old.operation_id,old.request_digest))
 or (old.state='settled' and new is distinct from old)
 or (old.state='linked' and new.state='authorized') then
  raise exception 'recovery execution authorization is immutable' using errcode='23514';
 end if;
 return new;
end $$;
create trigger recovery_execution_guard before update on knowledge_service.recovery_execution for each row execute function knowledge_service.guard_recovery_execution();
create trigger recovery_revision_retirement_guard before insert on knowledge_service.recovery_revision for each row
 execute function orchestration.guard_retired_artifact_reference('[{"local":"tenant_id","parent":"tenant_id"},{"local":"artifact_id","parent":"id"}]');

revoke all on function knowledge_service.guard_recovery_case(),knowledge_service.guard_recovery_original(),knowledge_service.guard_recovery_execution() from public;
do $$
declare name text;
begin
 foreach name in array array['recovery_case','recovery_original','recovery_revision','recovery_execution','recovery_dependency_claim'] loop
  execute format('alter table knowledge_service.%I enable row level security',name);
  execute format('create policy %I on knowledge_service.%I for all to executor_service using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id())',name||'_tenant',name);
  execute format('grant select,insert,update on knowledge_service.%I to executor_service',name);
 end loop;
end $$;
grant usage on sequence knowledge_service.recovery_claim_fence to executor_service;

create function knowledge_service.guard_recovery_revision_artifact() returns trigger language plpgsql security definer set search_path='' as $$
declare artifact record;
begin
 select sha256,storage_state into artifact from orchestration.artifact where tenant_id=new.tenant_id and id=new.artifact_id for share;
 if artifact.storage_state is distinct from 'available' or ('sha256:'||artifact.sha256) is distinct from (new.artifact_handle->>'digest') then
  raise exception 'recovery revision requires exact available artifact' using errcode='23514';
 end if;
 return new;
end $$;
revoke all on function knowledge_service.guard_recovery_revision_artifact() from public;
create trigger recovery_revision_artifact_guard before insert on knowledge_service.recovery_revision for each row execute function knowledge_service.guard_recovery_revision_artifact();

-- Metadata ancestry arrays are not foreign keys: retain every verified closure member explicitly.
create table knowledge_service.recovery_artifact_reference (
 tenant_id uuid not null, case_id text not null, artifact_id uuid not null,
 primary key(tenant_id,case_id,artifact_id),
 foreign key(tenant_id,case_id) references knowledge_service.recovery_case(tenant_id,case_id),
 foreign key(tenant_id,artifact_id) references orchestration.artifact(tenant_id,id)
);
create trigger recovery_artifact_reference_immutable before update or delete on knowledge_service.recovery_artifact_reference for each row execute function util.reject_mutation();
create trigger recovery_artifact_reference_retirement_guard before insert on knowledge_service.recovery_artifact_reference for each row
 execute function orchestration.guard_retired_artifact_reference('[{"local":"tenant_id","parent":"tenant_id"},{"local":"artifact_id","parent":"id"}]');
alter table knowledge_service.recovery_artifact_reference enable row level security;
create policy recovery_artifact_reference_tenant on knowledge_service.recovery_artifact_reference for all to executor_service using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert on knowledge_service.recovery_artifact_reference to executor_service;
