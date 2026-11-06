-- Pre-research v2: run phases, qualification/finish state, organization
-- taxonomy, contextualized summaries, artifact registry, and tightened claim.

-- ---------------------------------------------------------------------------
-- 4.1 Run metadata and session ledger
-- ---------------------------------------------------------------------------

alter table public.research_pre_research_run
  add column if not exists research_as_of date not null default (timezone('utc', now())::date),
  add column if not exists packet_schema_version text not null default '1.0.0',
  add column if not exists packet_storage_prefix text,
  add column if not exists packet_sha256 text,
  add column if not exists research_session_id text,
  add column if not exists synthesis_session_id text,
  add column if not exists research_completed_at timestamptz,
  add column if not exists synthesis_started_at timestamptz;

alter table public.research_pre_research_run
  drop constraint if exists research_pre_research_run_packet_sha256_check;
alter table public.research_pre_research_run
  add constraint research_pre_research_run_packet_sha256_check
    check (packet_sha256 is null or packet_sha256 ~ '^[0-9a-f]{64}$');

drop index if exists public.research_pre_research_run_live_video_hash_uidx;
create unique index research_pre_research_run_live_video_hash_uidx
  on public.research_pre_research_run (video_id, transcript_sha256)
  where status in (
    'queued',
    'claimed',
    'analyzing',
    'research_complete',
    'synthesizing',
    'intent_ready',
    'applying'
  );

create table if not exists public.research_pre_research_session (
  pre_research_session_id uuid primary key default gen_random_uuid(),
  run_id uuid not null
    references public.research_pre_research_run (run_id)
    on delete cascade,
  phase text not null,
  attempt integer not null,
  eve_session_id text not null unique,
  status text not null,
  started_at timestamptz not null default timezone('utc', now()),
  completed_at timestamptz,
  error_code text,
  error_detail text,
  result_summary jsonb,
  constraint research_pre_research_session_phase_check
    check (phase in ('research', 'synthesis')),
  constraint research_pre_research_session_attempt_check
    check (attempt >= 1),
  constraint research_pre_research_session_status_check
    check (status in ('started', 'completed', 'failed', 'cancelled')),
  unique (run_id, phase, attempt)
);

create index if not exists research_pre_research_session_run_idx
  on public.research_pre_research_session (run_id, phase, attempt desc);

-- ---------------------------------------------------------------------------
-- 4.2 Transcript-hash-aware qualification and completion state
-- ---------------------------------------------------------------------------

create table if not exists public.research_pre_research_video_state (
  video_id text primary key
    references public.research_starter_videos (video_id),
  transcript_sha256 text,
  eligibility_status text not null default 'pending',
  ineligibility_reasons text[] not null default '{}',
  duration_seconds integer,
  transcript_object_exists boolean not null default false,
  evaluated_at timestamptz,
  latest_run_id uuid
    references public.research_pre_research_run (run_id),
  pipeline_status text not null default 'not_started',
  pre_research_pipeline_finished boolean not null default false,
  pre_research_pipeline_finished_at timestamptz,
  finished_transcript_sha256 text,
  finished_intent_id uuid
    references public.research_ingestion_intent (intent_id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint research_pre_research_video_state_eligibility_check
    check (eligibility_status in ('pending', 'eligible', 'ineligible')),
  constraint research_pre_research_video_state_pipeline_check
    check (pipeline_status in (
      'not_started',
      'eligible',
      'claimed',
      'researching',
      'research_complete',
      'synthesizing',
      'intent_ready',
      'review_required',
      'applying',
      'finalizing',
      'finished',
      'failed',
      'superseded'
    )),
  constraint research_pre_research_video_state_sha256_check
    check (
      transcript_sha256 is null
      or transcript_sha256 ~ '^[0-9a-f]{64}$'
    ),
  constraint research_pre_research_video_state_finished_sha256_check
    check (
      finished_transcript_sha256 is null
      or finished_transcript_sha256 ~ '^[0-9a-f]{64}$'
    ),
  constraint research_pre_research_video_state_finished_check
    check (
      pre_research_pipeline_finished = false
      or (
        pre_research_pipeline_finished_at is not null
        and finished_transcript_sha256 is not null
        and finished_intent_id is not null
        and pipeline_status = 'finished'
      )
    )
);

drop trigger if exists set_research_pre_research_video_state_updated_at
  on public.research_pre_research_video_state;
create trigger set_research_pre_research_video_state_updated_at
  before update on public.research_pre_research_video_state
  for each row execute procedure public.set_updated_at();

create index if not exists research_pre_research_video_state_eligible_idx
  on public.research_pre_research_video_state (eligibility_status, pipeline_status);

create index if not exists research_starter_videos_pre_research_eligible_idx
  on public.research_starter_videos (published_at asc nulls last, video_id asc)
  where transcript_status = 'stored'
    and duration_seconds is not null
    and duration_seconds > 0
    and duration_seconds < 5400;

-- ---------------------------------------------------------------------------
-- 4.3 Contextualized initial-summary table
-- ---------------------------------------------------------------------------

create table if not exists public.research_video_initial_summary (
  analysis_id uuid primary key
    references public.research_video_analysis (analysis_id)
    on delete cascade,
  video_id text not null
    references public.research_starter_videos (video_id),
  transcript_summary text not null,
  software_engineering_concepts jsonb not null default '[]'::jsonb,
  ai_concepts jsonb not null default '[]'::jsonb,
  external_context_notes jsonb not null default '[]'::jsonb,
  temporal_context text not null,
  research_as_of date not null,
  evidence_ids uuid[] not null default '{}',
  generated_at timestamptz not null default timezone('utc', now()),
  constraint research_video_initial_summary_se_concepts_check
    check (jsonb_typeof(software_engineering_concepts) = 'array'),
  constraint research_video_initial_summary_ai_concepts_check
    check (jsonb_typeof(ai_concepts) = 'array'),
  constraint research_video_initial_summary_notes_check
    check (jsonb_typeof(external_context_notes) = 'array')
);

create index if not exists research_video_initial_summary_video_idx
  on public.research_video_initial_summary (video_id);

-- ---------------------------------------------------------------------------
-- 4.4 Technology/library summary table
-- ---------------------------------------------------------------------------

create table if not exists public.research_video_technology_summary (
  technology_summary_id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null
    references public.research_video_analysis (analysis_id)
    on delete cascade,
  video_id text not null
    references public.research_starter_videos (video_id),
  family_rank integer not null,
  family_label text not null,
  primary_technology text not null,
  primary_technology_kind text not null,
  related_technologies jsonb not null default '[]'::jsonb,
  implementations jsonb not null default '[]'::jsonb,
  summary text not null,
  relationship_rationale text not null,
  role_in_video text not null,
  current_status text not null,
  temporal_status text not null,
  video_published_at timestamptz,
  research_as_of date not null,
  official_urls jsonb not null default '[]'::jsonb,
  evidence_ids uuid[] not null default '{}',
  confidence numeric(4, 3) not null,
  generated_at timestamptz not null default timezone('utc', now()),
  unique (analysis_id, family_rank),
  constraint research_video_technology_summary_rank_check
    check (family_rank >= 1),
  constraint research_video_technology_summary_kind_check
    check (primary_technology_kind in (
      'architecture',
      'technique',
      'protocol',
      'model_family',
      'platform_capability',
      'product',
      'other'
    )),
  constraint research_video_technology_summary_temporal_check
    check (temporal_status in (
      'current',
      'changed_since_publication',
      'historical',
      'uncertain'
    )),
  constraint research_video_technology_summary_confidence_check
    check (confidence >= 0 and confidence <= 1),
  constraint research_video_technology_summary_related_check
    check (jsonb_typeof(related_technologies) = 'array'),
  constraint research_video_technology_summary_impl_check
    check (jsonb_typeof(implementations) = 'array'),
  constraint research_video_technology_summary_urls_check
    check (jsonb_typeof(official_urls) = 'array')
);

create index if not exists research_video_technology_summary_analysis_idx
  on public.research_video_technology_summary (analysis_id, family_rank);

-- ---------------------------------------------------------------------------
-- 4.5 Organization-domain enum, hierarchy, profiles, and sources
-- ---------------------------------------------------------------------------

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public'
      and t.typname = 'research_organization_domain_code'
  ) then
    create type public.research_organization_domain_code as enum (
      'frontier_model_lab',
      'applied_ai_research_lab',
      'cloud_ai_platform',
      'ai_compute_hardware_systems',
      'model_training_inference_platform',
      'ai_data_curation_training_platform',
      'database_data_ai_platform',
      'retrieval_knowledge_platform',
      'agent_framework_orchestration',
      'ai_developer_platform_sdk',
      'coding_agents_developer_tools',
      'evaluation_observability_llmops',
      'ai_security_identity_governance',
      'multimodal_voice_media_ai',
      'robotics_embodied_edge_ai',
      'enterprise_ai_automation',
      'horizontal_ai_application',
      'vertical_ai_application',
      'open_source_ai_ecosystem',
      'ai_protocol_standards_body',
      'academic_nonprofit_research',
      'ai_services_consulting',
      'ai_community_education_media',
      'ai_adopting_product_company',
      'general_technology_ai_unit',
      'diversified_technology_company',
      'other_unknown'
    );
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public'
      and t.typname = 'research_organization_scope'
  ) then
    create type public.research_organization_scope as enum (
      'independent_company',
      'parent_company',
      'subsidiary',
      'division',
      'research_lab',
      'product_organization',
      'standards_body',
      'academic_institution',
      'nonprofit',
      'community_education_media',
      'other'
    );
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public'
      and t.typname = 'research_video_organization_role'
  ) then
    create type public.research_video_organization_role as enum (
      'primary_featured_organization',
      'implementation_owner',
      'speaker_employer',
      'parent_organization',
      'subsidiary_or_division',
      'acquisition_party',
      'partner',
      'customer_or_internal_user',
      'standards_steward',
      'mentioned_only'
    );
  end if;
