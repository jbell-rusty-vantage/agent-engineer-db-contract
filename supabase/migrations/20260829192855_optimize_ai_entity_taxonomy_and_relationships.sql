begin;

-- Primary entity divisions remain real typed corpus tables. This registry makes
-- that contract queryable and gives taxonomy scopes a stable foreign key.
create table taxonomy.entity_kind (
  code             text primary key,
  label            text not null,
  canonical_schema text not null default 'corpus',
  canonical_table  text not null,
  description      text not null,
  unique (canonical_schema, canonical_table)
);

insert into taxonomy.entity_kind (code, label, canonical_table, description) values
  ('library','Library','library','Installable or importable software package.'),
  ('repository','Repository','repository','Version-controlled source, specification, weights, or benchmark repository.'),
  ('paper','Paper','paper','Scholarly or technical publication with a durable scholarly identifier.'),
  ('person','Person','person','Individual contributor, author, maintainer, founder, or executive.'),
  ('organization','Organization','organization','Company, laboratory, institution, community, or standards body.'),
  ('product','AI product','product','Commercial or hosted product, platform, API, application, service, or hardware offering.'),
  ('ai_model','AI model','ai_model','Named AI or deep-learning model family; releases belong in ai_model_version.'),
  ('benchmark','Benchmark','benchmark','Repeatable evaluation definition; observed scores belong in ranking.metric_observation.'),
  ('ai_protocol','AI interoperability protocol or standard','ai_protocol','Versioned protocol, specification, or convention such as MCP or A2A.'),
  ('case_study','Case study','case_study','Documented implementation, adoption, migration, incident, or business outcome.'),
  ('dataset','Dataset','dataset','Versioned or externally identified data collection.'),
  ('concept','Concept','concept','Technique, architecture, metric, role, artifact, or phenomenon.'),
  ('mcp_server','MCP server','mcp_server','Concrete server implementation of the Model Context Protocol.'),
  ('agent_skill','Agent skill','agent_skill','Versioned reusable agent instruction or capability package.')
on conflict (code) do update set
  label = excluded.label,
  canonical_schema = excluded.canonical_schema,
  canonical_table = excluded.canonical_table,
  description = excluded.description;

-- A term can be valid only for selected primary entity divisions. Terms without
-- scope rows remain intentionally universal for backward compatibility.
create table taxonomy.term_target_kind (
  term_id          uuid not null references taxonomy.term(id) on delete cascade,
  entity_kind_code text not null references taxonomy.entity_kind(code) on delete cascade,
  created_at       timestamptz not null default now(),
  primary key (term_id, entity_kind_code)
);

insert into taxonomy.facet (slug, label, description, cardinality) values
  ('entity_subtype','Entity subtype','Secondary division within a canonical primary entity kind.','single'),
  ('modality','Modality','Input or output modalities supported by an entity.','multi'),
  ('access_model','Access model','How an entity is licensed, distributed, or commercially accessed.','multi'),
  ('deployment_model','Deployment model','Where and how software, models, or products can run.','multi'),
  ('organization_sector','Organization sector','Market or institutional sectors in which an organization operates.','multi')
on conflict (tenant_id, slug) do update set
  label = excluded.label,
  description = excluded.description,
  cardinality = excluded.cardinality;

insert into taxonomy.facet_version (facet_id, version, status, notes)
select id, 1, 'active', 'AI entity taxonomy baseline 2026-08-29'
from taxonomy.facet
where slug in ('entity_subtype','modality','access_model','deployment_model','organization_sector')
on conflict (facet_id, version) do nothing;

