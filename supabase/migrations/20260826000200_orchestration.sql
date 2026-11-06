-- 0002 | orchestration: missions, work graph, sessions, capabilities,
--        artifacts, intents, receipts.
--
-- Ordering inside this file is dictated by the internal FK graph: lookups, then
-- mission, then the work graph, then attempts, then the artifact registry, then
-- the intent/receipt pair.
--
-- Three columns are forward references to schemas that do not exist yet
-- (ranking.selection, evaluation.*, corpus.mcp_server_version). They are created
-- as plain uuid columns here and given their FKs in 0014_deferred_fks.

begin;

-- ---------------------------------------------------------------------------
-- Frozen vocabularies -> enums. Everything still evolving -> lookup tables,
-- so adding a value is a row, not a migration.
-- ---------------------------------------------------------------------------
create type orchestration.mission_status as enum (
  'created', 'planning', 'running', 'paused', 'blocked',
  'succeeded', 'failed', 'cancelled', 'superseded'
);

create type orchestration.work_item_status as enum (
  'pending', 'ready', 'running', 'blocked',
  'succeeded', 'failed', 'cancelled', 'skipped'
);

create type orchestration.attempt_outcome as enum (
  'succeeded', 'failed', 'timeout', 'cancelled', 'rejected'
);

create type orchestration.bucket_class as enum (
  'source_captures', 'candidate', 'accepted', 'ledger', 'published'
);

-- Lookup vocabularies.
create table orchestration.artifact_type (
  code        text primary key,
  description text not null,
  created_at  timestamptz not null default now()
);

create table orchestration.intent_type (
  code           text primary key,
  description    text not null,
  schema_version int  not null default 1,
  created_at     timestamptz not null default now()
);

create table orchestration.work_item_kind (
  code        text primary key,
  description text not null,
  created_at  timestamptz not null default now()
);