end
$$;

create table if not exists public.research_organization_domain_definition (
  domain_code public.research_organization_domain_code primary key,
  label text not null,
  description text not null,
  inclusion_criteria text[] not null default '{}',
  exclusion_criteria text[] not null default '{}',
  example_organizations text[] not null default '{}',
  active boolean not null default true,
  sort_order integer not null,
  definition_version text not null default '1.0.0'
);

insert into public.research_organization_domain_definition (
  domain_code, label, description, inclusion_criteria, exclusion_criteria,
  example_organizations, sort_order
)
values
  (
    'frontier_model_lab',
    'Frontier Model Lab',
    'Develops general-purpose frontier/foundation models as a core organizational mission, including the dedicated unit that owns them.',
    array['Core mission is building general-purpose frontier or foundation models', 'Includes the dedicated unit that officially owns those models'],
    array['Applied research labs that do not ship frontier models as their defining product', 'Broad parents that only own a frontier lab'],
    array['Anthropic', 'OpenAI', 'Google DeepMind', 'Mistral AI', 'Cohere', 'Meta Superintelligence Labs', 'Amazon AGI Lab'],
    10
  ),
  (
    'applied_ai_research_lab',
    'Applied AI Research Lab',
    'Primarily conducts AI research or translates research into prototypes, but is not best described as a commercial frontier-model provider.',
    array['Primary work is AI research or research-to-prototype translation'],
    array['Commercial frontier-model providers', 'Product engineering orgs whose research is incidental'],
    array['FAIR-like labs', 'independent applied-research labs'],
    20
  ),
  (
    'cloud_ai_platform',
    'Cloud AI Platform',
    'Hyperscale or broad cloud organization whose AI services, managed model access, and enterprise platform are the relevant implementation context.',
    array['Hyperscale or broad cloud org', 'AI services and managed model access are the implementation context'],
    array['A single coding-agent product inside the cloud company', 'A dedicated frontier lab inside the same parent'],
    array['AWS', 'Microsoft Azure AI'],
    30
  ),
  (
    'ai_compute_hardware_systems',
    'AI Compute Hardware & Systems',
    'Designs accelerators, chips, servers, or tightly coupled AI compute systems.',
    array['Designs accelerators, chips, servers, or tightly coupled AI compute systems'],
    array['Software inference platforms that do not design chips'],
    array['NVIDIA', 'Groq', 'Cerebras', 'SambaNova', 'AMD'],
    40
  ),
  (
    'model_training_inference_platform',
    'Model Training & Inference Platform',
    'Provides model training, fine-tuning, serving, inference, routing, or elastic AI runtime infrastructure rather than primarily designing chips.',
    array['Training, fine-tuning, serving, inference, routing, or elastic AI runtime'],
    array['Chip or accelerator design as the defining role'],
    array['Together AI', 'Modal', 'Replicate', 'Fireworks AI', 'Anyscale', 'OpenRouter'],
    50
  ),
  (
    'ai_data_curation_training_platform',
    'AI Data Curation & Training Platform',
    'Provides labeling, curation, synthetic data, data quality, feedback, or training-data infrastructure.',
    array['Labeling, curation, synthetic data, data quality, or training-data infrastructure'],
    array['Generic databases without a training-data product'],
    array['Scale AI', 'Snorkel'],
    60
  ),
  (
    'database_data_ai_platform',
    'Database & Data AI Platform',
    'General database, warehouse, graph, streaming, or data platform with a material AI engineering product surface.',
    array['Database, warehouse, graph, streaming, or data platform', 'Material AI engineering product surface'],
    array['Retrieval-only vector databases whose defining role is RAG infrastructure'],
    array['MongoDB', 'Supabase', 'Databricks', 'Snowflake', 'Redis', 'ClickHouse', 'Neo4j'],
    70
  ),
  (
    'retrieval_knowledge_platform',
    'Retrieval & Knowledge Platform',
    'Primarily builds retrieval, indexing, vector search, RAG, knowledge, or context infrastructure.',
    array['Retrieval, indexing, vector search, RAG, knowledge, or context infrastructure is the defining role'],
    array['General databases where retrieval is one feature among many'],
    array['LlamaIndex', 'Pinecone', 'Weaviate', 'Qdrant', 'Voyage AI'],
    80
  ),
  (
    'agent_framework_orchestration',
    'Agent Framework & Orchestration',
    'Primarily builds agent frameworks, control planes, workflow orchestration, memory, or durable execution for AI agents.',
    array['Agent frameworks, control planes, workflow orchestration, memory, or durable execution'],
    array['A coding-agent product whose defining role is software engineering'],
    array['LangChain', 'LangGraph', 'Prefect when AI orchestration is the evidenced unit'],
    90
  ),
  (
    'ai_developer_platform_sdk',
    'AI Developer Platform & SDK',
    'Provides broad SDKs, gateways, APIs, sandboxes, deployment primitives, or developer platforms for building AI systems, without a narrower category dominating.',
    array['Broad SDKs, gateways, APIs, sandboxes, or developer platforms for AI systems'],
    array['Coding agents when coding is the defining implementation'],
    array['Vercel AI SDK/platform', 'Cloudflare AI developer platform'],
    100
  ),
  (
    'coding_agents_developer_tools',
    'Coding Agents & Developer Tools',
    'Builds AI coding agents, IDE/terminal/PR tools, code intelligence, or AI-first software-engineering products.',
    array['AI coding agents, IDE/terminal/PR tools, code intelligence, or AI-first SWE products'],
    array['Frontier labs whose coding agent is a product line, not the org defining role'],
    array['GitHub', 'Cursor', 'Windsurf', 'Sourcegraph/Amp', 'Replit'],
    110
  ),
  (
    'evaluation_observability_llmops',
    'Evaluation, Observability & LLMOps',
    'Primarily builds AI evaluation, tracing, experimentation, observability, monitoring, or reliability products.',
    array['AI evaluation, tracing, experimentation, observability, monitoring, or reliability'],
    array['A talk about evals that does not change the org durable role'],
    array['Arize', 'Braintrust', 'Langfuse', 'Galileo', 'Weights & Biases'],
    120
  ),
  (
    'ai_security_identity_governance',
    'AI Security, Identity & Governance',
    'Primarily builds AI security, authorization, identity, policy, guardrails, red teaming, compliance, or governance systems.',
    array['AI security, authorization, identity, policy, guardrails, red teaming, compliance, or governance'],
    array['Generic reliability without a security/governance frame'],
    array['AI-focused WorkOS', 'Pomerium', 'security/governance vendors or units'],
    130
  ),
  (
    'multimodal_voice_media_ai',
    'Multimodal, Voice & Media AI',
    'Primarily builds voice, speech, audio, image, video, generative-media, or realtime multimodal AI products/platforms.',
    array['Voice, speech, audio, image, video, generative-media, or realtime multimodal products'],
    array['Text-only agent platforms'],
    array['ElevenLabs', 'Cartesia', 'Runway'],
    140
  ),
  (
    'robotics_embodied_edge_ai',
    'Robotics, Embodied & Edge AI',
    'Primarily builds robotics, embodied agents, computer-vision/physical systems, or on-device/edge AI platforms.',
    array['Robotics, embodied agents, physical computer vision, or on-device/edge AI'],
    array['Cloud-only software platforms without embodied or edge systems'],
    array['robotics companies', 'Roboflow-like vision platforms', 'dedicated edge-AI units'],
    150
  ),
  (
    'enterprise_ai_automation',
    'Enterprise AI Automation',
    'Primarily sells AI automation, enterprise knowledge work, support, search, productivity, or workflow systems to organizations.',
    array['Sells AI automation or workplace-AI systems to organizations'],
    array['Horizontal consumer assistants', 'Internal AI adoption by a non-AI company'],
    array['enterprise agent/automation and workplace-AI companies'],
    160
  ),
  (
    'horizontal_ai_application',
    'Horizontal AI Application',
    'Builds an AI-native end-user application spanning many industries and not better classified as enterprise automation, coding, or media.',
    array['AI-native end-user application spanning many industries'],
    array['Enterprise automation, coding agents, or media platforms that fit a narrower code'],
    array['general AI assistants/search/productivity applications'],
    170
  ),
  (
    'vertical_ai_application',
    'Vertical AI Application',
    'Builds an AI-native product for a specific industry or professional domain. The conventional vertical remains a separate research_application_domain.',
    array['AI-native product for a specific industry or professional domain'],
    array['Do not encode the application vertical into this org domain when a platform role dominates'],
    array['healthcare, legal, finance, or education AI startups'],
    180
  ),
  (
    'open_source_ai_ecosystem',
    'Open Source AI Ecosystem',
    'Stewardship of open models, libraries, hubs, communities, or distribution is the defining organizational role.',
    array['Stewardship of open models, libraries, hubs, communities, or distribution'],
    array['A company that merely publishes one open-source repo'],
    array['Hugging Face'],
    190
  ),
  (
    'ai_protocol_standards_body',
    'AI Protocol & Standards Body',
    'Stewards an AI protocol, specification, interoperability standard, or neutral technical governance group.',
    array['Stewards an AI protocol, specification, or neutral technical governance group'],
    array['A vendor that happens to implement a protocol'],
    array['MCP steering/standards organizations'],
    200
  ),
  (
    'academic_nonprofit_research',
    'Academic & Nonprofit Research',
    'University, academic lab, nonprofit institute, or public-interest research organization.',
    array['University, academic lab, nonprofit institute, or public-interest research org'],
    array['Commercial labs housed at a university brand without academic governance'],
    array['UC Berkeley labs'],
    210
  ),
  (
    'ai_services_consulting',
    'AI Services & Consulting',
    'Primarily provides AI implementation services, consulting, agencies, or systems integration rather than a repeatable AI product/platform.',
    array['AI implementation services, consulting, agencies, or systems integration'],
    array['A product company that also does professional services'],
    array['consultancies and agencies'],
    220
  ),
  (
    'ai_community_education_media',
    'AI Community, Education & Media',
    'Primarily operates AI education, events, media, professional community, or training.',
    array['AI education, events, media, professional community, or training'],
    array['A product company that publishes talks'],
    array['AI Engineer when it is itself the organization being discussed'],
    230
  ),
  (
    'ai_adopting_product_company',
    'AI-Adopting Product Company',
    'The featured organization primarily operates a non-AI product/business and the talk explains its internal application of AI.',
    array['Primary business is a non-AI product', 'The talk explains internal application of AI'],
    array['Use a narrower AI unit when that unit officially owns the implementation'],
    array['Booking.com', 'Pinterest', 'Uber', 'Amazon retail/recommendations'],
    240
  ),
  (
    'general_technology_ai_unit',
    'General Technology AI Unit',
    'A dedicated AI/product unit inside a broad technology company that is real and authoritative but does not fit a narrower value-chain category. Use sparingly.',
    array['Formally named AI/product unit inside a broad technology company', 'No narrower value-chain code fits'],
    array['Use whenever a narrower code describes the unit'],
    array['a formally named Google, Microsoft, Meta, IBM, or Oracle AI unit with broad scope'],
    250
  ),
  (
    'diversified_technology_company',
    'Diversified Technology Company',
    'Broad technology parent/holding company recorded for hierarchy, where no single AI value-chain role describes the parent as a whole. Do not use when a narrower AI unit is the primary featured organization.',
    array['Broad technology parent recorded for hierarchy'],
    array['Do not use when a narrower AI unit is the primary featured organization'],
    array['Microsoft', 'Alphabet/Google', 'Amazon', 'Meta', 'IBM', 'Oracle'],
    260
  ),
  (
    'other_unknown',
    'Other / Unknown',
    'Evidence is insufficient or no reviewed category fits. Requires a rationale and review flag.',
    array['Insufficient evidence', 'No reviewed category fits'],
    array['Do not use to avoid a close but evidenced classification'],
    array['unresolved cases only'],
    270
  )
