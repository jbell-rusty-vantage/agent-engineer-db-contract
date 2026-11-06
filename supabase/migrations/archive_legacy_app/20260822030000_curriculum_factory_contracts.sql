-- Immutable curriculum and real-product verification contracts.
--
-- Postgres remains authoritative. Neo4j consumes graph_outbox as a rebuildable
-- projection and never owns promotion, learner, or artifact truth.

create table if not exists public.knowledge_claim (
  claim_id uuid primary key default gen_random_uuid(),
  statement text not null,
  valid_from timestamptz,
  valid_to timestamptz,
  confidence numeric(4, 3) not null,
  review_status text not null default 'proposed',
  content_digest text not null unique,
  created_at timestamptz not null default timezone('utc', now()),
  constraint knowledge_claim_confidence_check check (confidence between 0 and 1),
  constraint knowledge_claim_review_status_check check (
    review_status in ('proposed', 'reviewed', 'approved', 'rejected', 'superseded')
  ),
  constraint knowledge_claim_validity_check check (
    valid_to is null or valid_from is null or valid_to >= valid_from
  ),
  constraint knowledge_claim_digest_check check (
    content_digest ~ '^sha256:[0-9a-f]{64}$'
  )
);

create table if not exists public.knowledge_claim_evidence (
  claim_id uuid not null references public.knowledge_claim(claim_id) on delete cascade,
  evidence_id uuid not null references public.research_evidence_anchor(evidence_id) on delete restrict,
  relation text not null,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (claim_id, evidence_id, relation),
  constraint knowledge_claim_evidence_relation_check check (
    relation in ('supports', 'contradicts', 'contextualizes')
  )
);

create table if not exists public.curriculum_competency (
  competency_id uuid primary key default gen_random_uuid(),
  slug text not null,
  version text not null,
  kind text not null,
  level smallint not null,
  title text not null,
  description text not null,
  evidence_requirements jsonb not null default '{}'::jsonb,
  status text not null default 'draft',
  content_digest text not null,
  created_at timestamptz not null default timezone('utc', now()),
  constraint curriculum_competency_kind_check check (
    kind in ('knowledge', 'skill', 'judgment', 'safety')
  ),
  constraint curriculum_competency_level_check check (level between 0 and 5),
  constraint curriculum_competency_status_check check (
    status in ('draft', 'review', 'active', 'retired')
  ),
  constraint curriculum_competency_digest_check check (
    content_digest ~ '^sha256:[0-9a-f]{64}$'
  ),
  constraint curriculum_competency_slug_version_uniq unique (slug, version)
);

create table if not exists public.curriculum_competency_edge (
  from_competency_id uuid not null references public.curriculum_competency(competency_id) on delete cascade,
  to_competency_id uuid not null references public.curriculum_competency(competency_id) on delete cascade,
  relation text not null,
  weight numeric(5, 4) not null default 1,
  reviewed_by text not null,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (from_competency_id, to_competency_id, relation),
  constraint curriculum_competency_edge_self_check check (
    from_competency_id <> to_competency_id
  ),
  constraint curriculum_competency_edge_relation_check check (
    relation in ('requires', 'enables', 'part_of', 'near_transfer', 'far_transfer')
  ),
  constraint curriculum_competency_edge_weight_check check (weight > 0 and weight <= 1)
);

create table if not exists public.learning_objective (
  objective_id uuid primary key default gen_random_uuid(),
  competency_id uuid not null references public.curriculum_competency(competency_id) on delete restrict,
  version text not null,
  audience_band text not null,
  bloom_verb text not null,
  statement text not null,
  mastery_threshold numeric(5, 4) not null,
  content_digest text not null,
  status text not null default 'draft',
  created_at timestamptz not null default timezone('utc', now()),
  constraint learning_objective_audience_check check (
    audience_band in ('adult', 'ages_13_15', 'ages_9_12')
  ),
  constraint learning_objective_mastery_check check (
    mastery_threshold > 0 and mastery_threshold <= 1
  ),
  constraint learning_objective_status_check check (
    status in ('draft', 'review', 'active', 'retired')
  ),
  constraint learning_objective_digest_check check (
    content_digest ~ '^sha256:[0-9a-f]{64}$'
  ),
  constraint learning_objective_version_uniq unique (
    competency_id, version, audience_band
  )
);