-- Root terms are navigational primary divisions. Their children are the precise
-- secondary divisions assigned to canonical entities.
with subtype_terms(kind, slug, label, definition, ord) as (values
  ('library','library','Library','Installable or importable software.',100),
  ('repository','repository','Repository','Version-controlled artifact container.',200),
  ('paper','paper','Paper','Scholarly or technical publication.',300),
  ('person','person','Person','Individual industry participant.',400),
  ('organization','organization','Organization','Institutional industry participant.',500),
  ('product','product','AI product','Commercial or hosted AI offering.',600),
  ('ai_model','ai-model','AI model','AI or deep-learning model family.',700),
  ('benchmark','benchmark','Benchmark','Repeatable evaluation definition.',800),
  ('ai_protocol','ai-protocol','AI protocol or standard','Versioned interoperability protocol, specification, standard, or convention.',900),
  ('case_study','case-study','Case study','Documented real-world application or outcome.',1000)
)
insert into taxonomy.term (facet_version_id, slug, label, definition, sort_order)
select fv.id, st.slug, st.label, st.definition, st.ord
from taxonomy.facet f
join taxonomy.facet_version fv on fv.facet_id=f.id and fv.version=1
cross join subtype_terms st
where f.slug='entity_subtype'
on conflict (facet_version_id, slug) do update set
  label=excluded.label, definition=excluded.definition, sort_order=excluded.sort_order;

with subtype_terms(kind, parent_slug, slug, label, ord) as (values
  ('library','library','sdk','SDK or client library',110),
  ('library','library','application-framework','Application framework',120),
  ('library','library','agent-framework','Agent framework',130),
  ('library','library','training-library','Training library',140),
  ('library','library','inference-runtime','Inference or serving runtime',150),
  ('library','library','evaluation-library','Evaluation library',160),
  ('library','library','data-library','Data, retrieval, or vector library',170),
  ('library','library','observability-library','Observability library',180),
  ('repository','repository','source-repository','Source-code repository',210),
  ('repository','repository','monorepo','Monorepo',220),
  ('repository','repository','reference-implementation','Reference implementation',230),
  ('repository','repository','specification-repository','Specification repository',240),
  ('repository','repository','benchmark-repository','Benchmark repository',250),
  ('repository','repository','model-artifact-repository','Model weights or artifacts repository',260),
  ('paper','paper','methods-paper','Methods paper',310),
  ('paper','paper','empirical-paper','Empirical paper',320),
  ('paper','paper','systems-paper','Systems paper',330),
  ('paper','paper','survey-paper','Survey or review',340),
  ('paper','paper','position-paper','Position or perspective paper',350),
  ('paper','paper','dataset-paper','Dataset paper',360),
  ('paper','paper','benchmark-paper','Benchmark paper',370),
  ('person','person','researcher','Researcher',410),
  ('person','person','engineer','Engineer',420),
  ('person','person','founder','Founder',430),
  ('person','person','executive','Executive',440),
  ('person','person','educator','Educator or developer advocate',450),
  ('person','person','investor','Investor or analyst',460),
  ('organization','organization','model-lab','AI model laboratory',510),
  ('organization','organization','software-vendor','Software vendor',520),
  ('organization','organization','cloud-provider','Cloud provider',530),
  ('organization','organization','hardware-vendor','Hardware or semiconductor vendor',540),
  ('organization','organization','academic-institution','Academic institution',550),
  ('organization','organization','standards-body','Standards body or consortium',560),
  ('organization','organization','nonprofit-organization','Nonprofit or foundation',570),
  ('organization','organization','open-source-community','Open-source community',580),
  ('organization','organization','consultancy-integrator','Consultancy or systems integrator',590),
  ('organization','organization','enterprise-adopter','Enterprise AI adopter',595),
  ('product','product','developer-tool','Developer tool or IDE',610),
  ('product','product','assistant-application','Assistant or chat application',620),
  ('product','product','model-api-service','Model API service',630),
  ('product','product','ai-platform','AI platform',640),
  ('product','product','agent-product','Agent product',650),
  ('product','product','observability-product','Observability or evaluation product',660),
  ('product','product','security-product','AI security or governance product',670),
  ('product','product','data-product','Data, retrieval, or vector product',680),
  ('product','product','ai-infrastructure','AI infrastructure or hardware',690),
  ('ai_model','ai-model','foundation-model','Foundation model',710),
  ('ai_model','ai-model','instruction-model','Instruction-tuned model',720),
  ('ai_model','ai-model','reasoning-model','Reasoning model',730),
  ('ai_model','ai-model','code-model','Code model',740),
  ('ai_model','ai-model','multimodal-model','Multimodal model',750),
  ('ai_model','ai-model','embedding-model','Embedding model',760),
  ('ai_model','ai-model','reranker-model','Reranker model',770),
  ('ai_model','ai-model','safety-model','Moderation or safety model',780),
  ('ai_model','ai-model','fine-tuned-model','Fine-tuned model',790),
  ('ai_model','ai-model','distilled-model','Distilled model',795),
  ('benchmark','benchmark','capability-benchmark','General capability benchmark',810),
  ('benchmark','benchmark','knowledge-benchmark','Knowledge benchmark',820),
  ('benchmark','benchmark','reasoning-benchmark','Reasoning benchmark',830),
  ('benchmark','benchmark','coding-benchmark','Coding benchmark',840),
  ('benchmark','benchmark','multimodal-benchmark','Multimodal benchmark',850),
  ('benchmark','benchmark','agentic-benchmark','Agentic or tool-use benchmark',860),
  ('benchmark','benchmark','safety-benchmark','Safety or alignment benchmark',870),
  ('benchmark','benchmark','robustness-benchmark','Robustness benchmark',880),
  ('benchmark','benchmark','efficiency-benchmark','Efficiency or systems benchmark',890),
  ('ai_protocol','ai-protocol','interoperability-protocol','Interoperability protocol',910),
  ('ai_protocol','ai-protocol','tool-interface-protocol','Tool interface protocol',920),
  ('ai_protocol','ai-protocol','agent-communication-protocol','Agent-to-agent communication protocol',930),
  ('ai_protocol','ai-protocol','context-exchange-protocol','Context exchange protocol',940),
  ('ai_protocol','ai-protocol','model-serving-api-standard','Model serving API standard',950),
  ('ai_protocol','ai-protocol','data-format-specification','Data format specification',960),
  ('ai_protocol','ai-protocol','safety-governance-standard','Safety or governance standard',970),
  ('case_study','case-study','implementation-case-study','Implementation case study',1010),
  ('case_study','case-study','adoption-case-study','Adoption case study',1020),
  ('case_study','case-study','migration-case-study','Migration case study',1030),
  ('case_study','case-study','benchmark-case-study','Comparative benchmark case study',1040),
  ('case_study','case-study','incident-case-study','Incident or failure case study',1050),
  ('case_study','case-study','business-outcome-case-study','Business outcome case study',1060)
), resolved as (
  select fv.id as facet_version_id, st.*, p.id as parent_term_id
  from taxonomy.facet f
  join taxonomy.facet_version fv on fv.facet_id=f.id and fv.version=1
  join subtype_terms st on true
  join taxonomy.term p on p.facet_version_id=fv.id and p.slug=st.parent_slug
  where f.slug='entity_subtype'
)
insert into taxonomy.term (facet_version_id, slug, label, parent_term_id, sort_order)
select facet_version_id, slug, label, parent_term_id, ord from resolved
on conflict (facet_version_id, slug) do update set
  label=excluded.label, parent_term_id=excluded.parent_term_id, sort_order=excluded.sort_order;