on conflict (domain_code) do update
set
  label = excluded.label,
  description = excluded.description,
  inclusion_criteria = excluded.inclusion_criteria,
  exclusion_criteria = excluded.exclusion_criteria,
  example_organizations = excluded.example_organizations,
  sort_order = excluded.sort_order,
  definition_version = excluded.definition_version;

create table if not exists public.research_organization_candidate (
  organization_candidate_id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null
    references public.research_video_analysis (analysis_id)
    on delete cascade,
  video_id text not null
    references public.research_starter_videos (video_id),
  canonical_name text not null,
  normalized_name text not null,
  organization_scope public.research_organization_scope not null,
  relationship_roles public.research_video_organization_role[] not null,
  is_primary_featured boolean not null default false,
  featured_rank integer not null,
  primary_domain_code public.research_organization_domain_code not null,
  secondary_domain_codes public.research_organization_domain_code[] not null default '{}',
  parent_name text,
  parent_canonical_url text,
  official_url text not null,
  authoritative_summary text not null,
  relationship_to_implementation text not null,
  current_status text not null,
  status_as_of date not null,
  video_time_name text,
  video_time_parent_name text,
  ownership_changed_since_video boolean not null default false,
  confidence numeric(4, 3) not null,
  evidence_ids uuid[] not null default '{}',
  generated_at timestamptz not null default timezone('utc', now()),
  unique (analysis_id, normalized_name),
  constraint research_organization_candidate_rank_check
    check (featured_rank >= 1),
  constraint research_organization_candidate_secondary_len_check
    check (cardinality(secondary_domain_codes) <= 2),
  constraint research_organization_candidate_confidence_check
    check (confidence >= 0 and confidence <= 1)
);