create table if not exists public.challenge_version (
  challenge_version_id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.challenge(challenge_id) on delete restrict,
  supersedes_id uuid references public.challenge_version(challenge_version_id) on delete restrict,
  version text not null,
  audience_band text not null,
  modality text not null,
  spec jsonb not null,
  spec_digest text not null,
  starter_repo_digest text not null,
  verifier_bundle_digest text not null,
  reward_contract_version text not null,
  risk_tier text not null default 'standard',
  status text not null default 'draft',
  published_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  constraint challenge_version_audience_check check (
    audience_band in ('adult', 'ages_13_15', 'ages_9_12')
  ),
  constraint challenge_version_modality_check check (
    modality in ('code_along', 'guided', 'independent', 'production')
  ),
  constraint challenge_version_risk_tier_check check (
    risk_tier in ('low', 'standard', 'high', 'regulated')
  ),
  constraint challenge_version_status_check check (
    status in ('draft', 'review', 'published', 'retired')
  ),
  constraint challenge_version_digest_check check (
    spec_digest ~ '^sha256:[0-9a-f]{64}$'
    and starter_repo_digest ~ '^sha256:[0-9a-f]{64}$'
    and verifier_bundle_digest ~ '^sha256:[0-9a-f]{64}$'
  ),
  constraint challenge_version_publish_time_check check (
    (status = 'published' and published_at is not null)
    or (status <> 'published')
  ),
  constraint challenge_version_identity_uniq unique (
    challenge_id, version, audience_band
  )
);

create table if not exists public.challenge_competency (
  challenge_version_id uuid not null references public.challenge_version(challenge_version_id) on delete cascade,
  competency_id uuid not null references public.curriculum_competency(competency_id) on delete restrict,
  role text not null,
  target_level smallint not null,
  primary key (challenge_version_id, competency_id, role),
  constraint challenge_competency_role_check check (
    role in ('teaches', 'requires', 'assesses')
  ),
  constraint challenge_competency_level_check check (target_level between 0 and 5)
);

create table if not exists public.challenge_evidence (
  challenge_version_id uuid not null references public.challenge_version(challenge_version_id) on delete cascade,
  evidence_id uuid not null references public.research_evidence_anchor(evidence_id) on delete restrict,
  claim_id uuid references public.knowledge_claim(claim_id) on delete restrict,
  role text not null,
  ord integer not null,
  primary key (challenge_version_id, evidence_id, role),
  constraint challenge_evidence_role_check check (
    role in ('primary', 'supporting', 'example')
  ),
  constraint challenge_evidence_order_check check (ord >= 0)
);

create table if not exists public.product_journey_spec (
  journey_spec_id uuid primary key default gen_random_uuid(),
  challenge_version_id uuid not null references public.challenge_version(challenge_version_id) on delete restrict,
  version text not null,
  persona text not null,
  starting_state jsonb not null,
  task_text text not null,
  allowed_actions text[] not null,
  success_predicates text[] not null,
  violation_predicates text[] not null,
  runner_kinds text[] not null,
  fixture_digest text not null,
  max_steps integer not null,
  privacy_class text not null default 'standard',
  content_digest text not null,
  status text not null default 'draft',
  created_at timestamptz not null default timezone('utc', now()),
  constraint product_journey_runner_check check (
    runner_kinds <@ array['playwright', 'computer_use']::text[]
    and 'playwright' = any(runner_kinds)
  ),
  constraint product_journey_privacy_check check (
    privacy_class in ('standard', 'minor_restricted', 'sensitive')
  ),
  constraint product_journey_status_check check (
    status in ('draft', 'review', 'active', 'retired')
  ),
  constraint product_journey_max_steps_check check (max_steps > 0),
  constraint product_journey_digest_check check (
    fixture_digest ~ '^sha256:[0-9a-f]{64}$'
    and content_digest ~ '^sha256:[0-9a-f]{64}$'
  ),
  constraint product_journey_version_uniq unique (challenge_version_id, version, persona)
);

