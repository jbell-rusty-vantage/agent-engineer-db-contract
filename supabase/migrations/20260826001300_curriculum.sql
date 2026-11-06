-- 0013 | curriculum: authoring-side content model.
--
-- Deliberately minimal until the curriculum contracts resolve, but the boundary
-- and the FK directions are fixed now so they are designed rather than
-- retrofitted.
--
-- Learner state -- progress, XP, submissions, enrolment -- is NOT here. It goes
-- in a future `learning` schema, so learner PII never entangles with the
-- authoring and content model.
--
-- lesson_backed_by is the payoff of the whole architecture: curriculum freshness
-- becomes a query over knowledge.*.revalidation_state, not an editorial guess.

begin;

create type curriculum.publish_status as enum ('draft','in_review','published','retired');

create table curriculum.curriculum (
  id         uuid primary key default util.uuidv7(),
  tenant_id  uuid not null default util.default_tenant_id(),
  slug       text not null,
  title      text not null,
  audience   text,
  version    integer not null default 1,
  status     curriculum.publish_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, slug, version)
);

create trigger curriculum_set_updated_at
  before update on curriculum.curriculum
  for each row execute function util.set_updated_at();

create table curriculum.track (
  id            uuid primary key default util.uuidv7(),
  curriculum_id uuid not null references curriculum.curriculum(id) on delete cascade,
  slug          text not null,
  title         text not null,
  ordering      integer not null default 0,
  created_at    timestamptz not null default now(),
  unique (curriculum_id, slug)
);

create table curriculum.module (
  id                uuid primary key default util.uuidv7(),
  track_id          uuid not null references curriculum.track(id) on delete cascade,
  slug              text not null,
  title             text not null,
  ordering          integer not null default 0,
  learning_level_term_id uuid references taxonomy.term(id),
  created_at        timestamptz not null default now(),
  unique (track_id, slug)
);

create table curriculum.lesson (
  id         uuid primary key default util.uuidv7(),
  module_id  uuid not null references curriculum.module(id) on delete cascade,
  slug       text not null,
  title      text not null,
  ordering   integer not null default 0,
  created_at timestamptz not null default now(),
  unique (module_id, slug)
);

-- IMMUTABLE. Content is versioned; the lesson row is stable identity.
create table curriculum.lesson_version (
  id                  uuid primary key default util.uuidv7(),
  lesson_id           uuid not null references curriculum.lesson(id) on delete cascade,
  version             integer not null,
  content_artifact_id uuid references orchestration.artifact(id),
  status              curriculum.publish_status not null default 'draft',
  published_at        timestamptz,
  created_at          timestamptz not null default now(),
  unique (lesson_id, version)
);

-- A published version is frozen; drafts may still be edited.
create or replace function curriculum.lesson_version_guard() returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    if old.status = 'published' then
      raise exception 'published lesson versions cannot be deleted' using errcode = 'restrict_violation';
    end if;
    return old;
  end if;
  if old.status = 'published'
     and (new.content_artifact_id, new.version, new.lesson_id)
         is distinct from (old.content_artifact_id, old.version, old.lesson_id) then
    raise exception 'lesson version % is published and immutable; create a new version', old.version
      using errcode = 'restrict_violation';
  end if;
  return new;
end;
$$;

create trigger lesson_version_immutable_when_published
  before update or delete on curriculum.lesson_version
  for each row execute function curriculum.lesson_version_guard();

create table curriculum.learning_objective (
  id                uuid primary key default util.uuidv7(),
  lesson_version_id uuid not null references curriculum.lesson_version(id) on delete cascade,
  statement         text not null,
  bloom_level       text check (bloom_level in
    ('remember','understand','apply','analyze','evaluate','create')),
  ordering          integer not null default 0,
  created_at        timestamptz not null default now()
);

create table curriculum.lesson_covers_concept (
  id                uuid primary key default util.uuidv7(),
  lesson_version_id uuid not null references curriculum.lesson_version(id) on delete cascade,
  concept_id        uuid not null references corpus.concept(id),
  depth             text not null default 'mention'
    check (depth in ('mention','section','dedicated')),
  unique (lesson_version_id, concept_id)
);

