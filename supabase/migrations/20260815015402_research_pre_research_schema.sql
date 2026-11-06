-- Pre-research schema for the research_starter_pre_research_agent.
-- Separate from aiengineerapp learner/entity tables. The only existing
-- source table this schema depends on is public.research_starter_videos.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Private schema for SECURITY DEFINER claim/status functions
-- ---------------------------------------------------------------------------

create schema if not exists research_private;

revoke all on schema research_private from public, anon, authenticated;
grant usage on schema research_private to postgres, service_role;

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public'
      and t.typname = 'research_engineering_category_code'
  ) then
    create type public.research_engineering_category_code as enum (
      'model_foundations_behavior',
      'inference_model_systems',
      'ai_data_engineering',
      'post_training_continual_learning',
      'prompting_llm_programming',
      'context_engineering_memory',
      'retrieval_search_knowledge',
      'agent_architecture_harnesses',
      'tools_protocols_integrations',
      'orchestration_durable_execution',
      'coding_agents_software_engineering',
      'evaluation_testing_benchmarking',
      'observability_reliability_llmops',
      'security_safety_identity_governance',
      'multimodal_realtime_systems',
      'ai_product_ux_human_factors',
      'ai_platforms_developer_tooling'
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
      and t.typname = 'research_taxonomy_status'
  ) then
    create type public.research_taxonomy_status as enum (
      'draft',
      'active',
      'retired'
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
      and t.typname = 'research_pre_research_run_status'
  ) then
    create type public.research_pre_research_run_status as enum (
      'queued',
      'claimed',
      'analyzing',
      'intent_ready',
      'applying',
      'applied',
      'review_required',
      'failed',
      'superseded'
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
      and t.typname = 'research_category_assignment_role'
  ) then
    create type public.research_category_assignment_role as enum (
      'primary',
      'secondary'
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
      and t.typname = 'research_difficulty'
  ) then
    create type public.research_difficulty as enum (
      'introductory',
      'intermediate',
      'advanced',
      'expert'
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
      and t.typname = 'research_content_form'
  ) then
    create type public.research_content_form as enum (
      'talk',
      'tutorial',
      'demo',
      'panel',
      'interview',
      'workshop',
      'keynote'
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
      and t.typname = 'research_evidence_level'
  ) then
    create type public.research_evidence_level as enum (
      'anecdotal',
      'case_study',
      'benchmarked',
      'production_system',
      'research_paper'
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
      and t.typname = 'research_lifecycle_stage'
  ) then
    create type public.research_lifecycle_stage as enum (
      'research',
      'design',
      'implementation',
      'evaluation',
      'deployment',
      'operations',
      'governance'
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
      and t.typname = 'research_evidence_source_kind'
  ) then
    create type public.research_evidence_source_kind as enum (
      'transcript',
      'description',
      'web'
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
      and t.typname = 'research_verification_status'
  ) then
    create type public.research_verification_status as enum (
      'verified',
      'likely',
      'uncertain',
      'rejected'
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
      and t.typname = 'research_resource_type'
  ) then
    create type public.research_resource_type as enum (
      'repository',
      'code_example',
      'documentation',
      'paper',
      'article',
      'slides',
      'dataset',
      'benchmark',
      'model',
      'demo',
      'course',
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
      and t.typname = 'research_entity_kind'
  ) then
    create type public.research_entity_kind as enum (
      'person',
      'organization',
      'product',
      'model',
      'protocol',
      'dataset',
      'benchmark',
      'paper',
      'repository',
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
      and t.typname = 'research_intent_status'
  ) then
    create type public.research_intent_status as enum (
      'draft',
      'validated',
      'applied',
      'rejected'
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
      and t.typname = 'research_intent_event_status'
  ) then
    create type public.research_intent_event_status as enum (
      'pending',
      'applied',
      'skipped',
      'failed'
    );
  end if;
end
$$;

-- ---------------------------------------------------------------------------
-- Taxonomy
-- ---------------------------------------------------------------------------

create table if not exists public.research_taxonomy_version (
  taxonomy_version_id uuid primary key default gen_random_uuid(),
  version text not null unique,
  status public.research_taxonomy_status not null default 'draft',
  definition_sha256 text not null,
  created_at timestamptz not null default timezone('utc', now()),
  activated_at timestamptz,
  retired_at timestamptz,
  notes text,
  constraint research_taxonomy_version_sha256_check
    check (definition_sha256 ~ '^[0-9a-f]{64}$')
);

create unique index if not exists research_taxonomy_version_one_active_uidx
  on public.research_taxonomy_version (status)
  where status = 'active';

comment on table public.research_taxonomy_version is
  'Versioned AI engineering taxonomy. Exactly one row may be active.';