create table if not exists public.product_journey_result (
  journey_result_id uuid primary key default gen_random_uuid(),
  factory_episode_id uuid not null references public.factory_episode(factory_episode_id) on delete cascade,
  journey_spec_id uuid not null references public.product_journey_spec(journey_spec_id) on delete restrict,
  runner_kind text not null,
  model_route text,
  seed bigint not null,
  exact_candidate_sha text not null,
  outcome text not null,
  observed_predicates jsonb not null default '{}'::jsonb,
  violations jsonb not null default '[]'::jsonb,
  cost_usd numeric not null default 0,
  latency_ms bigint not null default 0,
  trace_artifact_id uuid references public.factory_artifact(factory_artifact_id) on delete restrict,
  screenshot_artifact_ids uuid[] not null default '{}'::uuid[],
  replay_digest text not null,
  created_at timestamptz not null default timezone('utc', now()),
  constraint product_journey_result_runner_check check (
    runner_kind in ('playwright', 'computer_use')
  ),
  constraint product_journey_result_outcome_check check (
    outcome in ('pass', 'fail', 'inconclusive')
  ),
  constraint product_journey_result_sha_check check (
    exact_candidate_sha ~ '^[0-9a-f]{40}$'
  ),
  constraint product_journey_result_digest_check check (
    replay_digest ~ '^sha256:[0-9a-f]{64}$'
  ),
  constraint product_journey_result_usage_check check (
    cost_usd >= 0 and latency_ms >= 0
  ),
  constraint product_journey_result_identity_uniq unique (
    factory_episode_id, journey_spec_id, runner_kind, seed, model_route
  )
);

create table if not exists public.learner_submission (
  learner_submission_id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.attempt(attempt_id) on delete cascade,
  challenge_version_id uuid not null references public.challenge_version(challenge_version_id) on delete restrict,
  user_id uuid not null references public.profiles(id) on delete cascade,
  repository_url text,
  commit_sha text,
  artifact_digest text not null,
  deployment_url text,
  state text not null default 'submitted',
  consent_scope jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  constraint learner_submission_state_check check (
    state in ('submitted', 'quarantined', 'verifying', 'passed', 'failed', 'withdrawn')
  ),
  constraint learner_submission_sha_check check (
    commit_sha is null or commit_sha ~ '^[0-9a-f]{40}$'
  ),
  constraint learner_submission_digest_check check (
    artifact_digest ~ '^sha256:[0-9a-f]{64}$'
  )
);

create table if not exists public.human_gate_request (
  human_gate_request_id uuid primary key default gen_random_uuid(),
  subject_kind text not null,
  subject_id uuid not null,
  gate_kind text not null,
  risk_tier text not null,
  required_role text not null,
  evidence_digest text not null,
  state text not null default 'pending',
  created_at timestamptz not null default timezone('utc', now()),
  constraint human_gate_request_risk_check check (
    risk_tier in ('low', 'standard', 'high', 'regulated')
  ),
  constraint human_gate_request_state_check check (
    state in ('pending', 'approved', 'rejected', 'expired', 'cancelled')
  ),
  constraint human_gate_request_digest_check check (
    evidence_digest ~ '^sha256:[0-9a-f]{64}$'
  )
);

create table if not exists public.human_gate_decision (
  human_gate_decision_id uuid primary key default gen_random_uuid(),
  human_gate_request_id uuid not null references public.human_gate_request(human_gate_request_id) on delete restrict,
  actor_principal text not null,
  decision text not null,
  rationale text not null,
  evidence_digest text not null,
  signed_at timestamptz not null default timezone('utc', now()),
  constraint human_gate_decision_check check (decision in ('approve', 'reject')),
  constraint human_gate_decision_digest_check check (
    evidence_digest ~ '^sha256:[0-9a-f]{64}$'
  ),
  constraint human_gate_decision_once_uniq unique (human_gate_request_id)
);

