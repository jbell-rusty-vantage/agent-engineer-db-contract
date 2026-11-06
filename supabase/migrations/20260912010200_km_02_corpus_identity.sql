-- Knowledge model v2: corpus_identity. See docs/knowledge-model/FINAL-RECOMMENDATION.md.
begin;
set local lock_timeout = '15s';
create table corpus.entity (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.current_tenant_id(),
  kind text not null references taxonomy.entity_kind(code),
  display_name text not null,                        -- projection (entity_name stream)
  slug text not null,
  summary text,                                      -- projection (latest entity_profile abstract)
  lifecycle text not null default 'active' check (lifecycle in ('active','merged','retired')),
  merged_into_id uuid references corpus.entity(id),
  projection_knowledge_seq bigint,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id), unique (tenant_id, id, kind), unique (tenant_id, kind, slug)
);
create table corpus.entity_alias (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  entity_id uuid not null references corpus.entity(id),
  alias text not null check (btrim(alias) <> ''),
  alias_normalized text generated always as (lower(btrim(alias))) stored,
  alias_kind text not null check (alias_kind in ('synonym','acronym','former_name','handle','ticker','slug','misspelling','translation','model_alias')),
  language text, source_claim_id uuid references evidence.claim(id),
  unique (tenant_id, entity_id, alias_normalized, alias_kind)
);
create table corpus.entity_identifier (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  entity_id uuid not null references corpus.entity(id),
  scheme text not null check (scheme in ('wikidata','ror','orcid','github','huggingface','npm','pypi','crates','go_module','doi','arxiv','openreview',
    'mcp_registry','cve','ghsa','spdx','crunchbase','pitchbook','linkedin','x','youtube_channel','youtube_playlist','youtube_video','spotify','apple_podcasts','domain','sec_cik','lei','isin','other')),
  value text not null,
  unique (tenant_id, scheme, value)
);
create index entity_name_trgm on corpus.entity using gin(display_name extensions.gin_trgm_ops);
create index entity_alias_trgm on corpus.entity_alias using gin(alias_normalized extensions.gin_trgm_ops);
create table corpus.entity_merge(id uuid primary key default util.uuidv7(),tenant_id uuid not null default util.current_tenant_id(),from_entity_id uuid not null references corpus.entity(id),to_entity_id uuid not null references corpus.entity(id),reason text not null,receipt_id uuid not null references orchestration.operation_receipt(id),created_at timestamptz not null default now(),check(from_entity_id<>to_entity_id));
create table corpus.person(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'person' check(kind='person'),given_name text, family_name text, orcid text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.organization(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'organization' check(kind='organization'),legal_name text, website_url text, country_code text, founded_on date,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.product(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'product' check(kind='product'),product_kind text, website_url text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.product_version(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'product_version' check(kind='product_version'),product_id uuid not null references corpus.product(id), version_label text not null,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.product_feature(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'product_feature' check(kind='product_feature'),product_id uuid not null references corpus.product(id), feature_key text not null, description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.ai_model(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'ai_model' check(kind='ai_model'),model_family text, modality text[], description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.ai_model_version(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'ai_model_version' check(kind='ai_model_version'),ai_model_id uuid not null references corpus.ai_model(id), version_label text not null, provider_model_id text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.model_offering(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'model_offering' check(kind='model_offering'),model_version_id uuid not null references corpus.ai_model_version(id), provider_entity_id uuid not null references corpus.entity(id), offering_key text not null,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.technique(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'technique' check(kind='technique'),technique_kind text, description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.dataset(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'dataset' check(kind='dataset'),dataset_kind text, canonical_url text, license_code text references corpus.license(code),unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.benchmark(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'benchmark' check(kind='benchmark'),canonical_url text, methodology text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.benchmark_run(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'benchmark_run' check(kind='benchmark_run'),benchmark_id uuid not null references corpus.benchmark(id), subject_entity_id uuid not null references corpus.entity(id), protocol jsonb not null default '{}', artifact_id uuid references orchestration.artifact(id),unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.repository(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'repository' check(kind='repository'),host text not null, owner text not null, name text not null, provider_native_id text, created_at_host timestamptz, is_fork boolean not null default false, fork_of_repository_id uuid references corpus.repository(id), unique(tenant_id,host,owner,name),unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.library(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'library' check(kind='library'),ecosystem text, package_name text, description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.library_release(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'library_release' check(kind='library_release'),library_id uuid not null references corpus.library(id), version_label text not null, registry_id uuid, source_revision_id uuid, license_code text references corpus.license(code), released_on date,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.mcp_server(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'mcp_server' check(kind='mcp_server'),transport text[], description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.agent_skill(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'agent_skill' check(kind='agent_skill'),skill_format text, description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.ai_protocol(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'ai_protocol' check(kind='ai_protocol'),specification_url text, description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.ai_protocol_version(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'ai_protocol_version' check(kind='ai_protocol_version'),ai_protocol_id uuid not null references corpus.ai_protocol(id), version_label text not null, specification_url text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.ai_protocol_feature(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'ai_protocol_feature' check(kind='ai_protocol_feature'),ai_protocol_id uuid not null references corpus.ai_protocol(id), feature_key text not null, description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.paper(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'paper' check(kind='paper'),title text not null, abstract text, doi text, arxiv_id text, published_on date,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.story(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'story' check(kind='story'),title text not null, canonical_url text, published_at timestamptz,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.case_study(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'case_study' check(kind='case_study'),title text not null, abstract text, canonical_url text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.concept(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'concept' check(kind='concept'),description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.funding_round(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'funding_round' check(kind='funding_round'),round_kind text, announced_on date, currency text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.corporate_transaction(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'corporate_transaction' check(kind='corporate_transaction'),transaction_kind text, announced_on date, description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.registry(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'registry' check(kind='registry'),registry_kind text, canonical_url text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.security_advisory(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'security_advisory' check(kind='security_advisory'),advisory_id text not null, ecosystem text, canonical_url text, description text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.compute_device(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'compute_device' check(kind='compute_device'),manufacturer_entity_id uuid references corpus.entity(id), device_kind text, architecture text, memory_gb numeric,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.compute_offering(id uuid primary key references corpus.entity(id),tenant_id uuid not null default util.current_tenant_id(),kind text not null default 'compute_offering' check(kind='compute_offering'),provider_entity_id uuid references corpus.entity(id), offering_key text, region text,unique(tenant_id,id),foreign key(tenant_id,id,kind) references corpus.entity(tenant_id,id,kind) deferrable initially deferred);
create table corpus.media_platform (
  code text primary key check (code in ('youtube','vimeo','spotify','apple_podcasts','x','linkedin','twitch','bilibili','self_hosted','conference_platform','other')),
  name text not null,
  media_url_template text,     -- 'https://www.youtube.com/watch?v={external_id}'
  channel_url_template text,   -- 'https://www.youtube.com/{handle}'
  timecode_param text,         -- 't' → deep link '&t={seconds}s'
  product_entity_id uuid references corpus.entity(id)
);
create table corpus.media_channel (
  id uuid primary key references corpus.entity(id), tenant_id uuid not null default util.current_tenant_id(),
  kind text not null default 'media_channel' check (kind = 'media_channel'),
  platform_code text not null references corpus.media_platform(code),
  external_id text not null, handle text, title text not null, url text,
  owner_entity_id uuid references corpus.entity(id),          -- organization | person (checked at seal)
  created_at_platform timestamptz,
  foreign key (tenant_id, id, kind) references corpus.entity (tenant_id, id, kind) deferrable initially deferred,
  unique (tenant_id, platform_code, external_id)
);
create table corpus.event_series (
  id uuid primary key references corpus.entity(id), tenant_id uuid not null default util.current_tenant_id(),
  kind text not null default 'event_series' check (kind = 'event_series'),
  slug text not null, name text not null,
  series_kind text not null check (series_kind in ('conference','fair','summit','developer_conference','hackathon_series','meetup_series','workshop_series')),
  organizer_entity_id uuid references corpus.entity(id), website_url text,
  foreign key (tenant_id, id, kind) references corpus.entity (tenant_id, id, kind) deferrable initially deferred,
  unique (tenant_id, slug)
);
create table corpus.industry_event (
  id uuid primary key references corpus.entity(id), tenant_id uuid not null default util.current_tenant_id(),
  kind text not null default 'industry_event' check (kind = 'industry_event'),
  series_id uuid references corpus.event_series(id),
  parent_event_id uuid references corpus.industry_event(id),  -- tracks, hackathons, expo days inside an edition
  slug text not null, name text not null, edition_label text,
  event_kind text not null check (event_kind in ('conference','fair','summit','hackathon','launch_event','workshop','meetup','track','expo','social')),
  starts_on date, ends_on date, timezone text, city text, country text, venue text,
  format text check (format in ('in_person','virtual','hybrid')), website_url text,
  foreign key (tenant_id, id, kind) references corpus.entity (tenant_id, id, kind) deferrable initially deferred,
  unique (tenant_id, slug), check (parent_event_id is null or parent_event_id <> id),
  check (ends_on is null or starts_on is null or ends_on >= starts_on)
);
create table corpus.media_series (
  id uuid primary key references corpus.entity(id), tenant_id uuid not null default util.current_tenant_id(),
  kind text not null default 'media_series' check (kind = 'media_series'),
  series_kind text not null check (series_kind in ('playlist','podcast_show','recurring_show','conference_recordings','course','livestream_series')),
  platform_code text references corpus.media_platform(code), external_id text,
  title text not null, description text,
  primary_channel_id uuid references corpus.media_channel(id),
  industry_event_id uuid references corpus.industry_event(id),  -- set for conference_recordings
  foreign key (tenant_id, id, kind) references corpus.entity (tenant_id, id, kind) deferrable initially deferred
);
create table corpus.media_work (
  id uuid primary key references corpus.entity(id), tenant_id uuid not null default util.current_tenant_id(),
  kind text not null default 'media_work' check (kind = 'media_work'),
  media_kind text not null check (media_kind in ('video','audio','image','slide_deck','livestream','screencast')),
  platform_code text not null references corpus.media_platform(code),
  external_id text, url text, title text not null,
  channel_id uuid references corpus.media_channel(id),
  published_at timestamptz, duration_ms integer check (duration_ms is null or duration_ms >= 0),
  width integer, height integer, language text,
  foreign key (tenant_id, id, kind) references corpus.entity (tenant_id, id, kind) deferrable initially deferred
);
create table corpus.talk (
  id uuid primary key references corpus.entity(id), tenant_id uuid not null default util.current_tenant_id(),
  kind text not null default 'talk' check (kind = 'talk'),
  title text not null,
  talk_kind text not null default 'talk' check (talk_kind in ('keynote','talk','workshop','panel','lightning','demo','fireside','poster','tutorial','announcement')),
  abstract text, delivered_on date, duration_minutes integer, language text,
  foreign key (tenant_id, id, kind) references corpus.entity (tenant_id, id, kind) deferrable initially deferred
);
create table corpus.repository_revision (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  repository_id uuid not null references corpus.repository(id),
  commit_sha text not null check (commit_sha ~ '^[0-9a-f]{40}$|^[0-9a-f]{64}$'),
  ref_name text, committed_at timestamptz, tree_sha text,
  tree_manifest_artifact_id uuid references orchestration.artifact(id), manifest_truncated boolean not null default false,
  file_count integer, total_bytes bigint, languages jsonb not null default '{}'::jsonb,
  capture_id uuid references evidence.source_capture(id), created_at timestamptz not null default now(),
  unique (tenant_id, repository_id, commit_sha));
create table corpus.repository_module (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  repository_id uuid not null references corpus.repository(id), path text not null,
  module_kind text not null check (module_kind in ('root','package','app','service','library','docs','examples','infra','tests','benchmarks','other')),
  name text, language text, manifest_path text,
  manifest_kind text check (manifest_kind in ('package_json','pyproject','cargo_toml','go_mod','pom','gemspec','dockerfile','mcp_json','skill_md','other')),
  library_id uuid references corpus.library(id),
  first_seen_revision_id uuid references corpus.repository_revision(id), last_seen_revision_id uuid references corpus.repository_revision(id),
  description text, unique (tenant_id, repository_id, path));
create table corpus.repository_file (
  id uuid primary key default util.uuidv7(), tenant_id uuid not null default util.current_tenant_id(),
  repository_id uuid not null references corpus.repository(id), revision_id uuid not null references corpus.repository_revision(id),
  path text not null, blob_sha text, size_bytes integer, language text,
  file_role text not null check (file_role in ('readme','manifest','license','changelog','docs','source','example','test','config','notebook','schema','workflow','other')),
  module_id uuid references corpus.repository_module(id), capture_id uuid references evidence.source_capture(id),
  created_at timestamptz not null default now(), unique (tenant_id, revision_id, path));
create table corpus.ai_model_version_spec(id uuid primary key default util.uuidv7(),tenant_id uuid not null default util.current_tenant_id(),model_version_id uuid not null references corpus.ai_model_version(id),parameters_billions numeric,context_tokens bigint,modalities text[],specification jsonb not null default '{}',source_claim_id uuid references evidence.claim(id),unique(tenant_id,id));
create table corpus.mcp_server_surface(id uuid primary key default util.uuidv7(),tenant_id uuid not null default util.current_tenant_id(),server_id uuid not null references corpus.mcp_server(id),surface_kind text not null check(surface_kind in ('tool','resource','prompt')),name text not null,schema_artifact_id uuid references orchestration.artifact(id),unique(tenant_id,server_id,surface_kind,name));
create table corpus.registry_listing(id uuid primary key default util.uuidv7(),tenant_id uuid not null default util.current_tenant_id(),registry_id uuid not null references corpus.registry(id),entity_id uuid not null references corpus.entity(id),external_id text not null,canonical_url text,unique(tenant_id,registry_id,external_id));
alter table corpus.library_release add foreign key(registry_id) references corpus.registry(id), add foreign key(source_revision_id) references corpus.repository_revision(id);
insert into corpus.media_platform(code,name,timecode_param) values ('youtube','youtube','t'),('vimeo','vimeo',null),('spotify','spotify',null),('apple_podcasts','apple_podcasts',null),('x','x',null),('linkedin','linkedin',null),('twitch','twitch',null),('bilibili','bilibili',null),('self_hosted','self_hosted',null),('conference_platform','conference_platform',null),('other','other',null);
commit;
