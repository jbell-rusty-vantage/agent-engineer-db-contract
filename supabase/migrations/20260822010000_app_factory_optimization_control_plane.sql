-- App Factory / Optimization Control Plane
--
-- Trusted-server tables for reproducible research, curriculum, application
-- build, learner-submission, and harness-optimization episodes. Generated code
-- and browser runners never receive direct database credentials for these
-- tables. Large artifacts live in content-addressed object storage.

create table if not exists public.factory_environment_version (
  environment_version_id uuid primary key default gen_random_uuid(),
  slug text not null,
  version text not null,
  task_kind text not null,
  image_digest text not null,
  verifier_bundle_digest text not null,
  reward_contract_version text not null,
  protocol_version text not null default '1',
  spec jsonb not null,
  status text not null default 'draft',
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_environment_task_kind_check check (
    task_kind in (
      'research_ingestion',
      'curriculum_generation',
      'app_feature',
      'app_repair',
      'learner_submission',
      'harness_optimization'
    )
  ),
  constraint factory_environment_status_check check (
    status in ('draft', 'active', 'retired')
  ),
  constraint factory_environment_slug_version_uniq unique (slug, version)
);

create table if not exists public.factory_task (
  factory_task_id uuid primary key default gen_random_uuid(),
  challenge_id uuid references public.challenge(challenge_id) on delete set null,
  parent_task_id uuid references public.factory_task(factory_task_id) on delete set null,
  task_kind text not null,
  slug text not null,
  version text not null,
  spec_digest text not null,
  spec jsonb not null,
  risk_tier text not null default 'standard',
  data_split text not null,
  status text not null default 'draft',
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_task_kind_check check (
    task_kind in (
      'research_ingestion',
      'curriculum_generation',
      'app_feature',
      'app_repair',
      'learner_submission',
      'harness_optimization'
    )
  ),
  constraint factory_task_risk_tier_check check (
    risk_tier in ('low', 'standard', 'high', 'regulated')
  ),
  constraint factory_task_data_split_check check (
    data_split in (
      'train',
      'development',
      'hidden_holdout',
      'adversarial',
      'temporal_frontier',
      'human_calibration',
      'production_quarantine'
    )
  ),
  constraint factory_task_status_check check (
    status in ('draft', 'review', 'active', 'retired', 'quarantined')
  ),
  constraint factory_task_slug_version_uniq unique (slug, version)
);

create table if not exists public.factory_component_version (
  component_version_id uuid primary key default gen_random_uuid(),
  component_kind text not null,
  slug text not null,
  version text not null,
  content_digest text not null,
  source_revision text not null,
  storage_uri text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_component_kind_check check (
    component_kind in (
      'instructions',
      'skill',
      'tool',
      'retriever',
      'workflow',
      'model_route',
      'memory_policy',
      'application_code',
      'model_weights',
      'verifier',
      'reward_contract'
    )
  ),
  constraint factory_component_slug_version_uniq unique (
    component_kind,
    slug,
    version
  )
);

create table if not exists public.factory_candidate (
  factory_candidate_id uuid primary key default gen_random_uuid(),
  parent_candidate_id uuid references public.factory_candidate(factory_candidate_id) on delete set null,
  candidate_kind text not null,
  content_digest text not null,
  source_revision text not null,
  proposer text not null,
  rationale text not null,
  mutation_surface jsonb not null,
  component_versions jsonb not null,
  status text not null default 'proposed',
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_candidate_kind_check check (
    candidate_kind in (
      'instructions',
      'skill',
      'tool',
      'retriever',
      'workflow',
      'model_route',
      'memory_policy',
      'application_code',
      'model_weights',
      'compound'
    )
  ),
  constraint factory_candidate_status_check check (
    status in ('proposed', 'evaluating', 'rejected', 'approved', 'canary', 'promoted', 'rolled_back')
  )
);

create table if not exists public.factory_episode (
  factory_episode_id uuid primary key default gen_random_uuid(),
  factory_task_id uuid not null references public.factory_task(factory_task_id) on delete restrict,
  environment_version_id uuid not null references public.factory_environment_version(environment_version_id) on delete restrict,
  factory_candidate_id uuid not null references public.factory_candidate(factory_candidate_id) on delete restrict,
  attempt_id uuid references public.attempt(attempt_id) on delete set null,
  seed bigint not null,
  idempotency_key text not null unique,
  workflow_run_id text,
  eve_session_id text,
  sandbox_provider text,
  sandbox_session_id text,
  source_revision text not null,
  status text not null default 'queued',
  terminal_state text,
  started_at timestamptz,
  finished_at timestamptz,
  duration_ms bigint,
  model_tokens bigint not null default 0,
  cost_usd numeric not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_episode_status_check check (
    status in ('queued', 'running', 'waiting', 'verifying', 'completed', 'failed', 'cancelled')
  ),
  constraint factory_episode_terminal_state_check check (
    terminal_state is null
    or terminal_state in ('completed', 'failed', 'timed_out', 'cancelled', 'budget_exhausted', 'policy_breach')
  ),
  constraint factory_episode_nonnegative_usage_check check (
    model_tokens >= 0 and cost_usd >= 0 and (duration_ms is null or duration_ms >= 0)
  )
);

