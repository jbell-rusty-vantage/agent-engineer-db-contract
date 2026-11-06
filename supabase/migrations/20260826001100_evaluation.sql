-- 0011 | evaluation: datasets, graders, runs, gates, and the review queue.
--
-- Reviewer decisions are provenance AND reusable eval labels, so review_decision
-- feeds eval_label rather than being a dead-end audit row.

begin;

create type evaluation.review_state as enum
  ('open','claimed','in_review','decided','escalated','cancelled');

create type evaluation.gate_action as enum
  ('block','quarantine','repair','rerun','review','escalate','optimize','allow');

-- ---------------------------------------------------------------------------
-- Datasets and cases.
-- ---------------------------------------------------------------------------
create table evaluation.eval_dataset (
  id          uuid primary key default util.uuidv7(),
  tenant_id   uuid not null default util.default_tenant_id(),
  slug        text not null,
  purpose     text not null,
  description text,
  created_at  timestamptz not null default now(),
  unique (tenant_id, slug)
);

create table evaluation.eval_case (
  id         uuid primary key default util.uuidv7(),
  dataset_id uuid not null references evaluation.eval_dataset(id) on delete cascade,
  external_key text,
  input      jsonb not null,
  expected   jsonb,
  metadata   jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (dataset_id, external_key)
);

create table evaluation.eval_label (
  id         uuid primary key default util.uuidv7(),
  case_id    uuid not null references evaluation.eval_case(id) on delete cascade,
  label      jsonb not null,
  labeled_by text not null,
  -- Set when this label originated as a human review decision.
  review_decision_id uuid,
  created_at timestamptz not null default now()
);

create index eval_label_case_idx on evaluation.eval_label (case_id);

-- ---------------------------------------------------------------------------
-- Graders.
-- ---------------------------------------------------------------------------
create table evaluation.grader (
  id         uuid primary key default util.uuidv7(),
  slug       text not null unique,
  kind       text not null check (kind in ('deterministic','model','hybrid','human')),
  purpose    text not null,
  created_at timestamptz not null default now()
);

create table evaluation.grader_version (
  id         uuid primary key default util.uuidv7(),
  grader_id  uuid not null references evaluation.grader(id) on delete cascade,
  version    integer not null,
  code_ref   text,
  model      text,
  prompt     text,
  config     jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (grader_id, version)
);

-- ---------------------------------------------------------------------------
-- Runs and scores. The target arc covers the versioned things that can be
-- evaluated; free-form targets (an extractor, a verifier, a deployment) are
-- named by code identity rather than FK, since they are not tables.
-- ---------------------------------------------------------------------------
create table evaluation.eval_run (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  dataset_id            uuid not null references evaluation.eval_dataset(id),
  grader_version_id     uuid references evaluation.grader_version(id),
  capability_version_id uuid references orchestration.capability_version(id),
  space_version_id      uuid references retrieval.vector_space_version(id),
  ranking_policy_version_id uuid references ranking.ranking_policy_version(id),
  metric_definition_version_id uuid references ranking.metric_definition_version(id),
  target_code_ref       text,
  target_kind           text generated always as (
    case
      when capability_version_id        is not null then 'capability_version'
      when space_version_id             is not null then 'vector_space_version'
      when ranking_policy_version_id    is not null then 'ranking_policy_version'
      when metric_definition_version_id is not null then 'metric_definition_version'
      when target_code_ref              is not null then 'code_ref'
    end) stored,
  config                jsonb not null default '{}'::jsonb,
  code_ref              text,
  executed_at           timestamptz not null default now(),
  constraint eval_run_exactly_one_target check (
    num_nonnulls(capability_version_id, space_version_id, ranking_policy_version_id,
                 metric_definition_version_id, target_code_ref) = 1)
);

create index eval_run_target_idx  on evaluation.eval_run (target_kind, executed_at desc);
create index eval_run_dataset_idx on evaluation.eval_run (dataset_id, executed_at desc);

create table evaluation.eval_score (
  id       uuid primary key default util.uuidv7(),
  run_id   uuid not null references evaluation.eval_run(id) on delete cascade,
  case_id  uuid not null references evaluation.eval_case(id),
  metrics  jsonb not null default '{}'::jsonb,
  passed   boolean,
  -- Called out first-class: accepting something that should have been rejected
  -- is the failure mode that matters most here.
  false_acceptance boolean not null default false,
  false_rejection  boolean not null default false,
  created_at timestamptz not null default now(),
  unique (run_id, case_id)
);

create index eval_score_false_acceptance_idx on evaluation.eval_score (run_id)
  where false_acceptance;

