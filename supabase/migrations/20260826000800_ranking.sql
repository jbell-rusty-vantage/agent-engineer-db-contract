-- 0008 | ranking: metrics, features, groups, policies, runs, selections.
--
-- Metrics never live on the canonical entity. They are immutable observations
-- here, so a value always carries the definition version that produced it, the
-- locator it came from, and the run that recorded it.
--
-- The entity arc here spans 10 targets, inside Fable's ~12 guidance, so it stays
-- a true exclusive arc rather than the supertype pattern used in staging.

begin;

create type ranking.approval_state as enum
  ('draft','proposed','approved','deprecated','rejected');

-- ---------------------------------------------------------------------------
-- Metric definitions. The full section 11 spec: what it means, how it is
-- acquired, how it decays, and what it may legitimately be used to rank.
-- ---------------------------------------------------------------------------
create table ranking.metric_definition (
  id          uuid primary key default util.uuidv7(),
  tenant_id   uuid not null default util.default_tenant_id(),
  slug        text not null,
  label       text not null,
  created_at  timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table ranking.metric_definition_version (
  id                uuid primary key default util.uuidv7(),
  metric_definition_id uuid not null references ranking.metric_definition(id) on delete cascade,
  version           integer not null,
  semantics         text not null,
  unit              text,
  source_field      text,
  acquisition       text,
  locator_method    text,
  cadence           interval,
  missingness_policy text,
  gaming_risk       text,
  decay_policy      jsonb not null default '{}'::jsonb,
  permitted_ranking_purposes text[] not null default '{}',
  approval_state    ranking.approval_state not null default 'draft',
  created_at        timestamptz not null default now(),
  unique (metric_definition_id, version)
);

create unique index metric_definition_one_approved
  on ranking.metric_definition_version (metric_definition_id)
  where approval_state = 'approved';

-- ---------------------------------------------------------------------------
-- Observations. IMMUTABLE. A value is a fact about a moment, not a column.
-- ---------------------------------------------------------------------------
create table ranking.metric_observation (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  definition_version_id uuid not null references ranking.metric_definition_version(id),
  library_id            uuid references corpus.library(id),
  repository_id         uuid references corpus.repository(id),
  person_id             uuid references corpus.person(id),
  organization_id       uuid references corpus.organization(id),
  paper_id              uuid references corpus.paper(id),
  video_id              uuid references corpus.video(id),
  ai_model_version_id   uuid references corpus.ai_model_version(id),
  mcp_server_id         uuid references corpus.mcp_server(id),
  agent_skill_id        uuid references corpus.agent_skill(id),
  product_id            uuid references corpus.product(id),
  entity_kind           text generated always as (
    case
      when library_id          is not null then 'library'
      when repository_id       is not null then 'repository'
      when person_id           is not null then 'person'
      when organization_id     is not null then 'organization'
      when paper_id            is not null then 'paper'
      when video_id            is not null then 'video'
      when ai_model_version_id is not null then 'ai_model_version'
      when mcp_server_id       is not null then 'mcp_server'
      when agent_skill_id      is not null then 'agent_skill'
      when product_id          is not null then 'product'
    end) stored,
  observed_at    timestamptz not null,
  value_numeric  numeric,
  value_text     text,
  value_jsonb    jsonb,
  locator_id     uuid references evidence.locator(id),
  run_id         uuid,
  created_at     timestamptz not null default now(),
  constraint metric_observation_exactly_one_entity check (
    num_nonnulls(library_id, repository_id, person_id, organization_id, paper_id,
                 video_id, ai_model_version_id, mcp_server_id, agent_skill_id, product_id) = 1),
  constraint metric_observation_has_value check (
    num_nonnulls(value_numeric, value_text, value_jsonb) >= 1)
);

create index metric_observation_def_time_idx
  on ranking.metric_observation (definition_version_id, observed_at desc);
create index metric_observation_entity_idx
  on ranking.metric_observation (entity_kind, observed_at desc);

do $$
declare c text;
begin
  foreach c in array array[
    'library_id','repository_id','person_id','organization_id','paper_id','video_id',
    'ai_model_version_id','mcp_server_id','agent_skill_id','product_id'
  ] loop
    execute format(
      'create index metric_observation_%s_idx on ranking.metric_observation (%I, observed_at desc) where %I is not null',
      c, c, c);
  end loop;
end;
$$;

create trigger metric_observation_immutable
  before update or delete on ranking.metric_observation
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------
-- Derived features, with lineage back to the observations that fed them.
-- ---------------------------------------------------------------------------
create table ranking.feature_definition (
  id         uuid primary key default util.uuidv7(),
  slug       text not null unique,
  version    integer not null default 1,
  expression text not null,
  inputs     jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table ranking.feature_value (
  id                    uuid primary key default util.uuidv7(),
  feature_definition_id uuid not null references ranking.feature_definition(id),
  entity_kind           text not null,
  entity_id             uuid not null,
  value_numeric         numeric,
  value_jsonb           jsonb,
  input_lineage         jsonb not null default '[]'::jsonb,
  computed_at           timestamptz not null default now(),
  unique (feature_definition_id, entity_kind, entity_id, computed_at)
);

create index feature_value_entity_idx on ranking.feature_value (entity_kind, entity_id);

-- ---------------------------------------------------------------------------
-- Groups: reviewed cohorts, with frozen snapshots for campaigns.
-- ---------------------------------------------------------------------------
create table ranking.entity_group (
  id          uuid primary key default util.uuidv7(),
  tenant_id   uuid not null default util.default_tenant_id(),
  slug        text not null,
  entity_kind text not null,
  purpose     text not null,
  definition  text,
  inclusion_rules jsonb not null default '{}'::jsonb,
  exclusion_rules jsonb not null default '{}'::jsonb,
  review_state ranking.approval_state not null default 'draft',
  created_at  timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table ranking.entity_group_version (
  id              uuid primary key default util.uuidv7(),
  entity_group_id uuid not null references ranking.entity_group(id) on delete cascade,
  version         integer not null,
  created_at      timestamptz not null default now(),
  unique (entity_group_id, version)
);

create table ranking.group_membership (
  id               uuid primary key default util.uuidv7(),
  group_version_id uuid not null references ranking.entity_group_version(id) on delete cascade,
  library_id       uuid references corpus.library(id),
  repository_id    uuid references corpus.repository(id),
  person_id        uuid references corpus.person(id),
  organization_id  uuid references corpus.organization(id),
  paper_id         uuid references corpus.paper(id),
  video_id         uuid references corpus.video(id),
  ai_model_version_id uuid references corpus.ai_model_version(id),
  mcp_server_id    uuid references corpus.mcp_server(id),
  agent_skill_id   uuid references corpus.agent_skill(id),
  product_id       uuid references corpus.product(id),
  entity_kind      text generated always as (
    case
      when library_id          is not null then 'library'
      when repository_id       is not null then 'repository'
      when person_id           is not null then 'person'
      when organization_id     is not null then 'organization'
      when paper_id            is not null then 'paper'
      when video_id            is not null then 'video'
      when ai_model_version_id is not null then 'ai_model_version'
      when mcp_server_id       is not null then 'mcp_server'
      when agent_skill_id      is not null then 'agent_skill'
      when product_id          is not null then 'product'
    end) stored,
  valid_from       timestamptz not null default now(),
  valid_to         timestamptz,
  provenance_claim_id uuid references evidence.claim(id),
  created_at       timestamptz not null default now(),
  constraint group_membership_exactly_one_entity check (
    num_nonnulls(library_id, repository_id, person_id, organization_id, paper_id,
                 video_id, ai_model_version_id, mcp_server_id, agent_skill_id, product_id) = 1)
);

create index group_membership_version_idx on ranking.group_membership (group_version_id);

-- IMMUTABLE. A frozen set, so a campaign can be replayed exactly.
create table ranking.membership_snapshot (
  id               uuid primary key default util.uuidv7(),
  group_version_id uuid not null references ranking.entity_group_version(id),
  members          jsonb not null,
  member_count     integer not null,
  frozen_at        timestamptz not null default now()
);

create trigger membership_snapshot_immutable
  before update or delete on ranking.membership_snapshot
  for each row execute function util.reject_mutation();

-- ---------------------------------------------------------------------------
-- Ranking policies and runs.
-- ---------------------------------------------------------------------------
create table ranking.ranking_policy (
  id         uuid primary key default util.uuidv7(),
  tenant_id  uuid not null default util.default_tenant_id(),
  slug       text not null,
  purpose    text not null check (purpose in (
    'research_priority','curriculum_value','production_readiness','frontier_monitoring',
    'challenge_feasibility','verification_priority','underexplored_discovery')),
  created_at timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table ranking.ranking_policy_version (
  id                uuid primary key default util.uuidv7(),
  ranking_policy_id uuid not null references ranking.ranking_policy(id) on delete cascade,
  version           integer not null,
  weights           jsonb not null default '{}'::jsonb,
  penalties         jsonb not null default '{}'::jsonb,
  approval_state    ranking.approval_state not null default 'draft',
  created_at        timestamptz not null default now(),
  unique (ranking_policy_id, version)
);

-- IMMUTABLE freeze: policy + snapshot + feature hash + code ref.
create table ranking.ranking_run (
  id                 uuid primary key default util.uuidv7(),
  policy_version_id  uuid not null references ranking.ranking_policy_version(id),
  snapshot_id        uuid references ranking.membership_snapshot(id),
  feature_set_hash   text,
  code_ref           text,
  work_item_id       uuid references orchestration.work_item(id),
  executed_at        timestamptz not null default now()
);

create trigger ranking_run_immutable
  before update or delete on ranking.ranking_run
  for each row execute function util.reject_mutation();

create table ranking.ranking_result (
  id            uuid primary key default util.uuidv7(),
  run_id        uuid not null references ranking.ranking_run(id) on delete cascade,
  entity_kind   text not null,
  entity_id     uuid not null,
  rank          integer not null,
  score         numeric not null,
  contributions jsonb not null default '{}'::jsonb,
  penalties     jsonb not null default '{}'::jsonb,
  uncertainty   numeric,
  explanation   text,
  unique (run_id, entity_kind, entity_id),
  unique (run_id, rank)
);

create index ranking_result_entity_idx on ranking.ranking_result (entity_kind, entity_id);

create table ranking.leaderboard (
  id                uuid primary key default util.uuidv7(),
  tenant_id         uuid not null default util.default_tenant_id(),
  slug              text not null,
  group_version_id  uuid not null references ranking.entity_group_version(id),
  policy_version_id uuid not null references ranking.ranking_policy_version(id),
  created_at        timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table ranking.leaderboard_edition (
  id             uuid primary key default util.uuidv7(),
  leaderboard_id uuid not null references ranking.leaderboard(id) on delete cascade,
  ranking_run_id uuid not null references ranking.ranking_run(id),
  edition_no     integer not null,
  published_at   timestamptz not null default now(),
  unique (leaderboard_id, edition_no)
);

-- ---------------------------------------------------------------------------
-- Selections: the diverse seed sets missions are launched from.
-- orchestration.mission.selection_id gets its FK to this table in 0014.
-- ---------------------------------------------------------------------------
create table ranking.selection (
  id                  uuid primary key default util.uuidv7(),
  tenant_id           uuid not null default util.default_tenant_id(),
  run_id              uuid references ranking.ranking_run(id),
  purpose             text not null,
  selected            jsonb not null default '[]'::jsonb,
  diversity_rationale text,
  coverage_rationale  text,
  created_at          timestamptz not null default now()
);

commit;