create index if not exists factory_episode_task_idx
  on public.factory_episode (factory_task_id, created_at desc);
create index if not exists factory_episode_candidate_idx
  on public.factory_episode (factory_candidate_id, created_at desc);
create index if not exists factory_episode_status_idx
  on public.factory_episode (status, created_at);

create table if not exists public.factory_artifact (
  factory_artifact_id uuid primary key default gen_random_uuid(),
  factory_episode_id uuid not null references public.factory_episode(factory_episode_id) on delete cascade,
  artifact_kind text not null,
  content_digest text not null,
  storage_uri text not null,
  media_type text,
  byte_size bigint,
  retention_class text not null default 'standard',
  contains_sensitive_data boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_artifact_kind_check check (
    artifact_kind in (
      'trace', 'patch', 'repository', 'build', 'log', 'sbom', 'screenshot',
      'video', 'playwright_trace', 'test_report', 'deployment', 'dataset',
      'research_bundle', 'challenge_spec', 'other'
    )
  ),
  constraint factory_artifact_retention_check check (
    retention_class in ('ephemeral', 'standard', 'long_term', 'legal_hold')
  ),
  constraint factory_artifact_size_check check (byte_size is null or byte_size >= 0),
  constraint factory_artifact_episode_digest_uniq unique (
    factory_episode_id,
    artifact_kind,
    content_digest
  )
);

create table if not exists public.factory_trace_span_ref (
  factory_trace_span_ref_id uuid primary key default gen_random_uuid(),
  factory_episode_id uuid not null references public.factory_episode(factory_episode_id) on delete cascade,
  trace_id text not null,
  span_id text not null,
  parent_span_id text,
  agent_role text,
  operation_name text not null,
  artifact_id uuid references public.factory_artifact(factory_artifact_id) on delete set null,
  started_at timestamptz,
  finished_at timestamptz,
  attributes jsonb not null default '{}'::jsonb,
  constraint factory_trace_span_uniq unique (trace_id, span_id)
);

create table if not exists public.factory_assertion_result (
  factory_assertion_result_id uuid primary key default gen_random_uuid(),
  factory_episode_id uuid not null references public.factory_episode(factory_episode_id) on delete cascade,
  assertion_key text not null,
  assertion_kind text not null,
  evaluator_version text not null,
  passed boolean not null,
  hard_gate boolean not null default false,
  score numeric,
  details jsonb not null default '{}'::jsonb,
  evidence_artifact_ids uuid[] not null default '{}'::uuid[],
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_assertion_score_check check (
    score is null or (score >= 0 and score <= 1)
  ),
  constraint factory_assertion_episode_key_uniq unique (
    factory_episode_id,
    assertion_key,
    evaluator_version
  )
);

create table if not exists public.factory_score_vector (
  factory_score_vector_id uuid primary key default gen_random_uuid(),
  factory_episode_id uuid not null references public.factory_episode(factory_episode_id) on delete cascade,
  reward_contract_version text not null,
  vector jsonb not null,
  weighted_score numeric,
  eligible_for_promotion boolean not null default false,
  ineligibility_reasons text[] not null default '{}'::text[],
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_score_weighted_check check (
    weighted_score is null or (weighted_score >= 0 and weighted_score <= 1)
  ),
  constraint factory_score_episode_contract_uniq unique (
    factory_episode_id,
    reward_contract_version
  )
);

create table if not exists public.factory_failure_cluster (
  factory_failure_cluster_id uuid primary key default gen_random_uuid(),
  signature text not null unique,
  title text not null,
  taxonomy_code text not null,
  severity text not null,
  affected_episode_ids uuid[] not null default '{}'::uuid[],
  evidence jsonb not null,
  status text not null default 'open',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint factory_failure_severity_check check (
    severity in ('low', 'medium', 'high', 'critical')
  ),
  constraint factory_failure_status_check check (
    status in ('open', 'triaged', 'eval_drafted', 'mitigated', 'accepted', 'invalid')
  )
);

