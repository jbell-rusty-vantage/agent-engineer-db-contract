-- The database states its release (20261120120000_database_release_record, VER-S1).
-- Runs on any database at or past that migration, stamped or not: it stamps inside a transaction and rolls back.
\set ON_ERROR_STOP on
begin;

do $$
declare
  head text;
  head_name text;
  before_rows bigint;
  answer jsonb;
  stamp jsonb;
  refused boolean;
begin
  select max(version) into head from supabase_migrations.schema_migrations;
  if head is null then raise exception 'this suite needs the migration list'; end if;
  head_name := head || '_suite_head';
  select count(*) into before_rows from util.database_release;

  -- 1. the answer has its shape before and after a stamp
  answer := api.database_release();
  if answer ->> 'format' <> 'ai-engineer-database-release/1' then raise exception 'format: %', answer; end if;
  if not (answer ? 'release' and answer ? 'state' and answer ? 'declared' and answer ? 'observed' and answer ? 'stamped_at' and answer ? 'stamped_by') then
    raise exception 'keys: %', answer;
  end if;
  if answer #>> '{observed,migration_version}' <> head then raise exception 'observed head: %', answer; end if;

  -- 2. a stamp at the live head makes the database that release, and current
  stamp := util.stamp_database_release('99.1.0', head_name, 1, 'sha256:' || repeat('a', 64), '{}'::jsonb, 'database_release.sql');
  if not (stamp ->> 'stamped')::boolean then raise exception 'first stamp: %', stamp; end if;
  answer := api.database_release();
  if answer ->> 'release' <> '99.1.0' or answer ->> 'state' <> 'current' or answer #>> '{declared,migration_head}' <> head_name then
    raise exception 'after stamp: %', answer;
  end if;

  -- 3. the same stamp again adds no row
  stamp := util.stamp_database_release('99.1.0', head_name, 1, 'sha256:' || repeat('a', 64), '{}'::jsonb, 'database_release.sql');
  if (stamp ->> 'stamped')::boolean or (select count(*) from util.database_release) <> before_rows + 1 then raise exception 'repeat stamp: %', stamp; end if;

  -- 4. a stamp may not claim a head the database is not at
  refused := false;
  begin
    perform util.stamp_database_release('99.2.0', '29990101000000_never', 1, 'sha256:' || repeat('b', 64), '{}'::jsonb, 'database_release.sql');
  exception when check_violation then refused := true;
  end;
  if not refused then raise exception 'a stamp at a head the database is not at was accepted'; end if;

  -- 5. a pinned component that is present at another version is drift; one that is absent is not
  perform util.stamp_database_release('99.3.0', head_name, 1, 'sha256:' || repeat('c', 64),
    '{"knowledge_verification": {"version": "0.0.1"}, "mission_control": {"version": "0.0.1"}}'::jsonb, 'database_release.sql');
  answer := api.database_release();
  if answer #>> '{observed,components,knowledge_verification}' is not null and answer ->> 'state' <> 'component_drift' then
    raise exception 'drift not reported: %', answer;
  end if;

  -- 6. the stamps are append-only
  refused := false;
  begin
    update util.database_release set contract_version = '0.0.0';
  exception when restrict_violation then refused := true;
  end;
  if not refused then raise exception 'util.database_release accepted an update'; end if;
  refused := false;
  begin
    delete from util.database_release;
  exception when restrict_violation then refused := true;
  end;
  if not refused then raise exception 'util.database_release accepted a delete'; end if;

  -- 7. who may ask and who may write
  if has_function_privilege('anon', 'api.database_release()', 'execute') then raise exception 'anon can ask for the release'; end if;
  if exists (select 1 from pg_proc p, aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a
             where p.oid in ('api.database_release()'::regprocedure, 'util.stamp_database_release(text,text,integer,text,jsonb,text)'::regprocedure) and a.grantee = 0) then
    raise exception 'PUBLIC can execute a release function';
  end if;
  if not (has_function_privilege('app_reader', 'api.database_release()', 'execute') and has_function_privilege('executor_service', 'api.database_release()', 'execute')
      and has_function_privilege('control_plane', 'api.database_release()', 'execute') and has_function_privilege('service_role', 'api.database_release()', 'execute')
      and has_function_privilege('authenticated', 'api.database_release()', 'execute')) then
    raise exception 'a service role cannot ask for the release';
  end if;
  if has_function_privilege('service_role', 'util.stamp_database_release(text,text,integer,text,jsonb,text)', 'execute')
     or has_function_privilege('executor_service', 'util.stamp_database_release(text,text,integer,text,jsonb,text)', 'execute')
     or has_function_privilege('authenticated', 'util.stamp_database_release(text,text,integer,text,jsonb,text)', 'execute') then
    raise exception 'a service role can stamp a release';
  end if;
  if has_table_privilege('app_reader', 'util.database_release', 'select') or has_table_privilege('authenticated', 'util.database_release', 'select')
     or has_table_privilege('anon', 'util.database_release', 'select') then
    raise exception 'the stamps are readable outside api.database_release()';
  end if;
end;
$$;

rollback;
select 'database_release: ok' as result;