create table if not exists public.research_category_definition (
  taxonomy_version_id uuid not null
    references public.research_taxonomy_version (taxonomy_version_id)
    on delete cascade,
  category_code public.research_engineering_category_code not null,
  label text not null,
  description text not null,
  inclusion_criteria text[] not null default '{}',
  exclusion_criteria text[] not null default '{}',
  example_topics text[] not null default '{}',
  sort_order integer not null,
  primary key (taxonomy_version_id, category_code)
);

create index if not exists research_category_definition_sort_idx
  on public.research_category_definition (taxonomy_version_id, sort_order);

comment on table public.research_category_definition is
  'Per-version definitions for the stable engineering category enum.';

create table if not exists public.research_application_domain (
  domain_code text primary key,
  label text not null,
  description text not null,
  parent_domain_code text
    references public.research_application_domain (domain_code),
  active boolean not null default true,
  sort_order integer not null default 100
);

comment on table public.research_application_domain is
  'Evolving application-domain lookup. Not a Postgres enum.';

-- ---------------------------------------------------------------------------
-- Orchestration
-- ---------------------------------------------------------------------------

create table if not exists public.research_pre_research_run (
  run_id uuid primary key default gen_random_uuid(),
  video_id text not null
    references public.research_starter_videos (video_id),
  taxonomy_version_id uuid not null
    references public.research_taxonomy_version (taxonomy_version_id),
  status public.research_pre_research_run_status not null default 'queued',
  attempt integer not null default 1,
  lease_token uuid,
  lease_expires_at timestamptz,
  transcript_sha256 text not null,
  prompt_bundle_version text not null,
  model_id text not null,
  workflow_session_id text,
  started_at timestamptz,
  completed_at timestamptz,
  error_code text,
  error_detail text,
  intent_path text,
  intent_sha256 text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint research_pre_research_run_attempt_check
    check (attempt >= 1),
  constraint research_pre_research_run_transcript_sha256_check
    check (transcript_sha256 ~ '^[0-9a-f]{64}$'),
  constraint research_pre_research_run_intent_sha256_check
    check (intent_sha256 is null or intent_sha256 ~ '^[0-9a-f]{64}$')
);

create index if not exists research_pre_research_run_video_id_idx
  on public.research_pre_research_run (video_id, created_at desc);

create index if not exists research_pre_research_run_status_idx
  on public.research_pre_research_run (status, created_at desc);

create index if not exists research_pre_research_run_lease_idx
  on public.research_pre_research_run (status, lease_expires_at)
  where status in ('claimed', 'analyzing');

create unique index if not exists research_pre_research_run_live_video_hash_uidx
  on public.research_pre_research_run (video_id, transcript_sha256)
  where status in ('queued', 'claimed', 'analyzing', 'intent_ready', 'applying');

create unique index if not exists research_pre_research_run_applied_video_hash_uidx
  on public.research_pre_research_run (video_id, transcript_sha256)
  where status = 'applied';

drop trigger if exists set_research_pre_research_run_updated_at
  on public.research_pre_research_run;
create trigger set_research_pre_research_run_updated_at
  before update on public.research_pre_research_run
  for each row execute procedure public.set_updated_at();

comment on table public.research_pre_research_run is
  'One claimable orchestration row per video+transcript-hash attempt.';

-- ---------------------------------------------------------------------------
-- Analysis
-- ---------------------------------------------------------------------------

create table if not exists public.research_video_analysis (
  analysis_id uuid primary key default gen_random_uuid(),
  run_id uuid not null unique
    references public.research_pre_research_run (run_id),
  video_id text not null
    references public.research_starter_videos (video_id),
  initial_summary text not null,
  structured_summary text not null,
  contextualized_abstract text not null,
  why_it_matters text not null,
  key_takeaways jsonb not null default '[]'::jsonb,
  concepts jsonb not null default '[]'::jsonb,
  prerequisites jsonb not null default '[]'::jsonb,
  learning_outcomes jsonb not null default '[]'::jsonb,
  limitations jsonb not null default '[]'::jsonb,
  quantitative_claims jsonb not null default '[]'::jsonb,
  demonstrations jsonb not null default '[]'::jsonb,
  curriculum_roles text[] not null default '{}',
  challenge_seeds jsonb not null default '[]'::jsonb,
  difficulty public.research_difficulty not null,
  content_form public.research_content_form not null,
  evidence_level public.research_evidence_level not null,
  overall_confidence numeric(4, 3) not null,
  generated_at timestamptz not null default timezone('utc', now()),
  constraint research_video_analysis_confidence_check
    check (overall_confidence >= 0 and overall_confidence <= 1),
  constraint research_video_analysis_key_takeaways_check
    check (jsonb_typeof(key_takeaways) = 'array'),
  constraint research_video_analysis_concepts_check
    check (jsonb_typeof(concepts) = 'array'),
  constraint research_video_analysis_prerequisites_check
    check (jsonb_typeof(prerequisites) = 'array'),
  constraint research_video_analysis_learning_outcomes_check
    check (jsonb_typeof(learning_outcomes) = 'array'),
  constraint research_video_analysis_limitations_check
    check (jsonb_typeof(limitations) = 'array'),
  constraint research_video_analysis_quantitative_claims_check
    check (jsonb_typeof(quantitative_claims) = 'array'),
  constraint research_video_analysis_demonstrations_check
    check (jsonb_typeof(demonstrations) = 'array'),
  constraint research_video_analysis_challenge_seeds_check
    check (jsonb_typeof(challenge_seeds) = 'array')
);

