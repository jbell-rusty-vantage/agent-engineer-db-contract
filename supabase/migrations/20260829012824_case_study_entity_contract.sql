begin;

create table corpus.case_study (
  id                     uuid primary key default util.uuidv7(),
  tenant_id              uuid not null default util.default_tenant_id(),
  slug                   text not null,
  title                  text not null,
  case_study_kind        text not null default 'implementation'
    check (case_study_kind in ('implementation','adoption','migration','benchmark','incident','business_outcome','other')),
  subject_organization_id uuid references corpus.organization(id),
  subject_product_id      uuid references corpus.product(id),
  published_on           date,
  source_url             text,
  summary                text,
  structured_outcomes    jsonb not null default '{}'::jsonb,
  lifecycle_state        corpus.lifecycle_state,
  merged_into_id         uuid references corpus.case_study(id),
  created_by_receipt_id  uuid not null references orchestration.operation_receipt(id),
  updated_by_receipt_id  uuid references orchestration.operation_receipt(id),
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  unique (tenant_id, slug)
);

create index case_study_organization_idx on corpus.case_study (subject_organization_id)
  where subject_organization_id is not null;
create index case_study_product_idx on corpus.case_study (subject_product_id)
  where subject_product_id is not null;
create trigger case_study_set_updated_at
  before update on corpus.case_study
  for each row execute function util.set_updated_at();

alter table corpus.case_study enable row level security;
create policy bounded_role_access on corpus.case_study
  as permissive for all
  to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());
grant select, insert, update on corpus.case_study to executor_service;
grant select on corpus.case_study to pipeline_agent, verifier_agent, app_reader;

alter table staging.candidate drop constraint candidate_candidate_kind_check;
alter table staging.candidate add constraint candidate_candidate_kind_check check (candidate_kind in (
  'library','repository','person','organization','paper','video','talk','product','case_study',
  'concept','dataset','benchmark','ai_model','ai_protocol','mcp_server','agent_skill','technical_record'
));

create table staging.candidate_case_study (
  candidate_id    uuid primary key references staging.candidate(id) on delete cascade,
  candidate_kind  text not null default 'case_study' check (candidate_kind = 'case_study'),
  slug            text,
  title           text,
  organization_name text,
  product_name    text,
  published_on    date,
  source_url      text,
  foreign key (candidate_id, candidate_kind) references staging.candidate(id, candidate_kind)
);
alter table staging.candidate_case_study enable row level security;
create policy bounded_role_access on staging.candidate_case_study
  as permissive for all
  to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (true) with check (true);
grant select, insert, update on staging.candidate_case_study to executor_service, pipeline_agent;
grant select on staging.candidate_case_study to verifier_agent;

drop index staging.identity_match_target_idx;
alter table staging.identity_match
  drop constraint identity_match_exactly_one_target,
  drop column target_kind,
  add column case_study_id uuid references corpus.case_study(id);
alter table staging.identity_match add column target_kind text generated always as (
  case
    when organization_id is not null then 'organization'
    when person_id is not null then 'person'
    when library_id is not null then 'library'
    when repository_id is not null then 'repository'
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
  end
) stored;
alter table staging.identity_match add constraint identity_match_exactly_one_target check (
  num_nonnulls(organization_id, person_id, library_id, repository_id, paper_id, talk_id,
    video_id, product_id, case_study_id, concept_id, dataset_id, benchmark_id, ai_model_id,
    ai_protocol_id, mcp_server_id, agent_skill_id) = 1
);
create index identity_match_target_idx on staging.identity_match (target_kind);
create index identity_match_case_study_id_idx on staging.identity_match (case_study_id)
  where case_study_id is not null;

create table evidence.claim_case_study (
  claim_id uuid not null references evidence.claim(id) on delete cascade,
  case_study_id uuid not null references corpus.case_study(id) on delete cascade,
  role_in_claim text not null default 'subject'
    check (role_in_claim in ('subject','object','context','comparison')),
  primary key (claim_id, case_study_id, role_in_claim)
);
create index claim_case_study_target_idx on evidence.claim_case_study (case_study_id);
alter table evidence.claim_case_study enable row level security;
create policy bounded_role_access on evidence.claim_case_study
  as permissive for all
  to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (true) with check (true);
