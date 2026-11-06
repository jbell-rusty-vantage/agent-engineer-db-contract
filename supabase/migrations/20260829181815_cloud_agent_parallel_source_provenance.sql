-- Operational provenance for bounded Cursor Cloud research runs.
-- This is deliberately smaller than the canonical evidence/claim system: it
-- records what an agent asked, which bytes it retrieved, and why those bytes
-- mattered to a work item. Canonical claims still use evidence.locator and the
-- intent -> approval -> receipt path.

begin;

-- Identical bytes may legitimately appear in two independent attempt archives.
-- Object identity, not content identity, is the provenance identity. Keep a
-- hash index for cache discovery without collapsing separate productions.
alter table orchestration.artifact
  drop constraint if exists artifact_sha256_artifact_type_key;

create index if not exists artifact_sha256_type_idx
  on orchestration.artifact (sha256, artifact_type, created_at desc);

create unique index if not exists source_capture_artifact_uq
  on evidence.source_capture (artifact_id);

insert into orchestration.artifact_type (code, description) values
  ('workspace_file', 'One preserved file from a cloud-agent attempt workspace'),
  ('workspace_manifest', 'Deterministic manifest for a preserved attempt workspace'),
  ('source_query_response', 'Raw provider response for one research query'),
  ('research_notes', 'Intermediate research notes preserved for provenance')
on conflict (code) do nothing;

create table evidence.source_query (
  id                   uuid primary key default util.uuidv7(),
  tenant_id            uuid not null default util.default_tenant_id(),
  mission_id           uuid not null references orchestration.mission(id) on delete cascade,
  work_item_id          uuid not null references orchestration.work_item(id) on delete cascade,
  attempt_id            uuid not null references orchestration.attempt(id) on delete cascade,
  provider              text not null,
  query_text            text not null,
  purpose               text not null,
  request_parameters    jsonb not null default '{}'::jsonb,
  response_artifact_id  uuid references orchestration.artifact(id),
  query_sha256          text not null check (query_sha256 ~ '^[0-9a-f]{64}$'),
  queried_at            timestamptz not null default now(),
  constraint source_query_nonempty check (
    btrim(provider) <> '' and btrim(query_text) <> '' and btrim(purpose) <> ''
  ),
  unique (attempt_id, provider, query_sha256)
);

comment on table evidence.source_query is
  'Operational source intelligence: exact query, provider parameters, raw response artifact, and intended work-item purpose.';

create index source_query_mission_idx
  on evidence.source_query (mission_id, queried_at desc);
create index source_query_work_item_idx
  on evidence.source_query (work_item_id, queried_at desc);

create table evidence.source_retrieval (
  id                   uuid primary key default util.uuidv7(),
  tenant_id            uuid not null default util.default_tenant_id(),
  query_id             uuid references evidence.source_query(id) on delete set null,
  source_id            uuid not null references evidence.source(id),
  capture_id           uuid references evidence.source_capture(id),
  work_item_id         uuid not null references orchestration.work_item(id) on delete cascade,
  attempt_id           uuid not null references orchestration.attempt(id) on delete cascade,
  requested_url        text not null,
  provider_result_id   text,
  result_rank          integer check (result_rank is null or result_rank > 0),
  retrieval_status     text not null check (
    retrieval_status in ('discovered', 'cache_hit', 'captured', 'failed', 'skipped')
  ),
  provider_metadata    jsonb not null default '{}'::jsonb,
  retrieved_at         timestamptz not null default now(),
  constraint source_retrieval_capture_consistent check (
    (retrieval_status in ('cache_hit', 'captured') and capture_id is not null)
    or (retrieval_status not in ('cache_hit', 'captured'))
  ),
  unique nulls not distinct (attempt_id, query_id, capture_id)
);

comment on table evidence.source_retrieval is
  'A query result or direct fetch, including cache outcome and the immutable capture when bytes were obtained.';

create index source_retrieval_query_idx
  on evidence.source_retrieval (query_id, result_rank, retrieved_at);
create index source_retrieval_source_idx
  on evidence.source_retrieval (source_id, retrieved_at desc);
create index source_retrieval_work_item_idx
  on evidence.source_retrieval (work_item_id, retrieved_at desc);

create table evidence.source_support (
  id              uuid primary key default util.uuidv7(),
  tenant_id       uuid not null default util.default_tenant_id(),
  retrieval_id    uuid not null references evidence.source_retrieval(id) on delete cascade,
  work_item_id    uuid not null references orchestration.work_item(id) on delete cascade,
  operation       text not null,
  support_role    text not null check (
    support_role in ('supports', 'challenges', 'context', 'background', 'discarded')
  ),
  statement       text not null,
  locator_id      uuid references evidence.locator(id),
  created_at      timestamptz not null default now(),
  constraint source_support_nonempty check (
    btrim(operation) <> '' and btrim(statement) <> ''
  ),
  unique (retrieval_id, work_item_id, operation, support_role, statement)
);

comment on table evidence.source_support is
  'Why a retrieval mattered to an operation. This is an operational audit statement, not a canonical factual claim.';

create index source_support_work_item_idx
  on evidence.source_support (work_item_id, operation, created_at);
create index source_support_retrieval_idx
  on evidence.source_support (retrieval_id);

create trigger source_query_immutable
  before update or delete on evidence.source_query
  for each row execute function util.reject_mutation();
create trigger source_retrieval_immutable
  before update or delete on evidence.source_retrieval
  for each row execute function util.reject_mutation();
create trigger source_support_immutable
  before update or delete on evidence.source_support
  for each row execute function util.reject_mutation();

alter table evidence.source_query enable row level security;
alter table evidence.source_retrieval enable row level security;
alter table evidence.source_support enable row level security;

create policy bounded_role_access on evidence.source_query
  as permissive for all
  to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());
create policy bounded_role_access on evidence.source_retrieval
  as permissive for all
  to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());
create policy bounded_role_access on evidence.source_support
  as permissive for all
  to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());

grant select, insert on evidence.source_query, evidence.source_retrieval, evidence.source_support
  to pipeline_agent;
grant select on evidence.source_query, evidence.source_retrieval, evidence.source_support
  to verifier_agent, control_plane, executor_service, app_reader;

commit;
