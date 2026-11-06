-- 0015 | api surface, role grants, and row-level security.
--
-- api is the only schema exposed to applications and agents. It owns no tables:
-- views and SECURITY DEFINER functions only.
--
-- The grant model is what actually enforces "agents never mutate canonical rows".
-- Note that service_role bypasses RLS, so for server-side agents the separation
-- comes from grants; RLS matters for `authenticated` traffic arriving through
-- PostgREST.

begin;

-- ===========================================================================
-- 1. API VIEWS
-- ===========================================================================

-- Current library profile: canonical row + current facts + taxonomy terms.
-- Regular views, not materialized: there is no data yet, and a matview would
-- need a refresh strategy before it earns its keep.
create view api.library_profile as
select
  l.id,
  l.ecosystem,
  l.package_name,
  l.display_name,
  l.description,
  l.primary_language,
  l.homepage_url,
  l.first_released_on,
  l.lifecycle_state,
  lic.license_spdx      as current_license,
  ms.status             as maintenance_status,
  coalesce(tax.terms, '[]'::jsonb) as taxonomy_terms,
  l.created_at,
  l.updated_at
from corpus.library l
left join lateral (
  select f.license_spdx
  from corpus.library_license_fact f
  where f.library_id = l.id and f.valid_to is null and f.lifecycle_state = 'active'
  order by f.valid_from desc limit 1
) lic on true
left join lateral (
  select f.status
  from corpus.library_maintenance_status_fact f
  where f.library_id = l.id and f.valid_to is null and f.lifecycle_state = 'active'
  order by f.valid_from desc limit 1
) ms on true
left join lateral (
  select jsonb_agg(jsonb_build_object('facet', fa.slug, 'term', t.slug, 'label', t.label)) as terms
  from taxonomy.assignment a
  join taxonomy.term t on t.id = a.term_id
  join taxonomy.facet_version fv on fv.id = t.facet_version_id
  join taxonomy.facet fa on fa.id = fv.facet_id
  where a.library_id = l.id and a.valid_to is null
) tax on true
where l.lifecycle_state = 'active';

create view api.mcp_server_profile as
select
  s.id,
  s.name,
  s.description,
  s.registry_id,
  s.ecosystem,
  s.package_name,
  s.distribution_kind,
  s.transport_kinds,
  s.license_spdx,
  s.lifecycle_state,
  reg.status as registry_status,
  (select count(*) from corpus.mcp_server_version v where v.mcp_server_id = s.id) as version_count,
  (select max(v.released_on) from corpus.mcp_server_version v where v.mcp_server_id = s.id) as latest_release,
  s.created_at,
  s.updated_at
from corpus.mcp_server s
left join lateral (
  select f.status
  from corpus.mcp_server_registry_status_fact f
  where f.mcp_server_id = s.id and f.valid_to is null and f.lifecycle_state = 'active'
  order by f.valid_from desc limit 1
) reg on true
where s.lifecycle_state = 'active';

create view api.agent_skill_profile as
select
  k.id, k.name, k.slug, k.distribution, k.description,
  k.skill_format, k.format_version, k.license_spdx, k.lifecycle_state,
  (select max(v.released_on) from corpus.agent_skill_version v where v.agent_skill_id = k.id) as latest_release,
  k.created_at, k.updated_at
from corpus.agent_skill k
where k.lifecycle_state = 'active';

create view api.model_profile as
select
  m.id,
  m.model_slug,
  m.display_name,
  m.family,
  m.modality,
  m.model_kind,
  m.openness,
  o.display_name as provider,
  mv.version_label as latest_version,
  mv.released_on   as latest_released_on,
  mv.context_window_tokens,
  av.availability,
  m.created_at
from corpus.ai_model m
join corpus.organization o on o.id = m.provider_organization_id
left join lateral (
  select v.* from corpus.ai_model_version v
  where v.ai_model_id = m.id
  order by v.released_on desc nulls last limit 1
) mv on true
left join lateral (
  select f.availability from corpus.ai_model_availability_fact f
  where f.ai_model_version_id = mv.id and f.valid_to is null and f.lifecycle_state = 'active'
  order by f.valid_from desc limit 1
) av on true
where m.lifecycle_state = 'active';

