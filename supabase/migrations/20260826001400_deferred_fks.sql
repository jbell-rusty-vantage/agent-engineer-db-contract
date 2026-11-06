-- 0014 | Deferred cross-schema wiring.
--
-- This slice exists because Fable's original 0001-0014 ordering contained five
-- forward references: columns whose targets are created in a later migration.
-- Rather than reorder the schemas (which cannot be done -- taxonomy.assignment
-- points into four schemas that all come after it), the columns were created
-- bare and are given their constraints here, once every target exists.
--
-- Three things land in this file:
--   1. The FKs for the forward-referencing columns from 0002, 0003, 0004,
--      0006 and 0007.
--   2. taxonomy.assignment, whose 18-column exclusive arc spans corpus,
--      knowledge and curriculum.
--   3. The 14 evidence.claim_<entity> association tables, which FK into corpus.

begin;

-- ---------------------------------------------------------------------------
-- 1. Forward-reference FKs.
-- ---------------------------------------------------------------------------

-- 0002 orchestration -> ranking (0008)
alter table orchestration.mission
  add constraint mission_selection_fk
  foreign key (selection_id) references ranking.selection(id);

-- 0002 orchestration -> corpus (0005)
alter table orchestration.capability
  add constraint capability_packages_mcp_server_version_fk
  foreign key (packages_mcp_server_version_id) references corpus.mcp_server_version(id);

-- 0002 orchestration -> evaluation (0011)
alter table orchestration.capability_version
  add constraint capability_version_eval_suite_fk
  foreign key (eval_suite_id) references evaluation.eval_dataset(id);

-- 0003 evidence -> evaluation (0011)
alter table evidence.degraded_assurance
  add constraint degraded_assurance_review_task_fk
  foreign key (approved_by_review_task_id) references evaluation.review_task(id);

alter table evidence.conflict_reconciliation
  add constraint conflict_reconciliation_review_task_fk
  foreign key (review_task_id) references evaluation.review_task(id);

-- 0004 taxonomy -> evaluation (0011)
alter table taxonomy.facet_version
  add constraint facet_version_review_task_fk
  foreign key (approved_by_review_task_id) references evaluation.review_task(id);

-- 0005 corpus -> evaluation (0011)
alter table corpus.entity_merge
  add constraint entity_merge_review_task_fk
  foreign key (review_task_id) references evaluation.review_task(id);

-- 0006 knowledge -> evaluation (0011)
alter table knowledge.record_reconciliation
  add constraint record_reconciliation_review_task_fk
  foreign key (review_task_id) references evaluation.review_task(id);

-- 0007 staging -> evaluation (0011)
alter table staging.vetting_decision
  add constraint vetting_decision_review_task_fk
  foreign key (review_task_id) references evaluation.review_task(id);

-- 0008 ranking -> itself (run_id was left bare to avoid an ordering cycle)
alter table ranking.metric_observation
  add constraint metric_observation_run_fk
  foreign key (run_id) references ranking.ranking_run(id);

-- 0009 research -> evaluation (0011)
alter table research.report_version
  add constraint report_version_consistency_eval_fk
  foreign key (synthesis_consistency_eval_id) references evaluation.eval_run(id);

-- 0010 retrieval -> evaluation (0011)
alter table retrieval.vector_space_version
  add constraint vector_space_version_promotion_gate_fk
  foreign key (promotion_gate_eval_id) references evaluation.eval_run(id);

alter table retrieval.vector_item
  add constraint vector_item_generation_run_fk
  foreign key (generation_run_id) references evaluation.eval_run(id);