create unique index if not exists research_organization_candidate_one_primary_uidx
  on public.research_organization_candidate (analysis_id)
  where is_primary_featured;

create unique index if not exists research_organization_candidate_one_rank1_uidx
  on public.research_organization_candidate (analysis_id)
  where featured_rank = 1;

create index if not exists research_organization_candidate_analysis_idx
  on public.research_organization_candidate (analysis_id, featured_rank);

create table if not exists public.research_organization_source (
  organization_source_id uuid primary key default gen_random_uuid(),
  organization_candidate_id uuid not null
    references public.research_organization_candidate (organization_candidate_id)
    on delete cascade,
  source_rank integer not null,
  source_role text not null,
  authority_tier text not null,
  title text not null,
  publisher text not null,
  url text not null,
  normalized_url text not null,
  publicly_retrievable boolean not null,
  retrieved_at timestamptz not null,
  source_published_at timestamptz,
  supports jsonb not null default '[]'::jsonb,
  verification_status public.research_verification_status not null,
  is_required_core_source boolean not null default false,
  evidence_id uuid
    references public.research_evidence_anchor (evidence_id),
  unique (organization_candidate_id, normalized_url),
  constraint research_organization_source_rank_check
    check (source_rank >= 1),
  constraint research_organization_source_role_check
    check (source_role in (
      'official_homepage',
      'official_about',
      'official_product',
      'official_documentation',
      'official_research',
      'official_model_or_system_card',
      'official_repository',
      'official_engineering_blog',
      'official_changelog',
      'official_press_release',
      'regulatory_or_company_registry',
      'standards_specification',
      'conference_primary_material',
      'reputable_secondary_context'
    )),
  constraint research_organization_source_authority_check
    check (authority_tier in (
      'first_party',
      'official_registry',
      'standards_body',
      'reputable_secondary'
    )),
  constraint research_organization_source_supports_check
    check (jsonb_typeof(supports) = 'array')
);

create index if not exists research_organization_source_candidate_idx
  on public.research_organization_source (organization_candidate_id, source_rank);

-- ---------------------------------------------------------------------------
-- 4.6 Artifact registry
-- ---------------------------------------------------------------------------

create table if not exists public.research_pre_research_artifact (
  artifact_id uuid primary key default gen_random_uuid(),
  run_id uuid not null
    references public.research_pre_research_run (run_id)
    on delete cascade,
  intent_id uuid
    references public.research_ingestion_intent (intent_id)
    on delete cascade,
  artifact_kind text not null,
  schema_version text not null,
  storage_bucket text not null,
  storage_path text not null,
  content_sha256 text not null,
  byte_count bigint not null,
  created_at timestamptz not null default timezone('utc', now()),
  unique (run_id, artifact_kind),
  unique (storage_bucket, storage_path),
  constraint research_pre_research_artifact_kind_check
    check (artifact_kind in (
      'run_manifest',
      'transcript_analysis',
      'taxonomy_classification',
      'web_context',
      'organization_research',
      'source_verification',
      'curriculum_signals',
      'initial_summary',
      'technology_library_summary',
      'organization_profile',
      'ingestion_intent',
      'execution_receipt'
    )),
  constraint research_pre_research_artifact_sha256_check
    check (content_sha256 ~ '^[0-9a-f]{64}$'),
  constraint research_pre_research_artifact_byte_count_check
    check (byte_count >= 0)
);

create index if not exists research_pre_research_artifact_run_idx
  on public.research_pre_research_artifact (run_id, artifact_kind);

-- ---------------------------------------------------------------------------
-- RLS and grants for new tables
-- ---------------------------------------------------------------------------

alter table public.research_pre_research_session enable row level security;
alter table public.research_pre_research_video_state enable row level security;
alter table public.research_video_initial_summary enable row level security;
alter table public.research_video_technology_summary enable row level security;
alter table public.research_organization_domain_definition enable row level security;
alter table public.research_organization_candidate enable row level security;
alter table public.research_organization_source enable row level security;
alter table public.research_pre_research_artifact enable row level security;

revoke all on public.research_pre_research_session from anon, authenticated;
revoke all on public.research_pre_research_video_state from anon, authenticated;
revoke all on public.research_video_initial_summary from anon, authenticated;
revoke all on public.research_video_technology_summary from anon, authenticated;
revoke all on public.research_organization_domain_definition from anon, authenticated;
revoke all on public.research_organization_candidate from anon, authenticated;
revoke all on public.research_organization_source from anon, authenticated;
revoke all on public.research_pre_research_artifact from anon, authenticated;

