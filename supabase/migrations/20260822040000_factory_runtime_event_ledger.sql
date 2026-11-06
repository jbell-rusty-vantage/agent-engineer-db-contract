-- Native Eve runtime evidence ledger.
--
-- Eve hooks append every durable root-agent stream event here. The event id is
-- Eve-owned and stable, which makes hook replay idempotent. Postgres remains the
-- authority for episode identity and lifecycle; large external artifacts can
-- still live in object storage and be referenced by factory_artifact.

create table if not exists public.factory_runtime_event (
  eve_event_id text primary key,
  factory_episode_id uuid not null references public.factory_episode(factory_episode_id) on delete cascade,
  eve_session_id text not null,
  event_type text not null,
  event_data jsonb,
  event_meta jsonb not null,
  payload_sha256 text not null,
  payload_byte_size bigint not null,
  redaction_version text not null default 'factory-event-redaction-v1',
  payload_truncated boolean not null default false,
  agent_name text not null,
  agent_node_id text,
  channel_kind text,
  subagent_name text,
  call_id text,
  emitted_at timestamptz not null,
  ingested_at timestamptz not null default timezone('utc', now()),
  constraint factory_runtime_event_size_check check (payload_byte_size >= 0),
  constraint factory_runtime_event_digest_check check (
    payload_sha256 ~ '^sha256:[0-9a-f]{64}$'
  )
);

create index if not exists factory_runtime_event_episode_idx
  on public.factory_runtime_event (factory_episode_id, emitted_at, eve_event_id);
create index if not exists factory_runtime_event_session_idx
  on public.factory_runtime_event (eve_session_id, emitted_at, eve_event_id);
create index if not exists factory_runtime_event_station_idx
  on public.factory_runtime_event (subagent_name, emitted_at)
  where subagent_name is not null;

-- One durable Eve session maps to exactly one optimization episode.
create unique index if not exists factory_episode_eve_session_uniq
  on public.factory_episode (eve_session_id)
  where eve_session_id is not null;

do $$
declare
  has_anon boolean := exists (select 1 from pg_roles where rolname = 'anon');
  has_authenticated boolean := exists (
    select 1 from pg_roles where rolname = 'authenticated'
  );
begin
  alter table public.factory_runtime_event enable row level security;
  if has_anon then
    revoke all on table public.factory_runtime_event from anon;
  end if;
  if has_authenticated then
    revoke all on table public.factory_runtime_event from authenticated;
  end if;
end
$$;

comment on table public.factory_runtime_event is
  'Append-only, redacted copy of Eve root-agent durable stream events. Eve event ids provide idempotency; session ids bind events to factory episodes.';