insert into taxonomy.term_target_kind (term_id, entity_kind_code)
select t.id,
  case
    when t.slug in ('library','sdk','application-framework','agent-framework','training-library','inference-runtime','evaluation-library','data-library','observability-library') then 'library'
    when t.slug in ('repository','source-repository','monorepo','reference-implementation','specification-repository','benchmark-repository','model-artifact-repository') then 'repository'
    when t.slug in ('paper','methods-paper','empirical-paper','systems-paper','survey-paper','position-paper','dataset-paper','benchmark-paper') then 'paper'
    when t.slug in ('person','researcher','engineer','founder','executive','educator','investor') then 'person'
    when t.slug in ('organization','model-lab','software-vendor','cloud-provider','hardware-vendor','academic-institution','standards-body','nonprofit-organization','open-source-community','consultancy-integrator','enterprise-adopter') then 'organization'
    when t.slug in ('product','developer-tool','assistant-application','model-api-service','ai-platform','agent-product','observability-product','security-product','data-product','ai-infrastructure') then 'product'
    when t.slug in ('ai-model','foundation-model','instruction-model','reasoning-model','code-model','multimodal-model','embedding-model','reranker-model','safety-model','fine-tuned-model','distilled-model') then 'ai_model'
    when t.slug in ('benchmark','capability-benchmark','knowledge-benchmark','reasoning-benchmark','coding-benchmark','multimodal-benchmark','agentic-benchmark','safety-benchmark','robustness-benchmark','efficiency-benchmark') then 'benchmark'
    when t.slug in ('ai-protocol','interoperability-protocol','tool-interface-protocol','agent-communication-protocol','context-exchange-protocol','model-serving-api-standard','data-format-specification','safety-governance-standard') then 'ai_protocol'
    when t.slug in ('case-study','implementation-case-study','adoption-case-study','migration-case-study','benchmark-case-study','incident-case-study','business-outcome-case-study') then 'case_study'
  end