grant all on public.research_pre_research_session to postgres, service_role;
grant all on public.research_pre_research_video_state to postgres, service_role;
grant all on public.research_video_initial_summary to postgres, service_role;
grant all on public.research_video_technology_summary to postgres, service_role;
grant all on public.research_organization_domain_definition to postgres, service_role;
grant all on public.research_organization_candidate to postgres, service_role;
grant all on public.research_organization_source to postgres, service_role;
grant all on public.research_pre_research_artifact to postgres, service_role;

-- ---------------------------------------------------------------------------
-- Shared qualification helper
-- ---------------------------------------------------------------------------

create or replace function research_private.evaluate_pre_research_qualification(
  p_video public.research_starter_videos
)
returns table (
  transcript_sha256 text,
  duration_seconds integer,
  transcript_object_exists boolean,
  eligibility_status text,
  ineligibility_reasons text[],
  already_live boolean,
  already_finished boolean
)
language plpgsql
stable
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_hash text;
  v_object_exists boolean := false;
  v_reasons text[] := '{}';
  v_live boolean := false;
  v_finished boolean := false;
begin
  if p_video.transcript_text is not null and length(btrim(p_video.transcript_text)) > 0 then
    v_hash := encode(digest(p_video.transcript_text, 'sha256'), 'hex');
  end if;

  if p_video.transcript_bucket is not null and p_video.transcript_path is not null then
    select exists (
      select 1
      from storage.objects o
      where o.bucket_id = p_video.transcript_bucket
        and o.name = p_video.transcript_path
    ) into v_object_exists;
  end if;

  if p_video.transcript_status is distinct from 'stored' then
    v_reasons := array_append(v_reasons, 'transcript_status_not_stored');
  end if;
  if p_video.transcript_text is null or length(btrim(p_video.transcript_text)) = 0 then
    v_reasons := array_append(v_reasons, 'transcript_text_empty');
  end if;
  if p_video.transcript_bucket is distinct from 'ai-engineer-transcripts' then
    v_reasons := array_append(v_reasons, 'transcript_bucket_invalid');
  end if;
  if p_video.transcript_path is null or length(btrim(p_video.transcript_path)) = 0 then
    v_reasons := array_append(v_reasons, 'transcript_path_missing');
  elsif not v_object_exists then
    v_reasons := array_append(v_reasons, 'transcript_object_missing');
  end if;
  if p_video.duration_seconds is null then
    v_reasons := array_append(v_reasons, 'duration_missing');
  elsif p_video.duration_seconds <= 0 then
    v_reasons := array_append(v_reasons, 'duration_non_positive');
  elsif p_video.duration_seconds >= 5400 then
    v_reasons := array_append(v_reasons, 'duration_at_or_over_5400_seconds');
  end if;

  if v_hash is not null then
    select exists (
      select 1
      from public.research_pre_research_run r
      where r.video_id = p_video.video_id
        and r.transcript_sha256 = v_hash
        and r.status in (
          'queued',
          'claimed',
          'analyzing',
          'research_complete',
          'synthesizing',
          'intent_ready',
          'applying',
          'applied'
        )
    ) into v_live;

    select exists (
      select 1
      from public.research_pre_research_video_state s
      where s.video_id = p_video.video_id
        and s.pre_research_pipeline_finished
        and s.finished_transcript_sha256 = v_hash
    ) into v_finished;
  end if;

  if v_live then
    v_reasons := array_append(v_reasons, 'already_live_for_current_transcript');
  end if;
  if v_finished then
    v_reasons := array_append(v_reasons, 'already_finished_for_current_transcript');
  end if;

  return query select
    v_hash,
    p_video.duration_seconds,
    v_object_exists,
    case when cardinality(v_reasons) = 0 then 'eligible' else 'ineligible' end,
    v_reasons,
    v_live,
    v_finished;
end;
$$;

create or replace function research_private.project_pre_research_video_state(
  p_video_id text,
  p_latest_run_id uuid default null,
  p_pipeline_status text default null
)
returns public.research_pre_research_video_state
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_video public.research_starter_videos%rowtype;
  v_eval record;
  v_state public.research_pre_research_video_state%rowtype;
  v_status text;
begin
  select * into v_video
  from public.research_starter_videos
  where video_id = p_video_id;

  if not found then
    raise exception 'VIDEO_NOT_FOUND: %', p_video_id;
  end if;

  select * into v_eval
  from research_private.evaluate_pre_research_qualification(v_video);

  v_status := coalesce(
    p_pipeline_status,
    case
      when v_eval.already_finished then 'finished'
      when v_eval.eligibility_status = 'eligible' then 'eligible'
      else 'not_started'
    end
  );

  insert into public.research_pre_research_video_state (
    video_id,
    transcript_sha256,
    eligibility_status,
    ineligibility_reasons,
    duration_seconds,
    transcript_object_exists,
    evaluated_at,
    latest_run_id,
    pipeline_status,
    pre_research_pipeline_finished,
    pre_research_pipeline_finished_at,
    finished_transcript_sha256,
    finished_intent_id
  )
  values (
    p_video_id,
    v_eval.transcript_sha256,
    v_eval.eligibility_status,
    v_eval.ineligibility_reasons,
    v_eval.duration_seconds,
    v_eval.transcript_object_exists,
    timezone('utc', now()),
    p_latest_run_id,
    v_status,
    false,
    null,
    null,
    null
  )
  on conflict (video_id) do update
  set
    transcript_sha256 = excluded.transcript_sha256,
    eligibility_status = excluded.eligibility_status,
    ineligibility_reasons = excluded.ineligibility_reasons,
    duration_seconds = excluded.duration_seconds,
    transcript_object_exists = excluded.transcript_object_exists,
    evaluated_at = excluded.evaluated_at,
    latest_run_id = coalesce(excluded.latest_run_id, public.research_pre_research_video_state.latest_run_id),
    pipeline_status = case
      when public.research_pre_research_video_state.finished_transcript_sha256
        is distinct from excluded.transcript_sha256
        then coalesce(
          p_pipeline_status,
          case
            when excluded.eligibility_status = 'eligible' then 'eligible'
            else 'superseded'
          end
        )
      else coalesce(p_pipeline_status, public.research_pre_research_video_state.pipeline_status)
    end,
    pre_research_pipeline_finished = case
      when public.research_pre_research_video_state.finished_transcript_sha256 is distinct from excluded.transcript_sha256
        then false
      else public.research_pre_research_video_state.pre_research_pipeline_finished
    end,
    pre_research_pipeline_finished_at = case
      when public.research_pre_research_video_state.finished_transcript_sha256 is distinct from excluded.transcript_sha256
        then null
      else public.research_pre_research_video_state.pre_research_pipeline_finished_at
    end,
    finished_transcript_sha256 = case
      when public.research_pre_research_video_state.finished_transcript_sha256 is distinct from excluded.transcript_sha256
        then null
      else public.research_pre_research_video_state.finished_transcript_sha256
    end,
    finished_intent_id = case
      when public.research_pre_research_video_state.finished_transcript_sha256 is distinct from excluded.transcript_sha256
        then null
      else public.research_pre_research_video_state.finished_intent_id
    end
  returning * into v_state;

  return v_state;
