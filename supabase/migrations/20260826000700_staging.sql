-- 0007 | staging: typed candidates, mentions, identity resolution, vetting.
--
-- This is the one place pipeline_agent has broad INSERT. Promotion into corpus
-- or knowledge happens only through orchestration.operation_intent -> executor
-- -> receipt; staging never writes canonical rows itself.
--
-- DEVIATION FROM FABLE section 8, deliberate and documented:
--
--   Fable puts an exclusive arc over the candidate tables on four different
--   infrastructure tables (mention, identity_match, resolution_decision,
--   vetting_decision). With 16 candidate kinds that is a 16-column arc repeated
--   four times -- 64 columns of arc -- and Fable's own guidance says to revisit
--   an arc past about 12 targets.
--
--   Instead: staging.candidate is a real supertype table carrying the shared
--   block, and each per-type candidate table is a subtype keyed on it. The four
--   infrastructure tables take a single real FK to staging.candidate(id).
--
--   The subtype link is fully enforced, not conventional: each subtype pins its
--   candidate_kind with a CHECK and a composite FK into
--   staging.candidate(id, candidate_kind), so a library candidate row cannot
--   attach itself to a person candidate. This keeps Fable's rule -- never an
--   untyped (entity_type text, entity_id uuid) pair without FKs -- while
--   avoiding the 64-column arc.
--
--   The arc that genuinely belongs (a candidate resolving to one of 15 canonical
--   corpus types) is still an exclusive arc, on identity_match only.

begin;

-- Frozen by checkpoint section 10.
create type staging.resolution_outcome as enum (
  'insert','update','link','merge','supersede','no_op','quarantine','reject','review'
);

-- Frozen by checkpoint section 11.
create type staging.vetting_outcome as enum (
  'approved_for_metrics','approved_for_research','approved_provisionally',
  'deferred','insufficient_evidence','out_of_scope','rejected'
);

create type staging.candidate_status as enum (
  'discovered','enriched','matched','resolved','promoted','quarantined','rejected'
);

-- ---------------------------------------------------------------------------
-- The candidate supertype: the block every candidate shares.
-- ---------------------------------------------------------------------------
create table staging.candidate (
  id             uuid primary key default util.uuidv7(),
  tenant_id      uuid not null default util.default_tenant_id(),
  candidate_kind text not null check (candidate_kind in (
    'library','repository','person','organization','paper','video','talk','product',
    'concept','dataset','benchmark','ai_model','ai_protocol','mcp_server','agent_skill',
    'technical_record')),
  status         staging.candidate_status not null default 'discovered',
  raw            jsonb not null default '{}'::jsonb,
  discovered_by_attempt_id uuid references orchestration.attempt(id),
  discovery_method text,
  provider       text,
  -- Identity evidence: what was actually seen, and where in it.
  capture_id     uuid references evidence.source_capture(id),
  locator_id     uuid references evidence.locator(id),
  mission_id     uuid references orchestration.mission(id) on delete set null,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  -- The composite target that lets subtypes prove they match their kind.
  unique (id, candidate_kind)
);

create index candidate_kind_status_idx on staging.candidate (candidate_kind, status);
create index candidate_mission_idx     on staging.candidate (mission_id);
create index candidate_attempt_idx     on staging.candidate (discovered_by_attempt_id);

create trigger candidate_set_updated_at
  before update on staging.candidate
  for each row execute function util.set_updated_at();

-- ---------------------------------------------------------------------------
-- Per-type candidate subtypes. Columns mirror the canonical identity keys, so
-- matching is a comparison of like with like.
-- ---------------------------------------------------------------------------

