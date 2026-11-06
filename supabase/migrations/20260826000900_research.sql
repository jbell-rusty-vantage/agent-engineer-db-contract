-- 0009 | research: mission-scoped outputs.
--
-- Missions themselves live in orchestration. What lives here is what a mission
-- produced: bundles, reports, findings, comparisons, handoffs.

begin;

create type research.bundle_status as enum
  ('assembling','complete','failed','superseded');

create type research.finding_resolution as enum
  ('pending','promoted','rejected','deferred','merged');

-- ---------------------------------------------------------------------------
-- Research bundles: the typed manifest of one mission's output artifacts.
-- ---------------------------------------------------------------------------
create table research.research_bundle (
  id                   uuid primary key default util.uuidv7(),
  tenant_id            uuid not null default util.default_tenant_id(),
  mission_id           uuid not null references orchestration.mission(id) on delete cascade,
  bundle_version       integer not null default 1,
  manifest_artifact_id uuid references orchestration.artifact(id),
  status               research.bundle_status not null default 'assembling',
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  unique (mission_id, bundle_version)
);

create trigger research_bundle_set_updated_at
  before update on research.research_bundle
  for each row execute function util.set_updated_at();

create table research.bundle_artifact (
  bundle_id   uuid not null references research.research_bundle(id) on delete cascade,
  artifact_id uuid not null references orchestration.artifact(id),
  role        text not null,
  primary key (bundle_id, artifact_id, role)
);

-- ---------------------------------------------------------------------------
-- Reports. The logical report is mutable identity; every version is immutable.
-- ---------------------------------------------------------------------------
create table research.report (
  id         uuid primary key default util.uuidv7(),
  tenant_id  uuid not null default util.default_tenant_id(),
  mission_id uuid references orchestration.mission(id) on delete set null,
  slug       text not null,
  title      text not null,
  created_at timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table research.report_version (
  id                    uuid primary key default util.uuidv7(),
  report_id             uuid not null references research.report(id) on delete cascade,
  version               integer not null,
  markdown_artifact_id  uuid references orchestration.artifact(id),
  json_artifact_id      uuid references orchestration.artifact(id),
  synthesis_consistency_eval_id uuid,
  assurance_summary     jsonb not null default '{}'::jsonb,
  published_at          timestamptz not null default now(),
  unique (report_id, version)
);

create trigger report_version_immutable
  before update or delete on research.report_version
  for each row execute function util.reject_mutation();

-- Every assertion in a report version traces to the claims that carry it.
create table research.report_claim (
  report_version_id uuid not null references research.report_version(id) on delete cascade,
  claim_id          uuid not null references evidence.claim(id),
  role              text not null default 'supports'
    check (role in ('supports','context','caveat','contradicts')),
  primary key (report_version_id, claim_id, role)
);

create index report_claim_claim_idx on research.report_claim (claim_id);

-- ---------------------------------------------------------------------------
-- Findings. A mission-level discovery is a typed object that must be resolved
-- into a knowledge record or explicitly rejected -- it cannot just sit in prose.
-- ---------------------------------------------------------------------------
create table research.finding (
  id                    uuid primary key default util.uuidv7(),
  mission_id            uuid not null references orchestration.mission(id) on delete cascade,
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  proposed_record_kind  text check (proposed_record_kind in (
    'technical_problem','solution_pattern','advanced_usage_pattern','implementation_example',
    'failure_mode','benchmark_result','compatibility_constraint','operational_practice',
    'security_consideration')),
  resolution            research.finding_resolution not null default 'pending',
  -- Set when resolution = 'promoted'. Which knowledge table it landed in is
  -- given by proposed_record_kind.
  resolved_record_id    uuid,
  rejection_reason      text,
  provenance_claim_id   uuid references evidence.claim(id),
  created_at            timestamptz not null default now(),
  resolved_at           timestamptz,
  constraint finding_promoted_has_record check (
    (resolution = 'promoted') = (resolved_record_id is not null)),
  constraint finding_rejected_has_reason check (
    resolution <> 'rejected' or rejection_reason is not null)
);

create index finding_mission_idx    on research.finding (mission_id, resolution);
create index finding_unresolved_idx on research.finding (created_at)
  where resolution = 'pending';

-- ---------------------------------------------------------------------------
-- Comparisons: the normalized form of comparisons.json.
-- ---------------------------------------------------------------------------
create table research.comparison (
  id          uuid primary key default util.uuidv7(),
  mission_id  uuid not null references orchestration.mission(id) on delete cascade,
  title       text not null,
  entity_kind text not null,
  entity_ids  uuid[] not null default '{}',
  dimensions  jsonb not null default '[]'::jsonb,
  verdicts    jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Handoffs to downstream pipelines.
-- ---------------------------------------------------------------------------
create table research.downstream_handoff (
  id                  uuid primary key default util.uuidv7(),
  mission_id          uuid not null references orchestration.mission(id) on delete cascade,
  target_pipeline     text not null
    check (target_pipeline in ('curriculum','challenge','retrieval','ranking','publication')),
  payload_artifact_id uuid references orchestration.artifact(id),
  consumed_by_work_item_id uuid references orchestration.work_item(id),
  status              text not null default 'pending'
    check (status in ('pending','consumed','failed','cancelled')),
  created_at          timestamptz not null default now(),
  consumed_at         timestamptz
);

create index downstream_handoff_pending_idx
  on research.downstream_handoff (target_pipeline, created_at)
  where status = 'pending';

commit;
