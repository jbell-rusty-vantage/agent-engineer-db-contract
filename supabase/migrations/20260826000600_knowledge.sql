-- 0006 | knowledge: the treasure domain.
--
-- Verified technical records. These differ from corpus entities in ways that
-- earn a separate schema: per-record scoping, revalidation state, reconciliation,
-- and assurance levels. Curriculum and retrieval read this heavily; identity
-- resolution reads corpus.
--
-- Every record carries the same scoping/assurance block, so freshness is a query
-- over revalidation_state rather than an editorial guess.

begin;

create type knowledge.maturity as enum
  ('experimental','emerging','established','declining');

create type knowledge.revalidation_state as enum
  ('fresh','due','in_progress','stale','failed','retired');

-- The assurance ladder, as a lookup so rungs can be added without a migration.
create table knowledge.assurance_level (
  code        text primary key,
  rank        integer not null unique,
  description text not null
);

insert into knowledge.assurance_level (code, rank, description) values
  ('asserted',               10, 'Stated by a source, not otherwise checked'),
  ('source_inspection',      20, 'Confirmed by reading primary source or code'),
  ('documentation_confirmed',30, 'Confirmed against official documentation'),
  ('local_execution',        40, 'Reproduced by executing code locally'),
  ('integration_tested',     50, 'Reproduced in an integration environment'),
  ('production_confirmation',60, 'Confirmed in a production system')
on conflict (code) do nothing;

-- ---------------------------------------------------------------------------
-- The nine record types. Shared block first, type-specific columns after.
-- ---------------------------------------------------------------------------

