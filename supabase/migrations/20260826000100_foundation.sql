-- 0001 | Foundation: bounded schemas, extensions, shared helpers, role model.
--
-- Additive only. Nothing in public is touched, so the live pre-research pipeline
-- is unaffected.

begin;

-- ---------------------------------------------------------------------------
-- 1. The thirteen bounded schemas, plus util for shared helpers.
-- ---------------------------------------------------------------------------
create schema if not exists util;
create schema if not exists orchestration;
create schema if not exists evidence;
create schema if not exists taxonomy;
create schema if not exists corpus;
create schema if not exists knowledge;
create schema if not exists staging;
create schema if not exists ranking;
create schema if not exists research;
create schema if not exists retrieval;
create schema if not exists evaluation;
create schema if not exists observability;
create schema if not exists curriculum;
create schema if not exists api;

comment on schema orchestration is 'Missions, work graph, sessions, capability catalog, intents, receipts, artifacts.';
comment on schema evidence      is 'Sources, captures, locators, signatures, claims, support, verification. PROVISIONAL until the attribution lab stabilizes it.';
comment on schema taxonomy      is 'Versioned multi-facet taxonomies and their enforced assignments.';
comment on schema corpus        is 'Canonical typed entities and property-bearing relationships.';
comment on schema knowledge     is 'The treasure domain: verified technical records and their relationships.';
comment on schema staging       is 'Typed candidates, discovery results, mentions, identity resolution.';
comment on schema ranking       is 'Metric definitions/observations, features, groups, policies, snapshots.';
comment on schema research      is 'Mission-scoped outputs: bundles, reports, findings, syntheses, handoffs.';
comment on schema retrieval     is 'Vector spaces, vector catalog, retrieval plans/runs, evidence packets.';
comment on schema evaluation    is 'Datasets, cases, graders, runs, scores, gates, review queue.';
comment on schema observability is 'Trace index, spans, raw/normalized events, I/O links, handoffs.';
comment on schema curriculum    is 'Learning paths, modules, lessons, challenges, knowledge mappings.';
comment on schema api           is 'Views and functions only. The sole surface exposed to apps and agents.';
comment on schema util          is 'Shared helper functions. Owns no domain tables.';

-- ---------------------------------------------------------------------------
-- 2. Extensions.
--    btree_gist is required by the temporal-fact exclusion constraints in 0005
--    (uuid equality inside a GiST index). It is available but was not installed.
-- ---------------------------------------------------------------------------
create extension if not exists btree_gist with schema extensions;
create extension if not exists vector with schema extensions;

-- ---------------------------------------------------------------------------
-- 3. util.uuidv7()
--
--    uuidv7() is built in to PostgreSQL 18; this instance is 17.6 and no
--    pg_uuidv7 extension is available, so we define it ourselves on pgcrypto.
--    Every id column defaults to util.uuidv7(), which makes the PG18 upgrade a
--    one-line function swap rather than 200 ALTER COLUMN statements.
--
--    Time-ordered ids matter for the insert-only, high-volume tables
--    (observability.raw_event/span, ranking.metric_observation,
--    evidence.source_capture, orchestration.operation_receipt): sequential
--    index inserts instead of random B-tree page splits.
--
--    Layout: 48-bit big-endian millisecond timestamp, then the version nibble
--    forced to 7, then random bits from gen_random_uuid(). PostgreSQL numbers
--    bytea bits LSB-first within each byte, so the version nibble of byte 6 is
--    bits 52-55; setting 52 and 53 turns v4 (0100) into v7 (0111).
-- ---------------------------------------------------------------------------
create or replace function util.uuidv7() returns uuid
language sql volatile parallel safe
set search_path = ''
as $$
  -- overlay(... placing ... from ... for ...) and substring(... from ...) are SQL
  -- syntax that resolves directly to pg_catalog, so they need no qualification
  -- under the empty search_path; the plain function calls do.
  select pg_catalog.encode(
    pg_catalog.set_bit(
      pg_catalog.set_bit(
        overlay(
          pg_catalog.uuid_send(pg_catalog.gen_random_uuid())
          placing substring(
            pg_catalog.int8send(
              pg_catalog.floor(
                extract(epoch from pg_catalog.clock_timestamp()) * 1000
              )::bigint)
            from 3)
          from 1 for 6),
        52, 1),
      53, 1),
    'hex')::uuid;
$$;

comment on function util.uuidv7() is
  'Time-ordered UUID v7. Replace with the built-in uuidv7() on PostgreSQL 18+.';

-- ---------------------------------------------------------------------------
-- 4. Shared triggers.
-- ---------------------------------------------------------------------------
create or replace function util.set_updated_at() returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

comment on function util.set_updated_at() is
  'BEFORE UPDATE trigger maintaining updated_at. Distinct from public.set_updated_at, which belongs to the pre-research pipeline and must not be touched.';

-- Defence in depth for the immutable tables: receipts, captures, observations,
-- snapshots, vectors, report versions, trace rows. Grants are the primary
-- mechanism; this trigger makes a mistake loud instead of silent.
create or replace function util.reject_mutation() returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'table %.% is append-only; % is not permitted (supersede with a new row instead)',
    tg_table_schema, tg_table_name, tg_op
    using errcode = 'restrict_violation';
end;
$$;

comment on function util.reject_mutation() is
  'BEFORE UPDATE OR DELETE trigger enforcing append-only tables.';

-- ---------------------------------------------------------------------------
-- 5. Tenancy.
--    Single-tenant today. The column exists everywhere from day one because
--    adding it later is the expensive part; the policies are deferred.
-- ---------------------------------------------------------------------------
create or replace function util.default_tenant_id() returns uuid
language sql immutable parallel safe
set search_path = ''
as $$ select '00000000-0000-7000-8000-000000000001'::uuid $$;

comment on function util.default_tenant_id() is
  'The single tenant. Replace with a session/JWT lookup when multi-tenancy arrives.';

-- ---------------------------------------------------------------------------
-- 6. Role model.
--
--    Fable's five roles cannot be PostgREST login roles: Supabase issues JWTs
--    for anon / authenticated / service_role only. They are created as NOLOGIN
--    roles granted to service_role, and each service SET ROLEs after connecting.
--    That keeps "agents never mutate canonical rows" a grant rather than a
--    convention, without fighting Supabase auth.
--
--    Grants themselves land in 0015 once the tables exist.
-- ---------------------------------------------------------------------------
do $$
declare
  r text;
begin
  foreach r in array array[
    'executor_service',   -- sole DML on corpus, knowledge, canonical evidence, receipts
    'pipeline_agent',     -- INSERT on staging, evidence candidates, intents, raw events
    'verifier_agent',     -- SELECT on evidence/corpus/knowledge; INSERT verification only
    'control_plane',      -- orchestration DML, evaluation review tables
    'app_reader'          -- SELECT on api views only
  ]
  loop
    if not exists (select 1 from pg_roles where rolname = r) then
      execute format('create role %I nologin', r);
    end if;
    execute format('grant %I to service_role', r);
  end loop;
exception
  when insufficient_privilege then
    raise warning 'could not create the bounded roles (insufficient privilege); grants in 0015 will need to run as a superuser';
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. Lock down the new schemas. Only api is ever exposed.
-- ---------------------------------------------------------------------------
revoke all on schema
  orchestration, evidence, taxonomy, corpus, knowledge, staging, ranking,
  research, retrieval, evaluation, observability, curriculum, util
from public;

grant usage on schema api to anon, authenticated, service_role;

commit;