grant select, insert on evidence.claim_case_study to executor_service, pipeline_agent;
grant select on evidence.claim_case_study to verifier_agent, app_reader;

drop index taxonomy.assignment_target_idx;
alter table taxonomy.assignment
  drop constraint assignment_exactly_one_target,
  drop column target_kind,
  add column case_study_id uuid references corpus.case_study(id) on delete cascade;
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
    video_id, product_id, case_study_id, concept_id, ai_model_id, ai_protocol_id, mcp_server_id,
    agent_skill_id, technical_problem_id, solution_pattern_id, advanced_usage_pattern_id,
    failure_mode_id, lesson_id) = 1
);
create index assignment_target_idx on taxonomy.assignment (target_kind);
create index assignment_case_study_id_idx on taxonomy.assignment (case_study_id)
  where case_study_id is not null;

create or replace function taxonomy.enforce_facet_cardinality() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_card text;
  v_facet uuid;
  v_dupes integer;
  v_kind text;
  v_target uuid;
begin
  select f.cardinality, f.id into v_card, v_facet
    from taxonomy.term t
    join taxonomy.facet_version fv on fv.id = t.facet_version_id
    join taxonomy.facet f on f.id = fv.facet_id
   where t.id = new.term_id;
  if v_card <> 'single' then return new; end if;
  select k, i into v_kind, v_target from (values
    ('library_id',new.library_id),('repository_id',new.repository_id),('person_id',new.person_id),
    ('organization_id',new.organization_id),('paper_id',new.paper_id),('talk_id',new.talk_id),
    ('video_id',new.video_id),('product_id',new.product_id),('case_study_id',new.case_study_id),
    ('concept_id',new.concept_id),('ai_model_id',new.ai_model_id),('ai_protocol_id',new.ai_protocol_id),
    ('mcp_server_id',new.mcp_server_id),('agent_skill_id',new.agent_skill_id),
    ('technical_problem_id',new.technical_problem_id),('solution_pattern_id',new.solution_pattern_id),
    ('advanced_usage_pattern_id',new.advanced_usage_pattern_id),('failure_mode_id',new.failure_mode_id),
    ('lesson_id',new.lesson_id)
  ) as t(k,i) where i is not null limit 1;
  execute format(
    'select count(*) from taxonomy.assignment a
       join taxonomy.term t on t.id=a.term_id
       join taxonomy.facet_version fv on fv.id=t.facet_version_id
      where fv.facet_id=$1 and a.valid_to is null and a.%I=$2 and a.id<>$3', v_kind)
    into v_dupes using v_facet, v_target, new.id;
  if v_dupes > 0 then
    raise exception 'facet is single-cardinality; target already holds a current term from it'
      using errcode='unique_violation';
  end if;
  return new;
end;
$$;

drop index ranking.metric_observation_entity_idx;
alter table ranking.metric_observation
  drop constraint metric_observation_exactly_one_entity,
  drop column entity_kind,
  add column case_study_id uuid references corpus.case_study(id);
alter table ranking.metric_observation add column entity_kind text generated always as (
  case
    when library_id is not null then 'library'
    when repository_id is not null then 'repository'
    when person_id is not null then 'person'
    when organization_id is not null then 'organization'
    when paper_id is not null then 'paper'
    when video_id is not null then 'video'
    when talk_id is not null then 'talk'
    when dataset_id is not null then 'dataset'
    when benchmark_id is not null then 'benchmark'
    when ai_model_id is not null then 'ai_model'
    when ai_model_version_id is not null then 'ai_model_version'
    when mcp_server_id is not null then 'mcp_server'
    when agent_skill_id is not null then 'agent_skill'
    when product_id is not null then 'product'
    when case_study_id is not null then 'case_study'
  end
) stored;
alter table ranking.metric_observation add constraint metric_observation_exactly_one_entity check (
  num_nonnulls(library_id, repository_id, person_id, organization_id, paper_id, video_id,
    talk_id, dataset_id, benchmark_id, ai_model_id, ai_model_version_id, mcp_server_id,
    agent_skill_id, product_id, case_study_id) = 1
);
create index metric_observation_entity_idx on ranking.metric_observation (entity_kind, observed_at desc);
create index metric_observation_case_study_id_idx on ranking.metric_observation (case_study_id, observed_at desc)
  where case_study_id is not null;

commit;