create table if not exists public.eval_case_version (
  eval_case_version_id uuid primary key default gen_random_uuid(),
  slug text not null,
  version text not null,
  split text not null,
  task_digest text not null,
  verifier_digest text not null,
  status text not null default 'draft',
  frozen_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  constraint eval_case_split_check check (
    split in ('train', 'development', 'hidden_holdout', 'adversarial', 'temporal_frontier', 'human_calibration', 'production_quarantine')
  ),
  constraint eval_case_status_check check (
    status in ('draft', 'review', 'frozen', 'retired')
  ),
  constraint eval_case_freeze_check check (
    (status = 'frozen' and frozen_at is not null) or status <> 'frozen'
  ),
  constraint eval_case_digest_check check (
    task_digest ~ '^sha256:[0-9a-f]{64}$'
    and verifier_digest ~ '^sha256:[0-9a-f]{64}$'
  ),
  constraint eval_case_slug_version_uniq unique (slug, version)
);

create table if not exists public.dataset_split_membership (
  manifest_digest text not null,
  eval_case_version_id uuid not null references public.eval_case_version(eval_case_version_id) on delete restrict,
  split text not null,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (manifest_digest, eval_case_version_id),
  constraint dataset_split_manifest_digest_check check (
    manifest_digest ~ '^sha256:[0-9a-f]{64}$'
  )
);

create table if not exists public.graph_outbox (
  graph_outbox_id bigint generated always as identity primary key,
  aggregate_kind text not null,
  aggregate_id uuid not null,
  operation text not null,
  payload jsonb not null,
  source_txid bigint not null default txid_current(),
  created_at timestamptz not null default timezone('utc', now()),
  projected_at timestamptz,
  constraint graph_outbox_operation_check check (
    operation in ('upsert', 'delete', 'link', 'unlink')
  )
);

create index if not exists graph_outbox_pending_idx
  on public.graph_outbox (graph_outbox_id) where projected_at is null;
create index if not exists product_journey_result_episode_idx
  on public.product_journey_result (factory_episode_id, created_at);
create index if not exists learner_submission_user_idx
  on public.learner_submission (user_id, created_at desc);
create index if not exists challenge_version_status_idx
  on public.challenge_version (status, audience_band);

create or replace function public.prevent_published_challenge_version_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.status = 'published' then
    raise exception 'Published challenge versions are immutable; create a superseding version.';
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

drop trigger if exists prevent_published_challenge_version_mutation
  on public.challenge_version;
create trigger prevent_published_challenge_version_mutation
before update or delete on public.challenge_version
for each row execute procedure public.prevent_published_challenge_version_mutation();

do $$
declare
  table_name text;
  has_anon boolean := exists (select 1 from pg_roles where rolname = 'anon');
  has_authenticated boolean := exists (
    select 1 from pg_roles where rolname = 'authenticated'
  );
begin
  foreach table_name in array array[
    'knowledge_claim', 'knowledge_claim_evidence', 'curriculum_competency',
    'curriculum_competency_edge', 'learning_objective', 'challenge_version',
    'challenge_competency', 'challenge_evidence', 'product_journey_spec',
    'product_journey_result', 'learner_submission', 'human_gate_request',
    'human_gate_decision', 'eval_case_version', 'dataset_split_membership',
    'graph_outbox'
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

comment on table public.challenge_version is
  'Immutable published ChallengeSpec identity. Adult and child variants share a challenge family but never share mutable specs.';
comment on table public.product_journey_result is
  'Exact-SHA-bound Playwright or computer-use result with content-addressed replay evidence.';
comment on table public.graph_outbox is
  'Transactional source for the rebuildable Neo4j evidence and competency projection.';
