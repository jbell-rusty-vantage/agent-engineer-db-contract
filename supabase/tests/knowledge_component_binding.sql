-- Sprint V SV-03: the AI Engineer binding to the common knowledge_verification component.
-- Run against a disposable project where `knowledge-db install --application ai-engineer` preceded `db:migrate`.
-- Each block raises on failure; a silent run is a pass. First run in SV-08 on a disposable Supabase database.
begin;
set local role postgres;

-- The pin row contains the three foundation migrations (a superset is accepted: 2.1.0 adds 0004), every pinned key
-- is an installed receipt (equal on a fresh install; a later component upgrade adds receipts), and the version is major 2.
do $$
declare keys text[]; installed text[]; v text;
begin
  select migration_keys, component_version into keys, v from knowledge_service.verification_component_binding;
  select array_agg(migration_key order by migration_key) into installed
    from knowledge_verification.component_release where component = 'knowledge_verification';
  if keys is null or not keys @> array['0001_verification_foundation', '0002_observations_reports_and_custody', '0003_admission_revocation_and_outbox'] then
    raise exception 'binding pin lacks the foundation migrations: %', keys;
  end if;
  if not installed @> keys then
    raise exception 'binding pin % names keys that are not installed receipts %', keys, installed;
  end if;
  if v !~ '^2\.[0-9]+\.[0-9]+$' then
    raise exception 'binding pin version % is not major 2', v;
  end if;
end $$;

-- Bounded roles inherit the capability roles.
do $$
begin
  if not pg_has_role('executor_service', 'knowledge_verification_writer', 'member') then raise exception 'executor_service lacks writer'; end if;
  if not pg_has_role('verifier_agent', 'knowledge_verification_writer', 'member') then raise exception 'verifier_agent lacks writer'; end if;
  if not pg_has_role('app_reader', 'knowledge_verification_reader', 'member') then raise exception 'app_reader lacks reader'; end if;
  if pg_has_role('app_reader', 'knowledge_verification_writer', 'member') then raise exception 'app_reader must not write'; end if;
end $$;

-- PUBLIC cannot execute submit_intent (E09).
do $$
begin
  if has_function_privilege('public', 'api.submit_intent(text, jsonb, text, uuid, uuid, jsonb)', 'execute') then
    raise exception 'submit_intent is executable by PUBLIC';
  end if;
end $$;

-- Tenant-bound idempotency: the same key from another tenant conflicts instead of replaying.
select set_config('app.tenant_id', '00000000-0000-7000-8000-000000000001', true);
select api.submit_intent('verify_claim', '{"probe": true}'::jsonb, 'sv03-binding-probe') as first_id \gset
select set_config('app.tenant_id', '00000000-0000-7000-8000-0000000000bb', true);
do $$
begin
  perform api.submit_intent('verify_claim', '{"probe": true}'::jsonb, 'sv03-binding-probe');
  raise exception 'foreign tenant replayed another tenant''s idempotency key';
exception when unique_violation then
  null;
end $$;

rollback;