create table staging.candidate_library (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'library' check (candidate_kind = 'library'),
  ecosystem      text,
  package_name   text,
  display_name   text,
  homepage_url   text,
  primary_language text,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_repository (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'repository' check (candidate_kind = 'repository'),
  host           text,
  owner          text,
  name           text,
  primary_language text,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_person (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'person' check (candidate_kind = 'person'),
  display_name   text,
  given_name     text,
  family_name    text,
  headline       text,
  identifiers    jsonb not null default '{}'::jsonb,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_organization (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'organization' check (candidate_kind = 'organization'),
  display_name   text,
  legal_name     text,
  website_url    text,
  identifiers    jsonb not null default '{}'::jsonb,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_paper (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'paper' check (candidate_kind = 'paper'),
  title          text,
  doi            text,
  arxiv_id       text,
  openreview_id  text,
  published_on   date,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_video (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'video' check (candidate_kind = 'video'),
  platform       text,
  external_id    text,
  title          text,
  channel        text,
  published_at   timestamptz,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_talk (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'talk' check (candidate_kind = 'talk'),
  title          text,
  event_slug     text,
  event_name     text,
  delivered_on   date,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_product (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'product' check (candidate_kind = 'product'),
  display_name   text,
  vendor_name    text,
  homepage_url   text,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_concept (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'concept' check (candidate_kind = 'concept'),
  preferred_label text,
  definition     text,
  aliases        text[] not null default '{}',
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_dataset (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'dataset' check (candidate_kind = 'dataset'),
  host           text,
  external_id    text,
  name           text,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_benchmark (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'benchmark' check (candidate_kind = 'benchmark'),
  name           text,
  task_domain    text,
  homepage_url   text,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_ai_model (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'ai_model' check (candidate_kind = 'ai_model'),
  provider_name  text,
  model_slug     text,
  display_name   text,
  family         text,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_ai_protocol (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'ai_protocol' check (candidate_kind = 'ai_protocol'),
  slug           text,
  name           text,
  spec_url       text,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_mcp_server (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'mcp_server' check (candidate_kind = 'mcp_server'),
  name           text,
  registry_id    text,
  ecosystem      text,
  package_name   text,
  repository_url text,
  transport_kinds text[] not null default '{}',
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

create table staging.candidate_agent_skill (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'agent_skill' check (candidate_kind = 'agent_skill'),
  name           text,
  slug           text,
  distribution   text,
  repository_url text,
  skill_format   text,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

-- Technical records carry their own kind discriminator, matching the nine
-- knowledge record types.
create table staging.candidate_technical_record (
  candidate_id   uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind text not null default 'technical_record' check (candidate_kind = 'technical_record'),
  record_kind    text not null check (record_kind in (
    'technical_problem','solution_pattern','advanced_usage_pattern','implementation_example',
    'failure_mode','benchmark_result','compatibility_constraint','operational_practice',
    'security_consideration')),
  title          text,
  statement      text,
  structured     jsonb,
  scope          jsonb not null default '{}'::jsonb,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);

-- ---------------------------------------------------------------------------
-- Mentions: where a candidate was seen. Seed and mention extraction, section 11.
-- ---------------------------------------------------------------------------
create table staging.mention (
  id                 uuid primary key default util.uuidv7(),
  candidate_id       uuid not null references staging.candidate(id) on delete cascade,
  appeared_in_capture_id uuid not null references evidence.source_capture(id),
  snippet_locator_id uuid references evidence.locator(id),
  surface_form       text,
  created_at         timestamptz not null default now()
);

create index mention_candidate_idx on staging.mention (candidate_id);
create index mention_capture_idx   on staging.mention (appeared_in_capture_id);

-- ---------------------------------------------------------------------------
-- Identity matching. This is where the genuine exclusive arc lives: one
-- candidate resolving to one of fifteen canonical corpus types.
-- ---------------------------------------------------------------------------
create table staging.identity_match (
  id             uuid primary key default util.uuidv7(),
  candidate_id   uuid not null references staging.candidate(id) on delete cascade,
  organization_id uuid references corpus.organization(id),
  person_id      uuid references corpus.person(id),
  library_id     uuid references corpus.library(id),
  repository_id  uuid references corpus.repository(id),
  paper_id       uuid references corpus.paper(id),
  talk_id        uuid references corpus.talk(id),
  video_id       uuid references corpus.video(id),
  product_id     uuid references corpus.product(id),
  concept_id     uuid references corpus.concept(id),
  dataset_id     uuid references corpus.dataset(id),
  benchmark_id   uuid references corpus.benchmark(id),
  ai_model_id    uuid references corpus.ai_model(id),
  ai_protocol_id uuid references corpus.ai_protocol(id),
  mcp_server_id  uuid references corpus.mcp_server(id),
  agent_skill_id uuid references corpus.agent_skill(id),
  target_kind    text generated always as (
    case
      when organization_id is not null then 'organization'
      when person_id       is not null then 'person'
      when library_id      is not null then 'library'
      when repository_id   is not null then 'repository'
      when paper_id        is not null then 'paper'
      when talk_id         is not null then 'talk'
      when video_id        is not null then 'video'
      when product_id      is not null then 'product'
      when concept_id      is not null then 'concept'
      when dataset_id      is not null then 'dataset'
      when benchmark_id    is not null then 'benchmark'
      when ai_model_id     is not null then 'ai_model'
      when ai_protocol_id  is not null then 'ai_protocol'
      when mcp_server_id   is not null then 'mcp_server'
      when agent_skill_id  is not null then 'agent_skill'
    end) stored,
  match_method   text not null check (match_method in ('exact','normalized','model','human')),
  score          corpus.confidence,
  decided        boolean not null default false,
  created_at     timestamptz not null default now(),
  constraint identity_match_exactly_one_target check (
    num_nonnulls(organization_id, person_id, library_id, repository_id, paper_id,
                 talk_id, video_id, product_id, concept_id, dataset_id, benchmark_id,
                 ai_model_id, ai_protocol_id, mcp_server_id, agent_skill_id) = 1)
);

create index identity_match_candidate_idx on staging.identity_match (candidate_id, decided);
create index identity_match_target_idx    on staging.identity_match (target_kind);

-- Index each arc column, per Fable's association pattern guidance.
do $$
declare c text;
begin
  foreach c in array array[
    'organization_id','person_id','library_id','repository_id','paper_id','talk_id',
    'video_id','product_id','concept_id','dataset_id','benchmark_id','ai_model_id',
    'ai_protocol_id','mcp_server_id','agent_skill_id'
  ] loop
    execute format(
      'create index identity_match_%s_idx on staging.identity_match (%I) where %I is not null',
      c, c, c);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Resolution and vetting. Both reference the candidate directly; the target,
-- when there is one, comes through the chosen identity_match.
-- ---------------------------------------------------------------------------
create table staging.resolution_decision (
  id                uuid primary key default util.uuidv7(),
  candidate_id      uuid not null references staging.candidate(id) on delete cascade,
  identity_match_id uuid references staging.identity_match(id),
  outcome           staging.resolution_outcome not null,
  rationale         text,
  -- The intent that promotes this candidate. Present once outcome is actioned.
  intent_id         uuid references orchestration.operation_intent(id),
  decided_by_attempt_id uuid references orchestration.attempt(id),
  decided_at        timestamptz not null default now(),
  -- An outcome that names an existing target must carry the match that found it.
  constraint resolution_target_requires_match check (
    outcome not in ('update','link','merge','supersede') or identity_match_id is not null)
);

create index resolution_decision_candidate_idx on staging.resolution_decision (candidate_id);
create index resolution_decision_outcome_idx   on staging.resolution_decision (outcome, decided_at desc);

create table staging.vetting_decision (
  id             uuid primary key default util.uuidv7(),
  candidate_id   uuid not null references staging.candidate(id) on delete cascade,
  outcome        staging.vetting_outcome not null,
  rationale      text not null,
  -- forward reference: evaluation.review_task (0011), FK added in 0014
  review_task_id uuid,
  decided_by_attempt_id uuid references orchestration.attempt(id),
  decided_at     timestamptz not null default now()
);

create index vetting_decision_candidate_idx on staging.vetting_decision (candidate_id);
create index vetting_decision_outcome_idx   on staging.vetting_decision (outcome, decided_at desc);

commit;