-- ---------------------------------------------------------------------------
-- 2. taxonomy.assignment
--
-- The arc that could not exist in 0004. Eighteen enumerable targets spanning
-- corpus, knowledge and curriculum, each a real FK, with exactly-one enforced
-- and a generated target_kind for filtering.
-- ---------------------------------------------------------------------------
create table taxonomy.assignment (
  id      uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  term_id uuid not null references taxonomy.term(id) on delete cascade,
  -- corpus targets
  library_id      uuid references corpus.library(id)      on delete cascade,
  repository_id   uuid references corpus.repository(id)   on delete cascade,
  person_id       uuid references corpus.person(id)       on delete cascade,
  organization_id uuid references corpus.organization(id) on delete cascade,
  paper_id        uuid references corpus.paper(id)        on delete cascade,
  talk_id         uuid references corpus.talk(id)         on delete cascade,
  video_id        uuid references corpus.video(id)        on delete cascade,
  product_id      uuid references corpus.product(id)      on delete cascade,
  concept_id      uuid references corpus.concept(id)      on delete cascade,
  ai_model_id     uuid references corpus.ai_model(id)     on delete cascade,
  ai_protocol_id  uuid references corpus.ai_protocol(id)  on delete cascade,
  mcp_server_id   uuid references corpus.mcp_server(id)   on delete cascade,
  agent_skill_id  uuid references corpus.agent_skill(id)  on delete cascade,
  -- knowledge targets
  technical_problem_id      uuid references knowledge.technical_problem(id)      on delete cascade,
  solution_pattern_id       uuid references knowledge.solution_pattern(id)       on delete cascade,
  advanced_usage_pattern_id uuid references knowledge.advanced_usage_pattern(id) on delete cascade,
  failure_mode_id           uuid references knowledge.failure_mode(id)           on delete cascade,
  -- curriculum target
  lesson_id       uuid references curriculum.lesson(id) on delete cascade,
  target_kind text generated always as (
    case
      when library_id      is not null then 'library'
      when repository_id   is not null then 'repository'
      when person_id       is not null then 'person'
      when organization_id is not null then 'organization'
      when paper_id        is not null then 'paper'
      when talk_id         is not null then 'talk'
      when video_id        is not null then 'video'
      when product_id      is not null then 'product'
      when concept_id      is not null then 'concept'
      when ai_model_id     is not null then 'ai_model'
      when ai_protocol_id  is not null then 'ai_protocol'
      when mcp_server_id   is not null then 'mcp_server'
      when agent_skill_id  is not null then 'agent_skill'
      when technical_problem_id      is not null then 'technical_problem'
      when solution_pattern_id       is not null then 'solution_pattern'
      when advanced_usage_pattern_id is not null then 'advanced_usage_pattern'
      when failure_mode_id           is not null then 'failure_mode'
      when lesson_id       is not null then 'lesson'
    end) stored,
  method     text not null check (method in ('rule','model','human')),
  confidence corpus.confidence,
  provenance_claim_id uuid references evidence.claim(id),
  review_task_id      uuid references evaluation.review_task(id),
  valid_from timestamptz not null default now(),
  valid_to   timestamptz,
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  constraint assignment_exactly_one_target check (
    num_nonnulls(library_id, repository_id, person_id, organization_id, paper_id, talk_id,
                 video_id, product_id, concept_id, ai_model_id, ai_protocol_id, mcp_server_id,
                 agent_skill_id, technical_problem_id, solution_pattern_id,
                 advanced_usage_pattern_id, failure_mode_id, lesson_id) = 1)
);

create index assignment_term_idx   on taxonomy.assignment (term_id);
create index assignment_target_idx on taxonomy.assignment (target_kind);
create index assignment_current_idx on taxonomy.assignment (term_id) where valid_to is null;

do $$
declare c text;
begin
  foreach c in array array[
    'library_id','repository_id','person_id','organization_id','paper_id','talk_id','video_id',
    'product_id','concept_id','ai_model_id','ai_protocol_id','mcp_server_id','agent_skill_id',
    'technical_problem_id','solution_pattern_id','advanced_usage_pattern_id','failure_mode_id',
    'lesson_id'
  ] loop
    execute format(
      'create index assignment_%s_idx on taxonomy.assignment (%I) where %I is not null', c, c, c);
  end loop;
end;
$$;

-- A single-cardinality facet may hold only one current term per target. Enforced
-- here rather than trusted to the executor.
create or replace function taxonomy.enforce_facet_cardinality() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_card text;
  v_facet uuid;
  v_dupes integer;
  v_kind text;