create index if not exists research_video_analysis_video_id_idx
  on public.research_video_analysis (video_id, generated_at desc);

comment on table public.research_video_analysis is
  'Immutable analysis packet for one completed pre-research run.';
comment on column public.research_video_analysis.initial_summary is
  '75-125 word transcript-only abstract. No web-derived claims.';
comment on column public.research_video_analysis.structured_summary is
  '200-400 word transcript-grounded structured summary.';
comment on column public.research_video_analysis.contextualized_abstract is
  'Transcript plus verified web context. Distinguish evidence grades.';

create table if not exists public.research_video_category (
  analysis_id uuid not null
    references public.research_video_analysis (analysis_id)
    on delete cascade,
  category_code public.research_engineering_category_code not null,
  assignment_role public.research_category_assignment_role not null,
  confidence numeric(4, 3) not null,
  rationale text not null,
  alternative_rank integer,
  primary key (analysis_id, category_code),
  constraint research_video_category_confidence_check
    check (confidence >= 0 and confidence <= 1),
  constraint research_video_category_alternative_rank_check
    check (alternative_rank is null or alternative_rank >= 1)
);

create unique index if not exists research_video_category_one_primary_uidx
  on public.research_video_category (analysis_id)
  where assignment_role = 'primary';

create index if not exists research_video_category_code_idx
  on public.research_video_category (category_code, assignment_role);

comment on table public.research_video_category is
  'Exactly one primary category and up to three secondary categories per analysis.';

create table if not exists public.research_video_domain (
  analysis_id uuid not null
    references public.research_video_analysis (analysis_id)
    on delete cascade,
  domain_code text not null
    references public.research_application_domain (domain_code),
  confidence numeric(4, 3) not null,
  rationale text not null,
  primary key (analysis_id, domain_code),
  constraint research_video_domain_confidence_check
    check (confidence >= 0 and confidence <= 1)
);

create table if not exists public.research_video_lifecycle (
  analysis_id uuid not null
    references public.research_video_analysis (analysis_id)
    on delete cascade,
  lifecycle_stage public.research_lifecycle_stage not null,
  primary key (analysis_id, lifecycle_stage)
);

-- ---------------------------------------------------------------------------
-- Evidence and contextualization
-- ---------------------------------------------------------------------------

create table if not exists public.research_evidence_anchor (
  evidence_id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null
    references public.research_video_analysis (analysis_id)
    on delete cascade,
  source_kind public.research_evidence_source_kind not null,
  source_url text,
  transcript_segment text,
  start_seconds numeric,
  end_seconds numeric,
  start_character integer,
  end_character integer,
  short_excerpt text not null,
  supports text not null,
  constraint research_evidence_anchor_seconds_check
    check (
      start_seconds is null
      or end_seconds is null
      or end_seconds >= start_seconds
    ),
  constraint research_evidence_anchor_characters_check
    check (
      start_character is null
      or end_character is null
      or end_character >= start_character
    )
);

create index if not exists research_evidence_anchor_analysis_idx
  on public.research_evidence_anchor (analysis_id, source_kind);

create table if not exists public.research_entity_candidate (
  candidate_id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null
    references public.research_video_analysis (analysis_id)
    on delete cascade,
  entity_kind public.research_entity_kind not null,
  name text not null,
  normalized_name text not null,
  canonical_url text,
  organization_name text,
  relationship_to_video text not null,
  confidence numeric(4, 3) not null,
  verification_status public.research_verification_status not null,
  evidence_ids uuid[] not null default '{}',
  constraint research_entity_candidate_confidence_check
    check (confidence >= 0 and confidence <= 1)
);

create index if not exists research_entity_candidate_analysis_idx
  on public.research_entity_candidate (analysis_id, entity_kind);

create index if not exists research_entity_candidate_normalized_idx
  on public.research_entity_candidate (normalized_name);