-- ---------------------------------------------------------------------------
-- Every technical assertion in a lesson traces to a verified knowledge record.
-- Freshness inherits the record's revalidation state, so stale knowledge flags
-- stale lessons automatically.
-- ---------------------------------------------------------------------------
create table curriculum.lesson_backed_by (
  id                uuid primary key default util.uuidv7(),
  lesson_version_id uuid not null references curriculum.lesson_version(id) on delete cascade,
  technical_problem_id  uuid references knowledge.technical_problem(id),
  solution_pattern_id   uuid references knowledge.solution_pattern(id),
  advanced_usage_pattern_id uuid references knowledge.advanced_usage_pattern(id),
  implementation_example_id uuid references knowledge.implementation_example(id),
  failure_mode_id       uuid references knowledge.failure_mode(id),
  benchmark_result_id   uuid references knowledge.benchmark_result(id),
  compatibility_constraint_id uuid references knowledge.compatibility_constraint(id),
  operational_practice_id uuid references knowledge.operational_practice(id),
  security_consideration_id uuid references knowledge.security_consideration(id),
  record_kind text generated always as (
    case
      when technical_problem_id       is not null then 'technical_problem'
      when solution_pattern_id        is not null then 'solution_pattern'
      when advanced_usage_pattern_id  is not null then 'advanced_usage_pattern'
      when implementation_example_id  is not null then 'implementation_example'
      when failure_mode_id            is not null then 'failure_mode'
      when benchmark_result_id        is not null then 'benchmark_result'
      when compatibility_constraint_id is not null then 'compatibility_constraint'
      when operational_practice_id    is not null then 'operational_practice'
      when security_consideration_id  is not null then 'security_consideration'
    end) stored,
  assertion_ref text,
  created_at    timestamptz not null default now(),
  constraint lesson_backed_by_exactly_one check (
    num_nonnulls(technical_problem_id, solution_pattern_id, advanced_usage_pattern_id,
                 implementation_example_id, failure_mode_id, benchmark_result_id,
                 compatibility_constraint_id, operational_practice_id,
                 security_consideration_id) = 1)
);

create index lesson_backed_by_lesson_idx on curriculum.lesson_backed_by (lesson_version_id);
create index lesson_backed_by_kind_idx   on curriculum.lesson_backed_by (record_kind);

create table curriculum.lesson_prerequisite (
  lesson_id          uuid not null references curriculum.lesson(id) on delete cascade,
  requires_lesson_id uuid not null references curriculum.lesson(id) on delete cascade,
  primary key (lesson_id, requires_lesson_id),
  constraint lesson_prerequisite_no_self check (lesson_id <> requires_lesson_id)
);

-- ---------------------------------------------------------------------------
-- Challenges.
-- ---------------------------------------------------------------------------
create table curriculum.challenge (
  id         uuid primary key default util.uuidv7(),
  tenant_id  uuid not null default util.default_tenant_id(),
  slug       text not null,
  title      text not null,
  module_id  uuid references curriculum.module(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table curriculum.challenge_version (
  id                       uuid primary key default util.uuidv7(),
  challenge_id             uuid not null references curriculum.challenge(id) on delete cascade,
  version                  integer not null,
  statement                text not null,
  difficulty               text check (difficulty in ('introductory','intermediate','advanced','expert')),
  environment_spec_artifact_id uuid references orchestration.artifact(id),
  rubric                   jsonb not null default '{}'::jsonb,
  status                   curriculum.publish_status not null default 'draft',
  created_at               timestamptz not null default now(),
  unique (challenge_id, version)
);

create table curriculum.challenge_targets (
  id                   uuid primary key default util.uuidv7(),
  challenge_version_id uuid not null references curriculum.challenge_version(id) on delete cascade,
  concept_id           uuid references corpus.concept(id),
  library_id           uuid references corpus.library(id),
  mcp_server_id        uuid references corpus.mcp_server(id),
  agent_skill_id       uuid references corpus.agent_skill(id),
  solution_pattern_id  uuid references knowledge.solution_pattern(id),
  target_kind text generated always as (
    case
      when concept_id          is not null then 'concept'
      when library_id          is not null then 'library'
      when mcp_server_id       is not null then 'mcp_server'
      when agent_skill_id      is not null then 'agent_skill'
      when solution_pattern_id is not null then 'solution_pattern'
    end) stored,
  constraint challenge_targets_exactly_one check (
    num_nonnulls(concept_id, library_id, mcp_server_id, agent_skill_id, solution_pattern_id) = 1)
);

create index challenge_targets_version_idx on curriculum.challenge_targets (challenge_version_id);

-- Challenge provenance: which problem or failure mode this exercise came from.
create table curriculum.challenge_derived_from (
  id                   uuid primary key default util.uuidv7(),
  challenge_version_id uuid not null references curriculum.challenge_version(id) on delete cascade,
  technical_problem_id uuid references knowledge.technical_problem(id),
  failure_mode_id      uuid references knowledge.failure_mode(id),
  implementation_example_id uuid references knowledge.implementation_example(id),
  record_kind text generated always as (
    case
      when technical_problem_id      is not null then 'technical_problem'
      when failure_mode_id           is not null then 'failure_mode'
      when implementation_example_id is not null then 'implementation_example'
    end) stored,
  constraint challenge_derived_exactly_one check (
    num_nonnulls(technical_problem_id, failure_mode_id, implementation_example_id) = 1)
);

create index challenge_derived_from_version_idx on curriculum.challenge_derived_from (challenge_version_id);

commit;