begin
  select f.cardinality, f.id into v_card, v_facet
    from taxonomy.term t
    join taxonomy.facet_version fv on fv.id = t.facet_version_id
    join taxonomy.facet f on f.id = fv.facet_id
   where t.id = new.term_id;

  if v_card <> 'single' then
    return new;
  end if;

  -- Derive the target column without reading the generated column, which is not
  -- populated during a BEFORE trigger.
  select k into v_kind from (values
    ('library_id', new.library_id), ('repository_id', new.repository_id),
    ('person_id', new.person_id), ('organization_id', new.organization_id),
    ('paper_id', new.paper_id), ('talk_id', new.talk_id), ('video_id', new.video_id),
    ('product_id', new.product_id), ('concept_id', new.concept_id),
    ('ai_model_id', new.ai_model_id), ('ai_protocol_id', new.ai_protocol_id),
    ('mcp_server_id', new.mcp_server_id), ('agent_skill_id', new.agent_skill_id),
    ('technical_problem_id', new.technical_problem_id),
    ('solution_pattern_id', new.solution_pattern_id),
    ('advanced_usage_pattern_id', new.advanced_usage_pattern_id),
    ('failure_mode_id', new.failure_mode_id), ('lesson_id', new.lesson_id)
  ) as t(k, i) where i is not null limit 1;

  execute format(
    'select count(*) from taxonomy.assignment a
       join taxonomy.term t on t.id = a.term_id
       join taxonomy.facet_version fv on fv.id = t.facet_version_id
      where fv.facet_id = $1 and a.valid_to is null and a.%I = $2 and a.id <> $3', v_kind)
    into v_dupes
    using v_facet,
          coalesce(new.library_id, new.repository_id, new.person_id, new.organization_id,
                   new.paper_id, new.talk_id, new.video_id, new.product_id, new.concept_id,
                   new.ai_model_id, new.ai_protocol_id, new.mcp_server_id, new.agent_skill_id,
                   new.technical_problem_id, new.solution_pattern_id,
                   new.advanced_usage_pattern_id, new.failure_mode_id, new.lesson_id),
          new.id;

  if v_dupes > 0 then
    raise exception 'facet is single-cardinality; target already holds a current term from it'
      using errcode = 'unique_violation';
  end if;
  return new;
end;
$$;

create trigger assignment_facet_cardinality
  before insert or update on taxonomy.assignment
  for each row execute function taxonomy.enforce_facet_cardinality();

-- ---------------------------------------------------------------------------
-- 3. Claim <-> entity association tables.
--
-- Per-type join tables, per Fable section 9: highest fidelity, each with a role
-- in the claim. These could not live in 0003 because corpus comes later.
-- ---------------------------------------------------------------------------
do $$
declare
  spec record;
begin
  for spec in
    select * from (values
      ('claim_library',              'corpus',    'library',              'library_id'),
      ('claim_repository',           'corpus',    'repository',           'repository_id'),
      ('claim_person',               'corpus',    'person',               'person_id'),
      ('claim_organization',         'corpus',    'organization',         'organization_id'),
      ('claim_paper',                'corpus',    'paper',                'paper_id'),
      ('claim_talk',                 'corpus',    'talk',                 'talk_id'),
      ('claim_video',                'corpus',    'video',                'video_id'),
      ('claim_product',              'corpus',    'product',              'product_id'),
      ('claim_concept',              'corpus',    'concept',              'concept_id'),
      ('claim_dataset',              'corpus',    'dataset',              'dataset_id'),
      ('claim_benchmark',            'corpus',    'benchmark',            'benchmark_id'),
      ('claim_ai_model_version',     'corpus',    'ai_model_version',     'ai_model_version_id'),
      ('claim_mcp_server_version',   'corpus',    'mcp_server_version',   'mcp_server_version_id'),
      ('claim_agent_skill_version',  'corpus',    'agent_skill_version',  'agent_skill_version_id'),
      ('claim_protocol_version',     'corpus',    'ai_protocol_version',  'ai_protocol_version_id')
    ) as t(tbl, target_schema, target_table, col)
  loop
    execute format($f$
      create table evidence.%I (
        claim_id      uuid not null references evidence.claim(id) on delete cascade,
        %I            uuid not null references %I.%I(id) on delete cascade,
        role_in_claim text not null default 'subject'
          check (role_in_claim in ('subject','object','context','qualifier')),
        created_at    timestamptz not null default now(),
        primary key (claim_id, %I, role_in_claim)
      )$f$, spec.tbl, spec.col, spec.target_schema, spec.target_table, spec.col);

    execute format(
      'create index %I_target_idx on evidence.%I (%I)', spec.tbl, spec.tbl, spec.col);
  end loop;
end;
$$;

-- Technical records get one arc table rather than nine join tables, since the
-- claim-to-record link carries no per-type properties.
create table evidence.claim_technical_record (
  id       uuid primary key default util.uuidv7(),
  claim_id uuid not null references evidence.claim(id) on delete cascade,
  technical_problem_id      uuid references knowledge.technical_problem(id)      on delete cascade,
  solution_pattern_id       uuid references knowledge.solution_pattern(id)       on delete cascade,
  advanced_usage_pattern_id uuid references knowledge.advanced_usage_pattern(id) on delete cascade,
  implementation_example_id uuid references knowledge.implementation_example(id) on delete cascade,
  failure_mode_id           uuid references knowledge.failure_mode(id)           on delete cascade,
  benchmark_result_id       uuid references knowledge.benchmark_result(id)       on delete cascade,
  compatibility_constraint_id uuid references knowledge.compatibility_constraint(id) on delete cascade,
  operational_practice_id   uuid references knowledge.operational_practice(id)   on delete cascade,
  security_consideration_id uuid references knowledge.security_consideration(id) on delete cascade,
  record_kind text generated always as (
    case
      when technical_problem_id       is not null then 'technical_problem'
      when solution_pattern_id        is not null then 'solution_pattern'
      when advanced_usage_pattern_id  is not null then 'advanced_usage_pattern'
      when implementation_example_id  is not null then 'implementation_example'
      when failure_mode_id            is not null then 'failure_mode'
      when benchmark_result_id        is not null then 'benchmark_result'
      when compatibility_constraint_id is not null then 'compatibility_constraint'
      when operational_practice_id    is not null then 'operational_practice'
      when security_consideration_id  is not null then 'security_consideration'
    end) stored,
  role_in_claim text not null default 'subject'
    check (role_in_claim in ('subject','object','context','qualifier')),
  created_at timestamptz not null default now(),
  constraint claim_technical_record_exactly_one check (
    num_nonnulls(technical_problem_id, solution_pattern_id, advanced_usage_pattern_id,
                 implementation_example_id, failure_mode_id, benchmark_result_id,
                 compatibility_constraint_id, operational_practice_id,
                 security_consideration_id) = 1)
);

create index claim_technical_record_claim_idx on evidence.claim_technical_record (claim_id);
create index claim_technical_record_kind_idx  on evidence.claim_technical_record (record_kind);

commit;