from taxonomy.term t
join taxonomy.facet_version fv on fv.id=t.facet_version_id
join taxonomy.facet f on f.id=fv.facet_id
where f.slug='entity_subtype'
on conflict do nothing;

with facet_terms(facet_slug, slug, label, ord) as (values
  ('modality','text','Text',10),('modality','image','Image',20),('modality','audio','Audio',30),
  ('modality','video','Video',40),('modality','speech','Speech',50),('modality','code','Code',60),
  ('modality','structured-data','Structured data',70),('modality','embeddings','Embeddings',80),
  ('access_model','open-source','Open source',10),('access_model','open-weights','Open weights',20),
  ('access_model','source-available','Source available',30),('access_model','proprietary','Proprietary',40),
  ('access_model','free','Free',50),('access_model','freemium','Freemium',60),
  ('access_model','paid-subscription','Paid subscription',70),('access_model','usage-priced-api','Usage-priced API',80),
  ('access_model','enterprise-contract','Enterprise contract',90),
  ('deployment_model','hosted-saas','Hosted SaaS',10),('deployment_model','managed-api','Managed API',20),
  ('deployment_model','self-hosted','Self-hosted',30),('deployment_model','on-premises','On premises',40),
  ('deployment_model','edge-device','Edge or device',50),('deployment_model','hybrid','Hybrid',60),
  ('organization_sector','foundation-models','Foundation models',10),('organization_sector','developer-tools','Developer tools',20),
  ('organization_sector','cloud-infrastructure','Cloud infrastructure',30),('organization_sector','semiconductors','Semiconductors',40),
  ('organization_sector','data-infrastructure','Data infrastructure',50),('organization_sector','cybersecurity','Cybersecurity',60),
  ('organization_sector','enterprise-software','Enterprise software',70),('organization_sector','research-education','Research and education',80),
  ('organization_sector','consulting-services','Consulting and services',90),('organization_sector','consumer-ai','Consumer AI',100)
)
insert into taxonomy.term (facet_version_id, slug, label, sort_order)
select fv.id, ft.slug, ft.label, ft.ord
from taxonomy.facet f
join taxonomy.facet_version fv on fv.facet_id=f.id and fv.version=1
join facet_terms ft on ft.facet_slug=f.slug
on conflict (facet_version_id, slug) do update set label=excluded.label, sort_order=excluded.sort_order;

-- Benchmark and dataset were canonical corpus entities but were accidentally
-- absent from the taxonomy assignment arc. Add them before enforcing scopes.
drop index taxonomy.assignment_target_idx;
alter table taxonomy.assignment
  drop constraint assignment_exactly_one_target,
  drop column target_kind,
  add column dataset_id uuid references corpus.dataset(id) on delete cascade,
  add column benchmark_id uuid references corpus.benchmark(id) on delete cascade;
alter table taxonomy.assignment add column target_kind text generated always as (
  case
    when library_id is not null then 'library'
    when repository_id is not null then 'repository'
    when person_id is not null then 'person'
    when organization_id is not null then 'organization'
    when paper_id is not null then 'paper'
    when talk_id is not null then 'talk'
    when video_id is not null then 'video'
    when product_id is not null then 'product'
    when case_study_id is not null then 'case_study'
    when concept_id is not null then 'concept'
    when dataset_id is not null then 'dataset'
    when benchmark_id is not null then 'benchmark'
    when ai_model_id is not null then 'ai_model'
    when ai_protocol_id is not null then 'ai_protocol'
    when mcp_server_id is not null then 'mcp_server'
    when agent_skill_id is not null then 'agent_skill'
    when technical_problem_id is not null then 'technical_problem'
    when solution_pattern_id is not null then 'solution_pattern'
    when advanced_usage_pattern_id is not null then 'advanced_usage_pattern'
    when failure_mode_id is not null then 'failure_mode'
    when lesson_id is not null then 'lesson'
  end
) stored;
alter table taxonomy.assignment add constraint assignment_exactly_one_target check (
  num_nonnulls(library_id, repository_id, person_id, organization_id, paper_id, talk_id,
    video_id, product_id, case_study_id, concept_id, dataset_id, benchmark_id, ai_model_id,
    ai_protocol_id, mcp_server_id, agent_skill_id, technical_problem_id, solution_pattern_id,
    advanced_usage_pattern_id, failure_mode_id, lesson_id)=1
);
create index assignment_target_idx on taxonomy.assignment(target_kind);
create index assignment_dataset_id_idx on taxonomy.assignment(dataset_id) where dataset_id is not null;
create index assignment_benchmark_id_idx on taxonomy.assignment(benchmark_id) where benchmark_id is not null;