create table if not exists public.research_resource_candidate (
  resource_candidate_id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null
    references public.research_video_analysis (analysis_id)
    on delete cascade,
  resource_type public.research_resource_type not null,
  title text not null,
  url text not null,
  normalized_url text not null,
  publisher text,
  relationship_to_video text not null,
  why_valuable text not null,
  verification_status public.research_verification_status not null,
  is_first_party boolean not null default false,
  license text,
  confidence numeric(4, 3) not null,
  evidence_ids uuid[] not null default '{}',
  constraint research_resource_candidate_confidence_check
    check (confidence >= 0 and confidence <= 1)
);

create unique index if not exists research_resource_candidate_analysis_url_uidx
  on public.research_resource_candidate (analysis_id, normalized_url);

create index if not exists research_resource_candidate_analysis_idx
  on public.research_resource_candidate (analysis_id, resource_type);

create table if not exists public.research_web_search_event (
  search_event_id uuid primary key default gen_random_uuid(),
  run_id uuid not null
    references public.research_pre_research_run (run_id)
    on delete cascade,
  subagent text not null,
  query text not null,
  provider text not null default 'exa',
  searched_at timestamptz not null default timezone('utc', now()),
  result_urls jsonb not null default '[]'::jsonb,
  selected_urls jsonb not null default '[]'::jsonb,
  search_purpose text not null,
  constraint research_web_search_event_result_urls_check
    check (jsonb_typeof(result_urls) = 'array'),
  constraint research_web_search_event_selected_urls_check
    check (jsonb_typeof(selected_urls) = 'array')
);

create index if not exists research_web_search_event_run_idx
  on public.research_web_search_event (run_id, searched_at);

-- ---------------------------------------------------------------------------
-- Intent execution ledger
-- ---------------------------------------------------------------------------

create table if not exists public.research_ingestion_intent (
  intent_id uuid primary key default gen_random_uuid(),
  run_id uuid not null unique
    references public.research_pre_research_run (run_id),
  video_id text not null
    references public.research_starter_videos (video_id),
  schema_version text not null,
  idempotency_key text not null unique,
  storage_bucket text not null,
  storage_path text not null,
  content_sha256 text not null,
  status public.research_intent_status not null default 'draft',
  validated_at timestamptz,
  applied_at timestamptz,
  rejected_at timestamptz,
  error_detail text,
  created_at timestamptz not null default timezone('utc', now()),
  constraint research_ingestion_intent_content_sha256_check
    check (content_sha256 ~ '^[0-9a-f]{64}$')
);

create index if not exists research_ingestion_intent_video_id_idx
  on public.research_ingestion_intent (video_id, created_at desc);

create table if not exists public.research_ingestion_intent_event (
  event_id uuid primary key default gen_random_uuid(),
  intent_id uuid not null
    references public.research_ingestion_intent (intent_id)
    on delete cascade,
  operation_index integer not null,
  operation_kind text not null,
  status public.research_intent_event_status not null,
  affected_table text,
  affected_key text,
  error_detail text,
  created_at timestamptz not null default timezone('utc', now()),
  constraint research_ingestion_intent_event_operation_index_check
    check (operation_index >= 0)
);

create index if not exists research_ingestion_intent_event_intent_idx
  on public.research_ingestion_intent_event (intent_id, operation_index);

-- ---------------------------------------------------------------------------
-- Source-table lockdown: no client access to transcript_text
-- ---------------------------------------------------------------------------

drop view if exists public.research_starter_video_catalog;

drop policy if exists "research_starter_videos_public_read"
  on public.research_starter_videos;

revoke all on public.research_starter_videos from anon, authenticated;

-- ---------------------------------------------------------------------------
-- RLS: research tables are service/postgres only
-- ---------------------------------------------------------------------------

alter table public.research_taxonomy_version enable row level security;
alter table public.research_category_definition enable row level security;
alter table public.research_application_domain enable row level security;
alter table public.research_pre_research_run enable row level security;
alter table public.research_video_analysis enable row level security;
alter table public.research_video_category enable row level security;
alter table public.research_video_domain enable row level security;
alter table public.research_video_lifecycle enable row level security;
alter table public.research_evidence_anchor enable row level security;
alter table public.research_entity_candidate enable row level security;
alter table public.research_resource_candidate enable row level security;
alter table public.research_web_search_event enable row level security;
alter table public.research_ingestion_intent enable row level security;
alter table public.research_ingestion_intent_event enable row level security;

revoke all on public.research_taxonomy_version from anon, authenticated;
revoke all on public.research_category_definition from anon, authenticated;
revoke all on public.research_application_domain from anon, authenticated;
revoke all on public.research_pre_research_run from anon, authenticated;
revoke all on public.research_video_analysis from anon, authenticated;
revoke all on public.research_video_category from anon, authenticated;
revoke all on public.research_video_domain from anon, authenticated;
revoke all on public.research_video_lifecycle from anon, authenticated;
revoke all on public.research_evidence_anchor from anon, authenticated;
revoke all on public.research_entity_candidate from anon, authenticated;
revoke all on public.research_resource_candidate from anon, authenticated;
revoke all on public.research_web_search_event from anon, authenticated;
revoke all on public.research_ingestion_intent from anon, authenticated;
revoke all on public.research_ingestion_intent_event from anon, authenticated;