-- Claims with their evidence. Verified only by default -- an unverified claim
-- should never reach an application through the default path.
create view api.claim_with_evidence as
select
  c.id            as claim_id,
  c.claim_type,
  c.statement,
  c.status,
  c.created_at,
  coalesce(jsonb_agg(
    jsonb_build_object(
      'link_id',         el.id,
      'role',            el.role,
      'support_verdict', el.support_verdict,
      'locator_id',      el.locator_id,
      'capture_id',      loc.capture_id,
      'source_id',       cap.source_id,
      'canonical_url',   src.canonical_url,
      'captured_at',     cap.captured_at
    ) order by el.created_at
  ) filter (where el.id is not null), '[]'::jsonb) as evidence
from evidence.claim c
left join evidence.claim_evidence_link el on el.claim_id = c.id
left join evidence.locator loc            on loc.id = el.locator_id
left join evidence.source_capture cap     on cap.id = loc.capture_id
left join evidence.source src             on src.id = cap.source_id
where c.status = 'verified'
group by c.id;

-- Knowledge records for app consumption, with scope, assurance and freshness.
create view api.technical_record_search as
select record_kind, id, title, statement, scope, maturity,
       assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at
from (
  select 'technical_problem'::text  as record_kind, id, title, statement, scope, maturity, assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at from knowledge.technical_problem
  union all select 'solution_pattern',        id, title, statement, scope, maturity, assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at from knowledge.solution_pattern
  union all select 'advanced_usage_pattern',  id, title, statement, scope, maturity, assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at from knowledge.advanced_usage_pattern
  union all select 'implementation_example',  id, title, statement, scope, maturity, assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at from knowledge.implementation_example
  union all select 'failure_mode',            id, title, statement, scope, maturity, assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at from knowledge.failure_mode
  union all select 'benchmark_result',        id, title, statement, scope, maturity, assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at from knowledge.benchmark_result
  union all select 'compatibility_constraint',id, title, statement, scope, maturity, assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at from knowledge.compatibility_constraint
  union all select 'operational_practice',    id, title, statement, scope, maturity, assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at from knowledge.operational_practice
  union all select 'security_consideration',  id, title, statement, scope, maturity, assurance_level, confidence, revalidation_state, next_revalidation_at, updated_at from knowledge.security_consideration
) r;

-- Control-plane projection.
create view api.mission_progress as
select
  m.id as mission_id, m.slug, m.goal, m.status, m.started_at, m.ended_at,
  count(w.id)                                         as work_items,
  count(w.id) filter (where w.status = 'succeeded')    as succeeded,
  count(w.id) filter (where w.status = 'failed')       as failed,
  count(w.id) filter (where w.status in ('pending','ready','running')) as outstanding,
  coalesce(sum(u.cost_usd), 0)                         as cost_usd,
  m.budget_cost_usd
from orchestration.mission m
left join orchestration.work_item w on w.mission_id = m.id
left join observability.usage_rollup u on u.mission_id = m.id
group by m.id;

-- The reviewer's queue.
create view api.review_queue as
select id as review_task_id, task_kind, state, priority, assignee,
       summary, subject_kind, quorum_required, created_at, updated_at
from evaluation.review_task
where state in ('open','claimed','in_review');

-- Curriculum freshness: the payoff. A lesson is stale when any record backing it
-- is stale, and this is a query rather than an editorial judgement.
create view api.lesson_freshness as
select
  l.id            as lesson_id,
  l.slug,
  l.title,
  lv.version,
  lv.status,
  count(b.id)                                                          as backing_records,
  count(b.id) filter (where tr.revalidation_state in ('stale','failed')) as stale_records,
  case
    when count(b.id) = 0 then 'unbacked'
    when count(b.id) filter (where tr.revalidation_state in ('stale','failed')) > 0 then 'stale'
    when count(b.id) filter (where tr.revalidation_state = 'due') > 0 then 'due'
    else 'fresh'
  end as freshness