create table if not exists public.factory_evolution_proposal (
  factory_evolution_proposal_id uuid primary key default gen_random_uuid(),
  failure_cluster_id uuid references public.factory_failure_cluster(factory_failure_cluster_id) on delete set null,
  proposed_candidate_id uuid references public.factory_candidate(factory_candidate_id) on delete set null,
  hypothesized_component_kind text not null,
  hypothesis text not null,
  mutation_surface jsonb not null,
  predicted_impact jsonb not null,
  risks jsonb not null,
  evaluation_plan jsonb not null,
  budget jsonb not null,
  stop_condition jsonb not null,
  rollback_component_version_id uuid references public.factory_component_version(component_version_id) on delete restrict,
  status text not null default 'proposed',
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_evolution_status_check check (
    status in ('proposed', 'approved', 'running', 'no_promotion', 'promotion_requested', 'rejected', 'cancelled')
  )
);

create table if not exists public.factory_experiment (
  factory_experiment_id uuid primary key default gen_random_uuid(),
  evolution_proposal_id uuid not null references public.factory_evolution_proposal(factory_evolution_proposal_id) on delete cascade,
  experiment_version text not null,
  split_manifest_digest text not null,
  policy jsonb not null,
  status text not null default 'draft',
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_experiment_status_check check (
    status in ('draft', 'running', 'completed', 'failed', 'cancelled')
  )
);

create table if not exists public.factory_experiment_arm (
  factory_experiment_arm_id uuid primary key default gen_random_uuid(),
  factory_experiment_id uuid not null references public.factory_experiment(factory_experiment_id) on delete cascade,
  factory_candidate_id uuid not null references public.factory_candidate(factory_candidate_id) on delete restrict,
  arm_name text not null,
  assignment_probability numeric,
  aggregate_metrics jsonb not null default '{}'::jsonb,
  episode_ids uuid[] not null default '{}'::uuid[],
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_experiment_arm_probability_check check (
    assignment_probability is null
    or (assignment_probability > 0 and assignment_probability <= 1)
  ),
  constraint factory_experiment_arm_name_uniq unique (
    factory_experiment_id,
    arm_name
  )
);

create table if not exists public.factory_promotion_decision (
  factory_promotion_decision_id uuid primary key default gen_random_uuid(),
  factory_experiment_id uuid not null references public.factory_experiment(factory_experiment_id) on delete restrict,
  baseline_candidate_id uuid not null references public.factory_candidate(factory_candidate_id) on delete restrict,
  candidate_id uuid not null references public.factory_candidate(factory_candidate_id) on delete restrict,
  decision text not null,
  promotion_policy_version text not null,
  evidence jsonb not null,
  reasons text[] not null default '{}'::text[],
  decided_by text not null,
  rollback_component_version_id uuid references public.factory_component_version(component_version_id) on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_promotion_decision_check check (
    decision in ('promote', 'reject', 'shadow', 'canary', 'roll_back', 'needs_human_review')
  )
);

create table if not exists public.factory_canary_result (
  factory_canary_result_id uuid primary key default gen_random_uuid(),
  promotion_decision_id uuid not null references public.factory_promotion_decision(factory_promotion_decision_id) on delete cascade,
  traffic_fraction numeric not null,
  started_at timestamptz not null,
  finished_at timestamptz,
  status text not null default 'running',
  metrics jsonb not null default '{}'::jsonb,
  rollback_reason text,
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_canary_fraction_check check (
    traffic_fraction > 0 and traffic_fraction <= 1
  ),
  constraint factory_canary_status_check check (
    status in ('running', 'passed', 'failed', 'rolled_back', 'cancelled')
  )
);

do $$
declare
  table_name text;
  has_anon boolean := exists (select 1 from pg_roles where rolname = 'anon');
  has_authenticated boolean := exists (
    select 1 from pg_roles where rolname = 'authenticated'
  );
begin
  foreach table_name in array array[
    'factory_environment_version',
    'factory_task',
    'factory_component_version',
    'factory_candidate',
    'factory_episode',
    'factory_artifact',
    'factory_trace_span_ref',
    'factory_assertion_result',
    'factory_score_vector',
    'factory_failure_cluster',
    'factory_evolution_proposal',
    'factory_experiment',
    'factory_experiment_arm',
    'factory_promotion_decision',
    'factory_canary_result'
  ]
  loop
    execute format('alter table public.%I enable row level security', table_name);
    if has_anon then
      execute format('revoke all on table public.%I from anon', table_name);
    end if;
    if has_authenticated then
      execute format('revoke all on table public.%I from authenticated', table_name);
    end if;
  end loop;
end
$$;

comment on table public.factory_episode is
  'Immutable-identity app-factory or optimization rollout. External artifacts and OTel traces are referenced by content hash.';
comment on table public.factory_evolution_proposal is
  'Bounded, evidence-backed proposal. The optimizer may propose a candidate but cannot alter verifier, reward, promotion, or production authority.';
comment on table public.factory_promotion_decision is
  'Independent signed promotion outcome with evidence and an explicit rollback target.';
