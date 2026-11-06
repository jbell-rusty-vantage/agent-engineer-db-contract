-- Additive readiness contract for concurrent Cursor Cloud research agents.
-- The database remains the progress source of truth; agents still propose
-- canonical mutations through operation_intent and an executor records a receipt.

begin;

alter table orchestration.work_item
  add column if not exists idempotency_key text,
  add column if not exists lease_owner text,
  add column if not exists lease_expires_at timestamptz,
  add column if not exists heartbeat_at timestamptz;

create unique index if not exists work_item_idempotency_uq
  on orchestration.work_item (tenant_id, idempotency_key)
  where idempotency_key is not null;

create index if not exists work_item_lease_idx
  on orchestration.work_item (status, lease_expires_at, created_at)
  where status in ('pending', 'ready', 'running');

alter table orchestration.work_item
  drop constraint if exists work_item_lease_consistent;
alter table orchestration.work_item
  add constraint work_item_lease_consistent check (
    (status = 'running' and lease_owner is not null and lease_expires_at is not null)
    or
    (status <> 'running' and lease_owner is null and lease_expires_at is null)
  );

create table if not exists orchestration.work_item_event (
  id           uuid primary key default util.uuidv7(),
  tenant_id    uuid not null default util.default_tenant_id(),
  work_item_id uuid not null references orchestration.work_item(id) on delete cascade,
  attempt_id   uuid references orchestration.attempt(id) on delete set null,
  event_type   text not null check (event_type in (
    'created', 'ready', 'claimed', 'heartbeat', 'checkpoint', 'blocked',
    'released', 'succeeded', 'failed', 'cancelled', 'skipped'
  )),
  actor        text not null,
  message      text,
  payload      jsonb not null default '{}'::jsonb,
  occurred_at  timestamptz not null default now()
);

create index if not exists work_item_event_item_idx
  on orchestration.work_item_event (work_item_id, occurred_at);

create trigger work_item_event_immutable
  before update or delete on orchestration.work_item_event
  for each row execute function util.reject_mutation();

alter table orchestration.work_item_event enable row level security;
create policy bounded_role_access on orchestration.work_item_event
  as permissive for all
  to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());

grant select, insert on orchestration.work_item_event to
  executor_service, pipeline_agent, verifier_agent, control_plane;
grant select on orchestration.work_item_event to app_reader;

insert into orchestration.work_item_kind (code, description) values
  ('select_entities', 'Choose the highest-value entities from a source video and starter research'),
  ('probe_metrics', 'Collect source-attributed metric observations for one resolved entity'),
  ('build_ingestion_intent', 'Compile validated deterministic ingestion operations'),
  ('execute_ingestion_intent', 'Apply an approved intent and emit an immutable receipt'),
  ('verify_extraction', 'Independently verify extraction locators and source fidelity'),
  ('update_timeline', 'Extend the chronological cross-video contextual summary')
on conflict (code) do nothing;

insert into orchestration.intent_type (code, description) values
  ('record_metric_observations', 'Append source-attributed observations for a canonical entity'),
  ('ingest_research_bundle', 'Register a verified source bundle, claims, candidates, and report')
on conflict (code) do nothing;

insert into orchestration.artifact_type (code, description) values
  ('metric_probe_report', 'Source-attributed metric probe results for one entity'),
  ('ingestion_intent', 'Validated deterministic canonical mutation intent'),
  ('source_attribution_audit', 'Independent locator and extraction verification report'),
  ('timeline_summary', 'Versioned rolling chronological summary across source videos')
on conflict (code) do nothing;

-- Expand metric targets to every primary entity family requested by the
-- research workflow and make collection/provenance semantics first class.
drop index if exists ranking.metric_observation_entity_idx;
alter table ranking.metric_observation
  drop constraint if exists metric_observation_exactly_one_entity,
  drop constraint if exists metric_observation_has_value,
  drop column if exists entity_kind;

alter table ranking.metric_observation
  add column if not exists dataset_id uuid references corpus.dataset(id),
  add column if not exists benchmark_id uuid references corpus.benchmark(id),
  add column if not exists talk_id uuid references corpus.talk(id),
  add column if not exists ai_model_id uuid references corpus.ai_model(id),
  add column if not exists collected_at timestamptz not null default now(),
  add column if not exists observation_window text,
  add column if not exists dimensions jsonb not null default '{}'::jsonb,
  add column if not exists measurement_kind text,
  add column if not exists is_estimate boolean not null default false,
  add column if not exists visibility text not null default 'public',
  add column if not exists access_tier text,
  add column if not exists raw_capture_id uuid references evidence.source_capture(id),
  add column if not exists collector_version text,
  add column if not exists source_policy_version text,
  add column if not exists quality_flags text[] not null default '{}',
  add column if not exists provenance jsonb not null default '{}'::jsonb,
  add column if not exists unavailable_reason text;

alter table ranking.metric_observation
  add column entity_kind text generated always as (
    case
      when library_id          is not null then 'library'
      when repository_id       is not null then 'repository'
      when person_id           is not null then 'person'
      when organization_id     is not null then 'organization'
      when paper_id            is not null then 'paper'
      when video_id            is not null then 'video'
      when talk_id             is not null then 'talk'
      when dataset_id          is not null then 'dataset'
      when benchmark_id        is not null then 'benchmark'
      when ai_model_id         is not null then 'ai_model'
      when ai_model_version_id is not null then 'ai_model_version'
      when mcp_server_id       is not null then 'mcp_server'
      when agent_skill_id      is not null then 'agent_skill'
      when product_id          is not null then 'product'
    end
  ) stored;

alter table ranking.metric_observation
  add constraint metric_observation_exactly_one_entity check (
    num_nonnulls(
      library_id, repository_id, person_id, organization_id, paper_id,
      video_id, talk_id, dataset_id, benchmark_id, ai_model_id,
      ai_model_version_id, mcp_server_id, agent_skill_id, product_id
    ) = 1
  ),
  add constraint metric_observation_has_value_or_unavailable check (
    num_nonnulls(value_numeric, value_text, value_jsonb) >= 1
    or unavailable_reason is not null
  ),
  add constraint metric_observation_time_order check (collected_at >= observed_at);

create index metric_observation_entity_idx
  on ranking.metric_observation (entity_kind, observed_at desc);
create index metric_observation_dataset_id_idx
  on ranking.metric_observation (dataset_id, observed_at desc) where dataset_id is not null;
create index metric_observation_benchmark_id_idx
  on ranking.metric_observation (benchmark_id, observed_at desc) where benchmark_id is not null;
create index metric_observation_talk_id_idx
  on ranking.metric_observation (talk_id, observed_at desc) where talk_id is not null;
create index metric_observation_ai_model_id_idx
  on ranking.metric_observation (ai_model_id, observed_at desc) where ai_model_id is not null;
create index metric_observation_capture_idx
  on ranking.metric_observation (raw_capture_id) where raw_capture_id is not null;

comment on table orchestration.work_item_event is
  'Append-only cross-agent progress ledger. Lease state remains on work_item; every transition and checkpoint is recorded here.';
comment on column ranking.metric_observation.raw_capture_id is
  'Immutable raw provider response whose SHA-256 and storage pointer establish metric provenance.';
comment on column ranking.metric_observation.unavailable_reason is
  'Explicit missingness. Unavailable observations are recorded as null, never coerced to zero.';

commit;