-- ---------------------------------------------------------------------------
-- Intent storage bucket
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('research-ingestion-intents', 'research-ingestion-intents', false)
on conflict (id) do update
set public = false;

drop policy if exists "research_ingestion_intents_no_client_select"
  on storage.objects;

-- No anon/authenticated policies. Service role and postgres bypass RLS.

-- ---------------------------------------------------------------------------
-- Claim and run-status functions
-- ---------------------------------------------------------------------------

create or replace function research_private.claim_pre_research_video(
  p_lease_seconds integer default 1800,
  p_taxonomy_version text default '1.0.0',
  p_prompt_bundle_version text default 'pre-research-1.0.0',
  p_model_id text default 'zai/glm-5.2'
)
returns jsonb
language plpgsql
security definer
set search_path = research_private, public
as $$
declare
  v_video public.research_starter_videos%rowtype;
  v_hash text;
  v_run public.research_pre_research_run%rowtype;
  v_taxonomy_id uuid;
  v_lease_token uuid;
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
  where status in ('claimed', 'analyzing')
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

  select v.*
  into v_video
  from public.research_starter_videos v
  where v.transcript_status = 'stored'
    and v.transcript_text is not null
    and length(btrim(v.transcript_text)) > 0
    and not exists (
      select 1
      from public.research_pre_research_run r
      where r.video_id = v.video_id
        and r.transcript_sha256 = encode(digest(v.transcript_text, 'sha256'), 'hex')
        and r.status in (
          'queued',
          'claimed',
          'analyzing',
          'intent_ready',
          'applying',
          'applied'
        )
    )
  order by v.published_at desc nulls last, v.video_id
  for update of v skip locked
  limit 1;

  if not found then
    return jsonb_build_object('claimed', false, 'reason', 'NO_ELIGIBLE_VIDEO');
  end if;

  v_hash := encode(digest(v_video.transcript_text, 'sha256'), 'hex');
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
    v_hash,
    p_prompt_bundle_version,
    p_model_id,
    timezone('utc', now())
  )
  returning * into v_run;

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
      'transcript_sha256', v_hash
    )
  );
end;
$$;

create or replace function research_private.touch_pre_research_run(
  p_run_id uuid,
  p_lease_token uuid,
  p_status public.research_pre_research_run_status default null,
  p_lease_seconds integer default 1800,
  p_workflow_session_id text default null,
  p_intent_path text default null,
  p_intent_sha256 text default null,
  p_error_code text default null,
  p_error_detail text default null
)
returns public.research_pre_research_run
language plpgsql
security definer
set search_path = research_private, public
as $$
declare
  v_run public.research_pre_research_run%rowtype;
begin
  select *
  into v_run
  from public.research_pre_research_run
  where run_id = p_run_id
  for update;

  if not found then
    raise exception 'RUN_NOT_FOUND: %', p_run_id;
  end if;

  if v_run.lease_token is distinct from p_lease_token then
    raise exception 'LEASE_TOKEN_MISMATCH: %', p_run_id;
  end if;

  if v_run.status in ('applied', 'failed', 'superseded') then
    raise exception 'RUN_NOT_MUTABLE: % %', p_run_id, v_run.status;
  end if;

  update public.research_pre_research_run
  set
    status = coalesce(p_status, status),
    lease_expires_at = case
      when coalesce(p_status, status) in ('applied', 'failed', 'superseded', 'review_required')
        then lease_expires_at
      else timezone('utc', now()) + make_interval(secs => p_lease_seconds)
    end,
    workflow_session_id = coalesce(p_workflow_session_id, workflow_session_id),
    intent_path = coalesce(p_intent_path, intent_path),
    intent_sha256 = coalesce(p_intent_sha256, intent_sha256),
    error_code = coalesce(p_error_code, error_code),
    error_detail = coalesce(p_error_detail, error_detail),
    completed_at = case
      when coalesce(p_status, status) in ('applied', 'failed', 'superseded', 'review_required')
        then timezone('utc', now())
      else completed_at
    end
  where run_id = p_run_id
  returning * into v_run;

  return v_run;
end;
$$;

revoke all on function research_private.claim_pre_research_video(integer, text, text, text)
  from public, anon, authenticated;
revoke all on function research_private.touch_pre_research_run(
  uuid, uuid, public.research_pre_research_run_status, integer, text, text, text, text, text
) from public, anon, authenticated;

