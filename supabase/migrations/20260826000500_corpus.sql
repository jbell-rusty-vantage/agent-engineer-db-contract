-- 0005 | corpus: canonical typed entities, temporal facts, relationships.
--
-- There is no universal entity table. Each type gets its own identity/intrinsic
-- table, its own natural-identity uniques, and its own relationship set.
--
-- Agent frameworks, orchestration libraries, eval harnesses and vector stores are
-- corpus.library rows classified through the taxonomy architecture_role facet,
-- not separate tables. A type earns a table only if it has its own natural
-- identity AND its own intrinsic columns AND its own relationship set.
--
-- Metrics never live here; they are immutable observations in ranking (0008).

begin;

-- ---------------------------------------------------------------------------
-- Shared column patterns as domains, so the repetition is enforced rather than
-- retyped 40 times.
-- ---------------------------------------------------------------------------
create domain corpus.lifecycle_state as text
  not null default 'active'
  check (value in ('active','disputed','superseded','retracted','ended'));

create domain corpus.confidence as numeric(4,3)
  check (value is null or (value >= 0 and value <= 1));

create table corpus.distribution_kind (
  code        text primary key,
  description text not null
);

insert into corpus.distribution_kind (code, description) values
  ('npm','Node package'), ('pypi','Python package'), ('cargo','Rust crate'),
  ('go','Go module'), ('maven','Maven artifact'), ('gem','Ruby gem'),
  ('docker','Container image'), ('ghcr','GitHub container'), ('binary','Prebuilt binary'),
  ('remote','Hosted remote service'), ('source','Source only')
on conflict (code) do nothing;

-- ===========================================================================
-- CLASSIC ENTITY TYPES
-- ===========================================================================