create table orchestration.capability_kind (
  code        text primary key,
  description text not null,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Mission. Postgres, not the coordinator conversation, is the source of truth.
-- ---------------------------------------------------------------------------
create table orchestration.mission (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  slug                  text,
  goal                  text not null,
  research_questions    jsonb not null default '[]'::jsonb,
  acceptance_criteria   jsonb not null default '[]'::jsonb,
  -- forward reference: ranking.selection (0008), FK added in 0014
  selection_id          uuid,
  capability_profile_id uuid,
  budget_cost_usd       numeric(12,4),
  budget_wall_seconds   integer,
  budget_max_fanout     integer,
  budget_max_depth      integer,
  budget_max_retries    integer,
  status                orchestration.mission_status not null default 'created',
  terminal_reason       text,
  started_at            timestamptz,
  ended_at              timestamptz,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  constraint mission_slug_uq unique (tenant_id, slug),
  constraint mission_terminal_has_end check (
    (status in ('succeeded','failed','cancelled','superseded')) = (ended_at is not null)
  )
);

create index mission_status_idx on orchestration.mission (status, created_at desc);

create trigger mission_set_updated_at
  before update on orchestration.mission
  for each row execute function util.set_updated_at();

-- Append-only state transitions with actor and causation.
create table orchestration.mission_event (
  id           uuid primary key default util.uuidv7(),
  mission_id   uuid not null references orchestration.mission(id) on delete cascade,
  from_status  orchestration.mission_status,
  to_status    orchestration.mission_status not null,
  actor        text not null,
  reason       text,
  causation_id uuid,
  payload      jsonb not null default '{}'::jsonb,
  occurred_at  timestamptz not null default now()
);

create index mission_event_mission_idx on orchestration.mission_event (mission_id, occurred_at);

create trigger mission_event_immutable
  before update or delete on orchestration.mission_event
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------
-- Work graph: a typed DAG of work items.
-- ---------------------------------------------------------------------------
create table orchestration.work_item (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  mission_id            uuid not null references orchestration.mission(id) on delete cascade,
  kind                  text not null references orchestration.work_item_kind(code),
  spec                  jsonb not null default '{}'::jsonb,
  status                orchestration.work_item_status not null default 'pending',
  capability_profile_id uuid,
  budget_cost_usd       numeric(12,4),
  budget_wall_seconds   integer,
  max_attempts          integer not null default 3,
  attempt_count         integer not null default 0,
  terminal_evidence     jsonb,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  constraint work_item_attempts_sane check (attempt_count >= 0 and max_attempts > 0)
);

create index work_item_mission_idx on orchestration.work_item (mission_id, status);
create index work_item_ready_idx   on orchestration.work_item (status, created_at)
  where status in ('pending','ready');

create trigger work_item_set_updated_at
  before update on orchestration.work_item
  for each row execute function util.set_updated_at();

create table orchestration.work_item_dependency (
  work_item_id    uuid not null references orchestration.work_item(id) on delete cascade,
  depends_on_id   uuid not null references orchestration.work_item(id) on delete cascade,
  dependency_kind text not null default 'completion'
    check (dependency_kind in ('completion','artifact','approval','data')),
  created_at      timestamptz not null default now(),
  primary key (work_item_id, depends_on_id),
  constraint work_item_dependency_no_self check (work_item_id <> depends_on_id)
);

create index work_item_dependency_reverse_idx
  on orchestration.work_item_dependency (depends_on_id);

-- ---------------------------------------------------------------------------
-- Sessions and attempts.
-- ---------------------------------------------------------------------------
create table orchestration.agent_session (
  id                uuid primary key default util.uuidv7(),
  tenant_id         uuid not null default util.default_tenant_id(),
  eve_session_id    text not null unique,
  mission_id        uuid references orchestration.mission(id) on delete set null,
  agent_deployment  text not null,
  compaction_count  integer not null default 0,
  rotated_from_id   uuid references orchestration.agent_session(id),
  status            text not null default 'active'
    check (status in ('active','rotated','closed','failed')),
  started_at        timestamptz not null default now(),
  ended_at          timestamptz
);

create index agent_session_mission_idx on orchestration.agent_session (mission_id);

create table orchestration.attempt (
  id                  uuid primary key default util.uuidv7(),
  tenant_id           uuid not null default util.default_tenant_id(),
  work_item_id        uuid not null references orchestration.work_item(id) on delete cascade,
  attempt_no          integer not null,
  agent_deployment_id text not null,
  agent_session_id    uuid references orchestration.agent_session(id),
  eve_turn_ids        text[] not null default '{}',
  remote_child_ids    text[] not null default '{}',
  outcome             orchestration.attempt_outcome,
  cost_usd            numeric(12,4),
  latency_ms          bigint,
  token_input         bigint,
  token_output        bigint,
  started_at          timestamptz not null default now(),
  ended_at            timestamptz,
  unique (work_item_id, attempt_no)
);

create index attempt_deployment_idx on orchestration.attempt (agent_deployment_id);
create index attempt_session_idx    on orchestration.attempt (agent_session_id);

-- ---------------------------------------------------------------------------
-- Artifact registry. THE registry: every bucket object is registered here.
-- Immutable; supersession is a new row.
-- ---------------------------------------------------------------------------
create table orchestration.artifact (
  id              uuid primary key default util.uuidv7(),
  tenant_id       uuid not null default util.default_tenant_id(),
  artifact_type   text not null references orchestration.artifact_type(code),
  schema_version  int  not null default 1,
  sha256          text not null check (sha256 ~ '^[0-9a-f]{64}$'),
  bucket_class    orchestration.bucket_class not null,
  storage_bucket  text not null,
  object_path     text not null,
  media_type      text,
  size_bytes      bigint check (size_bytes >= 0),
  producer_attempt_id uuid references orchestration.attempt(id),
  mission_id      uuid references orchestration.mission(id) on delete set null,
  superseded_by_id uuid references orchestration.artifact(id),
  created_at      timestamptz not null default now(),
  unique (sha256, artifact_type),
  unique (storage_bucket, object_path)
);

create index artifact_mission_idx on orchestration.artifact (mission_id);
create index artifact_type_idx    on orchestration.artifact (artifact_type, created_at desc);

-- Immutable except for superseded_by_id, which is the one legal amendment.
create or replace function orchestration.artifact_guard() returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    raise exception 'orchestration.artifact is append-only' using errcode = 'restrict_violation';
  end if;
  if row(new.*) is distinct from row(old.*)
     and (new.id, new.sha256, new.artifact_type, new.storage_bucket, new.object_path,
          new.bucket_class, new.schema_version, new.created_at)
         is distinct from
         (old.id, old.sha256, old.artifact_type, old.storage_bucket, old.object_path,
          old.bucket_class, old.schema_version, old.created_at)
  then
    raise exception 'orchestration.artifact is immutable; only superseded_by_id may be set'
      using errcode = 'restrict_violation';
  end if;
  return new;
end;
$$;

create trigger artifact_immutable
  before update or delete on orchestration.artifact
  for each row execute function orchestration.artifact_guard();

-- Pipeline output manifests: required / produced / omitted / failed / deferred.
create table orchestration.artifact_manifest (
  id            uuid primary key default util.uuidv7(),
  mission_id    uuid references orchestration.mission(id) on delete cascade,
  work_item_id  uuid references orchestration.work_item(id) on delete cascade,
  required      jsonb not null default '[]'::jsonb,
  produced      jsonb not null default '[]'::jsonb,
  omitted       jsonb not null default '[]'::jsonb,
  failed        jsonb not null default '[]'::jsonb,
  deferred      jsonb not null default '[]'::jsonb,
  created_at    timestamptz not null default now(),
  constraint artifact_manifest_scope check (num_nonnulls(mission_id, work_item_id) >= 1)
);

-- Work item <-> artifact, both directions of use.
create table orchestration.work_item_artifact (
  work_item_id uuid not null references orchestration.work_item(id) on delete cascade,
  artifact_id  uuid not null references orchestration.artifact(id) on delete cascade,
  role         text not null check (role in ('produced','consumed')),
  primary key (work_item_id, artifact_id, role)
);

-- Coordinator compaction/rotation checkpoints.
create table orchestration.continuation_checkpoint (
  id                  uuid primary key default util.uuidv7(),
  mission_id          uuid not null references orchestration.mission(id) on delete cascade,
  agent_session_id    uuid references orchestration.agent_session(id),
  constraints_section jsonb not null default '{}'::jsonb,
  decisions           jsonb not null default '{}'::jsonb,
  completed           jsonb not null default '{}'::jsonb,
  active              jsonb not null default '{}'::jsonb,
  blocked             jsonb not null default '{}'::jsonb,
  failed_approaches   jsonb not null default '{}'::jsonb,
  pending_approvals   jsonb not null default '{}'::jsonb,
  digests             jsonb not null default '{}'::jsonb,
  refs                jsonb not null default '{}'::jsonb,
  verification_status text not null default 'unverified'
    check (verification_status in ('unverified','verified','failed')),
  package_artifact_id uuid references orchestration.artifact(id),
  created_at          timestamptz not null default now()
);

create index continuation_checkpoint_mission_idx
  on orchestration.continuation_checkpoint (mission_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Capability catalog. THIS IS YOUR RUNTIME, not corpus.mcp_server.
-- corpus.mcp_server is the industry under study; this is what agents may run.
-- ---------------------------------------------------------------------------
create table orchestration.capability (
  id          uuid primary key default util.uuidv7(),
  tenant_id   uuid not null default util.default_tenant_id(),
  slug        text not null,
  kind        text not null references orchestration.capability_kind(code),
  purpose     text not null,
  operations  text[] not null default '{}',
  -- forward reference: corpus.mcp_server_version (0005), FK added in 0014
  packages_mcp_server_version_id uuid,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (tenant_id, slug)
);

create trigger capability_set_updated_at
  before update on orchestration.capability
  for each row execute function util.set_updated_at();

create table orchestration.capability_version (
  id                   uuid primary key default util.uuidv7(),
  capability_id        uuid not null references orchestration.capability(id) on delete cascade,
  version_label        text not null,
  lifecycle            text not null default 'draft'
    check (lifecycle in ('draft','candidate','active','deprecated','retired')),
  -- forward reference: evaluation dataset/suite (0011), FK added in 0014
  eval_suite_id        uuid,
  network_requirements jsonb not null default '{}'::jsonb,
  secret_requirements  jsonb not null default '{}'::jsonb,
  approval_policy      jsonb not null default '{}'::jsonb,
  created_at           timestamptz not null default now(),
  unique (capability_id, version_label)
);

create table orchestration.capability_profile (
  id         uuid primary key default util.uuidv7(),
  tenant_id  uuid not null default util.default_tenant_id(),
  slug       text not null,
  purpose    text not null,
  created_at timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table orchestration.capability_profile_item (
  profile_id            uuid not null references orchestration.capability_profile(id) on delete cascade,
  capability_version_id uuid not null references orchestration.capability_version(id) on delete cascade,
  activation            text not null default 'available'
    check (activation in ('available','preloaded','on_demand','disabled')),
  primary key (profile_id, capability_version_id)
);

-- Router policy for abstract operations (discover_web_sources, fetch_page, ...).
create table orchestration.provider_route (
  id                 uuid primary key default util.uuidv7(),
  abstract_operation text not null,
  provider           text not null,
  policy_version     int  not null default 1,
  selection_rules    jsonb not null default '{}'::jsonb,
  priority           integer not null default 100,
  enabled            boolean not null default true,
  failure_rollup     jsonb not null default '{}'::jsonb,
  created_at         timestamptz not null default now(),
  unique (abstract_operation, provider, policy_version)
);

-- ---------------------------------------------------------------------------
-- The only canonical write path: intent -> executor -> receipt.
-- Agents emit intents. The executor mutates. This is enforced by grants in 0015.
-- ---------------------------------------------------------------------------
create table orchestration.operation_intent (
  id                  uuid primary key default util.uuidv7(),
  tenant_id           uuid not null default util.default_tenant_id(),
  intent_type         text not null references orchestration.intent_type(code),
  schema_version      int  not null default 1,
  payload             jsonb not null,
  preconditions       jsonb not null default '{}'::jsonb,
  idempotency_key     text not null unique,
  proposed_by_attempt uuid references orchestration.attempt(id),
  mission_id          uuid references orchestration.mission(id) on delete set null,
  approval_state      text not null default 'pending'
    check (approval_state in ('pending','approved','budgeted','denied','escalated')),
  policy_decision     jsonb,
  created_at          timestamptz not null default now()
);

create index operation_intent_state_idx on orchestration.operation_intent (approval_state, created_at);
create index operation_intent_mission_idx on orchestration.operation_intent (mission_id);

create table orchestration.operation_receipt (
  id                   uuid primary key default util.uuidv7(),
  intent_id            uuid not null unique references orchestration.operation_intent(id),
  executor_version     text not null,
  precondition_results jsonb not null default '{}'::jsonb,
  outcome              text not null
    check (outcome in ('applied','rejected','noop','partial')),
  changes_summary      jsonb not null default '{}'::jsonb,
  affected_refs        jsonb not null default '[]'::jsonb,
  applied_at           timestamptz not null default now()
);

create index operation_receipt_applied_idx on orchestration.operation_receipt (applied_at desc);

create trigger operation_receipt_immutable
  before update or delete on orchestration.operation_receipt
  for each row execute function util.reject_mutation();

-- Transactional outbox for the event relay.
create table orchestration.outbox_event (
  id            bigserial primary key,
  topic         text not null,
  payload       jsonb not null,
  mission_id    uuid references orchestration.mission(id) on delete cascade,
  causation_id  uuid,
  published_at  timestamptz,
  created_at    timestamptz not null default now()
);

create index outbox_event_unpublished_idx on orchestration.outbox_event (created_at)
  where published_at is null;

-- ---------------------------------------------------------------------------
-- Seed the lookup vocabularies with the values the checkpoint already fixes.
-- These are rows, so extending them later is an INSERT, not a migration.
-- ---------------------------------------------------------------------------
insert into orchestration.artifact_type (code, description) values
  ('run_manifest',        'Manifest describing one pipeline run'),
  ('source_capture',      'Raw captured source content'),
  ('claims',              'Extracted claims payload'),
  ('evidence_links',      'Claim to locator link set'),
  ('comparisons',         'Normalized entity comparison payload'),
  ('report_markdown',     'Rendered report, markdown'),
  ('report_json',         'Rendered report, structured'),
  ('evidence_packet',     'Retrieval evidence packet'),
  ('checkpoint_package',  'Coordinator continuation checkpoint bundle'),
  ('execution_receipt',   'Executor receipt payload'),
  ('transcript',          'Media transcript'),
  ('eval_dataset',        'Evaluation dataset snapshot')
on conflict (code) do nothing;

insert into orchestration.intent_type (code, description) values
  ('upsert_entity',        'Create or update a canonical corpus entity'),
  ('link_entities',        'Create a corpus relationship row'),
  ('merge_entities',       'Merge two canonical entities'),
  ('upsert_knowledge',     'Create or update a knowledge record'),
  ('assign_taxonomy_term', 'Assign a taxonomy term to a target'),
  ('record_claim',         'Register an evidence claim'),
  ('verify_claim',         'Record a verification outcome'),
  ('promote_candidate',    'Promote a staging candidate to canonical'),
  ('retract_record',       'Retract a canonical row or record'),
  ('publish_report',       'Publish an immutable report version')
on conflict (code) do nothing;

insert into orchestration.work_item_kind (code, description) values
  ('discover_sources',   'Find candidate sources for a research question'),
  ('capture_source',     'Fetch and store an immutable source capture'),
  ('extract_claims',     'Extract atomic claims with locators'),
  ('verify_claims',      'Independently verify extracted claims'),
  ('resolve_identity',   'Resolve candidates against canonical entities'),
  ('synthesize_report',  'Compose a report from verified claims'),
  ('rank_entities',      'Execute a ranking policy run'),
  ('build_vectors',      'Project content into a vector space'),
  ('author_lesson',      'Author or revise curriculum content'),
  ('review_task',        'Human or model review of a queued decision')
on conflict (code) do nothing;

insert into orchestration.capability_kind (code, description) values
  ('skill',        'An Eve/Claude agent skill'),
  ('mcp_server',   'A connected MCP server this runtime may call'),
  ('authored_tool','A tool authored in this monorepo'),
  ('sandbox',      'An execution sandbox'),
  ('provider_api', 'A direct third-party API integration')
on conflict (code) do nothing;

commit;