create table knowledge.technical_problem (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  record_schema_version int not null default 1,
  scope                 jsonb not null default '{}'::jsonb,
  maturity              knowledge.maturity,
  assurance_level       text not null default 'asserted' references knowledge.assurance_level(code),
  confidence            corpus.confidence,
  revalidation_policy_id uuid references evidence.revalidation_policy(id),
  revalidation_state    knowledge.revalidation_state not null default 'fresh',
  next_revalidation_at  timestamptz,
  provenance_claim_id   uuid references evidence.claim(id),
  superseded_by_id      uuid references knowledge.technical_problem(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- type-specific
  problem_class         text,
  symptoms              text[] not null default '{}',
  context_of_occurrence text
);

create table knowledge.solution_pattern (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  record_schema_version int not null default 1,
  scope                 jsonb not null default '{}'::jsonb,
  maturity              knowledge.maturity,
  assurance_level       text not null default 'asserted' references knowledge.assurance_level(code),
  confidence            corpus.confidence,
  revalidation_policy_id uuid references evidence.revalidation_policy(id),
  revalidation_state    knowledge.revalidation_state not null default 'fresh',
  next_revalidation_at  timestamptz,
  provenance_claim_id   uuid references evidence.claim(id),
  superseded_by_id      uuid references knowledge.solution_pattern(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- type-specific
  approach_summary      text,
  benefits              text,
  tradeoffs             text,
  alternatives_summary  text
);

create table knowledge.advanced_usage_pattern (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  record_schema_version int not null default 1,
  scope                 jsonb not null default '{}'::jsonb,
  maturity              knowledge.maturity,
  assurance_level       text not null default 'asserted' references knowledge.assurance_level(code),
  confidence            corpus.confidence,
  revalidation_policy_id uuid references evidence.revalidation_policy(id),
  revalidation_state    knowledge.revalidation_state not null default 'fresh',
  next_revalidation_at  timestamptz,
  provenance_claim_id   uuid references evidence.claim(id),
  superseded_by_id      uuid references knowledge.advanced_usage_pattern(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- type-specific
  library_id            uuid references corpus.library(id),
  api_surface           text,
  minimal_example_artifact_id uuid references orchestration.artifact(id),
  anti_pattern          boolean not null default false
);

create table knowledge.implementation_example (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  record_schema_version int not null default 1,
  scope                 jsonb not null default '{}'::jsonb,
  maturity              knowledge.maturity,
  assurance_level       text not null default 'asserted' references knowledge.assurance_level(code),
  confidence            corpus.confidence,
  revalidation_policy_id uuid references evidence.revalidation_policy(id),
  revalidation_state    knowledge.revalidation_state not null default 'fresh',
  next_revalidation_at  timestamptz,
  provenance_claim_id   uuid references evidence.claim(id),
  superseded_by_id      uuid references knowledge.implementation_example(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- type-specific
  repository_id         uuid references corpus.repository(id),
  commit_sha            text,
  path                  text,
  symbol                text,
  runnable              boolean not null default false,
  exec_verification_id  uuid references evidence.executable_verification(id)
);

create table knowledge.failure_mode (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  record_schema_version int not null default 1,
  scope                 jsonb not null default '{}'::jsonb,
  maturity              knowledge.maturity,
  assurance_level       text not null default 'asserted' references knowledge.assurance_level(code),
  confidence            corpus.confidence,
  revalidation_policy_id uuid references evidence.revalidation_policy(id),
  revalidation_state    knowledge.revalidation_state not null default 'fresh',
  next_revalidation_at  timestamptz,
  provenance_claim_id   uuid references evidence.claim(id),
  superseded_by_id      uuid references knowledge.failure_mode(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- type-specific
  trigger_conditions    text,
  blast_radius          text,
  detection             text,
  mitigation_summary    text
);

create table knowledge.benchmark_result (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  record_schema_version int not null default 1,
  scope                 jsonb not null default '{}'::jsonb,
  maturity              knowledge.maturity,
  assurance_level       text not null default 'asserted' references knowledge.assurance_level(code),
  confidence            corpus.confidence,
  revalidation_policy_id uuid references evidence.revalidation_policy(id),
  revalidation_state    knowledge.revalidation_state not null default 'fresh',
  next_revalidation_at  timestamptz,
  provenance_claim_id   uuid references evidence.claim(id),
  superseded_by_id      uuid references knowledge.benchmark_result(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- type-specific
  benchmark_id          uuid not null references corpus.benchmark(id),
  methodology           text,
  reproduction_state    text check (reproduction_state in ('unreproduced','reproduced','failed_to_reproduce','disputed'))
);

create table knowledge.compatibility_constraint (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  record_schema_version int not null default 1,
  scope                 jsonb not null default '{}'::jsonb,
  maturity              knowledge.maturity,
  assurance_level       text not null default 'asserted' references knowledge.assurance_level(code),
  confidence            corpus.confidence,
  revalidation_policy_id uuid references evidence.revalidation_policy(id),
  revalidation_state    knowledge.revalidation_state not null default 'fresh',
  next_revalidation_at  timestamptz,
  provenance_claim_id   uuid references evidence.claim(id),
  superseded_by_id      uuid references knowledge.compatibility_constraint(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- type-specific
  constraint_kind       text check (constraint_kind in ('version','platform','protocol','runtime','license')),
  machine_readable_rule jsonb
);

create table knowledge.operational_practice (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  record_schema_version int not null default 1,
  scope                 jsonb not null default '{}'::jsonb,
  maturity              knowledge.maturity,
  assurance_level       text not null default 'asserted' references knowledge.assurance_level(code),
  confidence            corpus.confidence,
  revalidation_policy_id uuid references evidence.revalidation_policy(id),
  revalidation_state    knowledge.revalidation_state not null default 'fresh',
  next_revalidation_at  timestamptz,
  provenance_claim_id   uuid references evidence.claim(id),
  superseded_by_id      uuid references knowledge.operational_practice(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- type-specific
  practice_domain       text check (practice_domain in ('deploy','observe','cost','scale','secure','test')),
  applicability         text
);

create table knowledge.security_consideration (
  id                    uuid primary key default util.uuidv7(),
  tenant_id             uuid not null default util.default_tenant_id(),
  title                 text not null,
  statement             text not null,
  structured            jsonb,
  record_schema_version int not null default 1,
  scope                 jsonb not null default '{}'::jsonb,
  maturity              knowledge.maturity,
  assurance_level       text not null default 'asserted' references knowledge.assurance_level(code),
  confidence            corpus.confidence,
  revalidation_policy_id uuid references evidence.revalidation_policy(id),
  revalidation_state    knowledge.revalidation_state not null default 'fresh',
  next_revalidation_at  timestamptz,
  provenance_claim_id   uuid references evidence.claim(id),
  superseded_by_id      uuid references knowledge.security_consideration(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  -- type-specific
  severity              text check (severity in ('info','low','medium','high','critical')),
  cve_ids               text[] not null default '{}',
  affected_surface      text
);

-- ---------------------------------------------------------------------------
-- Relationships between records, and from records into corpus.
-- ---------------------------------------------------------------------------

create table knowledge.library_addresses_problem (
  id uuid primary key default util.uuidv7(),
  library_id           uuid not null references corpus.library(id) on delete cascade,
  technical_problem_id uuid not null references knowledge.technical_problem(id) on delete cascade,
  library_version_range text,
  effectiveness        text check (effectiveness in ('complete','partial','workaround','ineffective')),
  caveats              text,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (library_id, technical_problem_id)
);

create table knowledge.problem_solved_by_solution (
  id uuid primary key default util.uuidv7(),
  technical_problem_id uuid not null references knowledge.technical_problem(id) on delete cascade,
  solution_pattern_id  uuid not null references knowledge.solution_pattern(id)  on delete cascade,
  conditions           text,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (technical_problem_id, solution_pattern_id)
);

create table knowledge.solution_applies_under_constraint (
  id uuid primary key default util.uuidv7(),
  solution_pattern_id        uuid not null references knowledge.solution_pattern(id) on delete cascade,
  compatibility_constraint_id uuid not null references knowledge.compatibility_constraint(id) on delete cascade,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (solution_pattern_id, compatibility_constraint_id)
);

create table knowledge.implementation_demonstrates_pattern (
  id uuid primary key default util.uuidv7(),
  implementation_example_id uuid not null references knowledge.implementation_example(id) on delete cascade,
  solution_pattern_id       uuid references knowledge.solution_pattern(id) on delete cascade,
  advanced_usage_pattern_id uuid references knowledge.advanced_usage_pattern(id) on delete cascade,
  fidelity text check (fidelity in ('canonical','representative','partial')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  constraint implementation_demonstrates_one_pattern
    check (num_nonnulls(solution_pattern_id, advanced_usage_pattern_id) = 1)
);

create table knowledge.repository_contains_implementation (
  id uuid primary key default util.uuidv7(),
  repository_id             uuid not null references corpus.repository(id) on delete cascade,
  implementation_example_id uuid not null references knowledge.implementation_example(id) on delete cascade,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (repository_id, implementation_example_id)
);

create table knowledge.paper_supports_solution (
  id uuid primary key default util.uuidv7(),
  paper_id            uuid not null references corpus.paper(id) on delete cascade,
  solution_pattern_id uuid not null references knowledge.solution_pattern(id) on delete cascade,
  support_strength    text check (support_strength in ('strong','moderate','weak','contested')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (paper_id, solution_pattern_id)
);

create table knowledge.failure_mode_affects_library_version (
  id uuid primary key default util.uuidv7(),
  failure_mode_id uuid not null references knowledge.failure_mode(id) on delete cascade,
  library_id      uuid not null references corpus.library(id) on delete cascade,
  affected_range  text,
  fixed_in        text,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (failure_mode_id, library_id)
);

create table knowledge.failure_mode_affects_mcp_server (
  id uuid primary key default util.uuidv7(),
  failure_mode_id uuid not null references knowledge.failure_mode(id) on delete cascade,
  mcp_server_id   uuid not null references corpus.mcp_server(id) on delete cascade,
  affected_range  text,
  fixed_in        text,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (failure_mode_id, mcp_server_id)
);

create table knowledge.benchmark_compares_libraries (
  id uuid primary key default util.uuidv7(),
  benchmark_result_id uuid not null references knowledge.benchmark_result(id) on delete cascade,
  library_id          uuid not null references corpus.library(id) on delete cascade,
  position            integer,
  score               numeric,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (benchmark_result_id, library_id)
);

create table knowledge.talk_explains_pattern (
  id uuid primary key default util.uuidv7(),
  talk_id                   uuid not null references corpus.talk(id) on delete cascade,
  solution_pattern_id       uuid references knowledge.solution_pattern(id) on delete cascade,
  advanced_usage_pattern_id uuid references knowledge.advanced_usage_pattern(id) on delete cascade,
  depth text check (depth in ('mention','section','dedicated')),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  constraint talk_explains_one_pattern
    check (num_nonnulls(solution_pattern_id, advanced_usage_pattern_id) = 1)
);

create table knowledge.solution_uses_protocol_version (
  id uuid primary key default util.uuidv7(),
  solution_pattern_id    uuid not null references knowledge.solution_pattern(id) on delete cascade,
  ai_protocol_version_id uuid not null references corpus.ai_protocol_version(id) on delete cascade,
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  confidence corpus.confidence,
  lifecycle_state corpus.lifecycle_state,
  provenance_claim_id uuid references evidence.claim(id),
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  unique (solution_pattern_id, ai_protocol_version_id)
);

-- ---------------------------------------------------------------------------
-- Reconciliation: two records describing the same thing are merged, kept
-- separate, or scoped apart. The decision is recorded, never implicit.
-- ---------------------------------------------------------------------------
create table knowledge.record_reconciliation (
  id            uuid primary key default util.uuidv7(),
  record_kind   text not null check (record_kind in (
    'technical_problem','solution_pattern','advanced_usage_pattern','implementation_example',
    'failure_mode','benchmark_result','compatibility_constraint','operational_practice',
    'security_consideration')),
  surviving_id  uuid not null,
  merged_id     uuid not null,
  outcome       text not null check (outcome in ('merged','kept_separate','scoped')),
  rationale     text not null,
  -- forward reference: evaluation.review_task (0011), FK added in 0014
  review_task_id uuid,
  created_by_receipt_id uuid not null references orchestration.operation_receipt(id),
  created_at    timestamptz not null default now(),
  constraint record_reconciliation_distinct check (surviving_id <> merged_id)
);

create index record_reconciliation_merged_idx
  on knowledge.record_reconciliation (record_kind, merged_id);

-- ---------------------------------------------------------------------------
-- updated_at triggers, and the indexes that make freshness cheap to query.
-- ---------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'technical_problem','solution_pattern','advanced_usage_pattern','implementation_example',
    'failure_mode','benchmark_result','compatibility_constraint','operational_practice',
    'security_consideration'
  ] loop
    execute format(
      'create trigger %I_set_updated_at before update on knowledge.%I
         for each row execute function util.set_updated_at()', t, t);
    -- Curriculum freshness is a query over these two columns, so index them.
    execute format(
      'create index %I_revalidation_idx on knowledge.%I (revalidation_state, next_revalidation_at)', t, t);
    execute format(
      'create index %I_assurance_idx on knowledge.%I (assurance_level)', t, t);
  end loop;
end;
$$;

commit;
