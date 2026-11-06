-- 20261024010000_knowledge_component_binding
-- Sprint V (SV-03 / plan §3 row A1/A2/A5): bind this application's PostgreSQL to the common Knowledge Services
-- verification component (schema knowledge_verification, package @aiengineer/knowledge-db-contract 2.x, authored
-- against 2.0.0).
--
-- Forward compatibility (SV-08, edited in place before first run; never published or applied anywhere): the binding
-- requires the three foundation migrations to be PRESENT (a superset is accepted, e.g. 2.1.0 adds 0004) and the
-- installed component major version to be 2 (>= 2.0.0, < 3.0.0, compared numerically, not as text). The pin row stores
-- the keys and version actually installed, so a later component upgrade is visible as pin drift, not as a failed
-- fresh install.
--
-- Install order (plan §3): the common component is installed FIRST by its own installer (`knowledge-db install`);
-- this migration never re-issues common DDL. It (1) asserts the component is present and complete, (2) grants the
-- component's capability roles to this application's bounded roles, (3) records the pinned component identity,
-- (4) repairs finding E09: tenant-bound submit_intent idempotency and the PUBLIC execute privilege on the
-- SECURITY DEFINER function.
begin;

-- 1. The common component must already be installed (fail closed: a binding without its component is an error).
do $$
declare keys text[]; installed int[];
begin
  if not exists (select 1 from pg_namespace where nspname = 'knowledge_verification') then
    raise exception 'KNOWLEDGE_VERIFICATION_COMPONENT_REQUIRED'
      using hint = 'install @aiengineer/knowledge-db-contract 2.x (knowledge-db install --application ai-engineer) before this migration';
  end if;
  select array_agg(migration_key order by migration_key),
         max(string_to_array(component_version, '.')::int[])
    into keys, installed
    from knowledge_verification.component_release where component = 'knowledge_verification';
  -- Superset, not equality: later component migrations (0004, ...) are expected and accepted.
  if keys is null or not keys @> array['0001_verification_foundation', '0002_observations_reports_and_custody', '0003_admission_revocation_and_outbox'] then
    raise exception 'KNOWLEDGE_VERIFICATION_COMPONENT_INCOMPLETE' using detail = coalesce(array_to_string(keys, ','), '<none>');
  end if;
  if installed is null or installed < array[2, 0, 0] or installed >= array[3, 0, 0] then
    raise exception 'KNOWLEDGE_VERIFICATION_COMPONENT_VERSION_UNSUPPORTED'
      using detail = coalesce(array_to_string(installed, '.'), '<none>'), hint = 'this binding requires component major version 2 (>= 2.0.0, < 3.0.0)';
  end if;
  if not exists (select 1 from knowledge_verification.installation where application_id = 'ai-engineer') then
    raise exception 'KNOWLEDGE_VERIFICATION_INSTALLATION_MISMATCH'
      using detail = 'the component in this database is not installed for application ai-engineer';
  end if;
end $$;

-- 2. Capability grants: the bounded roles KS switches to with `set local role` inherit the component roles.
grant knowledge_verification_reader to app_reader, pipeline_agent;
grant knowledge_verification_writer, knowledge_verification_reviewer, knowledge_verification_outbox_worker to executor_service;
grant knowledge_verification_writer to verifier_agent;
grant knowledge_verification_reader, knowledge_verification_reviewer, knowledge_verification_outbox_worker to control_plane;

-- 3. Pin: which component identity this application binding was authored against.
create table knowledge_service.verification_component_binding (
  singleton boolean primary key default true check (singleton),
  component text not null check (component = 'knowledge_verification'),
  component_version text not null,
  migration_keys text[] not null,
  bound_at timestamptz not null default now()
);
comment on table knowledge_service.verification_component_binding is
  'The common verification component this AI Engineer binding consumes (Sprint V): the installed migration keys (a superset of 0001..0003) and greatest component version at bind time. Domain projections (research.*) reference knowledge_verification runs by (tenant_id, run_id); no common DDL is copied here.';
-- The ACTUAL installed keys and the numerically greatest receipt version (text max would order 2.10.0 before 2.9.0).
insert into knowledge_service.verification_component_binding (component, component_version, migration_keys)
select 'knowledge_verification',
       array_to_string(max(string_to_array(component_version, '.')::int[]), '.'),
       array_agg(migration_key order by migration_key)
  from knowledge_verification.component_release where component = 'knowledge_verification';
grant select on knowledge_service.verification_component_binding to app_reader, pipeline_agent, verifier_agent, executor_service, control_plane;

-- 4. E09: submit_intent idempotency is tenant-bound and the SECURITY DEFINER function is not executable by PUBLIC.
create or replace function api.submit_intent(
  p_intent_type     text,
  p_payload         jsonb,
  p_idempotency_key text,
  p_mission_id      uuid default null,
  p_attempt_id      uuid default null,
  p_preconditions   jsonb default '{}'::jsonb
) returns uuid
language plpgsql security definer
set search_path = ''
as $$
declare
  v_id uuid;
  v_tenant uuid := util.current_tenant_id();
  v_owner uuid;
begin
  if v_tenant is null then
    raise exception 'TENANT_CONTEXT_REQUIRED' using errcode = 'insufficient_privilege';
  end if;
  if not exists (select 1 from orchestration.intent_type t where t.code = p_intent_type) then
    raise exception 'unknown intent_type %', p_intent_type using errcode = 'foreign_key_violation';
  end if;
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception 'payload must be a JSON object' using errcode = 'invalid_parameter_value';
  end if;
  if coalesce(btrim(p_idempotency_key), '') = '' then
    raise exception 'idempotency_key is required' using errcode = 'invalid_parameter_value';
  end if;

  -- Idempotent within the caller's tenant only: a key owned by another tenant is a conflict, never a replay.
  select id, tenant_id into v_id, v_owner from orchestration.operation_intent
   where idempotency_key = p_idempotency_key;
  if v_id is not null then
    if v_owner is distinct from v_tenant then
      raise exception 'IDEMPOTENCY_KEY_FOREIGN_TENANT' using errcode = 'unique_violation';
    end if;
    return v_id;
  end if;

  insert into orchestration.operation_intent
    (tenant_id, intent_type, payload, preconditions, idempotency_key, mission_id, proposed_by_attempt)
  values
    (v_tenant, p_intent_type, p_payload, coalesce(p_preconditions,'{}'::jsonb), p_idempotency_key,
     p_mission_id, p_attempt_id)
  returning id into v_id;

  return v_id;
end;
$$;

revoke all on function api.submit_intent(text, jsonb, text, uuid, uuid, jsonb) from public;
grant execute on function api.submit_intent(text, jsonb, text, uuid, uuid, jsonb)
  to service_role, pipeline_agent, verifier_agent;

commit;