-- ---------------------------------------------------------------------------
-- Gates: what must hold before something is promoted.
-- ---------------------------------------------------------------------------
create table evaluation.gate (
  id         uuid primary key default util.uuidv7(),
  slug       text not null unique,
  purpose    text not null,
  thresholds jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table evaluation.gate_binding (
  id          uuid primary key default util.uuidv7(),
  gate_id     uuid not null references evaluation.gate(id) on delete cascade,
  guards_kind text not null,
  guards_ref  text,
  created_at  timestamptz not null default now(),
  unique (gate_id, guards_kind, guards_ref)
);

create table evaluation.gate_result (
  id            uuid primary key default util.uuidv7(),
  gate_id       uuid not null references evaluation.gate(id),
  eval_run_id   uuid references evaluation.eval_run(id),
  passed        boolean not null,
  action        evaluation.gate_action not null,
  detail        jsonb not null default '{}'::jsonb,
  spawned_work_item_id uuid references orchestration.work_item(id),
  created_at    timestamptz not null default now()
);

create index gate_result_gate_idx on evaluation.gate_result (gate_id, created_at desc);

create table evaluation.regression (
  id            uuid primary key default util.uuidv7(),
  gate_id       uuid references evaluation.gate(id),
  baseline_run_id uuid not null references evaluation.eval_run(id),
  current_run_id  uuid not null references evaluation.eval_run(id),
  metric        text not null,
  baseline_value numeric,
  current_value  numeric,
  delta          numeric,
  detected_at   timestamptz not null default now(),
  constraint regression_distinct_runs check (baseline_run_id <> current_run_id)
);

-- ---------------------------------------------------------------------------
-- The typed review queue. This is the table the whole architecture points at
-- when something needs a human: identity, merges, claim support, conflicts,
-- extraction failures, ranking anomalies, synthesis, intents, publication,
-- migrations, harness promotion.
-- ---------------------------------------------------------------------------
create table evaluation.review_task (
  id          uuid primary key default util.uuidv7(),
  tenant_id   uuid not null default util.default_tenant_id(),
  task_kind   text not null check (task_kind in (
    'identity','merge','claim_support','conflict','extraction_failure','ranking_anomaly',
    'synthesis','intent','publication','migration','harness_promotion','vetting','taxonomy')),
  state       evaluation.review_state not null default 'open',
  priority    integer not null default 100,
  assignee    text,
  quorum_required integer not null default 1,
  summary     text not null,
  detail      jsonb not null default '{}'::jsonb,
  -- Subject arc: ten enumerable targets, each a real FK.
  candidate_id            uuid references staging.candidate(id) on delete cascade,
  claim_id                uuid references evidence.claim(id) on delete cascade,
  claim_conflict_id       uuid references evidence.claim_conflict(id) on delete cascade,
  entity_merge_id         uuid references corpus.entity_merge(id) on delete cascade,
  record_reconciliation_id uuid references knowledge.record_reconciliation(id) on delete cascade,
  ranking_result_id       uuid references ranking.ranking_result(id) on delete cascade,
  operation_intent_id     uuid references orchestration.operation_intent(id) on delete cascade,
  report_version_id       uuid references research.report_version(id) on delete cascade,
  capability_version_id   uuid references orchestration.capability_version(id) on delete cascade,
  vector_space_version_id uuid references retrieval.vector_space_version(id) on delete cascade,
  subject_kind text generated always as (
    case
      when candidate_id             is not null then 'candidate'
      when claim_id                 is not null then 'claim'
      when claim_conflict_id        is not null then 'claim_conflict'
      when entity_merge_id          is not null then 'entity_merge'
      when record_reconciliation_id is not null then 'record_reconciliation'
      when ranking_result_id        is not null then 'ranking_result'
      when operation_intent_id      is not null then 'operation_intent'
      when report_version_id        is not null then 'report_version'
      when capability_version_id    is not null then 'capability_version'
      when vector_space_version_id  is not null then 'vector_space_version'
    end) stored,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint review_task_exactly_one_subject check (
    num_nonnulls(candidate_id, claim_id, claim_conflict_id, entity_merge_id,
                 record_reconciliation_id, ranking_result_id, operation_intent_id,
                 report_version_id, capability_version_id, vector_space_version_id) = 1)
);

create index review_task_queue_idx on evaluation.review_task (state, task_kind, priority, created_at)
  where state in ('open','claimed','in_review');
create index review_task_subject_idx on evaluation.review_task (subject_kind);

create trigger review_task_set_updated_at
  before update on evaluation.review_task
  for each row execute function util.set_updated_at();

do $$
declare c text;
begin
  foreach c in array array[
    'candidate_id','claim_id','claim_conflict_id','entity_merge_id','record_reconciliation_id',
    'ranking_result_id','operation_intent_id','report_version_id','capability_version_id',
    'vector_space_version_id'
  ] loop
    execute format(
      'create index review_task_%s_idx on evaluation.review_task (%I) where %I is not null', c, c, c);
  end loop;
end;
$$;

create table evaluation.review_decision (
  id             uuid primary key default util.uuidv7(),
  review_task_id uuid not null references evaluation.review_task(id) on delete cascade,
  decision       text not null,
  rationale      text not null,
  decided_by     text not null,
  -- Closing the loop: a reviewer decision becomes a reusable eval label.
  eval_label_id  uuid references evaluation.eval_label(id),
  decided_at     timestamptz not null default now()
);

create index review_decision_task_idx on evaluation.review_decision (review_task_id);

-- Now that review_decision exists, close the reverse link on eval_label.
alter table evaluation.eval_label
  add constraint eval_label_review_decision_fk
  foreign key (review_decision_id) references evaluation.review_decision(id);

commit;