grant execute on function research_private.claim_pre_research_video(integer, text, text, text)
  to postgres, service_role;
grant execute on function research_private.touch_pre_research_run(
  uuid, uuid, public.research_pre_research_run_status, integer, text, text, text, text, text
) to postgres, service_role;

-- ---------------------------------------------------------------------------
-- Taxonomy v1 seed
-- ---------------------------------------------------------------------------

insert into public.research_taxonomy_version (
  taxonomy_version_id,
  version,
  status,
  definition_sha256,
  activated_at,
  notes
)
values (
  '11111111-1111-1111-1111-111111111111',
  '1.0.0',
  'active',
  'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
  timezone('utc', now()),
  'Initial AI engineering spine for pre-research classification.'
)
on conflict (version) do nothing;

insert into public.research_category_definition (
  taxonomy_version_id,
  category_code,
  label,
  description,
  inclusion_criteria,
  exclusion_criteria,
  example_topics,
  sort_order
)
values
  (
    '11111111-1111-1111-1111-111111111111',
    'model_foundations_behavior',
    'Model Foundations & Behavior',
    'How foundation models are built and how they behave: architectures, training dynamics, tokenization, sampling, scaling, and capability or alignment properties of the model itself.',
    array[
      'Talks whose primary object is the model: architecture, pretraining, scaling laws, tokenization, sampling, or intrinsic behavior',
      'Capability, hallucination, or alignment findings about the model rather than a product wrapping it'
    ],
    array[
      'Serving, batching, or inference-engine talks belong in inference_model_systems',
      'SFT, RLHF, DPO, or continual-learning talks belong in post_training_continual_learning'
    ],
    array['transformers', 'scaling laws', 'tokenization', 'sampling', 'model capabilities'],
    10
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'inference_model_systems',
    'Inference & Model Systems',
    'Serving trained models in production: batching, KV cache, quantization, speculative decoding, inference engines, and latency/cost tradeoffs.',
    array[
      'Primary focus is serving, inference performance, or model-system runtime',
      'Quantization, speculative decoding, or KV-cache engineering as the main subject'
    ],
    array[
      'Training or post-training methods are not the primary subject',
      'Application UX around a hosted model belongs in ai_product_ux_human_factors'
    ],
    array['vLLM', 'TensorRT-LLM', 'KV cache', 'speculative decoding', 'quantization'],
    20
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'ai_data_engineering',
    'AI Data Engineering',
    'Data work that makes models and agents useful: pipelines, labeling, synthetic data, curation, quality, and evaluation datasets as data products.',
    array[
      'Primary focus is data collection, labeling, synthetic generation, curation, or data quality for AI systems',
      'Dataset construction as an engineering discipline rather than a one-off benchmark mention'
    ],
    array[
      'Retrieval indexes and RAG pipelines belong in retrieval_search_knowledge',
      'Post-training recipes that merely consume data belong in post_training_continual_learning'
    ],
    array['synthetic data', 'labeling', 'data curation', 'data quality', 'preference data'],
    30
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'post_training_continual_learning',
    'Post-Training & Continual Learning',
    'Adapting models after pretraining: SFT, RLHF, DPO, continued pretraining, LoRA, unlearning, and enterprise continual-learning systems.',
    array[
      'Primary focus is fine-tuning, preference optimization, continued pretraining, or continual learning',
      'Parameter-efficient adaptation or unlearning as the main subject'
    ],
    array[
      'Prompt-only adaptation belongs in prompting_llm_programming',
      'Serving fine-tuned models belongs in inference_model_systems'
    ],
    array['SFT', 'RLHF', 'DPO', 'LoRA', 'continual learning', 'unlearning'],
    40
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'prompting_llm_programming',
    'Prompting & LLM Programming',
    'Programming models with language: prompt design, structured output, few-shot patterns, and compiler-like LLM programming systems.',
    array[
      'Primary focus is prompts, structured generation, or LLM-as-program patterns',
      'DSPy-like or compiler-style prompt optimization as the main subject'
    ],
    array[
      'Long-context, memory, or state management belongs in context_engineering_memory',
      'Tool calling and protocol design belong in tools_protocols_integrations'
    ],
    array['prompt design', 'structured output', 'few-shot', 'DSPy', 'JSON schema'],
    50
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'context_engineering_memory',
    'Context Engineering & Memory',
    'What enters the model context and how state persists: window management, memory systems, compaction, scratchpads, and long-running state.',
    array[
      'Primary focus is context construction, memory, compaction, or durable conversational state',
      'Engineering the working set the model sees across turns'
    ],
    array[
      'Document retrieval and indexes belong in retrieval_search_knowledge',
      'Agent loop or planner design belongs in agent_architecture_harnesses'
    ],
    array['memory systems', 'context compaction', 'scratchpads', 'long context', 'state'],
    60
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'retrieval_search_knowledge',
    'Retrieval, Search & Knowledge',
    'Finding and grounding knowledge: RAG, embeddings, hybrid search, knowledge bases, and ranking for generation.',
    array[
      'Primary focus is retrieval, search, embeddings, or knowledge-base design for AI systems',
      'RAG architecture, chunking, or ranking as the main subject'
    ],
    array[
      'Generic data pipelines without retrieval belong in ai_data_engineering',
      'Memory that is not retrieval-backed belongs in context_engineering_memory'
    ],
    array['RAG', 'embeddings', 'hybrid search', 'knowledge bases', 'reranking'],
    70
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'agent_architecture_harnesses',
    'Agent Architecture & Harnesses',
    'How agents are structured: loops, planning, multi-agent patterns, harnesses, and the control plane around a model.',
    array[
      'Primary focus is agent loops, planning, multi-agent design, or harness architecture',
      'The talk is about the agent system, not a single tool or a single workflow engine'
    ],
    array[
      'Durable workflow engines and queues belong in orchestration_durable_execution',
      'SWE-agent product talks whose core is coding belong in coding_agents_software_engineering'
    ],
    array['agent loop', 'planning', 'multi-agent', 'harness', 'control plane'],
    80
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'tools_protocols_integrations',
    'Tools, Protocols & Integrations',
    'How models call the world: tool calling, MCP, A2A, function calling, connectors, and integration protocols.',
    array[
      'Primary focus is tool calling, protocol design, or integrating external systems',
      'MCP, A2A, or function-calling contracts as the main subject'
    ],
    array[
      'The agent loop that uses tools belongs in agent_architecture_harnesses',
      'Durable execution of those calls belongs in orchestration_durable_execution'
    ],
    array['MCP', 'tool calling', 'A2A', 'function calling', 'connectors'],
    90
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'orchestration_durable_execution',
    'Orchestration & Durable Execution',
    'Making agent and model work survive failure: workflows, queues, retries, checkpoints, and durable execution runtimes.',
    array[
      'Primary focus is workflows, queues, retries, or durable execution for AI work',
      'Crash-safe long-running agent or pipeline orchestration'
    ],
    array[
      'In-memory agent loops without durability belong in agent_architecture_harnesses',
      'Observability of those runs belongs in observability_reliability_llmops'
    ],
    array['workflows', 'queues', 'retries', 'durable execution', 'checkpoints'],
    100
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'coding_agents_software_engineering',
    'Coding Agents & Software Engineering',
    'Agents that write, review, and ship software: IDE agents, PR agents, codegen, and SWE-bench-style engineering systems.',
    array[
      'Primary focus is coding agents, software-engineering agents, or AI-in-the-IDE/PR loop',
      'Code generation, repair, or review as the main product or research object'
    ],
    array[
      'General agent architecture without a coding focus belongs in agent_architecture_harnesses',
      'Evaluation methodology without a coding-agent system belongs in evaluation_testing_benchmarking'
    ],
    array['coding agents', 'codegen', 'PR agents', 'SWE-bench', 'IDE agents'],
    110
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'evaluation_testing_benchmarking',
    'Evaluation, Testing & Benchmarking',
    'Measuring AI systems: evals, benchmarks, judges, test suites, and measurement methodology.',
    array[
      'Primary focus is evaluation design, benchmarks, judges, or testing methodology',
      'How quality is measured rather than how a single system is built'
    ],
    array[
      'Production tracing and quality monitoring belong in observability_reliability_llmops',
      'A system talk that merely reports one score is not primarily this category'
    ],
    array['evals', 'benchmarks', 'LLM judges', 'test suites', 'offline evaluation'],
    120
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'observability_reliability_llmops',
    'Observability, Reliability & LLMOps',
    'Operating AI systems: tracing, logging, quality monitoring, incident response, and LLMOps.',
    array[
      'Primary focus is production observability, reliability, or operating LLM systems',
      'Tracing, quality monitors, or incident response for model/agent products'
    ],
    array[
      'Offline eval design belongs in evaluation_testing_benchmarking',
      'Security incidents and guardrails belong in security_safety_identity_governance'
    ],
    array['tracing', 'LLMOps', 'quality monitoring', 'incident response', 'reliability'],
    130
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'security_safety_identity_governance',
    'Security, Safety, Identity & Governance',
    'Keeping AI systems safe and governable: prompt injection, authz, identity, guardrails, policy, and compliance.',
    array[
      'Primary focus is security, safety, identity, authorization, or governance of AI systems',
      'Prompt injection, jailbreaks, or policy controls as the main subject'
    ],
    array[
      'Model-intrinsic alignment research belongs in model_foundations_behavior',
      'Generic reliability without a security/governance frame belongs in observability_reliability_llmops'
    ],
    array['prompt injection', 'guardrails', 'authz', 'identity', 'compliance'],
    140
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'multimodal_realtime_systems',
    'Multimodal & Realtime Systems',
    'Voice, vision, video, speech, and realtime interactive systems beyond text-only agents.',
    array[
      'Primary focus is multimodal models or realtime voice/vision/video systems',
      'Speech, streaming interaction, or embodied-adjacent realtime loops'
    ],
    array[
      'Text-only agent architecture belongs in agent_architecture_harnesses',
      'Product UX around a multimodal feature without systems depth belongs in ai_product_ux_human_factors'
    ],
    array['voice agents', 'vision', 'speech', 'realtime', 'video understanding'],
    150
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'ai_product_ux_human_factors',
    'AI Product, UX & Human Factors',
    'How people use AI products: UX, human-in-the-loop, trust, collaboration, and product design.',
    array[
      'Primary focus is product design, UX, human-in-the-loop, or trust in AI products',
      'How humans supervise, correct, or collaborate with the system'
    ],
    array[
      'Platform/SDK talks for builders belong in ai_platforms_developer_tooling',
      'Security/trust as governance rather than UX belongs in security_safety_identity_governance'
    ],
    array['human-in-the-loop', 'AI UX', 'trust', 'collaboration', 'product design'],
    160
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'ai_platforms_developer_tooling',
    'AI Platforms & Developer Tooling',
    'Infrastructure for builders: gateways, playgrounds, SDKs, eval platforms, and developer platforms that other teams build on.',
    array[
      'Primary focus is a platform, SDK, gateway, or developer tool for building AI systems',
      'The talk is about the substrate other engineers use, not one end-user application'
    ],
    array[
      'A single coding agent product belongs in coding_agents_software_engineering',
      'A single workflow engine without a platform frame belongs in orchestration_durable_execution'
    ],
    array['AI gateway', 'SDK', 'playground', 'developer platform', 'model router'],
    170
  )
