-- Normalized bounded-experiment membership, champion CAS state, and verified rollback receipts.

create table if not exists public.factory_experiment_episode (
  factory_experiment_episode_id uuid primary key default gen_random_uuid(),
  factory_experiment_id uuid not null references public.factory_experiment(factory_experiment_id) on delete cascade,
  factory_experiment_arm_id uuid not null references public.factory_experiment_arm(factory_experiment_arm_id) on delete cascade,
  pair_key text not null,
  data_split text not null,
  factory_task_id uuid not null references public.factory_task(factory_task_id) on delete restrict,
  environment_version_id uuid not null references public.factory_environment_version(environment_version_id) on delete restrict,
  seed bigint not null,
  factory_episode_id uuid not null references public.factory_episode(factory_episode_id) on delete restrict,
  execution_order smallint not null,
  assignment_probability numeric not null default 0.5,
  created_at timestamptz not null default timezone('utc', now()),
  constraint factory_experiment_episode_split_check check (
    data_split in ('train', 'development', 'hidden_holdout', 'adversarial',
      'temporal_frontier', 'human_calibration', 'production_quarantine')
  ),
  constraint factory_experiment_episode_order_check check (execution_order in (1, 2)),
  constraint factory_experiment_episode_probability_check check (
    assignment_probability > 0 and assignment_probability <= 1
  ),
  constraint factory_experiment_episode_pair_arm_uniq unique (
    factory_experiment_id, pair_key, factory_experiment_arm_id
  ),
  constraint factory_experiment_episode_episode_uniq unique (factory_episode_id)
);

create table if not exists public.factory_champion (
  scope text not null,
  component_kind text not null,
  candidate_id uuid not null references public.factory_candidate(factory_candidate_id) on delete restrict,
  previous_candidate_id uuid references public.factory_candidate(factory_candidate_id) on delete restrict,
  component_version_id uuid references public.factory_component_version(component_version_id) on delete restrict,
  generation bigint not null default 1,
  promotion_decision_id uuid references public.factory_promotion_decision(factory_promotion_decision_id) on delete restrict,
  active_configuration_digest text not null,
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (scope, component_kind),
  constraint factory_champion_generation_check check (generation > 0),
  constraint factory_champion_digest_check check (
    active_configuration_digest ~ '^sha256:[0-9a-f]{64}$'
  )
);

create table if not exists public.factory_rollback_execution (
  factory_rollback_execution_id uuid primary key default gen_random_uuid(),
  failed_candidate_id uuid not null references public.factory_candidate(factory_candidate_id) on delete restrict,
  rollback_candidate_id uuid not null references public.factory_candidate(factory_candidate_id) on delete restrict,
  triggering_decision_id uuid not null references public.factory_promotion_decision(factory_promotion_decision_id) on delete restrict,
  triggering_canary_result_id uuid references public.factory_canary_result(factory_canary_result_id) on delete restrict,
  expected_champion_generation bigint not null,
  external_operation_id text,
  requested_at timestamptz not null default timezone('utc', now()),
  completed_at timestamptz,
  status text not null default 'requested',
  verified_configuration_digest text,
  evidence_digest text not null,
  failure_reason text,
  constraint factory_rollback_generation_check check (expected_champion_generation > 0),
  constraint factory_rollback_status_check check (
    status in ('requested', 'executing', 'completed', 'failed', 'emergency_stop')
  ),
  constraint factory_rollback_evidence_digest_check check (
    evidence_digest ~ '^sha256:[0-9a-f]{64}$'
  ),
  constraint factory_rollback_verified_digest_check check (
    verified_configuration_digest is null
    or verified_configuration_digest ~ '^sha256:[0-9a-f]{64}$'
  )
);

alter table public.factory_canary_result
  add column if not exists stage_index smallint,
  add column if not exists candidate_episode_count integer,
  add column if not exists baseline_episode_count integer,
  add column if not exists baseline_metrics_digest text,
  add column if not exists candidate_metrics_digest text,
  add column if not exists routing_operation_id text,
  add column if not exists evidence_digest text,
  add column if not exists promotion_policy_version text;

create unique index if not exists factory_canary_decision_stage_uniq
  on public.factory_canary_result (promotion_decision_id, stage_index)
  where stage_index is not null;

create or replace function public.validate_factory_experiment_pair()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  existing public.factory_experiment_episode%rowtype;
begin
  select * into existing
    from public.factory_experiment_episode
   where factory_experiment_id = new.factory_experiment_id
     and pair_key = new.pair_key
   limit 1;
  if found and (
    existing.factory_task_id is distinct from new.factory_task_id
    or existing.environment_version_id is distinct from new.environment_version_id
    or existing.seed is distinct from new.seed
    or existing.data_split is distinct from new.data_split
  ) then
    raise exception 'Experiment pair coordinates must match across arms';
  end if;
  return new;
end;
$$;

drop trigger if exists validate_factory_experiment_pair
  on public.factory_experiment_episode;
create trigger validate_factory_experiment_pair
before insert or update on public.factory_experiment_episode
for each row execute procedure public.validate_factory_experiment_pair();

create or replace function public.promote_factory_champion(
  champion_scope text,
  champion_component_kind text,
  expected_baseline_candidate_id uuid,
  promoted_candidate_id uuid,
  promoted_component_version_id uuid,
  source_promotion_decision_id uuid,
  expected_generation bigint,
  configuration_digest text
)
returns bigint
language plpgsql
set search_path = ''
as $$
declare
  next_generation bigint;
begin
  update public.factory_champion
     set previous_candidate_id = candidate_id,
         candidate_id = promoted_candidate_id,
         component_version_id = promoted_component_version_id,
         generation = generation + 1,
         promotion_decision_id = source_promotion_decision_id,
         active_configuration_digest = configuration_digest,
         updated_at = timezone('utc', now())
   where scope = champion_scope
     and component_kind = champion_component_kind
     and candidate_id = expected_baseline_candidate_id
     and generation = expected_generation
  returning generation into next_generation;
  if next_generation is null then
    raise exception 'Stale champion generation or baseline; promotion rejected';
  end if;
  return next_generation;
end;
$$;

do $$
declare
  table_name text;
  has_anon boolean := exists (select 1 from pg_roles where rolname = 'anon');
  has_authenticated boolean := exists (select 1 from pg_roles where rolname = 'authenticated');
begin
  foreach table_name in array array[
    'factory_experiment_episode', 'factory_champion', 'factory_rollback_execution'
  ]
  loop
    execute format('alter table public.%I enable row level security', table_name);
    if has_anon then execute format('revoke all on table public.%I from anon', table_name); end if;
    if has_authenticated then execute format('revoke all on table public.%I from authenticated', table_name); end if;
  end loop;
end
$$;

comment on table public.factory_experiment_episode is
  'Authoritative paired membership for a bounded baseline/candidate experiment; arm episode arrays are summaries only.';
comment on table public.factory_champion is
  'Atomic compare-and-swap registry for the active bounded-optimizer component candidate.';
comment on table public.factory_rollback_execution is
  'External rollout rollback receipt; completion requires a verified active configuration digest.';
