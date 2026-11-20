-- The database says which release it is (VER-S1, D-117).
-- One release number covers the whole AI Engineer database: the contract version. A release names one migration chain
-- (head, count, digest) and pins the two guest components installed beside it (the Knowledge Services verification
-- component and the Mission Control component). Until now a service could only infer the release from the migration
-- list. This migration adds:
--   util.database_release           the stamps, append-only (one row per install or upgrade)
--   util.stamp_database_release()   the only writer; the installer and the lab stamp command call it as the owner
--   api.database_release()          what every service reads at startup: the stamped release, what is observed in the
--                                   database right now, and one state word
-- Lane: additive. No existing table, function or grant changes.

create table util.database_release (
  release_seq bigint generated always as identity primary key,
  contract_version text not null check (contract_version ~ '^[0-9]+\.[0-9]+\.[0-9]+$'),
  migration_head text not null check (migration_head ~ '^[0-9]{14}_[a-z0-9_]+$'),
  migrations integer not null check (migrations > 0),
  migrations_sha256 text not null check (migrations_sha256 ~ '^sha256:[0-9a-f]{64}$'),
  components jsonb not null check (jsonb_typeof(components) = 'object'),
  stamped_at timestamptz not null default now(),
  stamped_by text not null check (length(stamped_by) between 1 and 200)
);
comment on table util.database_release is
  'Which release this database is: one row per stamp, newest last, never edited. A release is the contract version; it names one migration chain and pins the guest components. Written only by util.stamp_database_release; read through api.database_release.';
comment on column util.database_release.contract_version is 'The release: the version in the contract repository''s contract.version.json.';
comment on column util.database_release.migration_head is 'The last migration of the release''s chain, as <14 digits>_<name>.';
comment on column util.database_release.migrations is 'How many migrations the release''s chain holds.';
comment on column util.database_release.migrations_sha256 is 'Digest of the chain''s file names and contents (line endings folded), as recorded in contract.version.json.';
comment on column util.database_release.components is 'The guest components the release pins, by name: {"knowledge_verification": {"version", "digest"}, "mission_control": {"version", ...}}.';
comment on column util.database_release.stamped_by is 'The tool that stamped the row (the installer, or the lab stamp command).';

create trigger database_release_append_only before update or delete on util.database_release
  for each row execute function util.reject_mutation();

revoke all on table util.database_release from public, anon, authenticated;

create function util.stamp_database_release(
  p_contract_version text, p_migration_head text, p_migrations integer, p_migrations_sha256 text,
  p_components jsonb, p_stamped_by text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  latest util.database_release%rowtype;
  live_head text;
  new_seq bigint;
begin
  -- A stamp may not claim a head the database is not at.
  if to_regclass('supabase_migrations.schema_migrations') is not null then
    execute 'select max(version) from supabase_migrations.schema_migrations' into live_head;
    if live_head is distinct from left(p_migration_head, 14) then
      raise exception 'release % ends at migration %, but this database is at %', p_contract_version, left(p_migration_head, 14), coalesce(live_head, 'no migration')
        using errcode = 'check_violation';
    end if;
  end if;
  select * into latest from util.database_release order by release_seq desc limit 1;
  if latest.release_seq is not null
     and latest.contract_version = p_contract_version and latest.migration_head = p_migration_head
     and latest.migrations = p_migrations and latest.migrations_sha256 = p_migrations_sha256
     and latest.components = p_components then
    return jsonb_build_object('stamped', false, 'release_seq', latest.release_seq, 'release', latest.contract_version);
  end if;
  insert into util.database_release (contract_version, migration_head, migrations, migrations_sha256, components, stamped_by)
  values (p_contract_version, p_migration_head, p_migrations, p_migrations_sha256, p_components, p_stamped_by)
  returning release_seq into new_seq;
  return jsonb_build_object('stamped', true, 'release_seq', new_seq, 'release', p_contract_version);
end;
$$;
comment on function util.stamp_database_release(text, text, integer, text, jsonb, text) is
  'Records the release this database was installed or upgraded to. Refuses a head the database is not at; adds a row only when the latest stamp differs. Owner only: the installer (scripts/install-ai-engineer.mjs) and the lab stamp command (scripts/database-release.mjs) call it.';
revoke all on function util.stamp_database_release(text, text, integer, text, jsonb, text) from public, anon, authenticated, service_role;

create function api.database_release()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  latest util.database_release%rowtype;
  live_head text;
  live_count integer;
  kv_version text;
  mc_version text;
  kv_pin text;
  mc_pin text;
  state text;
begin
  select * into latest from util.database_release order by release_seq desc limit 1;
  if to_regclass('supabase_migrations.schema_migrations') is not null then
    execute 'select max(version), count(*)::integer from supabase_migrations.schema_migrations' into live_head, live_count;
  end if;
  if to_regclass('knowledge_verification.component_release') is not null then
    execute 'select component_version from knowledge_verification.component_release order by string_to_array(component_version, ''.'')::integer[] desc limit 1' into kv_version;
  end if;
  if to_regclass('mission_control.application_installation') is not null then
    execute 'select schema_component_version from mission_control.application_installation where state = ''active'' order by 1 desc limit 1' into mc_version;
  end if;
  kv_pin := latest.components -> 'knowledge_verification' ->> 'version';
  mc_pin := latest.components -> 'mission_control' ->> 'version';
  state := case
    when latest.release_seq is null then 'unstamped'
    when live_head is null then 'unverifiable'
    when live_head < left(latest.migration_head, 14) then 'inconsistent'
    when live_head > left(latest.migration_head, 14) then 'ahead'
    when (kv_version is not null and kv_pin is not null and kv_version <> kv_pin)
      or (mc_version is not null and mc_pin is not null and mc_version <> mc_pin) then 'component_drift'
    else 'current'
  end;
  return jsonb_build_object(
    'format', 'ai-engineer-database-release/1',
    'release', latest.contract_version,
    'state', state,
    'declared', case when latest.release_seq is null then null else jsonb_build_object(
      'migration_head', latest.migration_head, 'migrations', latest.migrations,
      'migrations_sha256', latest.migrations_sha256, 'components', latest.components) end,
    'observed', jsonb_build_object(
      'migration_version', live_head, 'migrations', live_count,
      'components', jsonb_build_object('knowledge_verification', kv_version, 'mission_control', mc_version)),
    'stamped_at', latest.stamped_at,
    'stamped_by', latest.stamped_by);
end;
$$;
comment on function api.database_release() is
  'Which release this database is, for a service to check before it starts. Returns {format, release, state, declared, observed, stamped_at, stamped_by}. declared is the newest stamp (migration head, count, digest, pinned components). observed is read now: the live migration version and count, and the installed version of each guest component (null when that component is not in this database). state: unstamped (no stamp), current (the live head is the stamped head and every present component matches its pin), ahead (migrations applied after the stamp, as on a lab during a unit session), inconsistent (the live head is behind the stamp), component_drift (a present component differs from its pin), unverifiable (the migration list cannot be read).';
revoke all on function api.database_release() from public, anon;
grant execute on function api.database_release() to app_reader, authenticated, pipeline_agent, verifier_agent, control_plane, executor_service, service_role;