create table corpus.organization (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  slug                  text not null,
  legal_name            text,
  display_name          text not null,
  org_kind              text check (org_kind in ('lab','vendor','foundation','academic','nonprofit','community','standards_body','other')),
  website_url           text,
  founded_on            date,
  description           text,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.organization(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table corpus.organization_identifier (
  id              uuid primary key default util.uuidv7(),
  organization_id uuid not null references corpus.organization(id) on delete cascade,
  scheme          text not null check (scheme in ('ror','crunchbase','github_org','linkedin','wikidata','domain','cik','other')),
  value           text not null,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at      timestamptz not null default now(),
  unique (scheme, value)
);

create table corpus.person (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  slug                  text not null,
  display_name          text not null,
  given_name            text,
  family_name           text,
  headline              text,
  primary_role          text,
  primary_organization_id uuid references corpus.organization(id),
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.person(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table corpus.person_identifier (
  id        uuid primary key default util.uuidv7(),
  person_id uuid not null references corpus.person(id) on delete cascade,
  scheme    text not null check (scheme in ('orcid','github','x','scholar','linkedin','mastodon','bluesky','email','other')),
  value     text not null,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (scheme, value)
);

create table corpus.repository (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  host                  text not null check (host in ('github','gitlab','bitbucket','codeberg','sourcehut','other')),
  owner                 text not null,
  name                  text not null,
  default_branch        text,
  primary_language      text,
  is_fork               boolean not null default false,
  description           text,
  created_at_host       timestamptz,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.repository(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (host, owner, name)
);

-- Renames and transfers keep resolving to the same repository row.
create table corpus.repository_alias (
  id            uuid primary key default util.uuidv7(),
  repository_id uuid not null references corpus.repository(id) on delete cascade,
  host          text not null,
  owner         text not null,
  name          text not null,
  observed_at   timestamptz not null default now(),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  unique (host, owner, name)
);

create table corpus.library (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  ecosystem             text not null references corpus.distribution_kind(code),
  package_name          text not null,
  display_name          text,
  description           text,
  primary_language      text,
  homepage_url          text,
  first_released_on     date,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.library(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (ecosystem, package_name)
);

create table corpus.paper (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  abstract              text,
  venue                 text,
  published_on          date,
  paper_kind            text check (paper_kind in ('preprint','conference','journal','workshop','tech_report','thesis','other')),
  doi                   text,
  arxiv_id              text,
  openreview_id         text,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.paper(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  constraint paper_has_identity check (num_nonnulls(doi, arxiv_id, openreview_id) >= 1)
);

create unique index paper_doi_uq        on corpus.paper (doi)           where doi is not null;
create unique index paper_arxiv_uq      on corpus.paper (arxiv_id)      where arxiv_id is not null;
create unique index paper_openreview_uq on corpus.paper (openreview_id) where openreview_id is not null;

create table corpus.video (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  platform              text not null check (platform in ('youtube','vimeo','twitch','x','self_hosted','other')),
  external_id           text not null,
  title                 text not null,
  channel               text,
  channel_external_id   text,
  published_at          timestamptz,
  duration_seconds      integer check (duration_seconds is null or duration_seconds >= 0),
  url                   text,
  transcript_artifact_id uuid references orchestration.artifact(id),
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.video(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (platform, external_id)
);

create table corpus.talk (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  event_slug            text,
  event_name            text,
  event_edition         text,
  delivered_on          date,
  recording_video_id    uuid references corpus.video(id),
  abstract              text,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.talk(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create unique index talk_event_title_uq
  on corpus.talk (event_slug, title, delivered_on)
  where event_slug is not null and delivered_on is not null;

create table corpus.product (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  slug                  text not null,
  display_name          text not null,
  product_kind          text check (product_kind in ('ide','chat_app','api','platform','agent','plugin','service','hardware','other')),
  vendor_organization_id uuid references corpus.organization(id),
  launched_on           date,
  homepage_url          text,
  description           text,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.product(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table corpus.concept (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  slug                  text not null,
  preferred_label       text not null,
  definition            text,
  concept_kind          text check (concept_kind in ('technique','architecture','metric','artifact','role','phenomenon','other')),
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.concept(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table corpus.concept_alias (
  id         uuid primary key default util.uuidv7(),
  concept_id uuid not null references corpus.concept(id) on delete cascade,
  alias      text not null,
  alias_kind text not null default 'synonym'
    check (alias_kind in ('synonym','acronym','misspelling','former_name')),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (concept_id, alias)
);

create table corpus.dataset (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  host                  text not null check (host in ('huggingface','kaggle','zenodo','openml','github','other')),
  external_id           text not null,
  name                  text not null,
  modality              text[],
  license_spdx          text,
  size_descriptor       text,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.dataset(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (host, external_id)
);

create table corpus.benchmark (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  slug                  text not null,
  name                  text not null,
  measures              text,
  task_domain           text,
  homepage_url          text,
  retired               boolean not null default false,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.benchmark(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (tenant_id, slug)
);

-- ===========================================================================
-- AI-NATIVE ENTITY TYPES
--
-- These are industry entities under study. They are strictly distinct from
-- orchestration.capability, which is what YOUR agents are allowed to run.
-- ===========================================================================

create table corpus.ai_model (
  id                       uuid primary key default util.uuidv7(),
  tenant_id                uuid not null default util.default_tenant_id(),
  provider_organization_id uuid not null references corpus.organization(id),
  model_slug               text not null,
  family                   text,
  display_name             text not null,
  modality                 text[] not null default '{}',
  model_kind               text check (model_kind in ('foundation','fine_tune','distill','embedding','reranker','moderation','other')),
  openness                 text check (openness in ('proprietary','open_weights','open_source')),
  lifecycle_state          corpus.lifecycle_state,
  merged_into_id           uuid references corpus.ai_model(id),
  created_by_receipt_id    uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id    uuid references orchestration.operation_receipt(id),
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now(),
  unique (provider_organization_id, model_slug)
);

create table corpus.ai_model_version (
  id                    uuid primary key default util.uuidv7(),
  ai_model_id           uuid not null references corpus.ai_model(id) on delete cascade,
  version_label         text not null,
  released_on           date,
  context_window_tokens integer,
  max_output_tokens     integer,
  knowledge_cutoff_on   date,
  deprecation_state     text check (deprecation_state in ('ga','preview','deprecated','retired')),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  unique (ai_model_id, version_label)
);

create table corpus.ai_protocol (
  id                       uuid primary key default util.uuidv7(),
  tenant_id                uuid not null default util.default_tenant_id(),
  slug                     text not null,
  name                     text not null,
  purpose                  text,
  governing_organization_id uuid references corpus.organization(id),
  spec_repository_id       uuid references corpus.repository(id),
  status                   text check (status in ('draft','active','deprecated')),
  lifecycle_state          corpus.lifecycle_state,
  merged_into_id           uuid references corpus.ai_protocol(id),
  created_by_receipt_id    uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id    uuid references orchestration.operation_receipt(id),
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table corpus.ai_protocol_version (
  id              uuid primary key default util.uuidv7(),
  ai_protocol_id  uuid not null references corpus.ai_protocol(id) on delete cascade,
  version_label   text not null,
  spec_url        text,
  released_on     date,
  breaking_changes boolean not null default false,
  summary         text,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at      timestamptz not null default now(),
  unique (ai_protocol_id, version_label)
);

create table corpus.mcp_server (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  name                  text not null,
  description           text,
  registry_id           text,
  ecosystem             text references corpus.distribution_kind(code),
  package_name          text,
  repository_id         uuid references corpus.repository(id),
  maintainer_organization_id uuid references corpus.organization(id),
  distribution_kind     text not null references corpus.distribution_kind(code),
  transport_kinds       text[] not null default '{}',
  license_spdx          text,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.mcp_server(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  constraint mcp_server_has_identity
    check (num_nonnulls(registry_id, package_name, repository_id) >= 1),
  constraint mcp_server_pkg_pair
    check ((ecosystem is null) = (package_name is null))
);

create unique index mcp_server_registry_uq on corpus.mcp_server (registry_id)  where registry_id is not null;
create unique index mcp_server_package_uq  on corpus.mcp_server (ecosystem, package_name) where package_name is not null;
create unique index mcp_server_repo_uq     on corpus.mcp_server (repository_id) where repository_id is not null;

create table corpus.mcp_server_version (
  id                  uuid primary key default util.uuidv7(),
  mcp_server_id       uuid not null references corpus.mcp_server(id) on delete cascade,
  version_label       text not null,
  released_on         date,
  protocol_version_id uuid references corpus.ai_protocol_version(id),
  auth_model          text,
  packaging_hash      text,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at          timestamptz not null default now(),
  unique (mcp_server_id, version_label)
);

create table corpus.mcp_server_tool (
  id                    uuid primary key default util.uuidv7(),
  mcp_server_version_id uuid not null references corpus.mcp_server_version(id) on delete cascade,
  tool_name             text not null,
  description           text,
  input_schema          jsonb,
  output_schema         jsonb,
  annotations           jsonb,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  unique (mcp_server_version_id, tool_name)
);

create table corpus.mcp_server_resource (
  id                    uuid primary key default util.uuidv7(),
  mcp_server_version_id uuid not null references corpus.mcp_server_version(id) on delete cascade,
  name                  text not null,
  uri_template          text,
  description           text,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  unique (mcp_server_version_id, name)
);

create table corpus.mcp_server_prompt (
  id                    uuid primary key default util.uuidv7(),
  mcp_server_version_id uuid not null references corpus.mcp_server_version(id) on delete cascade,
  name                  text not null,
  arguments             jsonb,
  description           text,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  unique (mcp_server_version_id, name)
);

create table corpus.agent_skill (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  name                  text not null,
  slug                  text,
  distribution          text,
  description           text,
  skill_format          text,
  format_version        text,
  repository_id         uuid references corpus.repository(id),
  maintainer_organization_id uuid references corpus.organization(id),
  license_spdx          text,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.agent_skill(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  constraint agent_skill_has_identity
    check (num_nonnulls(slug, repository_id) >= 1),
  constraint agent_skill_dist_pair
    check ((distribution is null) = (slug is null))
);

create unique index agent_skill_dist_uq on corpus.agent_skill (distribution, slug) where slug is not null;
create unique index agent_skill_repo_uq on corpus.agent_skill (repository_id)      where repository_id is not null;

create table corpus.agent_skill_version (
  id               uuid primary key default util.uuidv7(),
  agent_skill_id   uuid not null references corpus.agent_skill(id) on delete cascade,
  version_label    text not null,
  released_on      date,
  manifest         jsonb,
  bundled_tooling  jsonb,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at       timestamptz not null default now(),
  unique (agent_skill_id, version_label)
);

-- ===========================================================================
-- TEMPORAL FACT TABLES
--
-- High-value disputed/temporal facts, each with the standard temporal block and
-- a GiST exclusion constraint where only one value may be current at a time.
-- This is what btree_gist was installed for.
-- ===========================================================================

create table corpus.library_license_fact (
  id                  uuid primary key default util.uuidv7(),
  library_id          uuid not null references corpus.library(id) on delete cascade,
  license_spdx        text not null,
  valid_from          timestamptz not null default now(),
  valid_to            timestamptz,
  validity            tstzrange generated always as (tstzrange(valid_from, valid_to, '[)')) stored,
  confidence          corpus.confidence,
  lifecycle_state     corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at          timestamptz not null default now(),
  constraint library_license_no_overlap
    exclude using gist (library_id with =, validity with &&)
    where (lifecycle_state = 'active')
);

create table corpus.library_maintenance_status_fact (
  id                  uuid primary key default util.uuidv7(),
  library_id          uuid not null references corpus.library(id) on delete cascade,
  status              text not null check (status in ('active','lts','maintenance','deprecated','abandoned')),
  valid_from          timestamptz not null default now(),
  valid_to            timestamptz,
  validity            tstzrange generated always as (tstzrange(valid_from, valid_to, '[)')) stored,
  confidence          corpus.confidence,
  lifecycle_state     corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at          timestamptz not null default now(),
  constraint library_maintenance_no_overlap
    exclude using gist (library_id with =, validity with &&)
    where (lifecycle_state = 'active')
);

create table corpus.repository_archival_fact (
  id                  uuid primary key default util.uuidv7(),
  repository_id       uuid not null references corpus.repository(id) on delete cascade,
  archived            boolean not null,
  valid_from          timestamptz not null default now(),
  valid_to            timestamptz,
  validity            tstzrange generated always as (tstzrange(valid_from, valid_to, '[)')) stored,
  confidence          corpus.confidence,
  lifecycle_state     corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at          timestamptz not null default now(),
  constraint repository_archival_no_overlap
    exclude using gist (repository_id with =, validity with &&)
    where (lifecycle_state = 'active')
);

create table corpus.ai_model_availability_fact (
  id                  uuid primary key default util.uuidv7(),
  ai_model_version_id uuid not null references corpus.ai_model_version(id) on delete cascade,
  availability        text not null check (availability in ('ga','preview','deprecated','retired')),
  valid_from          timestamptz not null default now(),
  valid_to            timestamptz,
  validity            tstzrange generated always as (tstzrange(valid_from, valid_to, '[)')) stored,
  confidence          corpus.confidence,
  lifecycle_state     corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at          timestamptz not null default now(),
  constraint ai_model_availability_no_overlap
    exclude using gist (ai_model_version_id with =, validity with &&)
    where (lifecycle_state = 'active')
);

create table corpus.mcp_server_registry_status_fact (
  id                  uuid primary key default util.uuidv7(),
  mcp_server_id       uuid not null references corpus.mcp_server(id) on delete cascade,
  status              text not null check (status in ('listed','delisted','flagged')),
  valid_from          timestamptz not null default now(),
  valid_to            timestamptz,
  validity            tstzrange generated always as (tstzrange(valid_from, valid_to, '[)')) stored,
  confidence          corpus.confidence,
  lifecycle_state     corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at          timestamptz not null default now(),
  constraint mcp_server_registry_no_overlap
    exclude using gist (mcp_server_id with =, validity with &&)
    where (lifecycle_state = 'active')
);

create table corpus.paper_retraction_fact (
  id                  uuid primary key default util.uuidv7(),
  paper_id            uuid not null references corpus.paper(id) on delete cascade,
  state               text not null check (state in ('none','correction','expression_of_concern','retracted')),
  notice_url          text,
  valid_from          timestamptz not null default now(),
  valid_to            timestamptz,
  validity            tstzrange generated always as (tstzrange(valid_from, valid_to, '[)')) stored,
  confidence          corpus.confidence,
  lifecycle_state     corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at          timestamptz not null default now(),
  constraint paper_retraction_no_overlap
    exclude using gist (paper_id with =, validity with &&)
    where (lifecycle_state = 'active')
);

-- ===========================================================================
-- RELATIONSHIP TABLES
--
-- One shape throughout: id, two real FKs, relationship properties, the temporal
-- block, a provenance claim, and a receipt.
-- ===========================================================================

create table corpus.library_maintained_by_person (
  id uuid primary key default util.uuidv7(),
  library_id uuid not null references corpus.library(id) on delete cascade,
  person_id  uuid not null references corpus.person(id)  on delete cascade,
  role       text not null default 'maintainer'
    check (role in ('maintainer','core','triager','author','emeritus')),
  source     text,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (library_id, person_id, role, valid_from)
);

create table corpus.paper_authored_by_person (
  id uuid primary key default util.uuidv7(),
  paper_id  uuid not null references corpus.paper(id)  on delete cascade,
  person_id uuid not null references corpus.person(id) on delete cascade,
  author_position integer,
  corresponding boolean not null default false,
  affiliation_organization_id uuid references corpus.organization(id),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (paper_id, person_id)
);

create table corpus.repository_implements_paper (
  id uuid primary key default util.uuidv7(),
  repository_id uuid not null references corpus.repository(id) on delete cascade,
  paper_id      uuid not null references corpus.paper(id)      on delete cascade,
  fidelity      text not null
    check (fidelity in ('official','reference','reimplementation','partial')),
  notes         text,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (repository_id, paper_id)
);

create table corpus.library_depends_on_library (
  id uuid primary key default util.uuidv7(),
  library_id     uuid not null references corpus.library(id) on delete cascade,
  depends_on_id  uuid not null references corpus.library(id) on delete cascade,
  dependency_kind text not null
    check (dependency_kind in ('runtime','dev','peer','optional','build')),
  version_range  text,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  constraint library_depends_no_self check (library_id <> depends_on_id),
  unique (library_id, depends_on_id, dependency_kind)
);

create table corpus.person_employed_by_organization (
  id uuid primary key default util.uuidv7(),
  person_id       uuid not null references corpus.person(id)       on delete cascade,
  organization_id uuid not null references corpus.organization(id) on delete cascade,
  title           text,
  seniority       text,
  employment_kind text check (employment_kind in ('full_time','part_time','contract','advisor','founder','executive','intern')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (person_id, organization_id, title, valid_from)
);

create table corpus.person_founded_organization (
  id uuid primary key default util.uuidv7(),
  person_id       uuid not null references corpus.person(id)       on delete cascade,
  organization_id uuid not null references corpus.organization(id) on delete cascade,
  founder_role    text,
  founded_on      date,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (person_id, organization_id)
);

create table corpus.talk_explains_concept (
  id uuid primary key default util.uuidv7(),
  talk_id    uuid not null references corpus.talk(id)    on delete cascade,
  concept_id uuid not null references corpus.concept(id) on delete cascade,
  depth      text not null default 'mention'
    check (depth in ('mention','section','dedicated')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (talk_id, concept_id)
);

create table corpus.person_presented_at_talk (
  id uuid primary key default util.uuidv7(),
  person_id uuid not null references corpus.person(id) on delete cascade,
  talk_id   uuid not null references corpus.talk(id)   on delete cascade,
  speaker_role text not null default 'speaker'
    check (speaker_role in ('speaker','co_speaker','panelist','moderator','host')),
  speaker_position integer,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (person_id, talk_id, speaker_role)
);

create table corpus.library_backed_by_repository (
  id uuid primary key default util.uuidv7(),
  library_id    uuid not null references corpus.library(id)    on delete cascade,
  repository_id uuid not null references corpus.repository(id) on delete cascade,
  relationship_kind text not null default 'source'
    check (relationship_kind in ('source','mirror','fork','monorepo_path')),
  path_in_repo  text,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (library_id, repository_id, relationship_kind)
);

-- The appearance family. The corpus is seeded from conference video, so these
-- carry real weight rather than being an afterthought.
create table corpus.library_appeared_in_video (
  id uuid primary key default util.uuidv7(),
  library_id uuid not null references corpus.library(id) on delete cascade,
  video_id   uuid not null references corpus.video(id)   on delete cascade,
  prominence text check (prominence in ('primary','secondary','mention')),
  locator_id uuid references evidence.locator(id),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (library_id, video_id)
);

create table corpus.person_appeared_in_video (
  id uuid primary key default util.uuidv7(),
  person_id uuid not null references corpus.person(id) on delete cascade,
  video_id  uuid not null references corpus.video(id)  on delete cascade,
  appearance_role text check (appearance_role in ('speaker','interviewee','interviewer','panelist','mentioned')),
  locator_id uuid references evidence.locator(id),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (person_id, video_id)
);

create table corpus.paper_appeared_in_video (
  id uuid primary key default util.uuidv7(),
  paper_id uuid not null references corpus.paper(id) on delete cascade,
  video_id uuid not null references corpus.video(id) on delete cascade,
  treatment text check (treatment in ('cited','summarized','critiqued','presented')),
  locator_id uuid references evidence.locator(id),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (paper_id, video_id)
);

create table corpus.product_appeared_in_video (
  id uuid primary key default util.uuidv7(),
  product_id uuid not null references corpus.product(id) on delete cascade,
  video_id   uuid not null references corpus.video(id)   on delete cascade,
  prominence text check (prominence in ('primary','secondary','mention')),
  locator_id uuid references evidence.locator(id),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (product_id, video_id)
);

create table corpus.paper_appeared_in_talk (
  id uuid primary key default util.uuidv7(),
  paper_id uuid not null references corpus.paper(id) on delete cascade,
  talk_id  uuid not null references corpus.talk(id)  on delete cascade,
  treatment text check (treatment in ('cited','summarized','critiqued','presented')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (paper_id, talk_id)
);

-- AI-native relationships.
create table corpus.mcp_server_backed_by_repository (
  id uuid primary key default util.uuidv7(),
  mcp_server_id uuid not null references corpus.mcp_server(id) on delete cascade,
  repository_id uuid not null references corpus.repository(id) on delete cascade,
  relationship_kind text not null default 'source'
    check (relationship_kind in ('source','mirror','fork')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (mcp_server_id, repository_id, relationship_kind)
);

create table corpus.mcp_server_wraps_product (
  id uuid primary key default util.uuidv7(),
  mcp_server_id uuid not null references corpus.mcp_server(id) on delete cascade,
  product_id    uuid not null references corpus.product(id)    on delete cascade,
  coverage      text check (coverage in ('full','partial','read_only')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (mcp_server_id, product_id)
);

create table corpus.library_implements_protocol_version (
  id uuid primary key default util.uuidv7(),
  library_id uuid not null references corpus.library(id) on delete cascade,
  ai_protocol_version_id uuid not null references corpus.ai_protocol_version(id) on delete cascade,
  conformance text not null check (conformance in ('full','partial','experimental')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (library_id, ai_protocol_version_id)
);

create table corpus.product_implements_protocol_version (
  id uuid primary key default util.uuidv7(),
  product_id uuid not null references corpus.product(id) on delete cascade,
  ai_protocol_version_id uuid not null references corpus.ai_protocol_version(id) on delete cascade,
  conformance text not null check (conformance in ('full','partial','experimental')),
  client_or_server text check (client_or_server in ('client','server','both')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (product_id, ai_protocol_version_id)
);

create table corpus.agent_skill_requires_mcp_server (
  id uuid primary key default util.uuidv7(),
  agent_skill_id uuid not null references corpus.agent_skill(id) on delete cascade,
  mcp_server_id  uuid not null references corpus.mcp_server(id)  on delete cascade,
  min_server_version text,
  optionality text not null default 'required'
    check (optionality in ('required','optional','recommended')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (agent_skill_id, mcp_server_id)
);

create table corpus.agent_skill_targets_library (
  id uuid primary key default util.uuidv7(),
  agent_skill_id uuid not null references corpus.agent_skill(id) on delete cascade,
  library_id     uuid not null references corpus.library(id)     on delete cascade,
  relationship   text not null default 'uses'
    check (relationship in ('uses','teaches','wraps','tests')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (agent_skill_id, library_id, relationship)
);

create table corpus.ai_model_released_by_organization (
  id uuid primary key default util.uuidv7(),
  ai_model_id     uuid not null references corpus.ai_model(id)     on delete cascade,
  organization_id uuid not null references corpus.organization(id) on delete cascade,
  release_role    text not null check (release_role in ('developer','host','distiller','funder')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (ai_model_id, organization_id, release_role)
);

create table corpus.product_built_on_model_version (
  id uuid primary key default util.uuidv7(),
  product_id uuid not null references corpus.product(id) on delete cascade,
  ai_model_version_id uuid not null references corpus.ai_model_version(id) on delete cascade,
  usage_kind text not null check (usage_kind in ('default','selectable','fine_tuned_base','fallback')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (product_id, ai_model_version_id, usage_kind)
);

create table corpus.library_supports_model_version (
  id uuid primary key default util.uuidv7(),
  library_id uuid not null references corpus.library(id) on delete cascade,
  ai_model_version_id uuid not null references corpus.ai_model_version(id) on delete cascade,
  integration_kind text not null check (integration_kind in ('sdk','adapter','native','community')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (library_id, ai_model_version_id)
);

create table corpus.person_created_mcp_server (
  id uuid primary key default util.uuidv7(),
  person_id     uuid not null references corpus.person(id)     on delete cascade,
  mcp_server_id uuid not null references corpus.mcp_server(id) on delete cascade,
  role  text not null default 'creator'
    check (role in ('creator','maintainer','contributor')),
  since date,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (person_id, mcp_server_id, role)
);

create table corpus.person_created_agent_skill (
  id uuid primary key default util.uuidv7(),
  person_id      uuid not null references corpus.person(id)      on delete cascade,
  agent_skill_id uuid not null references corpus.agent_skill(id) on delete cascade,
  role  text not null default 'creator'
    check (role in ('creator','maintainer','contributor')),
  since date,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (person_id, agent_skill_id, role)
);

-- ===========================================================================
-- MERGE / SUPERSESSION
--
-- Never hard-delete. Identity history is provenance. Losers get
-- lifecycle_state='superseded' and merged_into_id on their own typed table;
-- this records why.
-- ===========================================================================
create table corpus.entity_merge (
  id            uuid primary key default util.uuidv7(),
  entity_kind   text not null,
  winner_id     uuid not null,
  loser_id      uuid not null,
  merge_reason  text not null,
  -- forward reference: evaluation.review_task (0011), FK added in 0014
  review_task_id uuid,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at    timestamptz not null default now(),
  constraint entity_merge_distinct check (winner_id <> loser_id),
  constraint entity_merge_kind check (entity_kind in (
    'organization','person','library','repository','paper','talk','video','product',
    'concept','dataset','benchmark','ai_model','ai_protocol','mcp_server','agent_skill'))
);

create index entity_merge_loser_idx on corpus.entity_merge (entity_kind, loser_id);

-- ---------------------------------------------------------------------------
-- updated_at triggers on the entity tables.
-- ---------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'organization','person','repository','library','paper','video','talk','product',
    'concept','dataset','benchmark','ai_model','ai_protocol','mcp_server','agent_skill'
  ] loop
    execute format(
      'create trigger %I_set_updated_at before update on corpus.%I
         for each row execute function util.set_updated_at()', t, t);
  end loop;
end;
$$;

-- Frequently-filtered foreign keys.
create index person_primary_org_idx     on corpus.person (primary_organization_id);
create index product_vendor_idx         on corpus.product (vendor_organization_id);
create index mcp_server_repo_fk_idx     on corpus.mcp_server (repository_id);
create index mcp_server_maintainer_idx  on corpus.mcp_server (maintainer_organization_id);
create index ai_model_provider_idx      on corpus.ai_model (provider_organization_id);
create index talk_recording_idx         on corpus.talk (recording_video_id);
create index agent_skill_repo_fk_idx    on corpus.agent_skill (repository_id);

commit;