on conflict (taxonomy_version_id, category_code) do nothing;

insert into public.research_application_domain (
  domain_code,
  label,
  description,
  parent_domain_code,
  active,
  sort_order
)
values
  ('general_purpose', 'General Purpose', 'Cross-domain or no specific application vertical.', null, true, 10),
  ('developer_platforms', 'Developer Platforms', 'Tools and platforms used by software builders.', null, true, 20),
  ('coding_assistants', 'Coding Assistants', 'IDE, PR, and software-engineering assistants.', 'developer_platforms', true, 21),
  ('enterprise_operations', 'Enterprise Operations', 'Internal enterprise workflows, ops, and knowledge work.', null, true, 30),
  ('customer_support', 'Customer Support', 'Support, success, and helpdesk automation.', 'enterprise_operations', true, 31),
  ('search_and_knowledge', 'Search & Knowledge', 'Enterprise search, knowledge bases, and assistants over corpora.', null, true, 40),
  ('data_and_analytics', 'Data & Analytics', 'Analytics, BI, and data-agent products.', null, true, 50),
  ('scientific_research', 'Scientific Research', 'Science, labs, and research-assistant systems.', null, true, 60),
  ('healthcare_life_sciences', 'Healthcare & Life Sciences', 'Clinical, biomedical, and life-science applications.', null, true, 70),
  ('finance_trading', 'Finance & Trading', 'Financial services, risk, and trading systems.', null, true, 80),
  ('education_learning', 'Education & Learning', 'Tutoring, curriculum, and learning products.', null, true, 90),
  ('robotics_embodied', 'Robotics & Embodied', 'Robots, devices, and embodied agents.', null, true, 100),
  ('media_creative', 'Media & Creative', 'Content, design, and creative-production systems.', null, true, 110),
  ('security_defense', 'Security & Defense', 'Security operations and defense applications.', null, true, 120),
  ('legal_compliance', 'Legal & Compliance', 'Legal research, contracts, and compliance workflows.', null, true, 130),
  ('personal_productivity', 'Personal Productivity', 'Individual assistants and consumer productivity.', null, true, 140)
on conflict (domain_code) do nothing;

-- Replace the placeholder taxonomy hash with a hash of the seeded definition set.
update public.research_taxonomy_version
set definition_sha256 = encode(
  digest(
    (
      select string_agg(
        category_code::text || ':' || label || ':' || description,
        '|'
        order by sort_order
      )
      from public.research_category_definition
      where taxonomy_version_id = '11111111-1111-1111-1111-111111111111'
    ),
    'sha256'
  ),
  'hex'
)
where taxonomy_version_id = '11111111-1111-1111-1111-111111111111';