create or replace function taxonomy.enforce_facet_cardinality() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_card text;
  v_facet uuid;
  v_dupes integer;
  v_column text;
  v_target uuid;
begin
  select f.cardinality, f.id into v_card, v_facet
    from taxonomy.term t
    join taxonomy.facet_version fv on fv.id=t.facet_version_id
    join taxonomy.facet f on f.id=fv.facet_id
   where t.id=new.term_id;
  if v_card<>'single' then return new; end if;
  select k,i into v_column,v_target from (values
    ('library_id',new.library_id),('repository_id',new.repository_id),('person_id',new.person_id),
    ('organization_id',new.organization_id),('paper_id',new.paper_id),('talk_id',new.talk_id),
    ('video_id',new.video_id),('product_id',new.product_id),('case_study_id',new.case_study_id),
    ('concept_id',new.concept_id),('dataset_id',new.dataset_id),('benchmark_id',new.benchmark_id),
    ('ai_model_id',new.ai_model_id),('ai_protocol_id',new.ai_protocol_id),
    ('mcp_server_id',new.mcp_server_id),('agent_skill_id',new.agent_skill_id),
    ('technical_problem_id',new.technical_problem_id),('solution_pattern_id',new.solution_pattern_id),
    ('advanced_usage_pattern_id',new.advanced_usage_pattern_id),('failure_mode_id',new.failure_mode_id),
    ('lesson_id',new.lesson_id)
  ) as target(k,i) where i is not null limit 1;
  execute format(
    'select count(*) from taxonomy.assignment a
       join taxonomy.term t on t.id=a.term_id
       join taxonomy.facet_version fv on fv.id=t.facet_version_id
      where fv.facet_id=$1 and a.valid_to is null and a.%I=$2 and a.id<>$3',v_column)
    into v_dupes using v_facet,v_target,new.id;
  if v_dupes>0 then
    raise exception 'facet is single-cardinality; target already holds a current term from it'
      using errcode='unique_violation';
  end if;
  return new;
end;
$$;

create or replace function taxonomy.enforce_term_target_scope() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_kind text;
begin
  select k into v_kind from (values
    ('library',new.library_id),('repository',new.repository_id),('person',new.person_id),
    ('organization',new.organization_id),('paper',new.paper_id),('product',new.product_id),
    ('case_study',new.case_study_id),('concept',new.concept_id),('dataset',new.dataset_id),
    ('benchmark',new.benchmark_id),('ai_model',new.ai_model_id),('ai_protocol',new.ai_protocol_id),
    ('mcp_server',new.mcp_server_id),('agent_skill',new.agent_skill_id)
  ) as target(k,i) where i is not null limit 1;
  if exists (select 1 from taxonomy.term_target_kind s where s.term_id=new.term_id)
     and not exists (
       select 1 from taxonomy.term_target_kind s
       where s.term_id=new.term_id and s.entity_kind_code=v_kind
     ) then
    raise exception 'taxonomy term % is not valid for target kind %', new.term_id, v_kind
      using errcode='check_violation';
  end if;
  return new;
end;
$$;

create trigger assignment_term_target_scope
  before insert or update of term_id, library_id, repository_id, person_id, organization_id,
    paper_id, product_id, case_study_id, dataset_id, benchmark_id, ai_model_id, ai_protocol_id
  on taxonomy.assignment
  for each row execute function taxonomy.enforce_term_target_scope();

-- Typed relationships that complete the major-entity research graph. Mutable
-- measurements stay in ranking; each asserted edge can point to its provenance claim.
create table corpus.organization_relationship (
  from_organization_id uuid not null references corpus.organization(id) on delete cascade,
  to_organization_id   uuid not null references corpus.organization(id) on delete cascade,
  relationship_kind    text not null check (relationship_kind in ('parent','subsidiary','acquired','merged','spinout','partner','member','funder','other')),
  valid_from            date,
  valid_to              date,
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (from_organization_id, to_organization_id, relationship_kind),
  constraint organization_relationship_no_self check (from_organization_id<>to_organization_id),
  constraint organization_relationship_validity check (valid_to is null or valid_from is null or valid_to>=valid_from)
);

create table corpus.organization_product_relationship (
  organization_id       uuid not null references corpus.organization(id) on delete cascade,
  product_id            uuid not null references corpus.product(id) on delete cascade,
  relationship_kind     text not null check (relationship_kind in ('developer','vendor','owner','operator','distributor','implementation_partner','customer','other')),
  is_primary             boolean not null default false,
  valid_from             date,
  valid_to               date,
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (organization_id, product_id, relationship_kind),
  constraint organization_product_validity check (valid_to is null or valid_from is null or valid_to>=valid_from)
);

create table corpus.product_family (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  vendor_organization_id uuid references corpus.organization(id),
  slug                  text not null,
  display_name          text not null,
  description           text,
  lifecycle_state       corpus.lifecycle_state,
  merged_into_id        uuid references corpus.product_family(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table corpus.product_family_member (
  product_family_id     uuid not null references corpus.product_family(id) on delete cascade,
  product_id            uuid not null references corpus.product(id) on delete cascade,
  member_kind           text not null default 'product' check (member_kind in ('product','edition','module','service')),
  sort_order            integer not null default 0,
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (product_family_id, product_id)
);

create table corpus.product_version (
  id                    uuid primary key default util.uuidv7(),
  product_id            uuid not null references corpus.product(id) on delete cascade,
  version_label         text not null,
  release_channel       text check (release_channel in ('preview','beta','stable','lts','deprecated','retired')),
  released_on           date,
  ended_on              date,
  release_url           text,
  notes                 text,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  unique (product_id, version_label),
  constraint product_version_validity check (ended_on is null or released_on is null or ended_on>=released_on)
);

create table corpus.product_feature (
  id                    uuid primary key default util.uuidv7(),
  product_id            uuid not null references corpus.product(id) on delete cascade,
  slug                  text not null,
  name                  text not null,
  description           text,
  introduced_in_version_id uuid references corpus.product_version(id),
  retired_in_version_id uuid references corpus.product_version(id),
  lifecycle_state       corpus.lifecycle_state,
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (product_id, slug)
);

create trigger product_family_set_updated_at
  before update on corpus.product_family
  for each row execute function util.set_updated_at();
create trigger product_feature_set_updated_at
  before update on corpus.product_feature
  for each row execute function util.set_updated_at();

create table corpus.product_backed_by_repository (
  product_id            uuid not null references corpus.product(id) on delete cascade,
  repository_id         uuid not null references corpus.repository(id) on delete cascade,
  relationship_kind     text not null default 'source' check (relationship_kind in ('source','sdk','plugin','examples','documentation','mirror','other')),
  official              boolean not null default false,
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (product_id, repository_id, relationship_kind)
);

create table corpus.ai_model_relationship (
  from_ai_model_id      uuid not null references corpus.ai_model(id) on delete cascade,
  to_ai_model_id        uuid not null references corpus.ai_model(id) on delete cascade,
  relationship_kind     text not null check (relationship_kind in ('derived_from','fine_tuned_from','distilled_from','quantized_from','adapter_for','supersedes','component_of','other')),
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (from_ai_model_id, to_ai_model_id, relationship_kind),
  constraint ai_model_relationship_no_self check (from_ai_model_id<>to_ai_model_id)
);

create table corpus.ai_protocol_relationship (
  from_ai_protocol_id   uuid not null references corpus.ai_protocol(id) on delete cascade,
  to_ai_protocol_id     uuid not null references corpus.ai_protocol(id) on delete cascade,
  relationship_kind     text not null check (relationship_kind in ('extends','profiles','depends_on','supersedes','compatible_with','competes_with','other')),
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (from_ai_protocol_id, to_ai_protocol_id, relationship_kind),
  constraint ai_protocol_relationship_no_self check (from_ai_protocol_id<>to_ai_protocol_id)
);

create table corpus.repository_maintained_by_organization (
  repository_id         uuid not null references corpus.repository(id) on delete cascade,
  organization_id       uuid not null references corpus.organization(id) on delete cascade,
  maintenance_role      text not null default 'maintainer' check (maintenance_role in ('owner','maintainer','sponsor','governance','other')),
  valid_from             date,
  valid_to               date,
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (repository_id, organization_id, maintenance_role)
);

create table corpus.paper_introduces_model (
  paper_id              uuid not null references corpus.paper(id) on delete cascade,
  ai_model_id           uuid not null references corpus.ai_model(id) on delete cascade,
  relationship_kind     text not null default 'introduces' check (relationship_kind in ('introduces','describes','evaluates','compares','extends')),
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (paper_id, ai_model_id, relationship_kind)
);

create table corpus.benchmark_evaluates_model_version (
  benchmark_id          uuid not null references corpus.benchmark(id) on delete cascade,
  ai_model_version_id   uuid not null references corpus.ai_model_version(id) on delete cascade,
  evaluation_role       text not null default 'evaluated' check (evaluation_role in ('evaluated','baseline','judge','reference')),
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (benchmark_id, ai_model_version_id, evaluation_role)
);

create table corpus.benchmark_uses_dataset (
  benchmark_id          uuid not null references corpus.benchmark(id) on delete cascade,
  dataset_id            uuid not null references corpus.dataset(id) on delete cascade,
  usage_kind            text not null default 'evaluation' check (usage_kind in ('evaluation','training','calibration','reference')),
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (benchmark_id, dataset_id, usage_kind)
);

create table corpus.case_study_uses_model_version (
  case_study_id         uuid not null references corpus.case_study(id) on delete cascade,
  ai_model_version_id   uuid not null references corpus.ai_model_version(id) on delete cascade,
  usage_kind            text not null default 'production' check (usage_kind in ('production','pilot','evaluation','migration_source','migration_target','other')),
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (case_study_id, ai_model_version_id, usage_kind)
);

create table corpus.case_study_uses_library (
  case_study_id         uuid not null references corpus.case_study(id) on delete cascade,
  library_id            uuid not null references corpus.library(id) on delete cascade,
  usage_kind            text not null default 'implementation' check (usage_kind in ('implementation','integration','evaluation','migration_source','migration_target','other')),
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (case_study_id, library_id, usage_kind)
);

create table corpus.case_study_references_benchmark (
  case_study_id         uuid not null references corpus.case_study(id) on delete cascade,
  benchmark_id          uuid not null references corpus.benchmark(id) on delete cascade,
  relationship_kind     text not null default 'uses' check (relationship_kind in ('uses','reports','compares','challenges')),
  provenance_claim_id   uuid references evidence.claim(id),
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  primary key (case_study_id, benchmark_id, relationship_kind)
);

create index organization_relationship_to_idx on corpus.organization_relationship(to_organization_id);
create index organization_product_product_idx on corpus.organization_product_relationship(product_id);
create index product_family_vendor_idx on corpus.product_family(vendor_organization_id);
create index product_family_member_product_idx on corpus.product_family_member(product_id);
create index product_version_product_idx on corpus.product_version(product_id, released_on desc);
create index product_feature_product_idx on corpus.product_feature(product_id);
create index product_repository_idx on corpus.product_backed_by_repository(repository_id);
create index ai_model_relationship_to_idx on corpus.ai_model_relationship(to_ai_model_id);
create index ai_protocol_relationship_to_idx on corpus.ai_protocol_relationship(to_ai_protocol_id);
create index repository_maintainer_org_idx on corpus.repository_maintained_by_organization(organization_id);
create index paper_introduces_model_idx on corpus.paper_introduces_model(ai_model_id);
create index benchmark_model_version_idx on corpus.benchmark_evaluates_model_version(ai_model_version_id);
create index benchmark_dataset_idx on corpus.benchmark_uses_dataset(dataset_id);
create index case_study_model_version_idx on corpus.case_study_uses_model_version(ai_model_version_id);
create index case_study_library_idx on corpus.case_study_uses_library(library_id);
create index case_study_benchmark_idx on corpus.case_study_references_benchmark(benchmark_id);

alter table taxonomy.entity_kind enable row level security;
alter table taxonomy.term_target_kind enable row level security;
alter table corpus.organization_relationship enable row level security;
alter table corpus.organization_product_relationship enable row level security;
alter table corpus.product_family enable row level security;
alter table corpus.product_family_member enable row level security;
alter table corpus.product_version enable row level security;
alter table corpus.product_feature enable row level security;
alter table corpus.product_backed_by_repository enable row level security;
alter table corpus.ai_model_relationship enable row level security;
alter table corpus.ai_protocol_relationship enable row level security;
alter table corpus.repository_maintained_by_organization enable row level security;
alter table corpus.paper_introduces_model enable row level security;
alter table corpus.benchmark_evaluates_model_version enable row level security;
alter table corpus.benchmark_uses_dataset enable row level security;
alter table corpus.case_study_uses_model_version enable row level security;
alter table corpus.case_study_uses_library enable row level security;
alter table corpus.case_study_references_benchmark enable row level security;

create policy bounded_role_access on corpus.product_family
  as permissive for all
  to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id=util.current_tenant_id())
  with check (tenant_id=util.current_tenant_id());

do $$
declare relation_name text;
begin
  foreach relation_name in array array['entity_kind','term_target_kind'] loop
    execute format('create policy bounded_role_access on taxonomy.%I as permissive for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader using (true) with check (true)', relation_name);
  end loop;
  foreach relation_name in array array[
    'organization_relationship','organization_product_relationship','product_family_member',
    'product_version','product_feature','product_backed_by_repository','ai_model_relationship','ai_protocol_relationship',
    'repository_maintained_by_organization',
    'paper_introduces_model','benchmark_evaluates_model_version','benchmark_uses_dataset',
    'case_study_uses_model_version','case_study_uses_library','case_study_references_benchmark'
  ] loop
    execute format('create policy bounded_role_access on corpus.%I as permissive for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader using (true) with check (true)', relation_name);
  end loop;
end;
$$;

grant select, insert, update on taxonomy.entity_kind, taxonomy.term_target_kind to executor_service;
grant select on taxonomy.entity_kind, taxonomy.term_target_kind to pipeline_agent, verifier_agent, app_reader;
grant select, insert, update on
  corpus.organization_relationship, corpus.organization_product_relationship,
  corpus.product_family, corpus.product_family_member, corpus.product_version,
  corpus.product_feature, corpus.product_backed_by_repository,
  corpus.ai_model_relationship, corpus.ai_protocol_relationship,
  corpus.repository_maintained_by_organization, corpus.paper_introduces_model,
  corpus.benchmark_evaluates_model_version, corpus.benchmark_uses_dataset,
  corpus.case_study_uses_model_version, corpus.case_study_uses_library,
  corpus.case_study_references_benchmark
to executor_service;
grant select on
  corpus.organization_relationship, corpus.organization_product_relationship,
  corpus.product_family, corpus.product_family_member, corpus.product_version,
  corpus.product_feature, corpus.product_backed_by_repository,
  corpus.ai_model_relationship, corpus.ai_protocol_relationship,
  corpus.repository_maintained_by_organization, corpus.paper_introduces_model,
  corpus.benchmark_evaluates_model_version, corpus.benchmark_uses_dataset,
  corpus.case_study_uses_model_version, corpus.case_study_uses_library,
  corpus.case_study_references_benchmark
to pipeline_agent, verifier_agent, app_reader;

comment on table taxonomy.entity_kind is 'Primary canonical AI knowledge entity divisions and their typed corpus tables.';
comment on table taxonomy.term_target_kind is 'Restricts secondary taxonomy terms to compatible primary entity kinds.';
comment on table corpus.organization_product_relationship is 'Many-to-many organization roles for products; product.vendor_organization_id remains the primary vendor shortcut.';
comment on table corpus.benchmark_evaluates_model_version is 'Semantic benchmark/model link only; quantitative results belong in ranking.metric_observation.';

commit;
