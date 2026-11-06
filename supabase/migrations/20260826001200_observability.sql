-- 0012 | observability: traces, spans, events, I/O links, handoffs, rollups.
--
-- raw_event, span and normalized_event are the only unbounded-growth tables in
-- the system, so all three are declaratively range-partitioned by month from day
-- one. Retrofitting partitioning onto a large table is painful; doing it now is
-- free.
--
-- pg_cron and pg_partman are both available on this instance but NOT installed,
-- so partition creation is a plain function called by the control plane rather
-- than a scheduled job inside the database. No extension, no scheduler, and the
-- whole mechanism stays visible in migrations.

begin;

-- ---------------------------------------------------------------------------
-- Trace index. One row per distinct trace, carrying the section 21 propagation
-- set so a trace can be joined back to the work that produced it.
-- ---------------------------------------------------------------------------
create table observability.trace (
  trace_id      text primary key,
  tenant_id     uuid not null default util.default_tenant_id(),
  mission_id    uuid references orchestration.mission(id) on delete set null,
  work_item_id  uuid references orchestration.work_item(id) on delete set null,
  attempt_id    uuid references orchestration.attempt(id) on delete set null,
  causation_id  uuid,
  root_span_id  text,
  started_at    timestamptz not null default now(),
  ended_at      timestamptz
);

create index trace_mission_idx on observability.trace (mission_id, started_at desc);
create index trace_attempt_idx on observability.trace (attempt_id);

-- ---------------------------------------------------------------------------
-- Partitioned event tables.
-- ---------------------------------------------------------------------------
create table observability.span (
  id            uuid not null default util.uuidv7(),
  trace_id      text not null,
  span_id       text not null,
  parent_span_id text,
  name          text not null,
  kind          text not null check (kind in ('model','tool','mcp','retrieval','executor','http','db','internal')),
  status        text not null default 'ok' check (status in ('ok','error','cancelled')),
  started_at    timestamptz not null,
  ended_at      timestamptz,
  duration_ms   bigint,
  cost_usd      numeric(12,6),
  token_input   bigint,
  token_output  bigint,
  attributes    jsonb not null default '{}'::jsonb,
  occurred_at   timestamptz not null default now(),
  primary key (id, occurred_at)
) partition by range (occurred_at);

create index span_trace_idx on observability.span (trace_id, started_at);
create index span_kind_idx  on observability.span (kind, occurred_at desc);

create table observability.raw_event (
  id             uuid not null default util.uuidv7(),
  stream_cursor  text,
  idempotency_key text not null,
  event          jsonb not null,
  trace_id       text,
  occurred_at    timestamptz not null default now(),
  primary key (id, occurred_at),
  unique (idempotency_key, occurred_at)
) partition by range (occurred_at);

create index raw_event_trace_idx on observability.raw_event (trace_id, occurred_at desc);

create table observability.normalized_event (
  id            uuid not null default util.uuidv7(),
  raw_event_id  uuid,
  trace_id      text,
  mission_id    uuid,
  event_kind    text not null,
  lifecycle_phase text,
  payload       jsonb not null default '{}'::jsonb,
  occurred_at   timestamptz not null default now(),
  primary key (id, occurred_at)
) partition by range (occurred_at);

create index normalized_event_kind_idx    on observability.normalized_event (event_kind, occurred_at desc);
create index normalized_event_mission_idx on observability.normalized_event (mission_id, occurred_at desc);

-- Append-only. Partition children inherit triggers created on the parent.
create trigger span_immutable
  before update or delete on observability.span
  for each row execute function util.reject_mutation();

create trigger raw_event_immutable
  before update or delete on observability.raw_event
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------
-- Partition management. Idempotent, so the control plane can call it on every
-- mission start without coordination.
-- ---------------------------------------------------------------------------
create or replace function util.ensure_month_partitions(p_months_ahead integer default 3)
returns integer
language plpgsql
set search_path = ''
as $$
declare
  t           text;
  i           integer;
  v_start     date;
  v_end       date;
  v_name      text;
  v_created   integer := 0;
begin
  if p_months_ahead < 0 then
    raise exception 'p_months_ahead must be >= 0';
  end if;

  foreach t in array array['span','raw_event','normalized_event'] loop
    -- Start one month back so a late-arriving event still lands somewhere.
    for i in -1 .. p_months_ahead loop
      v_start := date_trunc('month', (now() at time zone 'utc')::date + make_interval(months => i))::date;
      v_end   := (v_start + interval '1 month')::date;
      v_name  := format('%s_%s', t, to_char(v_start, 'YYYYMM'));

      if not exists (
        select 1 from pg_class c
        join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'observability' and c.relname = v_name
      ) then
        execute format(
          'create table observability.%I partition of observability.%I for values from (%L) to (%L)',
          v_name, t, v_start, v_end);
        v_created := v_created + 1;
      end if;
    end loop;
  end loop;

  return v_created;
end;
$$;

comment on function util.ensure_month_partitions(integer) is
  'Idempotently creates monthly partitions for the observability event tables, from one month back to p_months_ahead forward. Call from the control plane; there is no pg_cron on this instance.';

-- A default partition would silently absorb rows outside every range and make
-- future partition creation fail, so instead we create real partitions up front
-- and rely on the control plane to keep running ahead.
select util.ensure_month_partitions(6);

-- ---------------------------------------------------------------------------
-- I/O links, handoffs, rollups.
-- ---------------------------------------------------------------------------
create table observability.io_link (
  id          uuid primary key default util.uuidv7(),
  trace_id    text,
  span_id     text,
  artifact_id uuid not null references orchestration.artifact(id),
  direction   text not null check (direction in ('input','output')),
  encrypted   boolean not null default true,
  created_at  timestamptz not null default now()
);

create index io_link_span_idx on observability.io_link (trace_id, span_id);

create table observability.coordinator_handoff (
  id                 uuid primary key default util.uuidv7(),
  old_session_id     uuid references orchestration.agent_session(id),
  new_session_id     uuid references orchestration.agent_session(id),
  checkpoint_id      uuid references orchestration.continuation_checkpoint(id),
  verification_state text not null default 'unverified'
    check (verification_state in ('unverified','verified','failed')),
  created_at         timestamptz not null default now()
);

create table observability.usage_rollup (
  id            uuid primary key default util.uuidv7(),
  mission_id    uuid references orchestration.mission(id) on delete cascade,
  day           date not null,
  cost_usd      numeric(14,6) not null default 0,
  token_input   bigint not null default 0,
  token_output  bigint not null default 0,
  latency_ms_p50 bigint,
  latency_ms_p95 bigint,
  retry_count   integer not null default 0,
  span_count    bigint not null default 0,
  computed_at   timestamptz not null default now(),
  unique (mission_id, day)
);

create index usage_rollup_day_idx on observability.usage_rollup (day desc);

commit;