from curriculum.lesson l
join curriculum.lesson_version lv on lv.lesson_id = l.id
left join curriculum.lesson_backed_by b on b.lesson_version_id = lv.id
left join api.technical_record_search tr
       on tr.record_kind = b.record_kind
      and tr.id = coalesce(b.technical_problem_id, b.solution_pattern_id,
                           b.advanced_usage_pattern_id, b.implementation_example_id,
                           b.failure_mode_id, b.benchmark_result_id,
                           b.compatibility_constraint_id, b.operational_practice_id,
                           b.security_consideration_id)
group by l.id, l.slug, l.title, lv.version, lv.status;

-- ===========================================================================
-- 2. API FUNCTIONS
-- ===========================================================================

create or replace function api.leaderboard(p_slug text)
returns table (
  rank integer, entity_kind text, entity_id uuid, score numeric, explanation text
)
language sql stable security definer
set search_path = ''
as $$
  select rr.rank, rr.entity_kind, rr.entity_id, rr.score, rr.explanation
  from ranking.leaderboard lb
  join lateral (
    select le.ranking_run_id from ranking.leaderboard_edition le
    where le.leaderboard_id = lb.id
    order by le.edition_no desc limit 1
  ) latest on true
  join ranking.ranking_result rr on rr.run_id = latest.ranking_run_id
  where lb.slug = p_slug
  order by rr.rank;
$$;

create or replace function api.evidence_packet(p_packet_id uuid)
returns jsonb
language sql stable security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'packet_id', p.id,
    'schema_version', p.packet_schema_version,
    'packet', p.packet,
    'members', coalesce((
      select jsonb_agg(jsonb_build_object(
        'member_kind', pm.member_kind,
        'locators', pm.locators,
        'verification_state', pm.verification_state,
        'freshness', pm.freshness,
        'contradiction_flags', pm.contradiction_flags,
        'coverage_role', pm.coverage_role))
      from retrieval.packet_member pm where pm.packet_id = p.id), '[]'::jsonb))
  from retrieval.evidence_packet p
  where p.id = p_packet_id;
$$;

-- The ONLY write path exposed to agent roles beyond staging. Agents propose;
-- the executor disposes.
create or replace function api.submit_intent(
  p_intent_type     text,
  p_payload         jsonb,
  p_idempotency_key text,
  p_mission_id      uuid default null,
  p_attempt_id      uuid default null,
  p_preconditions   jsonb default '{}'::jsonb
) returns uuid
language plpgsql security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  if not exists (select 1 from orchestration.intent_type t where t.code = p_intent_type) then
    raise exception 'unknown intent_type %', p_intent_type using errcode = 'foreign_key_violation';
  end if;
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception 'payload must be a JSON object' using errcode = 'invalid_parameter_value';
  end if;
  if coalesce(btrim(p_idempotency_key), '') = '' then
    raise exception 'idempotency_key is required' using errcode = 'invalid_parameter_value';
  end if;

  -- Idempotent by contract: resubmitting the same key returns the same intent.
  select id into v_id from orchestration.operation_intent
   where idempotency_key = p_idempotency_key;
  if v_id is not null then
    return v_id;
  end if;

  insert into orchestration.operation_intent
    (intent_type, payload, preconditions, idempotency_key, mission_id, proposed_by_attempt)
  values
    (p_intent_type, p_payload, coalesce(p_preconditions,'{}'::jsonb), p_idempotency_key,
     p_mission_id, p_attempt_id)
  returning id into v_id;

  return v_id;
end;
$$;

-- ===========================================================================
-- 3. GRANTS
-- ===========================================================================

-- Nothing but api is reachable by app or agent roles.
grant usage on schema api to anon, authenticated, service_role, app_reader,
  pipeline_agent, verifier_agent, executor_service, control_plane;

grant select on all tables in schema api to authenticated, service_role, app_reader;
grant execute on function api.leaderboard(text)      to authenticated, service_role, app_reader;
grant execute on function api.evidence_packet(uuid)  to authenticated, service_role, app_reader;
grant execute on function api.submit_intent(text, jsonb, text, uuid, uuid, jsonb)
  to service_role, pipeline_agent, verifier_agent;

