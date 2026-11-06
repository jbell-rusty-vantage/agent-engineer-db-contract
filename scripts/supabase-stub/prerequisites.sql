-- LOCAL TEST STUB ONLY. The minimum Supabase platform surface the AI Engineer migration chain needs, so the real
-- migration chain can replay on a plain PostgreSQL 17 + pgvector container (scripts/install-target.test.mjs and
-- scripts/install-manifest.mjs). Never apply this to a Supabase project: there these objects are platform-managed.
--
-- Applied inside one throwaway `disposable_*` database, which the caller drops; nothing here is cluster-wide.
-- Cluster-wide pieces are owned by openStubCluster() in scripts/install-manifest.mjs, which removes them afterwards:
--   roles     anon, authenticated, service_role, postgres (NOLOGIN), created only when absent and dropped again by
--             the run that created them (as are the chain's own app roles when the run created them)
--   extension pg_jsonschema stub (scripts/supabase-stub/pg_jsonschema*: jsonb_matches_schema() always returns true);
--             its files are on the server only while one stub database registers it, then deleted
--
-- Stubbed in this database, and nothing more:
--   schemas   auth, storage, extensions; database search_path "$user", public, extensions (as Supabase sets it)
--   auth      auth.users(id) and auth.jwt() (reads request.jwt.claims like GoTrue/PostgREST; '{}' when unset)
--   storage   storage.buckets, storage.objects (columns the chain reads; RLS enabled as on Supabase),
--             storage.foldername(text)
--   extension pgcrypto in schema extensions (Supabase preinstalls it there)
-- Not stubbed: GoTrue, Storage API, PostgREST, Realtime, Vault, pg_graphql, pg_net, event triggers, Supabase grants.
create schema if not exists extensions;
do $$ begin execute format('alter database %I set search_path = "$user", public, extensions', current_database()); end $$;
create extension if not exists pgcrypto with schema extensions;

create schema if not exists auth;
create table if not exists auth.users (id uuid primary key default gen_random_uuid(), email text, created_at timestamptz default now());
create or replace function auth.jwt() returns jsonb language sql stable as
  $$ select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb $$;

create schema if not exists storage;
create table if not exists storage.buckets (
  id text primary key, name text not null unique, owner uuid, public boolean default false,
  file_size_limit bigint, allowed_mime_types text[], created_at timestamptz default now(), updated_at timestamptz default now()
);
create table if not exists storage.objects (
  id uuid primary key default gen_random_uuid(), bucket_id text references storage.buckets(id), name text,
  owner uuid, owner_id text, metadata jsonb, version text, path_tokens text[] generated always as (string_to_array(name, '/')) stored,
  created_at timestamptz default now(), updated_at timestamptz default now(), last_accessed_at timestamptz default now()
);
alter table storage.objects enable row level security;
create or replace function storage.foldername(name text) returns text[] language sql immutable as
  $$ select (string_to_array(name, '/'))[1:greatest(array_length(string_to_array(name, '/'), 1) - 1, 0)] $$;

grant usage on schema auth, storage, extensions to anon, authenticated, service_role;