end;
$$;

create or replace function research_private.refresh_pre_research_video_qualification(
  p_video_id text default null
)
returns jsonb
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_id text;
  v_eligible integer := 0;
  v_ineligible integer := 0;
  v_state public.research_pre_research_video_state%rowtype;
begin
  for v_id in
    select v.video_id
    from public.research_starter_videos v
    where p_video_id is null or v.video_id = p_video_id
  loop
    v_state := research_private.project_pre_research_video_state(v_id);
    if v_state.eligibility_status = 'eligible' then
      v_eligible := v_eligible + 1;
    else
      v_ineligible := v_ineligible + 1;
    end if;
  end loop;

  return jsonb_build_object(
    'eligible', v_eligible,
    'ineligible', v_ineligible,
    'evaluated', v_eligible + v_ineligible
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 4.7 Claim RPC
-- ---------------------------------------------------------------------------

drop function if exists research_private.claim_pre_research_video(integer, text, text, text, text);

create or replace function research_private.claim_pre_research_video(
  p_lease_seconds integer default 1800,
  p_taxonomy_version text default '1.0.0',
  p_prompt_bundle_version text default 'pre-research-2.0.0',
  p_model_id text default 'zai/glm-5.2',
  p_packet_schema_version text default '2.0.0',
  p_video_id text default null
)
returns jsonb
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_video public.research_starter_videos%rowtype;
  v_eval record;
  v_run public.research_pre_research_run%rowtype;
  v_taxonomy_id uuid;
  v_lease_token uuid;
  v_reason text;
begin
  if p_lease_seconds < 60 or p_lease_seconds > 21600 then
    raise exception 'INVALID_LEASE_SECONDS: %', p_lease_seconds;
  end if;

  update public.research_pre_research_run
  set
    status = 'failed',
    error_code = 'LEASE_EXPIRED',
    error_detail = 'Lease expired before the run completed',
    completed_at = timezone('utc', now())
  where status in ('claimed', 'analyzing', 'synthesizing')
    and lease_expires_at is not null
    and lease_expires_at < timezone('utc', now());

  select taxonomy_version_id
  into v_taxonomy_id
  from public.research_taxonomy_version
  where version = p_taxonomy_version
    and status = 'active'
  limit 1;

  if v_taxonomy_id is null then
    raise exception 'ACTIVE_TAXONOMY_NOT_FOUND: %', p_taxonomy_version;
  end if;

  if p_video_id is not null then
    select v.*
    into v_video
    from public.research_starter_videos v
    where v.video_id = p_video_id
    for update of v skip locked;

    if not found then
      return jsonb_build_object('claimed', false, 'reason', 'VIDEO_NOT_FOUND', 'video_id', p_video_id);
    end if;

    select * into v_eval
    from research_private.evaluate_pre_research_qualification(v_video);

    if v_eval.eligibility_status <> 'eligible' then
      v_reason := case
        when v_eval.ineligibility_reasons && array['transcript_status_not_stored', 'transcript_text_empty']
          then 'TRANSCRIPT_NOT_STORED'
        when v_eval.ineligibility_reasons && array['transcript_object_missing', 'transcript_path_missing', 'transcript_bucket_invalid']
          then 'TRANSCRIPT_OBJECT_MISSING'
        when v_eval.ineligibility_reasons && array['duration_missing']
          then 'DURATION_MISSING'
        when v_eval.ineligibility_reasons && array['duration_non_positive']
          then 'DURATION_INVALID'
        when v_eval.ineligibility_reasons && array['duration_at_or_over_5400_seconds']
          then 'VIDEO_TOO_LONG'
        when v_eval.ineligibility_reasons && array[
          'already_live_for_current_transcript',
          'already_finished_for_current_transcript'
        ]
          then 'VIDEO_ALREADY_CLAIMED_OR_FINISHED'
        else 'VIDEO_INELIGIBLE'
      end;
      perform research_private.project_pre_research_video_state(v_video.video_id);
      return jsonb_build_object(
        'claimed', false,
        'reason', v_reason,
        'video_id', p_video_id,
        'ineligibility_reasons', to_jsonb(v_eval.ineligibility_reasons)
      );
    end if;
  else
    select v.*
    into v_video
    from public.research_starter_videos v
    where v.transcript_status = 'stored'
      and v.transcript_text is not null
      and length(btrim(v.transcript_text)) > 0
      and v.transcript_bucket = 'ai-engineer-transcripts'
      and v.transcript_path is not null
      and v.duration_seconds is not null
      and v.duration_seconds > 0
      and v.duration_seconds < 5400
      and exists (
        select 1
        from storage.objects o
        where o.bucket_id = v.transcript_bucket
          and o.name = v.transcript_path
      )
      and not exists (
        select 1
        from public.research_pre_research_run r
        where r.video_id = v.video_id
          and r.transcript_sha256 = encode(digest(v.transcript_text, 'sha256'), 'hex')
          and r.status in (
            'queued',
            'claimed',
            'analyzing',
            'research_complete',
            'synthesizing',
            'intent_ready',
            'applying',
            'applied'
          )
      )
      and not exists (
        select 1
        from public.research_pre_research_video_state s
        where s.video_id = v.video_id
          and s.pre_research_pipeline_finished
          and s.finished_transcript_sha256 = encode(digest(v.transcript_text, 'sha256'), 'hex')
      )
    order by v.published_at asc nulls last, v.video_id asc
    for update of v skip locked
    limit 1;

    if not found then
      return jsonb_build_object('claimed', false, 'reason', 'NO_ELIGIBLE_VIDEO');
    end if;

    select * into v_eval
    from research_private.evaluate_pre_research_qualification(v_video);

    if v_eval.eligibility_status <> 'eligible' then
      perform research_private.project_pre_research_video_state(v_video.video_id);
      return jsonb_build_object('claimed', false, 'reason', 'NO_ELIGIBLE_VIDEO');
    end if;
  end if;

  v_lease_token := gen_random_uuid();

  insert into public.research_pre_research_run (
    video_id,
    taxonomy_version_id,
    status,
    attempt,
    lease_token,
    lease_expires_at,
    transcript_sha256,
    prompt_bundle_version,
    model_id,
    research_as_of,
    packet_schema_version,
    started_at
  )
  values (
    v_video.video_id,
    v_taxonomy_id,
    'claimed',
    coalesce((
      select max(r.attempt)
      from public.research_pre_research_run r
      where r.video_id = v_video.video_id
    ), 0) + 1,
    v_lease_token,
    timezone('utc', now()) + make_interval(secs => p_lease_seconds),
    v_eval.transcript_sha256,
    p_prompt_bundle_version,
    p_model_id,
    timezone('utc', now())::date,
    p_packet_schema_version,
    timezone('utc', now())
  )
  returning * into v_run;

  perform research_private.project_pre_research_video_state(
    v_video.video_id,
    v_run.run_id,
    'claimed'
  );

  return jsonb_build_object(
    'claimed', true,
    'run', to_jsonb(v_run),
    'video', jsonb_build_object(
      'video_id', v_video.video_id,
      'title', v_video.title,
      'description', v_video.description,
      'published_at', v_video.published_at,
      'channel_id', v_video.channel_id,
      'channel_handle', v_video.channel_handle,
      'channel_title', v_video.channel_title,
      'duration', v_video.duration,
      'duration_seconds', v_video.duration_seconds,
      'url', v_video.url,
      'thumbnail_url', v_video.thumbnail_url,
      'transcript_status', v_video.transcript_status,
      'transcript_bucket', v_video.transcript_bucket,
      'transcript_path', v_video.transcript_path,
      'transcript_language', v_video.transcript_language,
      'transcript_char_count', v_video.transcript_char_count,
      'transcript_sha256', v_eval.transcript_sha256,
      'research_as_of', v_run.research_as_of,
      'packet_schema_version', v_run.packet_schema_version
    )
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Phase-transition functions
-- ---------------------------------------------------------------------------

create or replace function research_private.current_transcript_hash(p_video_id text)
returns text
language sql
stable
security definer
set search_path = research_private, public, extensions
as $$
  select encode(digest(v.transcript_text, 'sha256'), 'hex')
  from public.research_starter_videos v
  where v.video_id = p_video_id
    and v.transcript_text is not null;
$$;

create or replace function research_private.begin_research_session(
  p_run_id uuid,
  p_eve_session_id text
)
returns jsonb
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_run public.research_pre_research_run%rowtype;
  v_attempt integer;
  v_hash text;
begin
  if p_eve_session_id is null or length(btrim(p_eve_session_id)) = 0 then
    raise exception 'SESSION_BINDING_PENDING: %', p_run_id;
  end if;

  select * into v_run
  from public.research_pre_research_run
  where run_id = p_run_id
  for update;

  if not found then
    raise exception 'RUN_NOT_FOUND: %', p_run_id;
  end if;

  if v_run.status not in ('claimed', 'analyzing') then
    raise exception 'ILLEGAL_PHASE_TRANSITION: % %', p_run_id, v_run.status;
  end if;

  v_hash := research_private.current_transcript_hash(v_run.video_id);
  if v_hash is distinct from v_run.transcript_sha256 then
    raise exception 'TRANSCRIPT_HASH_MISMATCH: %', p_run_id;
  end if;

  v_attempt := coalesce((
    select max(s.attempt)
    from public.research_pre_research_session s
    where s.run_id = p_run_id and s.phase = 'research'
  ), 0) + 1;

  insert into public.research_pre_research_session (
    run_id, phase, attempt, eve_session_id, status
  ) values (
    p_run_id, 'research', v_attempt, p_eve_session_id, 'started'
  )
  on conflict (eve_session_id) do update
  set status = 'started', error_code = null, error_detail = null;

  update public.research_pre_research_run
  set
    status = 'analyzing',
    research_session_id = p_eve_session_id,
    workflow_session_id = p_eve_session_id
  where run_id = p_run_id
  returning * into v_run;

  perform research_private.project_pre_research_video_state(
    v_run.video_id,
    v_run.run_id,
    'researching'
  );

  return jsonb_build_object('ok', true, 'run', to_jsonb(v_run), 'attempt', v_attempt);
end;
$$;

create or replace function research_private.complete_research_phase(
  p_run_id uuid,
  p_eve_session_id text
)
returns jsonb
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_run public.research_pre_research_run%rowtype;
  v_required text[] := array[
    'run_manifest',
    'transcript_analysis',
    'taxonomy_classification',
    'web_context',
    'organization_research',
    'source_verification',
    'curriculum_signals'
  ];
  v_missing text[];
  v_hash text;
begin
  select * into v_run
  from public.research_pre_research_run
  where run_id = p_run_id
  for update;

  if not found then
    raise exception 'RUN_NOT_FOUND: %', p_run_id;
  end if;

  if v_run.research_session_id is null then
    raise exception 'SESSION_BINDING_PENDING: %', p_run_id;
  end if;

  if v_run.research_session_id is distinct from p_eve_session_id then
    raise exception 'SESSION_MISMATCH: %', p_run_id;
  end if;

  if v_run.status <> 'analyzing' then
    raise exception 'ILLEGAL_PHASE_TRANSITION: % %', p_run_id, v_run.status;
  end if;

  v_hash := research_private.current_transcript_hash(v_run.video_id);
  if v_hash is distinct from v_run.transcript_sha256 then
    raise exception 'TRANSCRIPT_HASH_MISMATCH: %', p_run_id;
  end if;

  select coalesce(array_agg(kind), '{}')
  into v_missing
  from unnest(v_required) as kind
  where not exists (
    select 1
    from public.research_pre_research_artifact a
    where a.run_id = p_run_id
      and a.artifact_kind = kind
      and a.content_sha256 ~ '^[0-9a-f]{64}$'
  );

  if cardinality(v_missing) > 0 then
    raise exception 'RESEARCH_CHECKPOINT_INCOMPLETE: %', array_to_string(v_missing, ',');
  end if;

  update public.research_pre_research_session
  set status = 'completed', completed_at = timezone('utc', now())
  where run_id = p_run_id
    and phase = 'research'
    and eve_session_id = p_eve_session_id
    and status = 'started';

  update public.research_pre_research_run
  set
    status = 'research_complete',
    research_completed_at = timezone('utc', now())
  where run_id = p_run_id
  returning * into v_run;

  perform research_private.project_pre_research_video_state(
    v_run.video_id,
    v_run.run_id,
    'research_complete'
  );

  return jsonb_build_object('ok', true, 'run', to_jsonb(v_run));
end;
$$;

create or replace function research_private.begin_synthesis_session(
  p_run_id uuid,
  p_eve_session_id text
)
returns jsonb
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_run public.research_pre_research_run%rowtype;
  v_attempt integer;
  v_hash text;
begin
  if p_eve_session_id is null or length(btrim(p_eve_session_id)) = 0 then
    raise exception 'SESSION_BINDING_PENDING: %', p_run_id;
  end if;

  select * into v_run
  from public.research_pre_research_run
  where run_id = p_run_id
  for update;

  if not found then
    raise exception 'RUN_NOT_FOUND: %', p_run_id;
  end if;

  if v_run.status <> 'research_complete' then
    raise exception 'ILLEGAL_PHASE_TRANSITION: % %', p_run_id, v_run.status;
  end if;

  v_hash := research_private.current_transcript_hash(v_run.video_id);
  if v_hash is distinct from v_run.transcript_sha256 then
    raise exception 'TRANSCRIPT_HASH_MISMATCH: %', p_run_id;
  end if;

  v_attempt := coalesce((
    select max(s.attempt)
    from public.research_pre_research_session s
    where s.run_id = p_run_id and s.phase = 'synthesis'
  ), 0) + 1;

  insert into public.research_pre_research_session (
    run_id, phase, attempt, eve_session_id, status
  ) values (
    p_run_id, 'synthesis', v_attempt, p_eve_session_id, 'started'
  )
  on conflict (eve_session_id) do update
  set status = 'started', error_code = null, error_detail = null;

  update public.research_pre_research_run
  set
    status = 'synthesizing',
    synthesis_session_id = p_eve_session_id,
    synthesis_started_at = timezone('utc', now())
  where run_id = p_run_id
  returning * into v_run;

  perform research_private.project_pre_research_video_state(
    v_run.video_id,
    v_run.run_id,
    'synthesizing'
  );

  return jsonb_build_object('ok', true, 'run', to_jsonb(v_run), 'attempt', v_attempt);
end;
$$;

create or replace function research_private.complete_synthesis_phase(
  p_run_id uuid,
  p_eve_session_id text,
  p_next_status public.research_pre_research_run_status
)
returns jsonb
language plpgsql
security definer
set search_path = research_private, public, extensions
as $$
declare
  v_run public.research_pre_research_run%rowtype;
  v_hash text;
begin
  if p_next_status not in ('intent_ready', 'review_required') then
    raise exception 'ILLEGAL_SYNTHESIS_NEXT_STATUS: %', p_next_status;
  end if;

  select * into v_run
  from public.research_pre_research_run
  where run_id = p_run_id
  for update;

  if not found then
    raise exception 'RUN_NOT_FOUND: %', p_run_id;
  end if;

  if v_run.synthesis_session_id is null then
    raise exception 'SESSION_BINDING_PENDING: %', p_run_id;
  end if;

  if v_run.synthesis_session_id is distinct from p_eve_session_id then
    raise exception 'SESSION_MISMATCH: %', p_run_id;
  end if;

  if v_run.status <> 'synthesizing' then
    raise exception 'ILLEGAL_PHASE_TRANSITION: % %', p_run_id, v_run.status;
  end if;

  v_hash := research_private.current_transcript_hash(v_run.video_id);
  if v_hash is distinct from v_run.transcript_sha256 then
    raise exception 'TRANSCRIPT_HASH_MISMATCH: %', p_run_id;
  end if;

  update public.research_pre_research_session
  set status = 'completed', completed_at = timezone('utc', now())
  where run_id = p_run_id
    and phase = 'synthesis'
    and eve_session_id = p_eve_session_id
    and status = 'started';

  update public.research_pre_research_run
  set status = p_next_status
  where run_id = p_run_id
  returning * into v_run;

  perform research_private.project_pre_research_video_state(
    v_run.video_id,
    v_run.run_id,
    p_next_status::text
  );

  return jsonb_build_object('ok', true, 'run', to_jsonb(v_run));
end;
$$;

-- ---------------------------------------------------------------------------
-- 4.8 Finished feed
-- ---------------------------------------------------------------------------

create or replace function research_private.list_finished_pre_research_videos()
returns table (
  video_id text,
  title text,
  published_at timestamptz,
  duration_seconds integer,
  transcript_bucket text,
  transcript_path text,
  transcript_sha256 text,
  run_id uuid,
  intent_id uuid,
  packet_storage_prefix text,
  research_as_of date,
  analysis_id uuid,
  initial_summary jsonb,
  technology_summaries jsonb,
  organization_candidates jsonb
)
language sql
stable
security definer
set search_path = research_private, public
as $$
  select
    v.video_id,
    v.title,
    v.published_at,
    v.duration_seconds,
    v.transcript_bucket,
    v.transcript_path,
    s.finished_transcript_sha256,
    s.latest_run_id,
    s.finished_intent_id,
    r.packet_storage_prefix,
    r.research_as_of,
    a.analysis_id,
    to_jsonb(i) as initial_summary,
    coalesce((
      select jsonb_agg(to_jsonb(t) order by t.family_rank)
      from public.research_video_technology_summary t
      where t.analysis_id = a.analysis_id
    ), '[]'::jsonb) as technology_summaries,
    coalesce((
      select jsonb_agg(
        to_jsonb(c) || jsonb_build_object(
          'sources', coalesce((
            select jsonb_agg(to_jsonb(src) order by src.source_rank)
            from public.research_organization_source src
            where src.organization_candidate_id = c.organization_candidate_id
          ), '[]'::jsonb)
        )
        order by c.featured_rank
      )
      from public.research_organization_candidate c
      where c.analysis_id = a.analysis_id
    ), '[]'::jsonb) as organization_candidates
  from public.research_pre_research_video_state s
  join public.research_starter_videos v on v.video_id = s.video_id
  join public.research_pre_research_run r on r.run_id = s.latest_run_id
  left join public.research_video_analysis a on a.run_id = r.run_id
  left join public.research_video_initial_summary i on i.analysis_id = a.analysis_id
  where s.pre_research_pipeline_finished
    and s.pipeline_status = 'finished'
    and s.finished_transcript_sha256 = s.transcript_sha256
    and r.status = 'applied'
  order by v.published_at asc nulls last, v.video_id;
$$;

revoke all on function research_private.claim_pre_research_video(integer, text, text, text, text, text)
  from public, anon, authenticated;
revoke all on function research_private.evaluate_pre_research_qualification(public.research_starter_videos)
  from public, anon, authenticated;
revoke all on function research_private.project_pre_research_video_state(text, uuid, text)
  from public, anon, authenticated;
revoke all on function research_private.refresh_pre_research_video_qualification(text)
  from public, anon, authenticated;
revoke all on function research_private.current_transcript_hash(text)
  from public, anon, authenticated;
revoke all on function research_private.begin_research_session(uuid, text)
  from public, anon, authenticated;
revoke all on function research_private.complete_research_phase(uuid, text)
  from public, anon, authenticated;
revoke all on function research_private.begin_synthesis_session(uuid, text)
  from public, anon, authenticated;
revoke all on function research_private.complete_synthesis_phase(uuid, text, public.research_pre_research_run_status)
  from public, anon, authenticated;
revoke all on function research_private.list_finished_pre_research_videos()
  from public, anon, authenticated;

grant execute on function research_private.claim_pre_research_video(integer, text, text, text, text, text)
  to postgres, service_role;
grant execute on function research_private.evaluate_pre_research_qualification(public.research_starter_videos)
  to postgres, service_role;
grant execute on function research_private.project_pre_research_video_state(text, uuid, text)
  to postgres, service_role;
grant execute on function research_private.refresh_pre_research_video_qualification(text)
  to postgres, service_role;
grant execute on function research_private.current_transcript_hash(text)
  to postgres, service_role;
grant execute on function research_private.begin_research_session(uuid, text)
  to postgres, service_role;
grant execute on function research_private.complete_research_phase(uuid, text)
  to postgres, service_role;
grant execute on function research_private.begin_synthesis_session(uuid, text)
  to postgres, service_role;
grant execute on function research_private.complete_synthesis_phase(uuid, text, public.research_pre_research_run_status)
  to postgres, service_role;
grant execute on function research_private.list_finished_pre_research_videos()
  to postgres, service_role;