alter default privileges in schema api grant select on tables to authenticated, service_role, app_reader;

-- Schema usage for the internal roles that must reach real tables.
grant usage on schema orchestration, evidence, taxonomy, corpus, knowledge, staging,
                      ranking, research, retrieval, evaluation, observability, curriculum, util
  to executor_service;
grant usage on schema staging, evidence, orchestration, observability, corpus, knowledge, util
  to pipeline_agent;
grant usage on schema evidence, corpus, knowledge, orchestration, util
  to verifier_agent;
grant usage on schema orchestration, evaluation, observability, research, util
  to control_plane;

-- executor_service: the only role with DML on canonical data.
grant select, insert, update on all tables in schema corpus, knowledge to executor_service;
grant select, insert, update on all tables in schema evidence, taxonomy   to executor_service;
grant select, insert, update on all tables in schema staging              to executor_service;
grant select, insert          on all tables in schema orchestration       to executor_service;
grant select, insert, update on all tables in schema retrieval, research, curriculum to executor_service;
grant select                  on all tables in schema ranking, evaluation to executor_service;

-- pipeline_agent: broad INSERT on staging, and on the candidate parts of
-- evidence. It may NOT touch corpus or knowledge -- that is the whole point.
grant select, insert, update on all tables in schema staging to pipeline_agent;
grant select on all tables in schema corpus, knowledge       to pipeline_agent;
grant select, insert on evidence.source, evidence.source_capture, evidence.locator,
                        evidence.extraction_signature, evidence.claim,
                        evidence.claim_evidence_link, evidence.degraded_assurance
  to pipeline_agent;
grant select, insert on orchestration.operation_intent to pipeline_agent;
grant select on orchestration.mission, orchestration.work_item, orchestration.attempt,
                orchestration.artifact, orchestration.intent_type
  to pipeline_agent;
grant insert on observability.raw_event, observability.span, observability.trace to pipeline_agent;

-- verifier_agent: reads evidence and canonical data, writes verification only.
grant select on all tables in schema evidence, corpus, knowledge to verifier_agent;
grant insert on evidence.verification_run, evidence.verification_finding,
                evidence.executable_verification, evidence.claim_conflict
  to verifier_agent;
grant select on orchestration.attempt, orchestration.work_item to verifier_agent;

-- control_plane: runs the orchestration and review machinery.
grant select, insert, update on all tables in schema orchestration to control_plane;
grant select, insert, update on all tables in schema evaluation    to control_plane;
grant select, insert on all tables in schema observability          to control_plane;
grant select on all tables in schema research                       to control_plane;
grant execute on function util.ensure_month_partitions(integer)     to control_plane, service_role;

-- Sequences that the granted inserts need.
grant usage, select on all sequences in schema orchestration to control_plane, executor_service;

-- The bounded roles are members of service_role, which is how a service assumes
-- one after connecting; no bounded role is a login role.
grant usage on schema util to pipeline_agent, verifier_agent, control_plane, executor_service;

-- ===========================================================================
-- 4. ROW LEVEL SECURITY
--
-- Enabled on every table in every bounded schema. Policies are deliberately
-- minimal: tenancy columns exist everywhere, but the multi-tenant policy set is
-- deferred. Enabling RLS with no permissive policy denies by default for every
-- non-superuser role that is not BYPASSRLS, which is the safe direction.
-- ===========================================================================
do $$
declare
  r record;
begin
  for r in
    select c.relnamespace::regnamespace::text as sch, c.relname as tbl
    from pg_class c
    where c.relnamespace::regnamespace::text in
          ('orchestration','evidence','taxonomy','corpus','knowledge','staging',
           'ranking','research','retrieval','evaluation','observability','curriculum')
      and c.relkind in ('r','p')
      and not c.relispartition
  loop
    execute format('alter table %I.%I enable row level security', r.sch, r.tbl);
  end loop;
end;
$$;

commit;
