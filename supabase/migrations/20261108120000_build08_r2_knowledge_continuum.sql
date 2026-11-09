-- Build 08 R2: knowledge continuum (recommendation R2, accepted 2026-11-08; loop 1 ran 2026-11-08/09 on disposable-aieng-build04).
-- One decisive migration: catalog/guidance/verification/acquisition namespaces, typed units + census + diffs + digests + assertion mappings,
-- one retrieval stack (lens, source tier, facets, both space layouts), L1 api views and L2 named queries, product API on the same stack.
-- Assembled from supabase/drafts/part1..part4 plus the loop-1 fixups 1-5 (dispatch_command retire, trigram 0.3, guard, modules_using_software, reader grants + talk linkage, claim candidate/conflict views).
begin;
-- Build 08 R2 draft (lab only): knowledge continuum. Part 1: renames, merges and retirements.
-- Recommendation R2 accepted 2026-11-08 (BUILD-08-KNOWLEDGE-LOOP.md §12). Applied only to disposable-aieng-build04.
-- Every knowledge-side table was empty in the lab at head 20261105010300, so merges and drops lose no rows.

-- ---------------------------------------------------------------------------------------------- 1. corpus -> catalog
alter schema corpus rename to catalog;
comment on schema catalog is 'Industry identities: one entity row per thing (kind + validated attributes), aliases, identifiers, merges, one relationship table, works (paper/talk/media/story/case study).';
update taxonomy.entity_kind set canonical_schema = 'catalog';

-- function bodies are text; rewrite every body that names the old schema
do $$
declare r record; def text;
begin
  for r in select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
           where p.prokind = 'f' and p.prosrc like '%corpus.%'
             and n.nspname not in ('pg_catalog','information_schema','extensions','auth','storage','realtime','vault','graphql','graphql_public','pgsodium','research_private','research','knowledge','ranking','provenance')
  loop
    def := replace(pg_get_functiondef(r.oid), 'corpus.', 'catalog.');
    execute def;
  end loop;
end $$;

-- ---------------------------------------------------------------------------------------------- 2. verification (acts 4-5) and the research retirement
create schema if not exists verification;
comment on schema verification is 'Evidence acts 4-5: verification observations and use decisions admitted into this domain store (Knowledge Services is the shared engine; this is the admission ledger).';
alter table research.use_admission set schema verification;
alter function research.assert_admitted_use(uuid, text, text, bigint, text) set schema verification;
alter function research.require_receipt_admission() set schema verification;
alter function research.guard_use_admission() set schema verification;
do $$
declare r record; def text;
begin
  for r in select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
           where p.prokind = 'f' and p.prosrc like '%research.%'
             and n.nspname in ('verification','evidence','retrieval','orchestration','api','temporal','content','catalog','taxonomy','knowledge_service','evaluation')
  loop
    def := replace(pg_get_functiondef(r.oid), 'research.use_admission', 'verification.use_admission');
    def := replace(def, 'research.assert_admitted_use', 'verification.assert_admitted_use');
    def := replace(def, 'research.guard_use_admission', 'verification.guard_use_admission');
    execute def;
  end loop;
end $$;
-- review_task loses its report/ranking/reconciliation subjects (those families retire); subject_kind is regenerated
drop view api.review_queue;
alter table evaluation.review_task drop column subject_kind;
alter table evaluation.review_task drop constraint review_task_exactly_one_subject;
alter table evaluation.review_task drop column report_version_id, drop column ranking_result_id, drop column record_reconciliation_id;
alter table evaluation.review_task add column subject_kind text generated always as (
  case when candidate_id is not null then 'candidate' when claim_id is not null then 'claim' when claim_conflict_id is not null then 'claim_conflict'
       when entity_merge_id is not null then 'entity_merge' when operation_intent_id is not null then 'operation_intent'
       when capability_version_id is not null then 'capability_version' when vector_space_version_id is not null then 'vector_space_version' end) stored;
alter table evaluation.review_task add constraint review_task_exactly_one_subject
  check (num_nonnulls(candidate_id, claim_id, claim_conflict_id, entity_merge_id, operation_intent_id, capability_version_id, vector_space_version_id) = 1);
create view api.review_queue as select * from evaluation.review_task;
grant select on api.review_queue to authenticated, service_role, app_reader, executor_service, pipeline_agent, verifier_agent, control_plane;
drop schema research cascade;

-- ---------------------------------------------------------------------------------------------- 3. provenance, public starter/factory families, research_private
drop schema provenance cascade;
drop schema research_private cascade;
drop function if exists catalog.import_research_starter_catalog(jsonb);
do $$
declare r record;
begin
  for r in select c.relname from pg_class c where c.relnamespace = 'public'::regnamespace and c.relkind in ('r','p','v','m')
           and (c.relname like 'research\_%' or c.relname like 'factory\_%') loop
    execute format('drop table if exists public.%I cascade', r.relname);
  end loop;
end $$;
drop function if exists public.protect_factory_episode_identity_and_terminal() cascade;
do $$
declare r record;
begin
  for r in select p.oid::regprocedure::text as sig from pg_proc p where p.pronamespace = 'public'::regnamespace
           and (p.proname like 'research\_%' or p.proname like 'factory\_%' or p.proname like '%pre\_research%' or p.proname like 'claim\_pre\_research%') loop
    execute format('drop function if exists %s cascade', r.sig);
  end loop;
end $$;

-- ---------------------------------------------------------------------------------------------- 4. ranking 16 -> 3 (numbers live in fact streams)
alter table evaluation.eval_run drop column target_kind, drop constraint eval_run_exactly_one_target;
alter table evaluation.eval_run drop column ranking_policy_version_id, drop column metric_definition_version_id;
alter table evaluation.eval_run add column target_kind text generated always as (
  case when capability_version_id is not null then 'capability_version' when space_version_id is not null then 'vector_space_version'
       when target_code_ref is not null then 'code_ref' end) stored;
alter table evaluation.eval_run add constraint eval_run_exactly_one_target check (num_nonnulls(capability_version_id, space_version_id, target_code_ref) = 1);
alter table orchestration.mission drop column selection_id;
drop function if exists api.leaderboard(integer);
drop table ranking.membership_snapshot, ranking.group_membership, ranking.feature_value, ranking.feature_definition, ranking.metric_observation,
           ranking.metric_definition_version, ranking.metric_definition, ranking.ranking_result, ranking.ranking_run, ranking.selection cascade;
alter table ranking.leaderboard drop column group_version_id, drop column policy_version_id;
drop table ranking.entity_group_version, ranking.entity_group, ranking.ranking_policy_version, ranking.ranking_policy cascade;
alter table ranking.leaderboard
  add column title text not null default '',
  add column definition jsonb not null default '{}'::jsonb,
  add column description text;
comment on table ranking.leaderboard is 'A named ranked view: cohort filter, metric (a stream kind) and policy are data in definition; values come from temporal.segment.';
alter table ranking.leaderboard_edition drop column ranking_run_id,
  add column tenant_id uuid not null default util.default_tenant_id(),
  add column knowledge_seq bigint,
  add column cohort jsonb not null default '[]'::jsonb;
comment on table ranking.leaderboard_edition is 'One frozen edition of a leaderboard: membership and knowledge head at publication.';
create table ranking.leaderboard_entry (
  tenant_id uuid not null default util.default_tenant_id(),
  edition_id uuid not null references ranking.leaderboard_edition(id) on delete restrict,
  rank integer not null check (rank >= 1),
  entity_id uuid not null references catalog.entity(id),
  score numeric,
  unit text,
  explanation jsonb not null default '{}'::jsonb,
  source_segment_ids uuid[] not null default '{}',
  primary key (edition_id, rank)
);
comment on table ranking.leaderboard_entry is 'Ranked row of an edition with the fact segments that produced the score.';
create or replace function api.leaderboard(p_slug text, p_limit integer default 20)
returns table(rank integer, entity_id uuid, display_name text, score numeric, unit text, explanation jsonb, edition_no integer, published_at timestamptz)
language sql stable security definer set search_path = '' as $$
  select e.rank, e.entity_id, en.display_name, e.score, e.unit, e.explanation, ed.edition_no, ed.published_at
  from ranking.leaderboard l join ranking.leaderboard_edition ed on ed.leaderboard_id = l.id
  join ranking.leaderboard_entry e on e.edition_id = ed.id join catalog.entity en on en.id = e.entity_id
  where l.tenant_id = util.current_tenant_id() and l.slug = p_slug
    and ed.edition_no = (select max(edition_no) from ranking.leaderboard_edition x where x.leaderboard_id = l.id)
  order by e.rank limit least(greatest(p_limit, 1), 200)
$$;

-- ---------------------------------------------------------------------------------------------- 5. knowledge -> guidance (13 -> 4)
drop view if exists api.technical_record_search;
alter table retrieval.packet_member drop column member_kind, drop constraint packet_member_exactly_one;
alter table retrieval.packet_member
  drop column technical_problem_id, drop column solution_pattern_id, drop column advanced_usage_pattern_id, drop column implementation_example_id,
  drop column failure_mode_id, drop column benchmark_result_id, drop column compatibility_constraint_id, drop column operational_practice_id,
  drop column security_consideration_id;
drop table knowledge.advanced_usage_pattern, knowledge.benchmark_result, knowledge.compatibility_constraint, knowledge.failure_mode,
           knowledge.implementation_example, knowledge.operational_practice, knowledge.security_consideration, knowledge.solution_pattern,
           knowledge.technical_problem, knowledge.record_reconciliation cascade;
alter schema knowledge rename to guidance;
comment on schema guidance is 'Expert engineering knowledge as typed items (problem, solution pattern, failure mode, compatibility constraint, operational practice, implementation example, security consideration, usage pattern) bound to entities and versions.';
alter table guidance.record rename to item;
alter table guidance.record_entity_link rename to item_subject;
alter table guidance.item_subject rename column record_id to item_id;
alter table guidance.item drop constraint record_kind_check;
create table guidance.item_kind (
  code text primary key,
  description text not null,
  payload_schema jsonb not null default '{"type":"object"}'::jsonb
);
comment on table guidance.item_kind is 'Vocabulary of guidance item kinds; payload_schema validates guidance.item.payload.';
insert into guidance.item_kind(code, description) values
  ('technical_problem', 'A problem engineers hit, with symptoms and context of occurrence'),
  ('solution_pattern', 'A mechanism that solves a problem, with trade-offs'),
  ('failure_mode', 'How a component or technique fails, its triggers and mitigations'),
  ('compatibility_constraint', 'A version/compatibility rule between components'),
  ('operational_practice', 'A procedure for running something in production'),
  ('implementation_example', 'A concrete code example anchored to a repository file/symbol or document unit'),
  ('security_consideration', 'A threat and its mitigation'),
  ('advanced_usage_pattern', 'A non-obvious usage with prerequisites'),
  ('setup_guide_step', 'A setup or development-guide step with exact commands and versions'),
  ('research_direction', 'A cautious research direction stated by a speaker/author; never a fact');
alter table guidance.item add column payload jsonb not null default '{}'::jsonb,
  add column applies_to_version_ids uuid[] not null default '{}',
  add column source_node_id uuid;
alter table guidance.item add constraint item_kind_fkey foreign key (kind) references guidance.item_kind(code);
comment on table guidance.item is 'One expert knowledge item: kind (guidance.item_kind), statement, scope, assurance level, provenance claim and typed payload.';
comment on table guidance.item_subject is 'Which entities an item is about and in which role (subject, component, version, alternative).';
alter table retrieval.packet_member add column guidance_item_id uuid references guidance.item(id);
alter table retrieval.packet_member add column member_kind text generated always as (
  case when claim_id is not null then 'claim' when guidance_item_id is not null then 'guidance_item' when source_representation_id is not null then 'source_representation' end) stored;
alter table retrieval.packet_member add constraint packet_member_exactly_one check (num_nonnulls(claim_id, guidance_item_id, source_representation_id) = 1);
comment on table retrieval.packet_member is 'One member of an evidence packet: a verified claim, a guidance item or a source-faithful representation, with scores and locators.';
create view api.guidance_items as
  select i.id, i.tenant_id, i.kind, i.title, i.statement, i.scope, i.assurance_level, i.payload, i.provenance_claim_id, i.created_at,
         (select array_agg(s.entity_id) from guidance.item_subject s where s.item_id = i.id) as subject_entity_ids
  from guidance.item i where i.tenant_id = util.current_tenant_id();
comment on view api.guidance_items is 'L1 view: expert guidance items with their subject entities.';

-- the evidence gate no longer dispatches over nine typed tables
create or replace function retrieval.enforce_evidence_gate() returns trigger language plpgsql set search_path = '' as $$
declare
  v_status text; v_rank integer;
  v_representation_class text; v_acceptance_state text; v_source_native_byte_identical boolean;
  c_floor constant integer := 20;
begin
  if new.claim_id is not null then
    select c.status::text into v_status from evidence.claim c where c.tenant_id=new.tenant_id and c.id=new.claim_id;
    if v_status is distinct from 'verified' then raise exception 'evidence gate: claim % is %, not verified',new.claim_id,coalesce(v_status,'missing') using errcode='restrict_violation'; end if;
    return new;
  end if;
  if new.source_representation_id is not null then
    select r.representation_class,r.acceptance_state,r.source_native_byte_identical into v_representation_class,v_acceptance_state,v_source_native_byte_identical
      from content.document_representation r where r.tenant_id=new.tenant_id and r.id=new.source_representation_id;
    if v_acceptance_state is distinct from 'accepted' then raise exception 'evidence gate: source representation % is %, not accepted',new.source_representation_id,coalesce(v_acceptance_state,'missing') using errcode='restrict_violation'; end if;
    if v_representation_class not in ('source_native','faithful_normalization') then raise exception 'evidence gate: representation class % is not source-faithful',v_representation_class using errcode='restrict_violation'; end if;
    if v_representation_class='source_native' and v_source_native_byte_identical is distinct from true then raise exception 'evidence gate: source-native representation % is not byte-identical',new.source_representation_id using errcode='restrict_violation'; end if;
    return new;
  end if;
  if new.guidance_item_id is null then raise exception 'evidence gate: packet member has no resolvable subject' using errcode='restrict_violation'; end if;
  select al.rank into v_rank from guidance.item r join guidance.assurance_level al on al.code=r.assurance_level where r.tenant_id=new.tenant_id and r.id=new.guidance_item_id;
  if v_rank is null or v_rank<c_floor then raise exception 'evidence gate: guidance item % is below the assurance floor (rank %, floor %)',new.guidance_item_id,coalesce(v_rank,-1),c_floor using errcode='restrict_violation'; end if;
  return new;
end;
$$;
do $$
declare r record; def text;
begin
  for r in select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
           where p.prokind = 'f' and (p.prosrc like '%knowledge.record%' or p.prosrc like '%knowledge.assurance_level%')
             and n.nspname in ('retrieval','taxonomy','evidence','api','catalog','content','temporal')
  loop
    def := replace(pg_get_functiondef(r.oid), 'knowledge.record_entity_link', 'guidance.item_subject');
    def := replace(def, 'knowledge.record', 'guidance.item');
    def := replace(def, 'knowledge.assurance_level', 'guidance.assurance_level');
    execute def;
  end loop;
end $$;

-- ---------------------------------------------------------------------------------------------- 6. catalog: thin kinds become entity rows with validated attributes; works merge
alter table taxonomy.entity_kind
  add column attributes_schema jsonb not null default '{"type":"object"}'::jsonb,
  add column parent_kind text references taxonomy.entity_kind(code),
  add column lens text not null default 'corpus' check (lens in ('corpus','ours','machinery')),
  add column is_work boolean not null default false;
comment on column taxonomy.entity_kind.attributes_schema is 'JSON Schema validating catalog.entity.attributes for this kind (pg_jsonschema).';
comment on column taxonomy.entity_kind.parent_kind is 'Kind whose rows this kind versions or belongs to (model version -> model); the link itself is a catalog.relationship.';

alter table catalog.entity add column attributes jsonb not null default '{}'::jsonb;
comment on column catalog.entity.attributes is 'Kind-specific attributes validated by taxonomy.entity_kind.attributes_schema. Numbers that change over time are fact streams, never attributes.';
create or replace function catalog.validate_entity_attributes() returns trigger language plpgsql set search_path = '' as $$
declare sch jsonb;
begin
  select attributes_schema into sch from taxonomy.entity_kind where code = new.kind;
  if sch is not null and sch <> '{"type":"object"}'::jsonb and not extensions.jsonb_matches_schema(sch::json, new.attributes) then
    raise exception 'entity attributes do not match the %s schema', new.kind using errcode = '23514';
  end if;
  return new;
end $$;
create trigger entity_attributes_valid before insert or update of attributes, kind on catalog.entity for each row execute function catalog.validate_entity_attributes();

-- temporal: specifications are streams now
alter table temporal.segment drop column specification_id;
drop function temporal.assert_state(uuid, text, tstzrange, text, text, numeric, text, text, uuid, jsonb, uuid, uuid, text, uuid, text, uuid);
create or replace function temporal.assert_state(p_entity uuid, p_stream_kind text, p_valid_during tstzrange, p_scope_key text default '', p_status text default null, p_amount numeric default null, p_currency text default null, p_unit text default null, p_ref_entity uuid default null, p_payload jsonb default '{}'::jsonb, p_extent uuid default null, p_claim uuid default null, p_temporal_basis text default 'explicit', p_relationship uuid default null, p_belief text default 'accepted')
returns uuid language plpgsql security definer set search_path = '' as $$
declare st uuid; result uuid; old temporal.segment; piece tstzrange; sk temporal.stream_kind; subject text; t uuid:=util.current_tenant_id();
begin
 if temporal.current_k() is null then raise exception 'no open knowledge batch'; end if;
 select * into strict sk from temporal.stream_kind where code=p_stream_kind;
 if sk.subject_mode='entity' then
  if p_relationship is not null then raise exception 'entity stream cannot target relationship'; end if;
  select kind into strict subject from catalog.entity where id=p_entity and tenant_id=t;
  if not(subject=any(sk.subject_kinds)) then raise exception 'stream does not admit entity kind' using errcode='23514'; end if;
 else
  if p_entity is not null then raise exception 'relationship stream cannot target entity'; end if;
  select r.kind into strict subject from catalog.relationship r join taxonomy.relationship_kind k on k.code=r.kind where r.id=p_relationship and r.tenant_id=t and r.k_to is null and k.temporal;
  if sk.code<>'relationship_active' and not(subject=any(sk.subject_kinds)) then raise exception 'stream does not admit relationship kind' using errcode='23514'; end if;
 end if;
 insert into temporal.stream(kind,subject_entity_id,subject_relationship_id,scope_key) values(p_stream_kind,p_entity,p_relationship,p_scope_key) on conflict do nothing;
 select id into strict st from temporal.stream where tenant_id=t and kind=p_stream_kind and subject_entity_id is not distinct from p_entity and subject_relationship_id is not distinct from p_relationship and scope_key=p_scope_key;
 if exists(select 1 from temporal.segment where stream_id=st and k_to is null and valid_during=p_valid_during and status is not distinct from p_status and amount is not distinct from p_amount and currency is not distinct from p_currency and unit is not distinct from p_unit and ref_entity_id is not distinct from p_ref_entity and payload=p_payload and extent_id is not distinct from p_extent and primary_claim_id is not distinct from p_claim and belief=p_belief and temporal_basis=p_temporal_basis) then
  select id into result from temporal.segment where stream_id=st and k_to is null and valid_during=p_valid_during; return result;
 end if;
 for old in select * from temporal.segment where stream_id=st and k_to is null and valid_during && p_valid_during for update loop
  if old.k_from=temporal.current_k() then raise exception 'overlapping assertions in one batch; consolidate before admission'; end if;
  perform temporal.close_segment(old.id);
  for piece in select unnest(tstzmultirange(old.valid_during)-tstzmultirange(p_valid_during)) loop
   insert into temporal.segment(stream_id,valid_during,belief,temporal_basis,status,amount,currency,unit,ref_entity_id,payload,extent_id,caused_by_event_id,replaces_segment_id,primary_claim_id)
   values(st,piece,old.belief,old.temporal_basis,old.status,old.amount,old.currency,old.unit,old.ref_entity_id,old.payload,old.extent_id,old.caused_by_event_id,old.id,old.primary_claim_id);
  end loop;
 end loop;
 insert into temporal.segment(stream_id,valid_during,belief,temporal_basis,status,amount,currency,unit,ref_entity_id,payload,extent_id,replaces_segment_id,primary_claim_id)
 values(st,p_valid_during,p_belief,p_temporal_basis,p_status,p_amount,p_currency,p_unit,p_ref_entity,p_payload,p_extent,old.id,p_claim) returning id into result;
 return result;
end $$;
create or replace function temporal.commit_batch(p_receipt uuid, p_idempotency_key text, p_input_digest text, p_summary jsonb default '{}'::jsonb)
returns bigint language plpgsql security definer set search_path = '' as $$
declare k bigint:=temporal.current_k(); t uuid:=util.current_tenant_id();
begin
 if k is null then raise exception 'no open knowledge batch'; end if;
 if not exists(select 1 from orchestration.operation_receipt r join orchestration.operation_intent i on i.id=r.intent_id where r.id=p_receipt and i.tenant_id=t) then raise exception 'receipt tenant mismatch'; end if;
 if exists(select 1 from temporal.segment s join temporal.stream st on st.id=s.stream_id join temporal.stream_kind sk on sk.code=st.kind where s.tenant_id=t and s.k_from=k and (
 (sk.status_values is not null and (s.status is null or not(s.status=any(sk.status_values)))) or
 (sk.requires_amount and (s.amount is null or s.unit is null)) or
 (sk.code in ('model_offering_price','offering_price','compute_offering_price','valuation') and (s.currency is null or s.currency !~ '^[A-Z]{3}$')) or
 (sk.unit_values is not null and (s.unit is null or not(s.unit=any(sk.unit_values)))) or
 (sk.requires_ref_entity and s.ref_entity_id is null) or
 not temporal.payload_valid(s.payload,sk.payload_schema))) then raise exception 'stream slot/payload rules violated' using errcode='23514'; end if;
 insert into temporal.knowledge_batch(tenant_id,knowledge_seq,receipt_id,idempotency_key,input_digest,summary) values(t,k,p_receipt,p_idempotency_key,p_input_digest,p_summary);
 update temporal.knowledge_head set knowledge_seq=k,open_xid=null,open_k=null,updated_at=clock_timestamp() where tenant_id=t;
 perform temporal.emit_outbox('knowledge.batch_sealed',k,jsonb_build_object('knowledge_seq',k,'receipt_id',p_receipt,'summary',p_summary));
 return k;
end $$;

drop view api.current_facts;
drop function api.current_fact_rows();
create function api.current_fact_rows() returns table(id uuid, tenant_id uuid, stream_id uuid, valid_during tstzrange, belief text, temporal_basis text, status text, amount numeric, currency character, unit text, ref_entity_id uuid, payload jsonb, extent_id uuid, caused_by_event_id uuid, replaces_segment_id uuid, primary_claim_id uuid, k_from bigint, k_to bigint, created_at timestamptz, stream_kind text, subject_entity_id uuid, subject_relationship_id uuid, scope_key text)
language sql stable security definer set search_path = '' as $$ select s.*,st.kind,st.subject_entity_id,st.subject_relationship_id,st.scope_key from temporal.segment s join temporal.stream st on st.id=s.stream_id where s.tenant_id=util.current_tenant_id() and s.k_to is null and s.valid_during @> now() $$;
grant execute on function api.current_fact_rows() to app_reader, authenticated, executor_service, pipeline_agent, verifier_agent, control_plane, service_role;
create view api.current_facts as select * from api.current_fact_rows();
grant select on api.current_facts to control_plane, executor_service, pipeline_agent, verifier_agent, authenticated, service_role, app_reader;

-- content.document no longer points at a repository file row (repository files are documents of kind repository_file)
alter table content.document drop column repository_file_id;
create or replace function content.check_document_work() returns trigger language plpgsql set search_path = '' as $$
declare expected text; actual text;
begin
 select work_entity_kind into expected from content.document_type where code=new.document_type_code;
 if new.work_entity_id is not null then select kind into strict actual from catalog.entity where id=new.work_entity_id and tenant_id=new.tenant_id; if expected is not null and actual<>expected then raise exception 'document type/work entity mismatch'; end if; end if;
 return new;
end $$;

drop view if exists api.library_profile;
drop function if exists catalog.check_repository_lineage() cascade;
drop table catalog.media_appearance, catalog.repository_file, catalog.repository_module, catalog.repository_revision, catalog.ai_model_version_spec,
           catalog.mcp_server_surface, catalog.registry_listing, catalog.product_feature, catalog.product_version, catalog.library_release,
           catalog.model_offering, catalog.ai_model_version, catalog.ai_protocol_feature, catalog.ai_protocol_version, catalog.benchmark_run,
           catalog.media_series, catalog.media_work, catalog.media_channel, catalog.industry_event, catalog.event_series,
           catalog.agent_skill, catalog.ai_model, catalog.ai_protocol, catalog.benchmark, catalog.case_study, catalog.compute_device, catalog.compute_offering,
           catalog.concept, catalog.corporate_transaction, catalog.dataset, catalog.funding_round, catalog.library, catalog.mcp_server,
           catalog.organization, catalog.paper, catalog.person, catalog.product, catalog.registry, catalog.repository, catalog.security_advisory,
           catalog.story, catalog.talk, catalog.technique cascade;

create table catalog.work (
  id uuid primary key references catalog.entity(id),
  tenant_id uuid not null default util.default_tenant_id(),
  kind text not null check (kind in ('paper','talk','media_work','story','case_study')),
  title text not null,
  subtitle text,
  abstract text,
  canonical_url text,
  published_at timestamptz,
  language text,
  duration_ms integer check (duration_ms is null or duration_ms >= 0),
  venue_entity_id uuid references catalog.entity(id),
  attributes jsonb not null default '{}'::jsonb,
  unique (tenant_id, id),
  foreign key (tenant_id, id, kind) references catalog.entity(tenant_id, id, kind) deferrable initially deferred
);
comment on table catalog.work is 'A published work entity (paper, talk, media work, story, case study): the bibliographic row behind the entity. Content lives in content.document (work_entity_id).';
alter table taxonomy.entity_kind drop constraint entity_kind_canonical_schema_canonical_table_key;
update taxonomy.entity_kind set canonical_table = 'entity';
update taxonomy.entity_kind set canonical_table = 'work', is_work = true where code in ('paper','talk','media_work','story','case_study');
update taxonomy.entity_kind set parent_kind = 'ai_model' where code in ('ai_model_version');
update taxonomy.entity_kind set parent_kind = 'ai_model_version' where code = 'model_offering';
update taxonomy.entity_kind set parent_kind = 'library' where code = 'library_release';
update taxonomy.entity_kind set parent_kind = 'product' where code in ('product_version','product_feature');
update taxonomy.entity_kind set parent_kind = 'ai_protocol' where code in ('ai_protocol_version','ai_protocol_feature');
update taxonomy.entity_kind set parent_kind = 'event_series' where code = 'industry_event';
update taxonomy.entity_kind set parent_kind = 'benchmark' where code = 'benchmark_run';
update taxonomy.entity_kind set parent_kind = 'media_channel' where code = 'media_series';

-- attribute schemas for the kinds loop 1 touches (others keep the permissive object schema until a loop needs them)
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"model_family":{"type":"string"},"description":{"type":"string"},"modalities":{"type":"array","items":{"type":"string"}}}}' where code = 'ai_model';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"required":["version_label"],"properties":{"version_label":{"type":"string"},"provider_model_id":{"type":"string"},"modalities":{"type":"array","items":{"type":"string"}},"open_weights":{"type":"boolean"},"model_page_url":{"type":"string"}}}' where code = 'ai_model_version';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"required":["offering_key"],"properties":{"offering_key":{"type":"string"},"provider_model_id":{"type":"string"},"region":{"type":"string"},"tier":{"type":"string"},"pricing_url":{"type":"string"}}}' where code = 'model_offering';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"legal_name":{"type":"string"},"website_url":{"type":"string"},"country_code":{"type":"string"},"founded_on":{"type":"string"},"org_kind":{"type":"string","enum":["frontier_lab","model_provider","cloud","tooling_vendor","startup","enterprise","academic","nonprofit","media","event_organizer","investor","other"]}}}' where code = 'organization';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"given_name":{"type":"string"},"family_name":{"type":"string"},"orcid":{"type":"string"},"title":{"type":"string"},"affiliation_text":{"type":"string"},"profile_url":{"type":"string"}}}' where code = 'person';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"ecosystem":{"type":"string"},"package_name":{"type":"string"},"description":{"type":"string"},"docs_url":{"type":"string"},"repository_url":{"type":"string"},"category":{"type":"string"}}}' where code = 'library';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"required":["version_label"],"properties":{"version_label":{"type":"string"},"released_on":{"type":"string"},"release_url":{"type":"string"},"breaking":{"type":"boolean"},"highlights":{"type":"array","items":{"type":"string"}},"license":{"type":"string"}}}' where code = 'library_release';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"required":["host","owner","name"],"properties":{"host":{"type":"string"},"owner":{"type":"string"},"name":{"type":"string"},"default_branch":{"type":"string"},"is_fork":{"type":"boolean"},"primary_language":{"type":"string"},"description":{"type":"string"}}}' where code = 'repository';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"transport":{"type":"array","items":{"type":"string"}},"hosting":{"type":"string","enum":["local","remote","both","unknown"]},"auth":{"type":"string"},"is_official":{"type":"boolean"},"description":{"type":"string"},"tools":{"type":"array","items":{"type":"string"}}}}' where code = 'mcp_server';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"description":{"type":"string"},"component":{"type":"string","enum":["rag","context","routing","workflow","harness","sandbox","tool","mcp","skill","eval","memory","agent_pattern","infrastructure","other"]},"level":{"type":"string","enum":["beginner","intermediate","advanced"]}}}' where code = 'concept';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"technique_kind":{"type":"string"},"description":{"type":"string"}}}' where code = 'technique';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"edition_label":{"type":"string"},"starts_on":{"type":"string"},"ends_on":{"type":"string"},"city":{"type":"string"},"country":{"type":"string"},"venue":{"type":"string"},"website_url":{"type":"string"},"format":{"type":"string"},"tracks":{"type":"array","items":{"type":"string"}}}}' where code = 'industry_event';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"series_kind":{"type":"string"},"website_url":{"type":"string"}}}' where code = 'event_series';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"talk_kind":{"type":"string","enum":["keynote","talk","workshop","panel","lightning","demo","fireside","poster","tutorial","announcement"]},"track":{"type":"string"},"level":{"type":"string"},"video_url":{"type":"string"},"slides_url":{"type":"string"},"session_id":{"type":"string"},"edition":{"type":"string"}}}' where code = 'talk';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"doi":{"type":"string"},"arxiv_id":{"type":"string"},"venue":{"type":"string"},"published_on":{"type":"string"}}}' where code = 'paper';
update taxonomy.entity_kind set attributes_schema = '{"type":"object","additionalProperties":true,"properties":{"canonical_url":{"type":"string"},"methodology":{"type":"string"},"metric":{"type":"string"},"higher_is_better":{"type":"boolean"}}}' where code = 'benchmark';
update taxonomy.entity_kind set description = 'Model version (the thing that is released, priced and evaluated); version_of -> ai_model' where code = 'ai_model_version';
update taxonomy.entity_kind set description = 'A model as sold on one API/provider: offered_as <- ai_model_version, offered_by -> organization; prices are offering_price streams' where code = 'model_offering';
update taxonomy.entity_kind set description = 'A conference talk/session (ai.engineer World''s Fair, Code Summit ...): presented_by -> person, presented_at -> industry_event; transcript and slides are content' where code = 'talk';

-- catalog clean-ups
comment on table catalog.entity is 'One canonical row per industry identity. kind -> taxonomy.entity_kind; attributes validated per kind; display_name/slug are projections (entity_name stream is authoritative).';
comment on table catalog.relationship is 'The only link between two entities: kind -> taxonomy.relationship_kind (endpoint kinds enforced); temporal kinds carry a relationship_active stream.';
-- Build 08 R2 draft. Part 2: honest acquisition, document axes, open-world kinds, census, unit grammar, typed units, diffs, bridge, digests.

-- ---------------------------------------------------------------------------------------------- 7. acquisition: the fetch ledger (F-25 honest capture provenance)
create schema if not exists acquisition;
comment on schema acquisition is 'How bytes were obtained: every product/harness/mission fetch is a ledger row before it becomes an evidence.source_capture. Search/provider attempts stay in evidence until the KS executor moves (deferred).';
create table acquisition.fetch (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  origin_kind text not null check (origin_kind in ('native_harness','mission_invocation','product_user','scheduled_refresh','manual_upload')),
  origin_label text not null,
  actor_principal_id uuid,
  mc_mission_id text,
  mc_run_id text,
  tool text not null check (tool in ('http','firecrawl','browser','api','repository','upload','youtube_transcript','other')),
  tool_version text,
  request_url text not null,
  final_url text,
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  http_status integer,
  outcome text not null check (outcome in ('captured','unchanged','failed','blocked','skipped')),
  content_sha256 text check (content_sha256 ~ '^[0-9a-f]{64}$'),
  media_type text,
  size_bytes bigint check (size_bytes is null or size_bytes >= 0),
  credits_used numeric,
  cost_usd numeric,
  failure_class text,
  prior_capture_id uuid references evidence.source_capture(id),
  notes jsonb not null default '{}'::jsonb
);
comment on table acquisition.fetch is 'One attempt to obtain bytes from a URL: who (origin), with what tool, outcome, hash, spend. unchanged = same bytes as prior_capture_id (no new document version).';
create index fetch_url_idx on acquisition.fetch (tenant_id, request_url, requested_at desc);
alter table evidence.source_capture add column acquisition_fetch_id uuid references acquisition.fetch(id);
alter table evidence.source_capture drop constraint source_capture_exactly_one_producer_ck;
alter table evidence.source_capture add constraint source_capture_exactly_one_producer_ck check (num_nonnulls(produced_by_attempt_id, knowledge_operation_id, acquisition_fetch_id) = 1);
comment on column evidence.source_capture.acquisition_fetch_id is 'Producer when the bytes came from a product/harness fetch (acquisition.fetch) rather than a mission attempt or a KS operation.';
insert into evidence.capture_method(code, description) values ('native_harness_http', 'Fetched by a coding-harness agent over plain HTTPS; provenance in acquisition.fetch') on conflict do nothing;

-- ---------------------------------------------------------------------------------------------- 8. document axes: format x kind x source role
create table content.format (
  code text primary key,
  description text not null,
  default_locator_kinds text[] not null default '{}'
);
comment on table content.format is 'Media/format axis of a captured version: decides the parser and the locator kinds (page+bbox, timecode, table cell, JSON pointer, line range).';
insert into content.format(code, description, default_locator_kinds) values
  ('html', 'HTML page', '{text_quote,html,table}'),
  ('markdown', 'Markdown text (including rendered .md of a talk page)', '{text_quote,character_position}'),
  ('pdf', 'PDF document', '{pdf_text,bounding_box,table}'),
  ('json', 'Machine-structured JSON or API record', '{json_pointer,api_record}'),
  ('timed_text', 'Timestamped transcript/captions', '{media_timecode,text_quote}'),
  ('code', 'Source code or notebook', '{repository,character_position}'),
  ('tabular', 'CSV/Parquet/spreadsheet', '{table,dataset}'),
  ('slides', 'Slide deck', '{bounding_box,pdf_text}'),
  ('video', 'Video file or page', '{media_timecode,media_region}'),
  ('audio', 'Audio', '{media_timecode}'),
  ('image', 'Image/diagram/screenshot', '{bounding_box,media_region}'),
  ('text', 'Plain text', '{text_quote,character_position}'),
  ('archive', 'Archive/bundle', '{repository}'),
  ('unknown', 'Not yet determined', '{}');

create table content.source_role (
  code text primary key,
  description text not null,
  authority_rank smallint not null,
  default_source_tier smallint not null check (default_source_tier between 0 and 4)
);
comment on table content.source_role is 'Who speaks: first party about itself, filer, academic, registry, third-party editorial, community, our own content, system. Feeds attribution/authority and the source tier.';
insert into content.source_role(code, description, authority_rank, default_source_tier) values
  ('first_party', 'The vendor/author about its own product, model, price or release', 90, 2),
  ('filer', 'A regulated filer about itself (SEC, patent office)', 90, 2),
  ('academic', 'Peer-reviewed or preprint research', 80, 2),
  ('event_organizer', 'Conference organizer publishing session metadata and talk pages', 75, 2),
  ('registry', 'Registry/aggregator records (package index, model hub, MCP registry, leaderboard)', 70, 2),
  ('third_party_editorial', 'Press, analysts, newsletters, blogs restating facts', 50, 3),
  ('community', 'Forums, social posts, Q&A, chat exports', 40, 3),
  ('own', 'Our courses, guides, reports and dataset cards', 60, 1),
  ('system', 'Generated by this system (digests, profiles, timelines)', 30, 1),
  ('unknown', 'Not yet classified', 10, 3);

alter table content.document_type
  add column status text not null default 'active' check (status in ('candidate','active','retired')),
  add column axis_note text,
  add column promoted_from_census boolean not null default false;
comment on column content.document_type.status is 'Open-world kinds: candidate (seen in census, grammar not settled), active, retired. unclassified is always valid.';
alter table content.document_type drop constraint document_type_family_check;
alter table content.document_type add constraint document_type_family_check check (family in ('regulatory_filing','research','vendor','code','media_transcript','editorial','market','registry','system_generated','event_media','own','unknown'));
insert into content.document_type(code, family, description, is_primary_source, default_chunking_slug, default_extraction_kinds, default_spaces, default_summary_kinds, work_entity_kind, published_at_is_world_time, status) values
  ('unclassified', 'unknown', 'Kind not assigned yet; universal units and census only; promotion candidate', false, 'section', '{}', '{units}', '{abstract}', null, false, 'active'),
  ('aie_talk', 'event_media', 'An ai.engineer talk page: write-up, resources, slides with timecodes and a timestamped transcript without speaker labels, plus its sessions.json record', true, 'transcript_window', '{claim,entity,relationship}', '{units,digests}', '{abstract,key_claims,timeline}', 'talk', true, 'active'),
  ('framework_docs_page', 'vendor', 'A framework/library documentation page (concepts, API usage, examples, version notes)', true, 'section', '{claim,entity}', '{units}', '{technical}', null, false, 'active'),
  ('github_release', 'code', 'A GitHub release entry (tag, date, notes, breaking changes)', true, 'section', '{claim,entity,relationship}', '{units}', '{key_claims}', null, true, 'active'),
  ('course_module', 'own', 'Our own course module/lesson/guide revision (authoring.work_revision) projected as tier-1 content', true, 'section', '{entity}', '{own_content}', '{abstract}', null, false, 'active'),
  ('guide', 'own', 'Our own setup/development guide', true, 'section', '{entity}', '{own_content}', '{abstract}', null, false, 'active')
on conflict (code) do nothing;
update content.document_type set description = 'Vendor pricing page: plan sections and price rows per offering/meter/tier/region; first-party about itself' where code = 'pricing_page';

alter table content.document_version add column format_code text references content.format(code);
comment on column content.document_version.format_code is 'Format axis of this captured version (content.format).';
alter table content.document
  add column source_role_code text references content.source_role(code),
  add column source_role_method text check (source_role_method in ('rule','model','person','default')),
  add column attributes jsonb not null default '{}'::jsonb;
comment on column content.document.source_role_code is 'Source-role axis: who speaks (content.source_role); set by rule (URL/publisher), model or person.';

create table content.document_kind_assignment (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_id uuid not null,
  document_type_code text not null references content.document_type(code),
  method text not null check (method in ('rule','model','person','census')),
  confidence numeric check (confidence between 0 and 1),
  rationale text,
  assigned_at timestamptz not null default now(),
  superseded_by_id uuid references content.document_kind_assignment(id),
  foreign key (tenant_id, document_id) references content.document(tenant_id, id) on delete restrict
);
comment on table content.document_kind_assignment is 'Append-only kind assignments of a document (open world): the current one has superseded_by_id null; document.document_type_code is the initial assignment.';
create index document_kind_assignment_current_idx on content.document_kind_assignment (tenant_id, document_id) where superseded_by_id is null;
create or replace function content.current_kind(p_document uuid) returns text language sql stable set search_path = '' as $$
  select coalesce((select a.document_type_code from content.document_kind_assignment a where a.document_id = p_document and a.superseded_by_id is null order by a.assigned_at desc limit 1),
                  (select d.document_type_code from content.document d where d.id = p_document))
$$;

-- ---------------------------------------------------------------------------------------------- 9. structure census (cheap, deterministic, before any grammar)
create table content.structure_census (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  representation_id uuid not null,
  census_version text not null,
  format_code text not null references content.format(code),
  counts jsonb not null,
  signatures jsonb not null default '{}'::jsonb,
  language text,
  digest text not null check (digest ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  foreign key (tenant_id, representation_id) references content.document_representation(tenant_id, id) on delete restrict,
  unique (tenant_id, representation_id, census_version),
  constraint structure_census_counts_shape check (extensions.jsonb_matches_schema('{"type":"object","properties":{"headings":{"type":"integer"},"heading_depth":{"type":"integer"},"paragraphs":{"type":"integer"},"tables":{"type":"integer"},"table_rows":{"type":"integer"},"lists":{"type":"integer"},"list_items":{"type":"integer"},"code_blocks":{"type":"integer"},"links":{"type":"integer"},"timecodes":{"type":"integer"},"speaker_labels":{"type":"integer"},"figures":{"type":"integer"},"machine_blocks":{"type":"integer"},"words":{"type":"integer"}},"additionalProperties":true}'::json, counts))
);
comment on table content.structure_census is 'What a captured representation structurally contains (headings, tables, lists, code, timecodes, speakers, figures, machine blocks) before a kind or grammar is assigned. Promotion candidates come from census statistics.';

-- ---------------------------------------------------------------------------------------------- 10. unit grammar as data and typed units
create table content.unit_kind (
  code text not null,
  version integer not null default 1 check (version >= 1),
  status text not null default 'active' check (status in ('candidate','active','retired')),
  description text not null,
  is_universal boolean not null default false,
  applicable_document_types text[],
  parent_kinds text[],
  attributes_schema jsonb not null default '{"type":"object"}'::jsonb,
  logical_key_attributes text[] not null default '{}',
  selector_kind text not null check (selector_kind in ('text_quote','character_position','multi_fragment_text','json_pointer','html','pdf_text','bounding_box','table','repository','dataset','api_record','media_timecode','media_region')),
  retrieval_role text not null default 'embed' check (retrieval_role in ('embed','filter','structure_only')),
  entity_roles text[] not null default '{}',
  primary key (code, version)
);
comment on table content.unit_kind is 'Grammar as data: the typed units a document kind decomposes into, with a JSON Schema for attributes, the attributes forming the logical key (stable across captures), the locator kind and the retrieval role. Universal units apply to every kind.';
insert into content.unit_kind(code, description, is_universal, applicable_document_types, parent_kinds, attributes_schema, logical_key_attributes, selector_kind, retrieval_role, entity_roles) values
  ('document_root', 'Root of a representation tree', true, null, null, '{"type":"object"}', '{}', 'character_position', 'structure_only', '{}'),
  ('section', 'Heading-delimited section', true, null, '{document_root,section}', '{"type":"object","properties":{"heading":{"type":"string"},"level":{"type":"integer"},"path":{"type":"string"}}}', '{path}', 'text_quote', 'embed', '{}'),
  ('paragraph', 'Prose paragraph', true, null, '{section,document_root,list_item}', '{"type":"object","properties":{"ordinal_in_section":{"type":"integer"}}}', '{}', 'text_quote', 'embed', '{mentions}'),
  ('list', 'Ordered or unordered list', true, null, '{section,document_root}', '{"type":"object","properties":{"ordered":{"type":"boolean"},"items":{"type":"integer"}}}', '{}', 'text_quote', 'structure_only', '{}'),
  ('list_item', 'List item', true, null, '{list}', '{"type":"object","properties":{"ordinal":{"type":"integer"}}}', '{}', 'text_quote', 'embed', '{mentions}'),
  ('table', 'Table with header signature', true, null, '{section,document_root}', '{"type":"object","properties":{"caption":{"type":"string"},"header":{"type":"array","items":{"type":"string"}},"rows":{"type":"integer"}}}', '{header}', 'table', 'structure_only', '{}'),
  ('table_row', 'Table row keyed by its first cell', true, null, '{table}', '{"type":"object","properties":{"row_key":{"type":"string"},"cells":{"type":"array","items":{"type":"string"}}}}', '{row_key}', 'table', 'embed', '{subject}'),
  ('code_block', 'Code block with language', true, null, '{section,list_item,document_root}', '{"type":"object","properties":{"language":{"type":"string"},"lines":{"type":"integer"}}}', '{}', 'character_position', 'embed', '{demonstrates}'),
  ('figure', 'Figure/image with caption', true, null, '{section,document_root}', '{"type":"object","properties":{"caption":{"type":"string"},"src":{"type":"string"}}}', '{}', 'bounding_box', 'embed', '{}'),
  ('media_segment', 'Timed segment of a transcript', true, null, '{document_root,section}', '{"type":"object","required":["t0_ms"],"properties":{"t0_ms":{"type":"integer"},"t1_ms":{"type":"integer"},"speaker":{"type":"string"}}}', '{t0_ms}', 'media_timecode', 'embed', '{speaker,mentions}'),
  ('link', 'Hyperlink with anchor text', true, null, '{paragraph,list_item,section}', '{"type":"object","required":["href"],"properties":{"href":{"type":"string"},"text":{"type":"string"}}}', '{href}', 'text_quote', 'filter', '{references}'),
  ('metadata_field', 'Machine-readable field (frontmatter, JSON key, meta tag)', true, null, '{document_root}', '{"type":"object","required":["key"],"properties":{"key":{"type":"string"},"value":{}}}', '{key}', 'json_pointer', 'filter', '{}'),
  -- pricing_page grammar
  ('plan_section', 'A pricing plan/model family section', false, '{pricing_page}', '{document_root,section}', '{"type":"object","required":["plan"],"properties":{"plan":{"type":"string"},"tier":{"type":"string"}}}', '{plan}', 'text_quote', 'embed', '{offering}'),
  ('price_row', 'One priced meter for an offering', false, '{pricing_page}', '{plan_section,table}', '{"type":"object","required":["offering","meter","amount","currency","unit"],"properties":{"offering":{"type":"string"},"meter":{"type":"string"},"amount":{"type":"number"},"currency":{"type":"string"},"unit":{"type":"string"},"tier":{"type":"string"},"region":{"type":"string"},"condition":{"type":"string"}}}', '{offering,meter,tier,region}', 'table', 'embed', '{offering,provider}'),
  -- changelog / release grammar
  ('release_entry', 'One dated release/version entry', false, '{changelog,release_notes,github_release}', '{document_root,section}', '{"type":"object","required":["version"],"properties":{"version":{"type":"string"},"released_on":{"type":"string"},"title":{"type":"string"},"breaking":{"type":"boolean"},"url":{"type":"string"}}}', '{version}', 'text_quote', 'embed', '{software,release}'),
  ('change_item', 'One change line inside a release entry', false, '{changelog,release_notes,github_release}', '{release_entry,list}', '{"type":"object","required":["kind"],"properties":{"kind":{"type":"string","enum":["added","changed","deprecated","removed","fixed","security","breaking","docs","other"]},"component":{"type":"string"},"ordinal":{"type":"integer"}}}', '{ordinal}', 'text_quote', 'embed', '{software,component,mentions}'),
  -- model/system card grammar
  ('model_card_section', 'Named section of a model/system card or model page', false, '{model_card,system_card,product_page}', '{document_root,section}', '{"type":"object","required":["section_kind"],"properties":{"section_kind":{"type":"string","enum":["overview","capabilities","limitations","safety","evaluation","training","pricing","availability","specifications","other"]},"heading":{"type":"string"}}}', '{section_kind}', 'text_quote', 'embed', '{model}'),
  ('eval_row', 'One benchmark result row', false, '{model_card,system_card,product_page}', '{model_card_section,table}', '{"type":"object","required":["benchmark","score"],"properties":{"benchmark":{"type":"string"},"score":{"type":"number"},"unit":{"type":"string"},"setting":{"type":"string"},"model":{"type":"string"},"comparison_model":{"type":"string"}}}', '{benchmark,setting,model}', 'table', 'embed', '{model,benchmark}'),
  ('spec_field', 'A specification field of a model page (context window, cutoff, modalities, pricing)', false, '{model_card,system_card,product_page}', '{model_card_section,metadata_field,table}', '{"type":"object","required":["field","value"],"properties":{"field":{"type":"string"},"value":{},"unit":{"type":"string"}}}', '{field}', 'text_quote', 'embed', '{model}'),
  -- aie_talk grammar
  ('talk_header', 'Talk title, speakers, track and event fields from the page/sessions record', false, '{aie_talk}', '{document_root}', '{"type":"object","properties":{"title":{"type":"string"},"speakers":{"type":"array","items":{"type":"string"}},"track":{"type":"string"},"event":{"type":"string"},"session_id":{"type":"string"},"video_url":{"type":"string"}}}', '{session_id}', 'json_pointer', 'filter', '{speaker,event}'),
  ('talk_writeup', 'Organizer/AI write-up section of a talk page: claim candidates, never facts', false, '{aie_talk}', '{document_root,section}', '{"type":"object","properties":{"heading":{"type":"string"},"path":{"type":"string"}}}', '{path}', 'text_quote', 'embed', '{mentions}'),
  ('talk_resource', 'A resource link listed on a talk page (repository, paper, docs)', false, '{aie_talk}', '{document_root,section,list}', '{"type":"object","required":["href"],"properties":{"href":{"type":"string"},"text":{"type":"string"},"resource_kind":{"type":"string","enum":["repository","paper","docs","website","video","slides","other"]}}}', '{href}', 'text_quote', 'filter', '{references}'),
  ('slide', 'A slide with its start timecode', false, '{aie_talk}', '{document_root,section}', '{"type":"object","required":["n","t0_ms"],"properties":{"n":{"type":"integer"},"title":{"type":"string"},"t0_ms":{"type":"integer"}}}', '{n}', 'media_timecode', 'embed', '{}'),
  ('transcript_segment', 'Timestamped transcript window (no speaker labels on ai.engineer pages)', false, '{aie_talk,video_transcript,podcast_transcript}', '{document_root,section}', '{"type":"object","required":["t0_ms"],"properties":{"t0_ms":{"type":"integer"},"t1_ms":{"type":"integer"},"speaker":{"type":"string"},"slide_n":{"type":"integer"}}}', '{t0_ms}', 'media_timecode', 'embed', '{speaker,mentions}'),
  -- framework docs grammar
  ('docs_section', 'Documentation section', false, '{framework_docs_page,official_docs_page,api_reference}', '{document_root,section}', '{"type":"object","properties":{"heading":{"type":"string"},"path":{"type":"string"},"version_note":{"type":"string"}}}', '{path}', 'text_quote', 'embed', '{software,concept}'),
  ('code_example', 'Code example in docs with language and the API it demonstrates', false, '{framework_docs_page,official_docs_page,repository_readme}', '{docs_section,section}', '{"type":"object","properties":{"language":{"type":"string"},"demonstrates":{"type":"string"},"path":{"type":"string"}}}', '{path,language}', 'character_position', 'embed', '{software,demonstrates}'),
  -- repository readme
  ('readme_section', 'README section', false, '{repository_readme}', '{document_root,section}', '{"type":"object","properties":{"heading":{"type":"string"},"path":{"type":"string"}}}', '{path}', 'text_quote', 'embed', '{software,concept}'),
  -- news/social
  ('post_paragraph', 'A paragraph of a post/article that may carry claims', false, '{news_article,social_post,thirdparty_blog_post,official_blog_post,analysis_post,newsletter_issue}', '{document_root,section}', '{"type":"object","properties":{"ordinal":{"type":"integer"},"byline":{"type":"string"},"published_at":{"type":"string"}}}', '{ordinal}', 'text_quote', 'embed', '{mentions,quotes}'),
  ('quote', 'A quotation attributed to a speaker', false, '{news_article,social_post,thirdparty_blog_post,official_blog_post,analysis_post,newsletter_issue,aie_talk}', '{post_paragraph,paragraph,transcript_segment}', '{"type":"object","properties":{"speaker":{"type":"string"},"ordinal":{"type":"integer"}}}', '{ordinal}', 'text_quote', 'embed', '{speaker}'),
  -- own content
  ('module_block', 'A block of our own module/lesson/guide revision', false, '{course_module,guide}', '{document_root,section}', '{"type":"object","required":["block_key"],"properties":{"block_key":{"type":"string"},"block_type":{"type":"string"}}}', '{block_key}', 'character_position', 'embed', '{covers,uses}');

alter table content.document_node rename column node_kind to unit_kind;
alter table content.document_node
  add column unit_kind_version integer not null default 1,
  add column attributes jsonb not null default '{}'::jsonb,
  add column logical_key text,
  add column grammar_version text;
alter table content.document_node add constraint document_node_unit_kind_fkey foreign key (unit_kind, unit_kind_version) references content.unit_kind(code, version);
create index document_node_logical_key_idx on content.document_node (tenant_id, logical_key) where logical_key is not null;
create index document_node_unit_kind_idx on content.document_node (tenant_id, unit_kind);
comment on table content.document_node is 'A typed unit of a representation: unit_kind (+version) from content.unit_kind, validated attributes, a logical_key stable across captures (grammar logical key), a stable_local_key within this representation, and typed position (offsets, page, bbox, timecodes).';
comment on column content.document_node.logical_key is 'Grammar logical key: unit_kind + the logical_key_attributes values, so the same unit can be matched across versions for diffs (price_row:gpt-6.1|input_tokens|standard|global).';
create or replace function content.validate_unit_attributes() returns trigger language plpgsql set search_path = '' as $$
declare sch jsonb;
begin
  select attributes_schema into sch from content.unit_kind where code = new.unit_kind and version = new.unit_kind_version;
  if sch is not null and sch <> '{"type":"object"}'::jsonb and not extensions.jsonb_matches_schema(sch::json, new.attributes) then
    raise exception 'unit attributes do not match the %/% schema', new.unit_kind, new.unit_kind_version using errcode = '23514';
  end if;
  return new;
end $$;
create trigger document_node_attributes_valid before insert on content.document_node for each row execute function content.validate_unit_attributes();
alter table content.document_representation add column grammar_version text;
comment on column content.document_representation.grammar_version is 'The grammar (unit_kind set + parser version) that produced this representation''s units; a later grammar never reinterprets old units silently.';

-- ---------------------------------------------------------------------------------------------- 11. refresh: unchanged checks and unit-level changes
create table content.refresh_check (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_id uuid not null,
  prior_version_id uuid not null,
  fetch_id uuid references acquisition.fetch(id),
  checked_at timestamptz not null default now(),
  outcome text not null check (outcome in ('unchanged','changed','failed')),
  content_sha256 text check (content_sha256 ~ '^[0-9a-f]{64}$'),
  new_version_id uuid,
  foreign key (tenant_id, document_id) references content.document(tenant_id, id),
  foreign key (tenant_id, prior_version_id) references content.document_version(tenant_id, id),
  foreign key (tenant_id, new_version_id) references content.document_version(tenant_id, id)
);
comment on table content.refresh_check is 'Each refresh of a document: unchanged (same bytes, no new version), changed (new version created) or failed. This is what a daily refresh writes even when nothing moved.';
create table content.unit_change (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_id uuid not null,
  logical_key text not null,
  unit_kind text not null,
  from_version_id uuid,
  to_version_id uuid not null,
  from_node_id uuid,
  to_node_id uuid,
  change_kind text not null check (change_kind in ('added','removed','attribute_changed','text_changed','moved')),
  changed_attributes jsonb not null default '{}'::jsonb,
  detected_at timestamptz not null default now(),
  refresh_check_id uuid references content.refresh_check(id),
  update_proposal_state text not null default 'none' check (update_proposal_state in ('none','proposed','applied','rejected')),
  foreign key (tenant_id, document_id) references content.document(tenant_id, id),
  foreign key (tenant_id, to_version_id) references content.document_version(tenant_id, id),
  foreign key (tenant_id, from_node_id) references content.document_node(tenant_id, id),
  foreign key (tenant_id, to_node_id) references content.document_node(tenant_id, id)
);
comment on table content.unit_change is 'A unit-level diff between two versions of a document, matched by logical_key: added/removed/attribute_changed/text_changed/moved, with the changed attribute values. Drives update proposals for facts.';
create index unit_change_document_idx on content.unit_change (tenant_id, document_id, detected_at desc);
create index unit_change_detected_idx on content.unit_change (tenant_id, detected_at desc);

-- ---------------------------------------------------------------------------------------------- 12. bridge: unit -> assertion template (act 3 as data) and unit-entity roles
create table content.unit_assertion_mapping (
  id uuid primary key default util.uuidv7(),
  unit_kind text not null,
  unit_kind_version integer not null default 1,
  document_type_code text references content.document_type(code),
  source_role_code text references content.source_role(code),
  target_kind text not null check (target_kind in ('stream','relationship','event','entity_attribute')),
  stream_kind text references temporal.stream_kind(code),
  relationship_kind text references taxonomy.relationship_kind(code),
  event_kind text references temporal.event_kind(code),
  subject_template jsonb not null,
  value_template jsonb not null default '{}'::jsonb,
  qualifier_template jsonb not null default '{}'::jsonb,
  time_template jsonb not null default '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}'::jsonb,
  deterministic boolean not null default true,
  risk_floor text not null default 'L0' check (risk_floor in ('L0','L1','L2','L3')),
  status text not null default 'active' check (status in ('candidate','active','retired')),
  description text not null,
  foreign key (unit_kind, unit_kind_version) references content.unit_kind(code, version),
  constraint mapping_target_consistent check (
    (target_kind = 'stream' and stream_kind is not null) or (target_kind = 'relationship' and relationship_kind is not null)
    or (target_kind = 'event' and event_kind is not null) or (target_kind = 'entity_attribute'))
);
comment on table content.unit_assertion_mapping is 'Declarative act 3: how a unit kind''s attributes become an assertion (stream kind / relationship / event / attribute) with subject, value, qualifier and time templates; deterministic mappings on first-party structured units take the cheap path, others carry a risk floor for KS verification.';
alter table evidence.extraction_record
  add column document_node_id uuid,
  add column mapping_id uuid references content.unit_assertion_mapping(id);
alter table evidence.extraction_record add constraint extraction_record_node_fk foreign key (tenant_id, document_node_id) references content.document_node(tenant_id, id) deferrable initially deferred;
comment on column evidence.extraction_record.document_node_id is 'Act 2 anchor: the typed unit this faithful extraction reads (chunks are derived; units are stable).';
comment on column evidence.extraction_record.mapping_id is 'Act 3 template used to interpret this unit into a claim (content.unit_assertion_mapping).';

create table content.unit_entity_role (
  tenant_id uuid not null default util.default_tenant_id(),
  node_id uuid not null,
  entity_id uuid not null references catalog.entity(id),
  role text not null,
  method text not null check (method in ('rule','model','person','mapping')),
  confidence numeric check (confidence between 0 and 1),
  claim_id uuid references evidence.claim(id),
  created_at timestamptz not null default now(),
  primary key (node_id, entity_id, role),
  foreign key (tenant_id, node_id) references content.document_node(tenant_id, id) on delete restrict
);
comment on table content.unit_entity_role is 'Which entity a unit is about and in what role from the unit kind''s role vocabulary (offering, provider, model, speaker, software, release, mentions ...). Anchored on units, never chunks.';
create index unit_entity_role_entity_idx on content.unit_entity_role (tenant_id, entity_id, role);
create or replace function content.validate_unit_entity_role() returns trigger language plpgsql set search_path = '' as $$
declare roles text[];
begin
  select k.entity_roles into roles from content.document_node n join content.unit_kind k on k.code = n.unit_kind and k.version = n.unit_kind_version where n.id = new.node_id;
  if roles is not null and cardinality(roles) > 0 and not (new.role = any(roles)) then
    raise exception 'role % is not in the unit kind role vocabulary %', new.role, roles using errcode = '23514';
  end if;
  return new;
end $$;
create trigger unit_entity_role_valid before insert or update on content.unit_entity_role for each row execute function content.validate_unit_entity_role();

-- ---------------------------------------------------------------------------------------------- 13. digests: structured, anchored, never evidence
create table content.document_digest (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  document_version_id uuid not null,
  scope text not null check (scope in ('document','section','entity_view')),
  scope_node_id uuid,
  focus_entity_id uuid references catalog.entity(id),
  digest_schema_version text not null default 'aieng.digest.v1',
  producer_identity text not null,
  producer_kind text not null check (producer_kind in ('deterministic','model','person')),
  transformation_run_id uuid,
  lifecycle text not null default 'active' check (lifecycle in ('active','superseded','withdrawn')),
  created_at timestamptz not null default now(),
  foreign key (tenant_id, document_version_id) references content.document_version(tenant_id, id),
  foreign key (tenant_id, scope_node_id) references content.document_node(tenant_id, id),
  foreign key (tenant_id, transformation_run_id) references content.transformation_run(tenant_id, id),
  constraint digest_section_scope check (scope <> 'section' or scope_node_id is not null),
  constraint digest_entity_scope check (scope <> 'entity_view' or focus_entity_id is not null)
);
comment on table content.document_digest is 'A structured digest of a version (or section/entity view): items are records anchored to units; prose summaries in content.document_summary are renderings of a digest, never evidence.';
create table content.digest_item (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  digest_id uuid not null references content.document_digest(id) on delete restrict,
  ordinal integer not null check (ordinal >= 0),
  item_kind text not null check (item_kind in ('key_point','entity_role','assertion_ref','change','open_question','limitation','research_direction')),
  text text,
  payload jsonb not null default '{}'::jsonb,
  node_ids uuid[] not null default '{}',
  entity_id uuid references catalog.entity(id),
  claim_id uuid references evidence.claim(id),
  unit_change_id uuid references content.unit_change(id),
  confidence numeric check (confidence between 0 and 1),
  unique (digest_id, ordinal)
);
comment on table content.digest_item is 'One digest item: a key point, an entity role, a reference to an assertion/claim, a change, an open question, a limitation or a cautious research direction, each anchored to unit node ids.';
alter table content.document_summary add column digest_id uuid references content.document_digest(id);
comment on column content.document_summary.digest_id is 'The structured digest this prose summary renders; prose without a digest is not evidence.';

-- grants and RLS for the new content/acquisition tables follow the knowledge-side pattern
do $$
declare t text;
begin
  foreach t in array array['acquisition.fetch','content.document_kind_assignment','content.structure_census','content.refresh_check','content.unit_change','content.unit_entity_role','content.document_digest','content.digest_item'] loop
    execute format('alter table %s enable row level security', t);
    execute format('create policy bounded_role_access on %s for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader using (tenant_id = util.current_tenant_id()) with check (tenant_id = util.current_tenant_id())', t);
    execute format('grant select on %s to pipeline_agent, verifier_agent, control_plane, app_reader, product_api_owner', t);
    execute format('grant select, insert, update on %s to executor_service', t);
  end loop;
  foreach t in array array['content.format','content.source_role','content.unit_kind','content.unit_assertion_mapping','guidance.item_kind','ranking.leaderboard_entry'] loop
    execute format('grant select on %s to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader, product_api_owner', t);
  end loop;
end $$;
grant usage on schema acquisition, verification, guidance, catalog to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader, product_api_owner;
grant usage on schema content to app_reader;
-- Build 08 R2 draft. Part 3: one retrieval stack (lens + source tier + facets), both space layouts, RLS-isolated learner notes, product API on the same stack.

-- ---------------------------------------------------------------------------------------------- 14. projection targets: units, digests, own revisions, private passages
alter table retrieval.projection_target drop constraint projection_target_tenant_id_target_kind_entity_id_record_id_key;
alter table retrieval.projection_target drop constraint projection_target_check;
alter table retrieval.projection_target drop constraint projection_target_check1;
alter table retrieval.projection_target drop constraint projection_target_target_kind_check;
alter table retrieval.projection_target
  add column document_node_id uuid,
  add column digest_id uuid references content.document_digest(id),
  add column authored_revision_id uuid references authoring.work_revision(id),
  add column passage_id uuid;
alter table retrieval.projection_target add constraint projection_target_node_fk foreign key (tenant_id, document_node_id) references content.document_node(tenant_id, id) deferrable initially deferred;
comment on column retrieval.projection_target.passage_id is 'library.passage of a private/own passage; soft reference (passages are re-indexed by deletion) so the retired vector item keeps its target row.';
comment on column retrieval.projection_target.record_id is 'guidance.item (expert knowledge item) when target_kind = record.';
alter table retrieval.projection_target add constraint projection_target_target_kind_check check (target_kind in ('entity','record','chunk','claim','summary','unit','digest','authored','passage'));
alter table retrieval.projection_target add constraint projection_target_exactly_one check (num_nonnulls(entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id) = 1);
alter table retrieval.projection_target add constraint projection_target_kind_matches check (
  (target_kind = 'entity' and entity_id is not null) or (target_kind = 'record' and record_id is not null) or (target_kind = 'chunk' and chunk_id is not null)
  or (target_kind = 'claim' and claim_id is not null) or (target_kind = 'summary' and summary_id is not null) or (target_kind = 'unit' and document_node_id is not null)
  or (target_kind = 'digest' and digest_id is not null) or (target_kind = 'authored' and authored_revision_id is not null) or (target_kind = 'passage' and passage_id is not null));
alter table retrieval.projection_target add constraint projection_target_one_row_per_target unique nulls not distinct (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id);
comment on table retrieval.projection_target is 'What a search projection is about: an entity card, a guidance item, a chunk, a claim, a summary, a typed unit, a digest, one of our authored revisions or a private passage. Exactly one target per row.';

-- ---------------------------------------------------------------------------------------------- 15. vector items carry lens, source tier and the facets questions filter on
alter table retrieval.vector_item
  add column lens text not null default 'corpus' check (lens in ('corpus','ours','private','evidence')),
  add column source_tier smallint check (source_tier between 0 and 4),
  add column workspace_id uuid,
  add column unit_kind text,
  add column document_id uuid,
  add column document_version_id uuid,
  add column source_role_code text references content.source_role(code),
  add column observed_at timestamptz,
  add column search_tsv_en tsvector generated always as (to_tsvector('english', coalesce(search_text, ''))) stored;
alter table retrieval.vector_item drop constraint vector_item_content_kind_check;
alter table retrieval.vector_item add constraint vector_item_content_kind_check check (content_kind in ('chunk','summary','claim','record','profile','timeline','measurement','unit','digest','passage','authored','guidance'));
alter table retrieval.vector_item add constraint vector_item_private_has_workspace check (lens <> 'private' or workspace_id is not null);
create index vector_item_lens_tier_idx on retrieval.vector_item (tenant_id, lens, source_tier) where lifecycle = 'active';
create index vector_item_tsv_en_idx on retrieval.vector_item using gin (search_tsv_en);
create index vector_item_workspace_idx on retrieval.vector_item (tenant_id, workspace_id) where lens = 'private' and lifecycle = 'active';
create index vector_item_document_idx on retrieval.vector_item (tenant_id, document_id) where lifecycle = 'active';
comment on column retrieval.vector_item.lens is 'Whose knowledge: corpus (ingested sources), ours (our courses/guides/reports), private (one workspace''s notes, RLS-isolated), evidence (assertions/claims).';
comment on column retrieval.vector_item.source_tier is 'T0 verified assertions, T1 our content, T2 primary corpus, T3 third-party corpus, T4 live web; a filter and a boost, never a truth claim.';
comment on table retrieval.vector_item is 'One searchable item in one vector space version: the text, its lens/tier/facets (document kind, unit kind, entity, time, assurance) and lifecycle. Embeddings live in vector_item_embedding_1536 partitions.';

-- the knowledge roles never see private items; the product owner sees only private and own items
drop policy bounded_role_access on retrieval.vector_item;
create policy bounded_role_access on retrieval.vector_item for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id() and lens <> 'private') with check (tenant_id = util.current_tenant_id() and lens <> 'private');
create policy product_private_access on retrieval.vector_item for all to product_api_owner using (lens in ('private','ours')) with check (lens in ('private','ours'));
drop policy bounded_role_access on retrieval.vector_item_embedding_1536;
create policy bounded_role_access on retrieval.vector_item_embedding_1536 for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id() and exists (select 1 from retrieval.vector_item v where v.id = vector_item_id and v.lens <> 'private'))
  with check (tenant_id = util.current_tenant_id() and exists (select 1 from retrieval.vector_item v where v.id = vector_item_id and v.lens <> 'private'));
create policy product_private_access on retrieval.vector_item_embedding_1536 for all to product_api_owner
  using (exists (select 1 from retrieval.vector_item v where v.id = vector_item_id and v.lens in ('private','ours')))
  with check (exists (select 1 from retrieval.vector_item v where v.id = vector_item_id and v.lens in ('private','ours')));
create policy product_private_access on retrieval.projection_target for all to product_api_owner using (true) with check (target_kind in ('passage','authored'));
create policy product_private_access on retrieval.search_projection for all to product_api_owner using (true) with check (visibility in ('private','workspace','tenant'));
grant select, insert, update on retrieval.vector_item, retrieval.vector_item_embedding_1536, retrieval.projection_target, retrieval.search_projection to product_api_owner;
grant select on retrieval.vector_space, retrieval.vector_space_version, retrieval.projection_procedure to product_api_owner, app_reader, pipeline_agent, verifier_agent, control_plane;
grant select on retrieval.vector_item, retrieval.vector_item_embedding_1536 to app_reader, pipeline_agent, verifier_agent, control_plane;

-- append-only items may be retired (re-indexing) without a successor; any other change still needs a first successor assignment
create or replace function retrieval.vector_item_guard() returns trigger language plpgsql set search_path = '' as $$
declare successor_created timestamptz; begin
 if tg_op='DELETE' then raise exception 'retrieval.vector_item is append-only' using errcode='restrict_violation'; end if;
 -- generated columns (search_tsv, search_tsv_en) are not computed yet in a BEFORE trigger, so they are excluded from the comparison
 if (to_jsonb(new)-'{lifecycle,search_tsv,search_tsv_en}'::text[]) = (to_jsonb(old)-'{lifecycle,search_tsv,search_tsv_en}'::text[]) and old.lifecycle='active' and new.lifecycle in ('retired','superseded') then return new; end if;
 if (to_jsonb(new)-'{superseded_by_id,search_tsv,search_tsv_en}'::text[]) is distinct from (to_jsonb(old)-'{superseded_by_id,search_tsv,search_tsv_en}'::text[])
    or old.superseded_by_id is not null or new.superseded_by_id is null or new.superseded_by_id=new.id then
  raise exception 'vector item is immutable; only a first successor assignment or retirement is allowed' using errcode='restrict_violation';
 end if;
 select created_at into successor_created from retrieval.vector_item where tenant_id=old.tenant_id and id=new.superseded_by_id;
 if successor_created is null or successor_created<=old.created_at then raise exception 'vector successor must be newer and same-tenant' using errcode='check_violation'; end if;
 return new;
end $$;

-- ---------------------------------------------------------------------------------------------- 16. spaces: layout A (kind spaces) and layout B (one topical space), 1536 halfvec partitions
insert into retrieval.projection_procedure(slug, version, description, template, projection_policy) values
  ('build08-text', 1, 'Build 08: the unit/digest/card/assertion/passage text itself (optionally with a short contextual prefix) is the embedding text', '{prefix}{text}', '{"layout_experiment":"A_vs_B"}')
on conflict (slug, version) do nothing;
insert into retrieval.vector_space(tenant_id, slug, purpose, class) values
  (util.default_tenant_id(), 'units', 'Layout A: text-bearing typed units (sections, rows, segments, slides, code examples)', 'exploratory'),
  (util.default_tenant_id(), 'digests', 'Layout A: digest items (key points, changes, open questions)', 'exploratory'),
  (util.default_tenant_id(), 'entity_cards', 'Layout A: one profile card per entity/concept (never a number)', 'exploratory'),
  (util.default_tenant_id(), 'assertions', 'Layout A: claim statements with qualifiers (evidence lens)', 'exploratory'),
  (util.default_tenant_id(), 'own_content', 'Layout A: our courses, guides and reports (ours lens, tier 1)', 'exploratory'),
  (util.default_tenant_id(), 'learner_notes', 'Layout A: private notes and uploads, RLS-isolated per workspace (private lens)', 'exploratory'),
  (util.default_tenant_id(), 'knowledge_text', 'Layout B: every corpus/ours text item in one topical space, facets do the scoping', 'exploratory')
on conflict (tenant_id, slug) do nothing;
insert into retrieval.vector_space_version(tenant_id, vector_space_id, version, embedding_model, dims, backend, precision, distance_operator, normalization, index_configuration, provider_routing_policy, publication_lifecycle)
select util.default_tenant_id(), s.id, 1, 'openai/text-embedding-3-small', 1536, 'pgvector', 'halfvec', 'cosine', 'l2', '{"hnsw":{"m":16,"ef_construction":64}}', '{"provider":"openai","role":"OPENAI_EMBEDDING_API_KEY"}', 'draft'
from retrieval.vector_space s where s.slug in ('units','digests','entity_cards','assertions','own_content','learner_notes','knowledge_text')
  and not exists (select 1 from retrieval.vector_space_version v where v.vector_space_id = s.id);
do $$
declare s text;
begin
  foreach s in array array['units','digests','entity_cards','assertions','own_content','learner_notes','knowledge_text'] loop
    execute format('create table if not exists retrieval.vector_item_embedding_1536_%I partition of retrieval.vector_item_embedding_1536 for values in (%L)', s, s);
    execute format('create index if not exists embedding_%s_hnsw on retrieval.vector_item_embedding_1536_%I using hnsw (embedding extensions.halfvec_cosine_ops)', s, s);
  end loop;
end $$;

-- ---------------------------------------------------------------------------------------------- 17. one way in: index a text item; one way to store its embedding
create or replace function retrieval.index_text_item(
  p_space_slug text, p_target_kind text, p_target_id uuid, p_text text, p_lens text, p_source_tier smallint, p_content_kind text,
  p_entity_id uuid default null, p_secondary_entity_ids uuid[] default '{}', p_document_type_code text default null, p_unit_kind text default null,
  p_document_id uuid default null, p_document_version_id uuid default null, p_source_role_code text default null, p_valid_during tstzrange default null,
  p_knowledge_seq bigint default null, p_workspace_id uuid default null, p_language text default 'en', p_observed_at timestamptz default null,
  p_start_ms integer default null, p_end_ms integer default null, p_contextual_prefix text default '', p_assurance_rank smallint default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare t uuid := util.default_tenant_id(); vsv uuid; target uuid; proj uuid; item uuid; proc uuid; sha text := encode(sha256(convert_to(p_text,'UTF8')),'hex'); esha text := encode(sha256(convert_to(p_contextual_prefix||p_text,'UTF8')),'hex'); psha text := encode(sha256(convert_to(coalesce(p_contextual_prefix,''),'UTF8')),'hex');
begin
  if p_text is null or btrim(p_text) = '' then raise exception 'empty text cannot be indexed' using errcode='invalid_parameter_value'; end if;
  if p_lens = 'private' and p_workspace_id is null then raise exception 'private items need a workspace' using errcode='invalid_parameter_value'; end if;
  select v.id into vsv from retrieval.vector_space_version v join retrieval.vector_space s on s.id = v.vector_space_id where s.tenant_id = t and s.slug = p_space_slug order by v.version desc limit 1;
  if vsv is null then raise exception 'unknown vector space %', p_space_slug; end if;
  select id into proc from retrieval.projection_procedure where slug = 'build08-text' and version = 1;
  insert into retrieval.projection_target(tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id)
  values (t, p_target_kind,
    case when p_target_kind='entity' then p_target_id end, case when p_target_kind='record' then p_target_id end, case when p_target_kind='chunk' then p_target_id end,
    case when p_target_kind='claim' then p_target_id end, case when p_target_kind='summary' then p_target_id end, case when p_target_kind='unit' then p_target_id end,
    case when p_target_kind='digest' then p_target_id end, case when p_target_kind='authored' then p_target_id end, case when p_target_kind='passage' then p_target_id end)
  on conflict (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id) do update set retired_at = null
  returning id into target;
  select id into proj from retrieval.search_projection where tenant_id = t and projection_target_id = target and projection_procedure_id = proc and purpose = 'build08_text' and embedding_text_sha256 = esha;
  if proj is null then
    insert into retrieval.search_projection(tenant_id, projection_target_id, projection_procedure_id, purpose, source_text, contextual_prefix, embedding_text, source_text_sha256, contextual_prefix_sha256, embedding_text_sha256, language, content_kind, visibility, classification, promotion_state, generator_identity)
    values (t, target, proc, 'build08_text', p_text, coalesce(p_contextual_prefix,''), p_contextual_prefix||p_text, sha, psha, esha, p_language, p_content_kind,
            case p_lens when 'private' then 'private' when 'ours' then 'tenant' else 'public' end, case p_lens when 'private' then 'private' else 'public' end, 'candidate', 'build08-text/1')
    returning id into proj;
  end if;
  select id into item from retrieval.vector_item where tenant_id = t and space_version_id = vsv and search_projection_id = proj and lifecycle = 'active';
  if item is not null then return item; end if;
  insert into retrieval.vector_item(tenant_id, space_version_id, content_sha256, chunk_index, verification_state, lifecycle, search_projection_id, projection_target_id, language, visibility, classification,
    authority_level, freshness_at, search_text, entity_id, entity_kind, secondary_entity_ids, document_type_code, content_kind, valid_during, knowledge_seq, assurance_rank, start_ms, end_ms,
    lens, source_tier, workspace_id, unit_kind, document_id, document_version_id, source_role_code, observed_at)
  values (t, vsv, sha, 0, 'pending', 'active', proj, target, p_language, case p_lens when 'private' then 'private' when 'ours' then 'tenant' else 'public' end, case p_lens when 'private' then 'private' else 'public' end,
    p_source_role_code, coalesce(p_observed_at, now()), p_contextual_prefix||p_text, p_entity_id, (select kind from catalog.entity where id = p_entity_id), coalesce(p_secondary_entity_ids,'{}'), p_document_type_code, p_content_kind, p_valid_during, p_knowledge_seq, p_assurance_rank, p_start_ms, p_end_ms,
    p_lens, p_source_tier, p_workspace_id, p_unit_kind, p_document_id, p_document_version_id, p_source_role_code, p_observed_at)
  returning id into item;
  return item;
end $$;
comment on function retrieval.index_text_item is 'The one way a text becomes searchable: upserts the projection target, the search projection and an active vector item in the named space with lens/tier/facets. Idempotent on identical text.';
create or replace function retrieval.store_embedding(p_vector_item uuid, p_embedding extensions.halfvec, p_embedding_sha256 text)
returns void language plpgsql security definer set search_path = '' as $$
declare t uuid; vsv uuid; key text;
begin
  select vi.tenant_id, vi.space_version_id, s.slug into t, vsv, key from retrieval.vector_item vi join retrieval.vector_space_version v on v.id = vi.space_version_id join retrieval.vector_space s on s.id = v.vector_space_id where vi.id = p_vector_item;
  if key is null then raise exception 'unknown vector item %', p_vector_item; end if;
  insert into retrieval.vector_item_embedding_1536(tenant_id, vector_space_key, vector_space_version_id, vector_item_id, embedding, embedding_sha256)
  values (t, key, vsv, p_vector_item, p_embedding, p_embedding_sha256)
  on conflict (vector_space_key, vector_item_id) do nothing;
end $$;
create or replace function retrieval.retire_items_for_passages(p_passage_ids uuid[]) returns integer language plpgsql security definer set search_path = '' as $$
declare n integer;
begin
  update retrieval.vector_item vi set lifecycle = 'retired' from retrieval.projection_target pt where pt.id = vi.projection_target_id and pt.passage_id = any(p_passage_ids) and vi.lifecycle = 'active';
  get diagnostics n = row_count; return n;
end $$;
grant execute on function retrieval.index_text_item(text,text,uuid,text,text,smallint,text,uuid,uuid[],text,text,uuid,uuid,text,tstzrange,bigint,uuid,text,timestamptz,integer,integer,text,smallint) to executor_service, product_api_owner;
grant execute on function retrieval.store_embedding(uuid, extensions.halfvec, text) to executor_service, product_api_owner;
grant execute on function retrieval.retire_items_for_passages(uuid[]) to product_api_owner;

-- ---------------------------------------------------------------------------------------------- 18. the one search: scope first (facets), then lexical + trigram + ANN fused with RRF
create or replace function api.search_unified(
  p_query text, p_query_embedding extensions.halfvec default null, p_lenses text[] default array['corpus','ours'], p_tiers smallint[] default null,
  p_space_slugs text[] default null, p_document_types text[] default null, p_unit_kinds text[] default null, p_entity_ids uuid[] default null,
  p_as_of timestamptz default null, p_workspace_ids uuid[] default null, p_source_roles text[] default null, p_content_kinds text[] default null,
  p_limit integer default 20, p_candidate_limit integer default 100, p_rrf_k integer default 60)
returns table(vector_item_id uuid, lens text, source_tier smallint, content_kind text, document_type_code text, unit_kind text, entity_id uuid, document_id uuid, document_version_id uuid,
              target_kind text, target_id uuid, workspace_id uuid, snippet text, start_ms integer, end_ms integer, observed_at timestamptz, valid_during tstzrange, space_slug text,
              fused_score double precision, channel_scores jsonb)
language plpgsql stable security definer set search_path = '' as $$
declare t uuid := util.default_tenant_id(); q tsquery := websearch_to_tsquery('english', p_query);
begin
  if coalesce(length(btrim(p_query)),0) < 1 or length(p_query) > 4096 then raise exception 'query text length must be between 1 and 4096' using errcode='invalid_parameter_value'; end if;
  if p_limit not between 1 and 200 or p_candidate_limit not between p_limit and 2000 then raise exception 'result/candidate bounds are invalid' using errcode='invalid_parameter_value'; end if;
  perform set_config('hnsw.iterative_scan','relaxed_order',true);
  return query
  with eligible as materialized (
    select vi.*, s.slug as space_slug_
    from retrieval.vector_item vi join retrieval.vector_space_version v on v.id = vi.space_version_id join retrieval.vector_space s on s.id = v.vector_space_id
    where vi.tenant_id = t and vi.lifecycle = 'active'
      and vi.lens = any(p_lenses)
      and (vi.lens <> 'private' or (p_workspace_ids is not null and vi.workspace_id = any(p_workspace_ids)))
      and (p_tiers is null or vi.source_tier = any(p_tiers))
      and (p_space_slugs is null or s.slug = any(p_space_slugs))
      and (p_document_types is null or vi.document_type_code = any(p_document_types))
      and (p_unit_kinds is null or vi.unit_kind = any(p_unit_kinds))
      and (p_content_kinds is null or vi.content_kind = any(p_content_kinds))
      and (p_source_roles is null or vi.source_role_code = any(p_source_roles))
      and (p_entity_ids is null or vi.entity_id = any(p_entity_ids) or vi.secondary_entity_ids && p_entity_ids)
      and (p_as_of is null or vi.valid_during is null or vi.valid_during @> p_as_of)
  ), fts as (
    select e.id, ts_rank_cd(e.search_tsv_en, q)::double precision raw, row_number() over (order by ts_rank_cd(e.search_tsv_en, q) desc, e.id)::bigint rk
    from eligible e where e.search_tsv_en @@ q limit p_candidate_limit
  ), trigram as (
    select e.id, extensions.similarity(e.search_text, p_query)::double precision raw, row_number() over (order by extensions.similarity(e.search_text, p_query) desc, e.id)::bigint rk
    from eligible e where length(p_query) >= 3 and extensions.similarity(e.search_text, p_query) > 0.3 limit p_candidate_limit
  ), ann as (
    select e.id, (1 - (emb.embedding operator(extensions.<=>) p_query_embedding))::double precision raw, row_number() over (order by emb.embedding operator(extensions.<=>) p_query_embedding, e.id)::bigint rk
    from eligible e join retrieval.vector_item_embedding_1536 emb on emb.vector_item_id = e.id and emb.vector_space_key = e.space_slug_
    where p_query_embedding is not null
    order by emb.embedding operator(extensions.<=>) p_query_embedding, e.id limit p_candidate_limit
  ), channels as (
    select id, 'fts' ch, raw, rk from fts union all select id, 'trigram', raw, rk from trigram union all select id, 'ann', raw, rk from ann
  ), fused as (
    select id, sum(1.0/(p_rrf_k + rk))::double precision score, jsonb_object_agg(ch, jsonb_build_object('score', raw, 'rank', rk) order by ch) details from channels group by id
  )
  select e.id, e.lens, e.source_tier, e.content_kind, e.document_type_code, e.unit_kind, e.entity_id, e.document_id, e.document_version_id,
         pt.target_kind, coalesce(pt.entity_id, pt.record_id, pt.chunk_id, pt.claim_id, pt.summary_id, pt.document_node_id, pt.digest_id, pt.authored_revision_id, pt.passage_id),
         e.workspace_id, left(e.search_text, 320), e.start_ms, e.end_ms, e.observed_at, e.valid_during, e.space_slug_, f.score * (1 + coalesce(0.1 * (3 - e.source_tier), 0)), f.details
  from fused f join eligible e on e.id = f.id left join retrieval.projection_target pt on pt.id = e.projection_target_id
  order by f.score * (1 + coalesce(0.1 * (3 - e.source_tier), 0)) desc, e.id limit p_limit;
end $$;
comment on function api.search_unified is 'L3 scoped semantic search over the one stack: resolve the scope first (lens, tier, space, document kind, unit kind, entity, as-of, workspace for private), then fuse english full-text, trigram and ANN (if an embedding is given) with RRF; tier is a mild boost. Private items are returned only for the workspaces passed in.';
grant execute on function api.search_unified(text, extensions.halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamptz, uuid[], text[], text[], integer, integer, integer) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

-- ---------------------------------------------------------------------------------------------- 19. product API: private passages and our content join the same stack
drop table library.passage_embedding_1536;
-- Build 08 R2 draft. Part 3b: product.dispatch_read / product.dispatch_worker re-created on the unified retrieval stack (patched copies of 20261105010300_product_api.sql).

create or replace function product.dispatch_read(ws uuid, op text, pl jsonb, p uuid) returns jsonb language plpgsql stable set search_path = '' as $$
declare res jsonb; q tsquery; lim int := least(coalesce((pl ->> 'limit')::int, 20), 50); o authoring.distribution_offer; e learning.enrollment;
begin
  case op
  when 'get_revision' then
    if not product.readable_revision((pl ->> 'revision_id')::uuid, p) then perform product.fail('NOT_FOUND', 'revision'); end if;
    select jsonb_build_object('id', r.id, 'workId', r.work_id, 'revisionNo', r.revision_no, 'title', r.title, 'body', r.body,
                              'contentSha256', r.content_sha256, 'purged', r.purged_at is not null) into res
      from authoring.work_revision r where r.id = (pl ->> 'revision_id')::uuid;
    return res;

  when 'list_works' then
    perform product.require_role(ws, p, array['owner','editor','reader']);
    return coalesce((select jsonb_agg(jsonb_build_object('id', w.id, 'kind', w.kind, 'slug', w.slug, 'head', w.head_revision_id) order by w.created_at)
                       from authoring.work w where w.workspace_id = ws), '[]');

  when 'preview_exposure' then
    perform product.require_role(ws, p, array['owner','editor']);
    if not exists (select 1 from authoring.work_revision r where r.id = (pl ->> 'root_revision_id')::uuid and r.workspace_id = ws) then perform product.fail('NOT_FOUND', 'revision'); end if;
    return product.exposure((pl ->> 'root_revision_id')::uuid, pl ->> 'ceiling');

  when 'get_offer' then
    select * into o from authoring.distribution_offer where id = (pl ->> 'offer_id')::uuid;
    if o.id is null or not product.can_read_offer(o, p) then perform product.fail('NOT_FOUND', 'offer'); end if;
    return jsonb_build_object('offerId', o.id, 'terms', o.terms, 'items',
      (select jsonb_agg(jsonb_build_object('releaseItemId', i.id, 'itemKey', i.item_key, 'disposition', i.disposition, 'revisionId', case when i.disposition in ('include','snapshot') then i.revision_id end,
                                           'artifactId', case when i.disposition in ('include','snapshot') then coalesce(i.substitute_artifact_id, i.artifact_id) end) order by i.item_key)
         from authoring.release_item i where i.release_id = o.release_id and i.disposition <> 'withheld'));

  when 'list_library' then
    return coalesce((select jsonb_agg(jsonb_build_object('distributionId', d.id, 'title', d.title, 'channel', d.channel, 'offerId', o2.id))
                       from authoring.distribution d join authoring.distribution_offer o2 on o2.distribution_id = d.id and o2.ended_at is null
                      where d.channel = coalesce(pl ->> 'channel', 'public_library') and d.closed_at is null and product.can_read_offer(o2, p)), '[]');

  when 'search' then
    -- Build 08: one retrieval stack. Private notes (lens private) and released course material (lens ours) are vector items;
    -- the workspace list bounds private candidates, the per-passage predicates below keep the exact Build 02/04 readability rules.
    return coalesce((select jsonb_agg(x order by (x ->> 'rank')::double precision desc) from (
      select jsonb_build_object('label', case when pa.message_id is not null then 'conversation'
                                              when wk.kind = 'document' or pa.artifact_id is not null then 'uploaded_source'
                                              when product.role_in(pa.workspace_id, p) is not null then 'private_note' else 'course_material' end,
                                'passageId', pa.id, 'revisionId', pa.revision_id, 'workKind', wk.kind, 'locator', pa.locator,
                                'snippet', left(pa.text, 240), 'rank', h.fused_score, 'lens', h.lens, 'tier', h.source_tier, 'channels', h.channel_scores) as x
        from api.search_unified(pl ->> 'query', null, array['private','ours'], null, array['learner_notes','own_content'], null, null, null, null,
               (select array_agg(distinct w) from (
                  select m.workspace_id w from authoring.workspace_member m where m.tenant_id = product.tenant() and m.principal_id = p and m.revoked_at is null
                  union select rv2.workspace_id from authoring.release_item i2 join authoring.distribution_offer o2 on o2.release_id = i2.release_id
                        join authoring.work_revision rv2 on rv2.id = i2.revision_id where i2.disposition in ('include','snapshot') and product.can_read_offer(o2, p)) ws_list),
               null, null, least(lim * 10, 200), least(lim * 20, 2000), 60) h
        join library.passage pa on pa.id = h.target_id and h.target_kind = 'passage'
        left join authoring.work_revision rv on rv.id = pa.revision_id
        left join authoring.work wk on wk.id = rv.work_id
        left join conversation.message m on m.id = pa.message_id
        left join conversation.thread th on th.id = m.thread_id
       where (   (pa.revision_id is not null and (product.role_in(pa.workspace_id, p) is not null or product.readable_revision(pa.revision_id, p)))
              or (pa.message_id is not null and m.redacted_at is null and (th.owner_id = p or (th.visibility = 'workspace' and product.role_in(th.workspace_id, p) is not null)))
              or (pa.artifact_id is not null and exists (select 1 from authoring.asset_scope s where s.artifact_id = pa.artifact_id and s.revoked_at is null
                                                         and product.role_in(s.workspace_id, p) is not null)))
         and not exists (select 1 from library.resource_control c where c.work_id = wk.id and c.excluded_at is not null and product.role_in(c.workspace_id, p) is not null)
         and not (pa.artifact_id is not null and product.restricted(null, pa.artifact_id, array['deny_all']))
         and (rv.id is null or rv.purged_at is null)
       limit lim) s), '[]');

  when 'progress' then
    select * into e from learning.enrollment where id = (pl ->> 'enrollment_id')::uuid;
    if e.id is null or not (e.learner_id = p or exists (select 1 from learning.evidence_grant g where g.learner_id = e.learner_id and g.grantee_id = p
          and g.revoked_at is null and 'progress' = any(g.includes) and (g.scope_kind = 'all_learning' or g.enrollment_id = e.id))) then
      perform product.fail('NOT_FOUND', 'enrollment');
    end if;
    return (select jsonb_build_object('enrollmentId', e.id, 'adoptionId', ad.id, 'requirements',
             (select jsonb_agg(jsonb_build_object('requirementKey', rq.requirement_key, 'kind', rq.kind,
                     'met', exists (select 1 from learning.credit c where c.adoption_id = ad.id and c.requirement_id = rq.id and c.status = 'active'))
                     order by rq.requirement_key)
                from authoring.release_item ri join curriculum.requirement rq on rq.revision_id = ri.revision_id
               where ri.release_id = o2.release_id))
       from learning.release_adoption ad join authoring.distribution_offer o2 on o2.id = ad.offer_id
      where ad.enrollment_id = e.id order by ad.sequence_no desc limit 1);

  when 'get_result' then
    return (select jsonb_build_object('resultId', r.id, 'status', r.status, 'outcomes', r.outcomes, 'supersedes', r.supersedes_id,
              'criteria', (select jsonb_agg(jsonb_build_object('criterion', c.criterion_key, 'value', case when c.visibility = 'student_visible' then c.value end,
                                   'visibility', c.visibility, 'judgedBy', c.judged_by, 'explanation', c.explanation) order by c.criterion_key)
                             from learning.grading_run gr join learning.criterion_result c on c.grading_run_id = gr.id where gr.submission_id = r.submission_id))
       from learning.assessment_result r join learning.submission sb on sb.id = r.submission_id
      where r.id = (pl ->> 'result_id')::uuid
        and (sb.learner_id = p or exists (select 1 from learning.evidence_grant g where g.learner_id = sb.learner_id and g.grantee_id = p
               and g.revoked_at is null and 'results' = any(g.includes))));
    -- (NULL above means not found; callers map NULL to NOT_FOUND)

  when 'get_lesson_view' then
    if not product.readable_revision((pl ->> 'revision_id')::uuid, p) then perform product.fail('NOT_FOUND', 'revision'); end if;
    return (select jsonb_build_object('revisionId', r.id, 'title', r.title, 'body', r.body,
       'blocks', (select jsonb_agg(jsonb_build_object('key', b.block_key, 'type', b.block_type, 'parent', b.parent_key, 'position', b.position) order by b.parent_key nulls first, b.position)
                    from authoring.revision_block b where b.revision_id = r.id),
       'learnerLayer', coalesce((select jsonb_agg(jsonb_build_object('workId', w.id, 'kind', w.kind, 'revisionId', lr.id, 'title', lr.title, 'blockKey', x.block_key,
                                  'anchoredRevisionNo', tr.revision_no, 'carriedForward', tr.id <> r.id))
            from authoring.revision_binding x
            join authoring.work_revision lr on lr.id = x.revision_id
            join authoring.work w on w.id = lr.work_id and w.head_revision_id = lr.id
            join authoring.workspace ws2 on ws2.id = lr.workspace_id and ws2.kind = 'personal' and ws2.owner_id = p
            join authoring.work_revision tr on tr.id = coalesce((select ri.revision_id from authoring.release_item ri where ri.id = x.release_item_id), x.target_revision_id)
           where x.relation = 'anchored_to' and tr.work_id = r.work_id
             and (x.block_key is null or exists (select 1 from authoring.revision_block rb where rb.revision_id = r.id and rb.block_key = x.block_key))), '[]'))
      from authoring.work_revision r where r.id = (pl ->> 'revision_id')::uuid);

  when 'get_thread' then
    return (select jsonb_build_object('threadId', th.id, 'messages', (select jsonb_agg(jsonb_build_object('seq', m.seq, 'role', m.role,
               'content', case when m.redacted_at is null then m.content end, 'surface', m.client_surface) order by m.seq) from conversation.message m where m.thread_id = th.id))
      from conversation.thread th where th.id = (pl ->> 'thread_id')::uuid
        and (th.owner_id = p or (th.visibility = 'workspace' and product.role_in(th.workspace_id, p) is not null)));

  else
    return product.dispatch_research_read(ws, op, pl, p);
  end case;
  return null;
end $$;

-- ================================================================== Build 07: research requests, datasets, statements and support
-- Dataset revision arithmetic: a version is visible in revision n when from <= n < coalesce(to, infinity).
create or replace function product.dataset_draft_no(dw uuid) returns integer language sql stable set search_path = '' as $$
  select coalesce((select r.revision_no from authoring.work w join authoring.work_revision r on r.id = w.head_revision_id where w.id = dw), 0) + 1
$$;

create or replace function product.dispatch_worker(op text, pl jsonb) returns jsonb language plpgsql set search_path = '' as $$
declare t uuid := product.tenant(); aid uuid; rid uuid; x jsonb; n int; s learning.submission; pol jsonb; auto boolean; ws uuid; cnt int; lens_ text;
begin
  case op
  when 'complete_asset' then
    select a.id into aid from orchestration.artifact a where a.id = (pl ->> 'artifact_id')::uuid and a.storage_bucket = 'aieng-workspaces' and a.storage_state = 'pending';
    if aid is null then perform product.fail('NOT_FOUND', 'pending artifact'); end if;
    if not exists (select 1 from storage.objects so where so.bucket_id = 'aieng-workspaces' and so.name = (select object_path from orchestration.artifact where id = aid)) then
      perform product.fail('STORAGE_OBJECT_MISSING', 'object not present in storage');
    end if;
    if (pl ->> 'verified_sha256') is distinct from (select sha256 from orchestration.artifact where id = aid) then
      -- stays pending: the worker removes the bad object and re-uploads the registered bytes (artifacts are append-only)
      return jsonb_build_object('state', 'pending', 'reason', 'digest_mismatch');
    end if;
    update orchestration.artifact set storage_state = 'available', available_at = now() where id = aid;
    return jsonb_build_object('state', 'available');

  when 'add_policy_version' then
    insert into access.policy_version(tenant_id, version, body, body_sha256, active_from)
    values (t, (select coalesce(max(version), 0) + 1 from access.policy_version where tenant_id = t), pl -> 'body', product.sha256_text((pl -> 'body')::text), now())
    returning id into rid;
    return jsonb_build_object('policyVersionId', rid);

  when 'set_account_profile' then
    insert into access.account_profile(tenant_id, principal_id, seq, age_band, jurisdiction, established_by, eligibility, policy_version_id)
    values (t, (pl ->> 'principal_id')::uuid,
            (select coalesce(max(seq), 0) + 1 from access.account_profile where tenant_id = t and principal_id = (pl ->> 'principal_id')::uuid),
            pl ->> 'age_band', pl ->> 'jurisdiction', pl ->> 'established_by', pl ->> 'eligibility', (product.policy() ->> 'policy_version_id')::uuid);
    return jsonb_build_object('ok', true);

  when 'grant_publisher' then
    insert into authoring.publisher_grant(tenant_id, principal_id, channel) values (t, (pl ->> 'principal_id')::uuid, 'official_catalog');
    return jsonb_build_object('ok', true);

  when 'record_equivalence_check' then
    update learning.equivalence_request set assistant_check = pl -> 'check', state = case when state = 'proposed' then 'checked' else state end
     where id = (pl ->> 'request_id')::uuid;
    return jsonb_build_object('ok', true);

  when 'issue_provided_credential' then
    insert into access.provided_credential(tenant_id, principal_id, provider_key, secret_handle, spend_limit_usd, period, expires_at)
    values (t, (pl ->> 'principal_id')::uuid, pl ->> 'provider_key', pl ->> 'secret_handle', (pl ->> 'spend_limit_usd')::numeric, pl ->> 'period',
            now() + make_interval(hours => coalesce((pl ->> 'ttl_hours')::int, 168))) returning id into rid;
    return jsonb_build_object('providedCredentialId', rid);

  when 'set_deployment_status' then
    update authoring.deployment set status = pl ->> 'status', retired_at = case when pl ->> 'status' = 'retired' then now() end where id = (pl ->> 'deployment_id')::uuid;
    return jsonb_build_object('ok', true);

  when 'restrict_source' then
    insert into access.source_restriction(tenant_id, artifact_id, capture_id, kind, effect, reason)
    values (t, (pl ->> 'artifact_id')::uuid, (pl ->> 'capture_id')::uuid, pl ->> 'kind', pl ->> 'effect', pl ->> 'reason') returning id into rid;
    return jsonb_build_object('restrictionId', rid);

  when 'index_passages' then
    ws := (pl ->> 'workspace_id')::uuid;
    perform retrieval.retire_items_for_passages((select coalesce(array_agg(id), '{}') from library.passage
       where workspace_id = ws and coalesce(revision_id, artifact_id, message_id) = coalesce((pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, (pl ->> 'message_id')::uuid)
         and procedure_version = pl ->> 'procedure_version'));
    perform pg_catalog.set_config('product.purge', 'on', true);
    delete from library.passage where workspace_id = ws and coalesce(revision_id, artifact_id, message_id) = coalesce((pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, (pl ->> 'message_id')::uuid)
       and procedure_version = pl ->> 'procedure_version';
    perform pg_catalog.set_config('product.purge', 'off', true);
    -- Build 08 lens rule: released course material is ours (tier 1, space own_content); everything else is private to its workspace (space learner_notes)
    select case when (pl ->> 'revision_id') is not null and exists (select 1 from authoring.release_item i where i.revision_id = (pl ->> 'revision_id')::uuid and i.disposition in ('include','snapshot'))
                then 'ours' else 'private' end into lens_;
    n := 0;
    for x in select * from jsonb_array_elements(pl -> 'passages') loop
      insert into library.passage(tenant_id, workspace_id, revision_id, artifact_id, message_id, passage_no, locator, text, content_sha256, procedure_version)
      values (t, ws, (pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, (pl ->> 'message_id')::uuid, n,
              x -> 'locator', x ->> 'text', product.sha256_text(x ->> 'text'), pl ->> 'procedure_version')
      returning id into rid;
      perform retrieval.index_text_item(case lens_ when 'ours' then 'own_content' else 'learner_notes' end, 'passage', rid, x ->> 'text', lens_,
                                        case lens_ when 'ours' then 1::smallint else null end, 'passage',
                                        p_workspace_id => ws, p_document_type_code => case lens_ when 'ours' then 'course_module' end, p_observed_at => now());
      n := n + 1;
    end loop;
    insert into library.preparation(tenant_id, workspace_id, revision_id, artifact_id, stage, procedure_version, status, attempt_count, output_ref)
    values (t, ws, (pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, 'index_lexical', pl ->> 'procedure_version', 'succeeded', 1, jsonb_build_object('passages', n, 'lens', lens_))
    on conflict do nothing;
    return jsonb_build_object('passages', n, 'lens', lens_);

  when 'record_embeddings' then
    ws := (pl ->> 'workspace_id')::uuid;
    if not product.processing_allowed((pl ->> 'principal_id')::uuid, 'embedding', pl ->> 'processor_key') then
      perform product.fail('CONSENT_REQUIRED', 'embedding processing is not authorized for the content owner');
    end if;
    n := 0;
    for x in select * from jsonb_array_elements(pl -> 'items') loop
      if not exists (select 1 from library.passage pa join authoring.work_revision rv on rv.id = pa.revision_id join library.resource_control c on c.work_id = rv.work_id
                      where pa.id = (x ->> 'passage_id')::uuid and pa.workspace_id = ws and c.semantic_index and c.excluded_at is null) then
        perform product.fail('FORBIDDEN', 'semantic indexing not enabled for this passage');
      end if;
      -- Build 08: the embedding lands in the one stack (partition of the passage's own space); the payload space_version_id is ignored
      select vi.id into rid from retrieval.vector_item vi join retrieval.projection_target pt on pt.id = vi.projection_target_id
       where pt.passage_id = (x ->> 'passage_id')::uuid and vi.lifecycle = 'active' and vi.workspace_id = ws limit 1;
      if rid is null then perform product.fail('NOT_FOUND', 'passage is not indexed'); end if;
      perform retrieval.store_embedding(rid, (x ->> 'embedding')::extensions.halfvec(1536), product.sha256_text(x ->> 'embedding'));
      n := n + 1;
    end loop;
    return jsonb_build_object('embeddings', n);

  when 'record_grading' then
    select * into s from learning.submission where id = (pl ->> 'submission_id')::uuid;
    if s.id is null then perform product.fail('NOT_FOUND', 'submission'); end if;
    if (select storage_state from orchestration.artifact where id = s.manifest_artifact_id) <> 'available' then
      perform product.fail('CONFLICT', 'submission manifest not yet stored and verified');
    end if;
    insert into learning.grading_run(tenant_id, workspace_id, submission_id, pipeline_revision_id, kind, runner, check_bundle_sha256, status, failure_class, reason,
                                     runtime_ref, requested_by, started_at, finished_at)
    values (t, s.workspace_id, s.id, (pl ->> 'pipeline_revision_id')::uuid, pl ->> 'kind', coalesce(pl -> 'runner', '{}'), pl ->> 'check_bundle_sha256',
            pl ->> 'status', pl ->> 'failure_class', pl ->> 'reason', coalesce(pl -> 'runtime_ref', '{}'), coalesce(pl ->> 'requested_by', 'initial'), now(), now())
    returning id into rid;
    if pl ->> 'status' <> 'completed' then
      return jsonb_build_object('gradingRunId', rid, 'result', null, 'note', 'infrastructure/abstention outcome recorded; no result, no learner failure');
    end if;
    for x in select * from jsonb_array_elements(pl -> 'criteria') loop
      insert into learning.criterion_result(tenant_id, workspace_id, grading_run_id, criterion_key, value, visibility, judged_by, judgment, explanation, evidence_refs)
      values (t, s.workspace_id, rid, x ->> 'criterion_key', x -> 'value', coalesce(x ->> 'visibility', 'student_visible'), x ->> 'judged_by', x -> 'judgment',
              x ->> 'explanation', coalesce(x -> 'evidence_refs', '[]'));
    end loop;
    select body -> 'metadata' -> 'finalization' into pol from authoring.work_revision where id = (pl ->> 'finalization_policy_revision_id')::uuid;
    auto := coalesce((pol ->> 'auto')::boolean, false)
        and not exists (select 1 from jsonb_array_elements(pl -> 'criteria') c where c ->> 'judged_by' = 'model'
                          and ((c -> 'judgment' ->> 'status') <> 'answered' or coalesce((c -> 'judgment' ->> 'confidence')::numeric, 0) < coalesce((pol ->> 'min_confidence')::numeric, 1)))
        and not exists (select 1 from jsonb_each_text(pl -> 'outcomes') o where o.value = 'insufficient_evidence');
    select coalesce(max(sequence_no), 0) + 1 into n from learning.assessment_result where submission_id = s.id;
    insert into learning.assessment_result(tenant_id, workspace_id, submission_id, sequence_no, outcomes, status, finalized_by, finalization_policy_revision_id, finalized_at, reason)
    values (t, s.workspace_id, s.id, n, pl -> 'outcomes', 'provisional', case when auto then 'auto' end,
            case when auto then (pl ->> 'finalization_policy_revision_id')::uuid end, case when auto then now() end,
            case when auto then 'auto-finalized under policy' else 'awaiting human review: policy conditions not met' end)
    returning id into aid;
    if auto then perform product.finalize(aid, 'auto', (pl ->> 'finalization_policy_revision_id')::uuid); end if;
    return jsonb_build_object('gradingRunId', rid, 'resultId', aid, 'status', case when auto then 'final' else 'provisional' end);

  else
    perform product.fail('UNKNOWN_OPERATION', op);
  end case;
end $$;
-- Build 08 R2 draft. Part 4: vocabulary seeds (one home for numbers, new verbs, assertion mappings), L1 catalog views, L2 time/change queries.

-- ---------------------------------------------------------------------------------------------- 20. vocabulary: numbers are fact streams
delete from temporal.stream_kind where code = 'model_offering_price';
insert into temporal.stream_kind(code, subject_mode, subject_kinds, status_values, requires_amount, unit_values, requires_ref_entity, ref_entity_kinds, payload_schema, description) values
  ('offering_price', 'entity', '{model_offering,compute_offering}', null, true, '{USD_per_1M_tokens,USD_per_1K_tokens,USD_per_request,USD_per_minute,USD_per_image,USD_per_hour,USD_per_GB,USD_per_month}', false, null,
   '{"type":"object","required":["meter"],"properties":{"meter":{"type":"string"},"tier":{"type":"string"},"region":{"type":"string"},"condition":{"type":"string"},"context_band":{"type":"string"}}}',
   'Price of one meter of an offering (input_tokens, output_tokens, cached_input_tokens, batch_input_tokens ...); scope_key = meter|tier|region; amount+currency+unit normalized; observation_bounded from the capture'),
  ('model_context_window', 'entity', '{ai_model_version}', null, true, '{tokens}', false, null, '{"type":"object"}', 'Maximum context window in tokens'),
  ('model_max_output_tokens', 'entity', '{ai_model_version}', null, true, '{tokens}', false, null, '{"type":"object"}', 'Maximum output tokens'),
  ('model_capability', 'entity', '{ai_model_version}', '{supported,unsupported,preview,unknown}', false, null, false, null, '{"type":"object","properties":{"detail":{"type":"string"}}}', 'Capability status per scope_key: tool_use, structured_output, reasoning, vision, audio, open_weights, prompt_caching, batch, fine_tuning'),
  ('model_knowledge_cutoff', 'entity', '{ai_model_version}', null, false, null, false, null, '{"type":"object","required":["cutoff_on"],"properties":{"cutoff_on":{"type":"string"}}}', 'Training data cutoff as stated by the developer'),
  ('model_availability', 'entity', '{ai_model_version,model_offering}', '{announced,preview,generally_available,deprecated,retired}', false, null, false, null, '{"type":"object"}', 'Lifecycle availability of a model version or offering'),
  ('benchmark_score', 'entity', '{ai_model_version,product_version,library_release}', null, true, '{percent,score,elo,pass_at_1,seconds,usd,count}', true, '{benchmark}', '{"type":"object","properties":{"setting":{"type":"string"},"source_kind":{"type":"string","enum":["first_party","third_party","own"]},"harness":{"type":"string"},"comparison":{"type":"string"}}}', 'A benchmark result: subject version, ref benchmark, amount+unit, setting and who measured it (first-party self-report vs third party)'),
  ('repository_stars', 'entity', '{repository}', null, true, '{count}', false, null, '{"type":"object"}', 'GitHub stars at observation'),
  ('repository_forks', 'entity', '{repository}', null, true, '{count}', false, null, '{"type":"object"}', 'Forks at observation'),
  ('repository_open_issues', 'entity', '{repository}', null, true, '{count}', false, null, '{"type":"object"}', 'Open issues at observation'),
  ('package_downloads', 'entity', '{library}', null, true, '{per_week,per_month,total}', false, null, '{"type":"object","properties":{"registry":{"type":"string"}}}', 'Package downloads for a window'),
  ('media_views', 'entity', '{media_work,talk}', null, true, '{count}', false, null, '{"type":"object","properties":{"platform":{"type":"string"}}}', 'Recording views at observation'),
  ('paper_citations', 'entity', '{paper}', null, true, '{count}', false, null, '{"type":"object","properties":{"source":{"type":"string"}}}', 'Citation count at observation'),
  ('organization_headcount', 'entity', '{organization}', null, true, '{count}', false, null, '{"type":"object","properties":{"source":{"type":"string"}}}', 'Headcount at observation')
on conflict (code) do nothing;
update temporal.stream_kind set subject_kinds = '{library,repository,mcp_server,agent_skill,product,ai_model_version}', description = 'License of a software thing or open-weights model (payload spdx), as stated by the publisher' where code = 'library_license';

insert into taxonomy.relationship_kind(code, from_kinds, to_kinds, temporal, "symmetric", inverse_label, description, property_schema) values
  ('has_code', '{talk,paper,media_work,story,case_study}', '{repository}', false, false, 'code_for', 'A work points at the repository that holds its code', '{"type":"object"}'),
  ('compatible_with', '{library_release,product_version,ai_model_version,mcp_server}', '{library_release,product_version,ai_model_version,ai_protocol_version}', false, false, 'compatible_with', 'A stated compatibility between versions (constraint in properties)', '{"type":"object","properties":{"constraint":{"type":"string"},"stated_by":{"type":"string"}}}'),
  ('integrates_with', '{library,product,mcp_server,agent_skill}', '{library,product,mcp_server,ai_model,ai_protocol}', true, false, 'integrated_by', 'A documented integration between software things', '{"type":"object","properties":{"kind":{"type":"string"}}}'),
  ('published_in', '{paper}', '{industry_event,media_channel,organization}', false, false, 'published', 'Venue of a paper', '{"type":"object"}')
on conflict (code) do nothing;
update taxonomy.relationship_kind set from_kinds = '{story,case_study,talk,paper,media_work}' where code = 'about';
update taxonomy.relationship_kind set to_kinds = array_cat(to_kinds, '{talk,paper}') where code = 'has_code' and not ('talk' = any(to_kinds));

-- ---------------------------------------------------------------------------------------------- 21. assertion mappings (act 3 as data)
alter table content.unit_assertion_mapping drop constraint unit_assertion_mapping_target_kind_check;
alter table content.unit_assertion_mapping add constraint unit_assertion_mapping_target_kind_check check (target_kind in ('stream','relationship','event','entity_attribute','claim_candidate','guidance_item'));
alter table content.unit_assertion_mapping drop constraint mapping_target_consistent;
alter table content.unit_assertion_mapping add constraint mapping_target_consistent check ((target_kind = 'stream' and stream_kind is not null) or (target_kind = 'relationship' and relationship_kind is not null) or (target_kind = 'event' and event_kind is not null) or target_kind in ('entity_attribute','claim_candidate','guidance_item'));
insert into content.unit_assertion_mapping(unit_kind, document_type_code, source_role_code, target_kind, stream_kind, relationship_kind, event_kind, subject_template, value_template, qualifier_template, time_template, deterministic, risk_floor, description) values
  ('price_row', 'pricing_page', 'first_party', 'stream', 'offering_price', null, null, '{"entity":"$role.offering"}', '{"amount":"$attr.amount","currency":"$attr.currency","unit":"$attr.unit"}', '{"scope_key":"$attr.meter|$attr.tier|$attr.region","payload":{"meter":"$attr.meter","tier":"$attr.tier","region":"$attr.region","condition":"$attr.condition"}}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'A vendor price row establishes the vendor''s own price as of the capture (cheap path: act 1 + deterministic act 3 + first-party authority)'),
  ('release_entry', 'changelog', 'first_party', 'event', null, null, 'release_published', '{"entity":"$role.release"}', '{"payload":{"version":"$attr.version","breaking":"$attr.breaking","title":"$attr.title","url":"$attr.url"}}', '{}', '{"occurred_at":"$attr.released_on","mode":"actual"}', true, 'L0', 'A first-party changelog entry establishes the release and its date'),
  ('release_entry', 'github_release', 'first_party', 'event', null, null, 'release_published', '{"entity":"$role.release"}', '{"payload":{"version":"$attr.version","breaking":"$attr.breaking","title":"$attr.title","url":"$attr.url"}}', '{}', '{"occurred_at":"$attr.released_on","mode":"actual"}', true, 'L0', 'A GitHub release entry establishes the release and its date'),
  ('release_entry', 'release_notes', 'first_party', 'event', null, null, 'release_published', '{"entity":"$role.release"}', '{"payload":{"version":"$attr.version","breaking":"$attr.breaking","title":"$attr.title","url":"$attr.url"}}', '{}', '{"occurred_at":"$attr.released_on","mode":"actual"}', true, 'L0', 'Release notes establish the release and its date'),
  ('eval_row', 'model_card', 'first_party', 'stream', 'benchmark_score', null, null, '{"entity":"$role.model","ref_entity":"$role.benchmark"}', '{"amount":"$attr.score","unit":"$attr.unit"}', '{"scope_key":"$attr.benchmark|$attr.setting","payload":{"setting":"$attr.setting","source_kind":"first_party"}}', '{"temporal_basis":"observation_bounded","valid_from":"$version.published_at"}', true, 'L0', 'A first-party evaluation row is a self-reported score, kept with source_kind first_party'),
  ('eval_row', 'product_page', 'first_party', 'stream', 'benchmark_score', null, null, '{"entity":"$role.model","ref_entity":"$role.benchmark"}', '{"amount":"$attr.score","unit":"$attr.unit"}', '{"scope_key":"$attr.benchmark|$attr.setting","payload":{"setting":"$attr.setting","source_kind":"first_party"}}', '{"temporal_basis":"observation_bounded","valid_from":"$version.published_at"}', true, 'L0', 'A model page evaluation row is a self-reported score'),
  ('spec_field', 'product_page', 'first_party', 'stream', 'model_context_window', null, null, '{"entity":"$role.model"}', '{"amount":"$attr.value","unit":"tokens"}', '{"when":{"field":"context_window"}}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'Context window from a model page spec field'),
  ('spec_field', 'product_page', 'first_party', 'stream', 'model_max_output_tokens', null, null, '{"entity":"$role.model"}', '{"amount":"$attr.value","unit":"tokens"}', '{"when":{"field":"max_output_tokens"}}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'Max output tokens from a model page spec field'),
  ('spec_field', 'product_page', 'first_party', 'stream', 'model_knowledge_cutoff', null, null, '{"entity":"$role.model"}', '{"payload":{"cutoff_on":"$attr.value"}}', '{"when":{"field":"knowledge_cutoff"}}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'Knowledge cutoff from a model page spec field'),
  ('spec_field', 'product_page', 'first_party', 'stream', 'model_capability', null, null, '{"entity":"$role.model"}', '{"status":"$attr.value"}', '{"when":{"field_in":["tool_use","structured_output","reasoning","vision","audio","open_weights","prompt_caching","batch","fine_tuning"]},"scope_key":"$attr.field"}', '{"temporal_basis":"observation_bounded","valid_from":"$capture.captured_at"}', true, 'L0', 'Capability status from a model page spec field'),
  ('talk_header', 'aie_talk', 'event_organizer', 'relationship', null, 'presented_by', null, '{"from":"$role.talk","to":"$role.speaker"}', '{}', '{}', '{}', true, 'L0', 'The organizer''s session record establishes who presented the talk'),
  ('talk_header', 'aie_talk', 'event_organizer', 'relationship', null, 'presented_at', null, '{"from":"$role.talk","to":"$role.event"}', '{}', '{}', '{}', true, 'L0', 'The organizer''s session record establishes the event'),
  ('talk_resource', 'aie_talk', 'event_organizer', 'relationship', null, 'has_code', null, '{"from":"$role.talk","to":"$role.repository"}', '{}', '{"when":{"resource_kind":"repository"}}', '{}', true, 'L0', 'A repository listed under a talk''s Resources is the talk''s code'),
  ('transcript_segment', 'aie_talk', 'event_organizer', 'claim_candidate', null, null, null, '{"speaker":"$talk.speakers","timecode":"$attr.t0_ms"}', '{}', '{}', '{}', false, 'L1', 'What a speaker says at a timecode is a claim candidate attributed to the talk (no speaker labels in panel transcripts), never a fact until verified'),
  ('talk_writeup', 'aie_talk', 'event_organizer', 'claim_candidate', null, null, null, '{"speaker":"$talk.speakers"}', '{}', '{}', '{}', false, 'L1', 'A talk write-up heading such as "X teaches the model Y" is a claim candidate with speaker role'),
  ('post_paragraph', null, 'third_party_editorial', 'claim_candidate', null, null, null, '{"mentions":"$role.mentions"}', '{}', '{}', '{"learned_at":"$version.published_at"}', false, 'L1', 'A third-party restatement sets learned-at, never valid-from; conflicts with first-party values are kept as disputed'),
  ('code_example', 'framework_docs_page', 'first_party', 'guidance_item', null, null, null, '{"entity":"$role.software"}', '{"kind":"implementation_example"}', '{}', '{}', true, 'L0', 'A docs code example becomes an implementation_example guidance item bound to the software version'),
  ('docs_section', 'framework_docs_page', 'first_party', 'claim_candidate', null, null, null, '{"entity":"$role.software"}', '{}', '{"when":{"has_version_note":true}}', '{}', false, 'L1', 'A version note in docs is a candidate compatibility/breaking statement');

-- ---------------------------------------------------------------------------------------------- 22. L2 helpers: current fact slots
create or replace function api.fact_amount(p_entity uuid, p_kind text, p_scope_key text default null, p_at timestamptz default now()) returns numeric
language sql stable security definer set search_path = '' as $$
  select s.amount from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where st.subject_entity_id = p_entity and st.kind = p_kind and (p_scope_key is null or st.scope_key = p_scope_key) and s.k_to is null and s.valid_during @> p_at and s.belief = 'accepted'
  order by s.created_at desc limit 1
$$;
create or replace function api.fact_status(p_entity uuid, p_kind text, p_scope_key text default null, p_at timestamptz default now()) returns text
language sql stable security definer set search_path = '' as $$
  select s.status from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where st.subject_entity_id = p_entity and st.kind = p_kind and (p_scope_key is null or st.scope_key = p_scope_key) and s.k_to is null and s.valid_during @> p_at and s.belief = 'accepted'
  order by s.created_at desc limit 1
$$;
create or replace function api.fact_payload(p_entity uuid, p_kind text, p_scope_key text default null, p_at timestamptz default now()) returns jsonb
language sql stable security definer set search_path = '' as $$
  select s.payload from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where st.subject_entity_id = p_entity and st.kind = p_kind and (p_scope_key is null or st.scope_key = p_scope_key) and s.k_to is null and s.valid_during @> p_at and s.belief = 'accepted'
  order by s.created_at desc limit 1
$$;
create or replace function api.price_per_1m(p_offering uuid, p_meter text, p_at timestamptz default now()) returns numeric
language sql stable security definer set search_path = '' as $$
  select case s.unit when 'USD_per_1M_tokens' then s.amount when 'USD_per_1K_tokens' then s.amount * 1000 end
  from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where st.subject_entity_id = p_offering and st.kind = 'offering_price' and s.payload->>'meter' = p_meter and coalesce(s.payload->>'tier','standard') in ('standard','default')
    and s.k_to is null and s.valid_during @> p_at and s.belief = 'accepted' and s.currency = 'USD'
  order by s.created_at desc limit 1
$$;
create or replace function api.related(p_entity uuid, p_kind text, p_direction text default 'outgoing', p_at timestamptz default now()) returns setof uuid
language sql stable security definer set search_path = '' as $$
  select case when p_direction = 'outgoing' then r.to_entity_id else r.from_entity_id end
  from catalog.relationship r join taxonomy.relationship_kind rk on rk.code = r.kind
  where r.kind = p_kind and r.k_to is null and ((p_direction = 'outgoing' and r.from_entity_id = p_entity) or (p_direction = 'incoming' and r.to_entity_id = p_entity))
    and (not rk.temporal or exists (select 1 from temporal.stream st join temporal.segment s on s.stream_id = st.id where st.subject_relationship_id = r.id and st.kind = 'relationship_active' and s.status = 'active' and s.k_to is null and s.valid_during @> p_at))
$$;
create or replace function api.names(p_ids uuid[]) returns text[] language sql stable security definer set search_path = '' as $$
  select coalesce(array_agg(e.display_name order by e.display_name), '{}') from catalog.entity e where e.id = any(p_ids)
$$;
grant execute on function api.fact_amount(uuid,text,text,timestamptz), api.fact_status(uuid,text,text,timestamptz), api.fact_payload(uuid,text,text,timestamptz), api.price_per_1m(uuid,text,timestamptz), api.related(uuid,text,text,timestamptz), api.names(uuid[]) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

-- ---------------------------------------------------------------------------------------------- 23. L1 catalog views (derived from entities, attributes and current facts; never stored twice)
create or replace function api.models_at(p_at timestamptz default now()) returns table(
  model_version_id uuid, model text, slug text, version_label text, provider_model_id text, model_family_id uuid, model_family text, developer_id uuid, developer text,
  released_on date, context_tokens numeric, max_output_tokens numeric, modalities text[], tool_use text, structured_output text, reasoning text, vision text, open_weights boolean,
  knowledge_cutoff text, availability text, min_input_usd_per_1m numeric, min_output_usd_per_1m numeric, offering_count bigint, observed_at timestamptz, as_of_knowledge_seq bigint)
language sql stable security definer set search_path = '' as $$
  with head as (select coalesce(max(h.knowledge_seq), 0) k from temporal.knowledge_head h where h.tenant_id = util.current_tenant_id())
  select v.id, v.display_name, v.slug, v.attributes->>'version_label', v.attributes->>'provider_model_id',
    fam.id, fam.display_name, dev.id, dev.display_name,
    (select lower(o.occurred_during)::date from temporal.event e join temporal.event_occurrence o on o.event_id = e.id where e.subject_entity_id = v.id and e.kind = 'model_version_released' and o.k_to is null order by lower(o.occurred_during) limit 1),
    api.fact_amount(v.id, 'model_context_window', null, p_at), api.fact_amount(v.id, 'model_max_output_tokens', null, p_at),
    coalesce((select array_agg(x) from jsonb_array_elements_text(coalesce(v.attributes->'modalities', '[]'::jsonb)) x), '{}'),
    api.fact_status(v.id, 'model_capability', 'tool_use', p_at), api.fact_status(v.id, 'model_capability', 'structured_output', p_at), api.fact_status(v.id, 'model_capability', 'reasoning', p_at), api.fact_status(v.id, 'model_capability', 'vision', p_at),
    coalesce((v.attributes->>'open_weights')::boolean, api.fact_status(v.id, 'model_capability', 'open_weights', p_at) = 'supported', false),
    api.fact_payload(v.id, 'model_knowledge_cutoff', null, p_at)->>'cutoff_on', api.fact_status(v.id, 'model_availability', null, p_at),
    (select min(api.price_per_1m(o.id, 'input_tokens', p_at)) from catalog.entity o where o.id in (select api.related(v.id, 'offered_as', 'outgoing', p_at))),
    (select min(api.price_per_1m(o.id, 'output_tokens', p_at)) from catalog.entity o where o.id in (select api.related(v.id, 'offered_as', 'outgoing', p_at))),
    (select count(*) from api.related(v.id, 'offered_as', 'outgoing', p_at)),
    (select max(s.created_at) from temporal.segment s join temporal.stream st on st.id = s.stream_id where st.subject_entity_id = v.id),
    head.k
  from catalog.entity v cross join head
  left join lateral (select e.* from catalog.entity e where e.id in (select api.related(v.id, 'version_of', 'outgoing', p_at)) limit 1) fam on true
  left join lateral (select e.* from catalog.entity e where e.id in (select api.related(fam.id, 'develops', 'incoming', p_at)) limit 1) dev on true
  where v.tenant_id = util.current_tenant_id() and v.kind = 'ai_model_version' and v.lifecycle = 'active'
$$;
create or replace view api.models as select * from api.models_at(now());
comment on view api.models is 'L1: one row per model version with developer, release date, context, modalities, capability statuses, knowledge cutoff, availability and the minimum current price per 1M tokens across offerings. Filter/compare/rank here; no embeddings.';

create or replace function api.model_offerings_at(p_at timestamptz default now()) returns table(
  offering_id uuid, offering text, offering_key text, model_version_id uuid, model text, provider_id uuid, provider text, region text, tier text,
  input_usd_per_1m numeric, output_usd_per_1m numeric, cached_input_usd_per_1m numeric, batch_input_usd_per_1m numeric, availability text, pricing_url text,
  price_valid_from timestamptz, price_observed_at timestamptz, price_claim_id uuid, price_locator_id uuid, as_of_knowledge_seq bigint)
language sql stable security definer set search_path = '' as $$
  with head as (select coalesce(max(h.knowledge_seq), 0) k from temporal.knowledge_head h where h.tenant_id = util.current_tenant_id())
  select o.id, o.display_name, o.attributes->>'offering_key', mv.id, mv.display_name, pr.id, pr.display_name, o.attributes->>'region', o.attributes->>'tier',
    api.price_per_1m(o.id, 'input_tokens', p_at), api.price_per_1m(o.id, 'output_tokens', p_at), api.price_per_1m(o.id, 'cached_input_tokens', p_at), api.price_per_1m(o.id, 'batch_input_tokens', p_at),
    api.fact_status(o.id, 'model_availability', null, p_at), o.attributes->>'pricing_url',
    ip.valid_from, ip.created_at, ip.primary_claim_id, (select ss.locator_id from evidence.segment_support ss where ss.segment_id = ip.id and ss.role = 'supports' limit 1), head.k
  from catalog.entity o cross join head
  left join lateral (select e.* from catalog.entity e where e.id in (select api.related(o.id, 'offered_as', 'incoming', p_at)) limit 1) mv on true
  left join lateral (select e.* from catalog.entity e where e.id in (select api.related(o.id, 'offered_by', 'outgoing', p_at)) limit 1) pr on true
  left join lateral (select s.id, lower(s.valid_during) valid_from, s.created_at, s.primary_claim_id from temporal.segment s join temporal.stream st on st.id = s.stream_id
                     where st.subject_entity_id = o.id and st.kind = 'offering_price' and s.payload->>'meter' = 'input_tokens' and s.k_to is null and s.valid_during @> p_at order by s.created_at desc limit 1) ip on true
  where o.tenant_id = util.current_tenant_id() and o.kind = 'model_offering' and o.lifecycle = 'active'
$$;
create or replace view api.model_offerings as select * from api.model_offerings_at(now());
comment on view api.model_offerings is 'L1: one row per offering (model as sold by a provider) with normalized USD per 1M tokens for input/output/cached/batch, availability and the exact claim + locator behind the input price.';

create or replace view api.organizations as
  select e.id as organization_id, e.display_name as organization, e.slug, e.attributes->>'org_kind' org_kind, e.attributes->>'website_url' website_url, e.attributes->>'country_code' country_code, e.attributes->>'founded_on' founded_on, e.summary,
    (select count(*) from api.related(e.id, 'develops', 'outgoing')) developed_count,
    (select count(*) from api.related(e.id, 'offered_by', 'incoming')) offering_count,
    (select count(*) from api.related(e.id, 'employed_by', 'incoming')) people_count,
    api.fact_amount(e.id, 'organization_headcount') headcount
  from catalog.entity e where e.tenant_id = util.current_tenant_id() and e.kind = 'organization' and e.lifecycle = 'active';
comment on view api.organizations is 'L1: organizations with kind, site, country, founding date and counts of what they develop, sell and employ.';

create or replace view api.people as
  select e.id as person_id, e.display_name as person, e.slug, e.attributes->>'title' title, e.attributes->>'profile_url' profile_url,
    api.names((select array_agg(x) from api.related(e.id, 'employed_by', 'outgoing') x)) affiliations,
    (select count(*) from api.related(e.id, 'presented_by', 'incoming')) talk_count,
    (select count(*) from api.related(e.id, 'authored_by', 'incoming')) work_count
  from catalog.entity e where e.tenant_id = util.current_tenant_id() and e.kind = 'person' and e.lifecycle = 'active';
comment on view api.people is 'L1: people with current affiliations (employed_by, as of now) and how many talks/works they presented or authored.';

create or replace view api.software as
  select e.id as software_id, e.kind, e.display_name as software, e.slug, e.attributes->>'ecosystem' ecosystem, e.attributes->>'package_name' package_name, e.attributes->>'category' category,
    e.attributes->>'docs_url' docs_url, coalesce(e.attributes->>'repository_url', (select 'https://'||(x.attributes->>'host')||'/'||(x.attributes->>'owner')||'/'||(x.attributes->>'name') from catalog.entity x where x.id in (select api.related(e.id, 'backed_by_repository', 'outgoing')) limit 1)) repository_url,
    api.names((select array_agg(x) from api.related(e.id, 'develops', 'incoming') x)) developers,
    api.names((select array_agg(x) from api.related(e.id, 'maintains', 'incoming') x)) maintainers,
    lr.version_label latest_release, lr.released_on latest_release_on,
    coalesce(api.fact_payload(e.id, 'library_license')->>'spdx', e.attributes->>'license') license,
    api.fact_amount(coalesce((select api.related(e.id, 'backed_by_repository', 'outgoing') limit 1), e.id), 'repository_stars') stars,
    api.fact_amount(e.id, 'package_downloads') downloads,
    e.attributes->>'hosting' mcp_hosting, e.attributes->>'auth' mcp_auth, (e.attributes->>'is_official')::boolean mcp_is_official,
    api.names((select array_agg(x) from api.related(e.id, 'implements_protocol', 'outgoing') x)) protocols,
    api.names((select array_agg(x) from api.related(e.id, 'instance_of_concept', 'outgoing') x)) concepts,
    e.summary
  from catalog.entity e
  left join lateral (select r.attributes->>'version_label' version_label, (r.attributes->>'released_on')::date released_on from catalog.entity r
                     where r.kind = 'library_release' and r.id in (select api.related(e.id, 'version_of', 'incoming')) order by (r.attributes->>'released_on') desc nulls last limit 1) lr on true
  where e.tenant_id = util.current_tenant_id() and e.kind in ('library','repository','mcp_server','agent_skill','product','ai_protocol') and e.lifecycle = 'active';
comment on view api.software is 'L1: libraries, repositories, MCP servers, agent skills, products and protocols in one table with ecosystem, docs/repo links, developers, latest release, license, stars/downloads, MCP hosting/auth/official flags, protocols and concepts.';
create or replace view api.libraries as select * from api.software where kind = 'library';
create or replace view api.repositories as select * from api.software where kind = 'repository';
create or replace view api.mcp_servers as select * from api.software where kind = 'mcp_server';
create or replace view api.agent_skills as select * from api.software where kind = 'agent_skill';

create or replace view api.software_releases as
  select r.id as release_id, r.display_name as release, s.id as software_id, s.display_name as software, s.kind software_kind, r.attributes->>'version_label' version_label,
    coalesce((select lower(o.occurred_during) from temporal.event e join temporal.event_occurrence o on o.event_id = e.id where e.subject_entity_id = r.id and e.kind = 'release_published' and o.k_to is null order by lower(o.occurred_during) limit 1), (r.attributes->>'released_on')::timestamptz) released_at,
    coalesce((r.attributes->>'breaking')::boolean, false) breaking, coalesce((select array_agg(x) from jsonb_array_elements_text(coalesce(r.attributes->'highlights', '[]'::jsonb)) x), '{}') highlights,
    r.attributes->>'release_url' release_url,
    (select o.k_from from temporal.event e join temporal.event_occurrence o on o.event_id = e.id where e.subject_entity_id = r.id and e.kind = 'release_published' and o.k_to is null limit 1) learned_k,
    r.created_at observed_at
  from catalog.entity r join catalog.relationship rel on rel.from_entity_id = r.id and rel.kind = 'version_of' and rel.k_to is null join catalog.entity s on s.id = rel.to_entity_id
  where r.tenant_id = util.current_tenant_id() and r.kind = 'library_release' and r.lifecycle = 'active';
comment on view api.software_releases is 'L1/L2: every known release of a software thing with its date, breaking flag, highlights and the knowledge sequence it was learned at. Order by released_at for history.';

create or replace view api.talks as
  select w.id as talk_id, w.title, e.slug, w.attributes->>'talk_kind' talk_kind, w.attributes->>'track' track, w.attributes->>'level' level,
    ev.display_name event, ev.id event_id, (ev.attributes->>'starts_on') event_starts_on,
    api.names((select array_agg(x) from api.related(w.id, 'presented_by', 'outgoing') x)) speakers,
    (select array_agg(distinct org.display_name) from api.related(w.id, 'presented_by', 'outgoing') sp join catalog.relationship r on r.from_entity_id = sp and r.kind = 'employed_by' and r.k_to is null join catalog.entity org on org.id = r.to_entity_id) speaker_affiliations,
    api.names((select array_agg(x) from api.related(w.id, 'about', 'outgoing') x)) topics,
    api.names((select array_agg(x) from api.related(w.id, 'has_code', 'outgoing') x)) repositories,
    w.published_at recorded_at, w.duration_ms, w.canonical_url, w.attributes->>'video_url' video_url, w.attributes->>'slides_url' slides_url, w.attributes->>'session_id' session_id,
    (select count(*) from content.document d where d.work_entity_id = w.id) document_count,
    e.summary
  from catalog.work w join catalog.entity e on e.id = w.id
  left join lateral (select x.* from catalog.entity x where x.id in (select api.related(w.id, 'presented_at', 'outgoing')) limit 1) ev on true
  where w.tenant_id = util.current_tenant_id() and w.kind = 'talk' and e.lifecycle = 'active';
comment on view api.talks is 'L1: conference talks with event, track, speakers and their affiliations, topics (about), linked repositories (has_code), recording and slides links.';

create or replace view api.events as
  select e.id as event_id, e.display_name as event, e.slug, e.attributes->>'edition_label' edition_label, e.attributes->>'starts_on' starts_on, e.attributes->>'ends_on' ends_on, e.attributes->>'city' city, e.attributes->>'country' country, e.attributes->>'website_url' website_url,
    api.names((select array_agg(x) from api.related(e.id, 'edition_of', 'outgoing') x)) series,
    api.names((select array_agg(x) from api.related(e.id, 'organized_by', 'outgoing') x)) organizers,
    (select count(*) from api.related(e.id, 'presented_at', 'incoming')) talk_count,
    coalesce((select array_agg(x) from jsonb_array_elements_text(coalesce(e.attributes->'tracks', '[]'::jsonb)) x), '{}') tracks
  from catalog.entity e where e.tenant_id = util.current_tenant_id() and e.kind = 'industry_event' and e.lifecycle = 'active';
comment on view api.events is 'L1: industry events (conference editions) with dates, place, series, organizers, tracks and talk counts.';

create or replace view api.concepts as
  select e.id as concept_id, e.kind, e.display_name as concept, e.slug, e.attributes->>'component' component, e.attributes->>'level' level, coalesce(e.attributes->>'description', e.summary) description,
    (select count(*) from api.related(e.id, 'about', 'incoming')) works_about,
    (select count(*) from api.related(e.id, 'instance_of_concept', 'incoming')) instances,
    (select count(*) from api.related(e.id, 'implements_technique', 'incoming')) implementations,
    (select count(*) from guidance.item_subject s where s.entity_id = e.id) guidance_items,
    (select count(distinct b.revision_id) from authoring.revision_binding b where b.entity_id = e.id and b.relation = 'covers') modules_covering
  from catalog.entity e where e.tenant_id = util.current_tenant_id() and e.kind in ('concept','technique') and e.lifecycle = 'active';
comment on view api.concepts is 'L1: concepts and techniques (RAG, context engineering, harness, sandbox, MCP, skills ...) with how many works discuss them, software implements them, guidance items explain them and our modules cover them.';

create or replace view api.papers as
  select w.id as paper_id, w.title, w.attributes->>'arxiv_id' arxiv_id, w.attributes->>'doi' doi, w.published_at published_at, w.canonical_url,
    api.names((select array_agg(x) from api.related(w.id, 'authored_by', 'outgoing') x)) authors,
    api.names((select array_agg(x) from api.related(w.id, 'published_by', 'outgoing') x)) publishers,
    api.names((select array_agg(x) from api.related(w.id, 'has_code', 'outgoing') x)) repositories,
    api.names((select array_agg(x) from api.related(w.id, 'introduces_technique', 'outgoing') x)) techniques,
    (select count(*) from catalog.relationship r join catalog.entity t on t.id = r.from_entity_id where r.to_entity_id = w.id and r.kind = 'about' and t.kind = 'talk' and r.k_to is null) talks_about,
    api.fact_amount(w.id, 'paper_citations') citations, w.abstract
  from catalog.work w join catalog.entity e on e.id = w.id where w.tenant_id = util.current_tenant_id() and w.kind = 'paper' and e.lifecycle = 'active';
comment on view api.papers is 'L1: papers with identifiers, authors, code repositories, techniques introduced and the talks that discuss them.';

create or replace view api.benchmark_scores as
  select s.id as segment_id, st.subject_entity_id as subject_id, sub.display_name as subject, sub.kind subject_kind, s.ref_entity_id as benchmark_id, b.display_name as benchmark,
    s.amount as score, s.unit, s.payload->>'setting' setting, s.payload->>'source_kind' source_kind, lower(s.valid_during) valid_from, s.k_from learned_k, s.created_at observed_at, s.primary_claim_id claim_id, s.belief
  from temporal.segment s join temporal.stream st on st.id = s.stream_id join catalog.entity sub on sub.id = st.subject_entity_id left join catalog.entity b on b.id = s.ref_entity_id
  where s.tenant_id = util.current_tenant_id() and st.kind = 'benchmark_score' and s.k_to is null;
comment on view api.benchmark_scores is 'L1: benchmark results as facts (one home for numbers): subject version, benchmark, score/unit, setting, who measured it, when it holds and when we learned it.';

create or replace view api.works_authored as
  select w.id as work_id, w.kind, w.slug, r.title, r.id as head_revision_id, r.revision_no, w.workspace_id, ws.kind workspace_kind,
    exists (select 1 from authoring.release_item i where i.revision_id = r.id and i.disposition in ('include','snapshot')) released,
    api.names((select array_agg(b.entity_id) from authoring.revision_binding b where b.revision_id = r.id and b.relation = 'covers' and b.entity_id is not null)) covers_concepts,
    api.names((select array_agg(x) from (select b.entity_id x from authoring.revision_binding b where b.revision_id = r.id and b.relation = 'uses' and b.entity_id is not null union select q.entity_id from authoring.runtime_requirement q where q.revision_id = r.id and q.entity_id is not null) u)) uses_software,
    (select array_agg(q.name||' '||coalesce(q.version_spec,'')) from authoring.runtime_requirement q where q.revision_id = r.id) runtime_requirements,
    r.knowledge_seq, r.created_at, 1::smallint source_tier
  from authoring.work w join authoring.work_revision r on r.id = w.head_revision_id join authoring.workspace ws on ws.id = w.workspace_id
  where w.tenant_id = util.default_tenant_id() and w.kind in ('course','track','module','lesson','activity','report','project_template','challenge','component','experience');
comment on view api.works_authored is 'L1 (ours, tier 1): our courses, modules, lessons, activities, reports and templates at their head revision, whether released, which concepts they cover and which software/versions they use.';

grant select on api.models, api.model_offerings, api.organizations, api.people, api.software, api.libraries, api.repositories, api.mcp_servers, api.agent_skills, api.software_releases, api.talks, api.events, api.concepts, api.papers, api.benchmark_scores, api.works_authored, api.guidance_items
  to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
grant execute on function api.models_at(timestamptz), api.model_offerings_at(timestamptz) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

-- ---------------------------------------------------------------------------------------------- 24. L2 named queries: both clocks, history, flywheel, locators, talk passages
create or replace function api.changes_since(p_since timestamptz, p_stream_kinds text[] default null, p_entity_kinds text[] default null, p_document_types text[] default null) returns table(
  change_source text, change_kind text, learned_at timestamptz, knowledge_seq bigint, world_from timestamptz, subject_entity_id uuid, subject text, stream_kind text, scope_key text,
  old_value jsonb, new_value jsonb, document_id uuid, document_title text, logical_key text, unit_kind text, changed_attributes jsonb, claim_id uuid)
language sql stable security definer set search_path = '' as $$
  with t as (select util.current_tenant_id() id)
  select 'fact', case when s.replaces_segment_id is null then 'opened' else 'replaced' end, kb.recorded_at, s.k_from, lower(s.valid_during), st.subject_entity_id, e.display_name, st.kind, st.scope_key,
    (select jsonb_build_object('amount', o.amount, 'currency', o.currency, 'unit', o.unit, 'status', o.status, 'payload', o.payload) from temporal.segment o where o.id = s.replaces_segment_id),
    jsonb_build_object('amount', s.amount, 'currency', s.currency, 'unit', s.unit, 'status', s.status, 'payload', s.payload), null::uuid, null::text, null::text, null::text, null::jsonb, s.primary_claim_id
  from temporal.segment s join temporal.stream st on st.id = s.stream_id join temporal.knowledge_batch kb on kb.tenant_id = s.tenant_id and kb.knowledge_seq = s.k_from
  left join catalog.entity e on e.id = st.subject_entity_id, t
  where s.tenant_id = t.id and kb.recorded_at > p_since and (p_stream_kinds is null or st.kind = any(p_stream_kinds)) and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  select 'event', ev.kind, kb.recorded_at, o.k_from, lower(o.occurred_during), ev.subject_entity_id, e.display_name, null::text, null::text, null::jsonb, o.payload, null::uuid, null::text, null::text, null::text, null::jsonb, o.primary_claim_id
  from temporal.event_occurrence o join temporal.event ev on ev.id = o.event_id join temporal.knowledge_batch kb on kb.tenant_id = o.tenant_id and kb.knowledge_seq = o.k_from
  left join catalog.entity e on e.id = ev.subject_entity_id, t
  where o.tenant_id = t.id and kb.recorded_at > p_since and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  select 'unit', uc.change_kind, uc.detected_at, null::bigint, dv.published_at, d.work_entity_id, e.display_name, null::text, null::text,
    (select to_jsonb(n.attributes) from content.document_node n where n.id = uc.from_node_id), (select to_jsonb(n.attributes) from content.document_node n where n.id = uc.to_node_id),
    d.id, d.canonical_title, uc.logical_key, uc.unit_kind, uc.changed_attributes, null::uuid
  from content.unit_change uc join content.document d on d.id = uc.document_id join content.document_version dv on dv.id = uc.to_version_id left join catalog.entity e on e.id = d.work_entity_id, t
  where uc.tenant_id = t.id and uc.detected_at > p_since and (p_document_types is null or d.document_type_code = any(p_document_types))
  order by 3 desc
$$;
comment on function api.changes_since is 'L2 both clocks: what changed since a date, as facts opened/replaced (with the old value), events, and unit-level diffs of refreshed documents; learned_at is when we recorded it, world_from is when it holds in the world.';

create or replace function api.price_history(p_offering uuid, p_meter text default 'input_tokens') returns table(
  segment_id uuid, meter text, tier text, region text, amount numeric, currency text, unit text, valid_during tstzrange, belief text, temporal_basis text, k_from bigint, k_to bigint, learned_at timestamptz, retracted_at timestamptz, claim_id uuid, replaces_segment_id uuid)
language sql stable security definer set search_path = '' as $$
  select s.id, s.payload->>'meter', s.payload->>'tier', s.payload->>'region', s.amount, s.currency::text, s.unit, s.valid_during, s.belief, s.temporal_basis, s.k_from, s.k_to,
    (select kb.recorded_at from temporal.knowledge_batch kb where kb.tenant_id = s.tenant_id and kb.knowledge_seq = s.k_from),
    (select kb.recorded_at from temporal.knowledge_batch kb where kb.tenant_id = s.tenant_id and kb.knowledge_seq = s.k_to), s.primary_claim_id, s.replaces_segment_id
  from temporal.segment s join temporal.stream st on st.id = s.stream_id
  where s.tenant_id = util.current_tenant_id() and st.subject_entity_id = p_offering and st.kind = 'offering_price' and (p_meter is null or s.payload->>'meter' = p_meter)
  order by lower(s.valid_during), s.k_from
$$;
comment on function api.price_history is 'L2: every price segment of an offering and meter with both clocks (valid_during; k_from/k_to with learned_at), including superseded beliefs.';

create or replace function api.fact_locators(p_entity uuid, p_stream_kind text, p_scope_key text default null) returns table(
  segment_id uuid, scope_key text, amount numeric, currency text, unit text, status text, payload jsonb, valid_during tstzrange, claim_id uuid, claim_statement text, locator_id uuid, selector_kind text, selector jsonb, normalized_value text,
  capture_id uuid, captured_at timestamptz, request_url text, source_url text, document_node_id uuid, unit_kind text, logical_key text)
language sql stable security definer set search_path = '' as $$
  select s.id, st.scope_key, s.amount, s.currency::text, s.unit, s.status, s.payload, s.valid_during, c.id, c.statement, l.id, l.selector_kind, l.selector, l.normalized_value,
    cap.id, cap.captured_at, cap.request_url, src.canonical_url, xr.document_node_id, n.unit_kind, n.logical_key
  from temporal.segment s join temporal.stream st on st.id = s.stream_id
  left join evidence.claim c on c.id = s.primary_claim_id
  left join evidence.segment_support ss on ss.segment_id = s.id and ss.role = 'supports'
  left join evidence.locator l on l.id = ss.locator_id
  left join evidence.source_capture cap on cap.id = l.capture_id
  left join evidence.source src on src.id = cap.source_id
  left join evidence.extraction_record xr on xr.claim_id = c.id
  left join content.document_node n on n.id = xr.document_node_id
  where s.tenant_id = util.current_tenant_id() and st.subject_entity_id = p_entity and st.kind = p_stream_kind and (p_scope_key is null or st.scope_key = p_scope_key) and s.k_to is null
  order by lower(s.valid_during) desc
$$;
comment on function api.fact_locators is 'L1->evidence: a current fact with its claim, exact locator (selector + normalized value), the capture (URL, time) and the typed unit it was read from.';

create or replace function api.modules_affected_by_release(p_release uuid) returns table(
  work_id uuid, work_kind text, work_slug text, revision_id uuid, revision_title text, revision_created_at timestamptz, software text, release text, released_at timestamptz, breaking boolean, binding text, version_spec text)
language sql stable security definer set search_path = '' as $$
  with rel as (select r.* from api.software_releases r where r.release_id = p_release)
  select w.id, w.kind, w.slug, rv.id, rv.title, rv.created_at, rel.software, rel.release, rel.released_at, rel.breaking, b.binding, b.version_spec
  from rel join (
    select x.revision_id, 'binding:'||x.relation binding, null::text version_spec, x.entity_id from authoring.revision_binding x where x.entity_id is not null
    union all select q.revision_id, 'runtime_requirement', q.version_spec, q.entity_id from authoring.runtime_requirement q where q.entity_id is not null
  ) b on b.entity_id = rel.software_id
  join authoring.work_revision rv on rv.id = b.revision_id join authoring.work w on w.id = rv.work_id and w.head_revision_id = rv.id
  where rel.released_at is null or rv.created_at < rel.released_at
  order by rel.released_at desc, w.slug
$$;
comment on function api.modules_affected_by_release is 'L2 flywheel: our head revisions (modules, activities, courses) that bind or require the software a release belongs to and were authored before that release; breaking tells which need review first.';

create or replace function api.talk_segments(p_talk uuid, p_from_ms integer default null, p_to_ms integer default null, p_query text default null) returns table(
  node_id uuid, unit_kind text, start_ms integer, end_ms integer, slide_n integer, text text, document_id uuid, representation_id uuid, logical_key text)
language sql stable security definer set search_path = '' as $$
  select n.id, n.unit_kind, n.start_ms, n.end_ms, (n.attributes->>'slide_n')::integer, n.inline_text, d.id, n.representation_id, n.logical_key
  from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and d.work_entity_id = p_talk and n.unit_kind in ('transcript_segment','slide','talk_writeup')
    and (p_from_ms is null or coalesce(n.end_ms, n.start_ms) >= p_from_ms) and (p_to_ms is null or n.start_ms <= p_to_ms)
    and (p_query is null or to_tsvector('english', coalesce(n.inline_text,'')) @@ websearch_to_tsquery('english', p_query))
  order by n.start_ms nulls last, n.ordinal
$$;
comment on function api.talk_segments is 'L3 exact: the transcript segments and slides of a talk inside a timecode window, optionally filtered by text; the speaker is the talk''s presenter unless the segment carries a speaker attribute (ai.engineer transcripts have none).';

create or replace function api.document_units(p_document uuid, p_unit_kinds text[] default null) returns table(
  node_id uuid, version_label text, unit_kind text, logical_key text, attributes jsonb, inline_text text, page_number integer, start_ms integer, end_ms integer, stable_local_key text)
language sql stable security definer set search_path = '' as $$
  select n.id, v.version_label, n.unit_kind, n.logical_key, n.attributes, n.inline_text, n.page_number, n.start_ms, n.end_ms, n.stable_local_key
  from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and d.id = p_document and (p_unit_kinds is null or n.unit_kind = any(p_unit_kinds))
  order by v.created_at desc, n.ordinal
$$;
comment on function api.document_units is 'Typed units of a document across its versions (newest first): the structural view a question drills into after the L1 row.';

create or replace function api.document_digest(p_document uuid) returns table(digest_id uuid, version_label text, scope text, producer_kind text, ordinal integer, item_kind text, text text, payload jsonb, entity text, node_ids uuid[], claim_id uuid, confidence numeric)
language sql stable security definer set search_path = '' as $$
  select g.id, v.version_label, g.scope, g.producer_kind, i.ordinal, i.item_kind, i.text, i.payload, e.display_name, i.node_ids, i.claim_id, i.confidence
  from content.document_digest g join content.document_version v on v.id = g.document_version_id join content.digest_item i on i.digest_id = g.id left join catalog.entity e on e.id = i.entity_id
  where g.tenant_id = util.current_tenant_id() and v.document_id = p_document and g.lifecycle = 'active' order by v.created_at desc, i.ordinal
$$;
comment on function api.document_digest is 'The structured digest of a document''s newest version: key points, entity roles, assertion references, changes, open questions and research directions, each anchored to units.';

grant execute on function api.changes_since(timestamptz, text[], text[], text[]), api.price_history(uuid, text), api.fact_locators(uuid, text, text), api.modules_affected_by_release(uuid), api.talk_segments(uuid, integer, integer, text), api.document_units(uuid, text[]), api.document_digest(uuid)
  to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
create or replace function product.dispatch_command(ws uuid, op text, head uuid, pl jsonb, p uuid, g access.client_grant) returns jsonb
language plpgsql set search_path = '' as $$
declare
  t uuid := product.tenant(); w authoring.work; rid uuid; res jsonb; ex jsonb; ev uuid; rel authoring.release; d authoring.distribution;
  o authoring.distribution_offer; e learning.enrollment; aid uuid; x jsonb; human boolean; surface text; k text; tok text;
  a learning.attempt; s learning.submission; r learning.assessment_result; ap learning.appeal; n int; srcws uuid; cnt int; rm library.removal;
begin
  human := g.id is null or g.client_kind = 'cli';          -- MCP/harness grants act as agents; web or interactive CLI = human
  surface := case when g.id is null then 'web' else 'harness' end;

  case op
  when 'ensure_personal_workspace' then
    return jsonb_build_object('workspaceId', product.personal_workspace(p));

  when 'create_workspace' then
    insert into authoring.workspace(tenant_id, owner_id, kind, name) values (t, p, 'shared', pl ->> 'name') returning id into rid;
    insert into authoring.workspace_member(tenant_id, workspace_id, principal_id, role, granted_by) values (t, rid, p, 'owner', p);
    return jsonb_build_object('workspaceId', rid);

  when 'grant_member' then
    perform product.require_role(ws, p, array['owner']);
    insert into authoring.workspace_member(tenant_id, workspace_id, principal_id, role, granted_by)
    values (t, ws, (pl ->> 'principal_id')::uuid, pl ->> 'role', p);
    return jsonb_build_object('granted', true);

  when 'revoke_member' then
    perform product.require_role(ws, p, array['owner']);
    if product.role_in(ws, (pl ->> 'principal_id')::uuid) = 'owner'
       and (select count(*) from authoring.workspace_member where workspace_id = ws and role = 'owner' and revoked_at is null) = 1 then
      perform product.fail('CONFLICT', 'cannot revoke the last owner');
    end if;
    update authoring.workspace_member set revoked_at = now() where workspace_id = ws and principal_id = (pl ->> 'principal_id')::uuid and revoked_at is null;
    return jsonb_build_object('revoked', true);

  when 'create_work' then
    perform product.require_role(ws, p, array['owner','editor']);
    if pl ->> 'kind' = 'dataset' then perform product.fail('VALIDATION', 'create datasets with create_dataset'); end if;
    insert into authoring.work(tenant_id, workspace_id, kind, slug, created_by) values (t, ws, pl ->> 'kind', pl ->> 'slug', p) returning * into w;
    rid := product.insert_revision(ws, w, p, null, pl -> 'revision');
    update authoring.work set head_revision_id = rid where id = w.id;
    return jsonb_build_object('workId', w.id, 'revisionId', rid);

  when 'revise_work' then
    perform product.require_role(ws, p, array['owner','editor']);
    select * into w from authoring.work where id = (pl ->> 'work_id')::uuid and workspace_id = ws for update;
    if w.id is null then perform product.fail('NOT_FOUND', 'work'); end if;
    if w.kind = 'dataset' then perform product.fail('VALIDATION', 'revise datasets with edit_dataset and commit_dataset_revision'); end if;
    if head is null or w.head_revision_id is distinct from head then perform product.fail('CONFLICT', 'stale expected head'); end if;
    rid := product.insert_revision(ws, w, p, w.head_revision_id, pl -> 'revision');
    update authoring.work set head_revision_id = rid where id = w.id;
    return jsonb_build_object('workId', w.id, 'revisionId', rid);

  when 'review_revision' then
    perform product.require_role(ws, p, array['owner','editor']);
    if (pl -> 'review' ->> 'reviewType') in ('release_review','official_publication','transition_review','runtime_review') and not human then
      perform product.fail('FORBIDDEN', 'agents may propose but not record human reviews');
    end if;
    if pl -> 'review' ->> 'reviewType' = 'official_publication' and not exists (select 1 from authoring.publisher_grant pg
         where pg.tenant_id = t and pg.principal_id = p and pg.revoked_at is null) then
      perform product.fail('FORBIDDEN', 'official publication requires a publisher grant');
    end if;
    ev := product.new_event(ws, p, (pl ->> 'work_id')::uuid, (pl ->> 'revision_id')::uuid, 'reviewed', pl -> 'review',
                            coalesce(pl ->> 'dedupe_key', 'review:' || util.uuidv7()), case when human then 'human' else 'agent' end, surface, 'maintainer');
    return jsonb_build_object('eventId', ev);

  when 'freeze_release' then
    perform product.require_role(ws, p, array['owner','editor']);
    select wk.* into w from authoring.work_revision rv join authoring.work wk on wk.id = rv.work_id
      where rv.id = (pl ->> 'root_revision_id')::uuid and rv.workspace_id = ws;
    if w.id is null then perform product.fail('NOT_FOUND', 'root revision'); end if;
    ex := product.exposure((pl ->> 'root_revision_id')::uuid, pl ->> 'ceiling');
    -- apply explicit author decisions to blockers
    for x in select * from jsonb_array_elements(coalesce(pl -> 'decisions', '[]')) loop
      ex := jsonb_set(ex, '{items}', (select jsonb_agg(case when i ->> 'item_key' = x ->> 'item_key'
              then i || jsonb_build_object('disposition', x ->> 'disposition', 'decided', true, 'rationale', x ->> 'rationale', 'substitute', x ->> 'substitute_artifact_id') else i end)
              from jsonb_array_elements(ex -> 'items') i));
    end loop;
    if exists (select 1 from jsonb_array_elements(ex -> 'items') i where i ->> 'disposition' = 'BLOCKER') then
      perform product.fail('EXPOSURE_BLOCKED', (select string_agg(i ->> 'item_key', ',') from jsonb_array_elements(ex -> 'items') i where i ->> 'disposition' = 'BLOCKER'));
    end if;
    if not exists (select 1 from authoring.event v where v.id = (pl ->> 'approval_event_id')::uuid and v.workspace_id = ws and v.kind = 'reviewed'
                    and v.actor_kind = 'human' and v.payload ->> 'reviewType' = 'release_review' and v.payload ->> 'decision' = 'approve'
                    and v.payload ->> 'closure_sha256' = ex ->> 'closure_sha256' and v.payload ->> 'ceiling' = pl ->> 'ceiling'
                    and product.role_in(ws, v.actor_id) in ('owner','editor')) then
      perform product.fail('FORBIDDEN', 'release requires a human review of this exact closure and ceiling');
    end if;
    aid := product.register_artifact(ws, p, 'course_release_manifest', product.sha256_text(ex::text), octet_length(ex::text), 'application/json',
                                     'private_copy', 'release manifest generated by the platform');
    select coalesce(max(release_no), 0) + 1 into n from authoring.release where root_work_id = w.id;
    insert into authoring.release(tenant_id, workspace_id, root_work_id, root_revision_id, release_no, audience_ceiling, manifest_artifact_id, closure_sha256, approved_event_id, created_by)
    values (t, ws, w.id, (pl ->> 'root_revision_id')::uuid, n, pl ->> 'ceiling', aid, ex ->> 'closure_sha256', (pl ->> 'approval_event_id')::uuid, p) returning * into rel;
    insert into authoring.release_item(tenant_id, workspace_id, release_id, item_key, revision_id, artifact_id, capture_id, locator_id, claim_id, record_id, entity_id,
                                       via_binding_id, disposition, substitute_artifact_id, decided_by, rationale)
    select t, ws, rel.id, i ->> 'item_key',
           case when i ->> 'kind' = 'revision' then (i ->> 'id')::uuid end, case when i ->> 'kind' = 'artifact' then (i ->> 'id')::uuid end,
           case when i ->> 'kind' = 'capture' then (i ->> 'id')::uuid end, case when i ->> 'kind' = 'locator' then (i ->> 'id')::uuid end,
           case when i ->> 'kind' = 'claim' then (i ->> 'id')::uuid end, case when i ->> 'kind' = 'record' then (i ->> 'id')::uuid end,
           case when i ->> 'kind' = 'entity' then (i ->> 'id')::uuid end, (i ->> 'binding_id')::uuid, i ->> 'disposition',
           (i ->> 'substitute')::uuid, case when (i ->> 'decided')::boolean then p end, case when (i ->> 'decided')::boolean then i ->> 'rationale' end
      from jsonb_array_elements(ex -> 'items') i;
    return jsonb_build_object('releaseId', rel.id, 'releaseNo', n, 'manifestArtifactId', aid, 'manifestText', ex::text,
                              'objectPath', (select object_path from orchestration.artifact where id = aid));

  when 'open_distribution' then
    perform product.require_role(ws, p, array['owner','editor']);
    if pl ->> 'channel' = 'public_library'
       and product.band_rank(product.band(p)) < product.band_rank(coalesce(product.policy() ->> 'public_publish_min_band', 'adult')) then
      perform product.fail('FORBIDDEN', 'account band may not publish publicly under the active policy');
    end if;
    insert into authoring.distribution(tenant_id, workspace_id, root_work_id, channel, title, created_by)
    values (t, ws, (pl ->> 'root_work_id')::uuid, pl ->> 'channel', pl ->> 'title', p) returning * into d;
    return jsonb_build_object('distributionId', d.id);

  when 'grant_reader' then
    perform product.require_role(ws, p, array['owner','editor']);
    insert into authoring.distribution_member(tenant_id, workspace_id, distribution_id, principal_id, grant_basis, granted_by)
    select t, ws, d2.id, (pl ->> 'principal_id')::uuid, 'invited', p from authoring.distribution d2
     where d2.id = (pl ->> 'distribution_id')::uuid and d2.workspace_id = ws and d2.channel = 'invited';
    get diagnostics cnt = row_count;
    if cnt = 0 then perform product.fail('NOT_FOUND', 'invited distribution'); end if;
    return jsonb_build_object('granted', true);

  when 'offer_release' then
    perform product.require_role(ws, p, array['owner','editor']);
    select * into d from authoring.distribution where id = (pl ->> 'distribution_id')::uuid and workspace_id = ws and closed_at is null;
    select * into rel from authoring.release where id = (pl ->> 'release_id')::uuid and workspace_id = ws;
    if d.id is null or rel.id is null or rel.root_work_id <> d.root_work_id then perform product.fail('NOT_FOUND', 'distribution/release'); end if;
    if not ((d.channel = 'workspace') or (d.channel = 'invited' and rel.audience_ceiling in ('named','public'))
         or (d.channel in ('public_library','official_catalog') and rel.audience_ceiling = 'public')) then
      perform product.fail('FORBIDDEN', format('release ceiling %s cannot be offered in %s', rel.audience_ceiling, d.channel));
    end if;
    if (select storage_state from orchestration.artifact where id = rel.manifest_artifact_id) <> 'available' then
      perform product.fail('CONFLICT', 'release manifest not yet stored and verified');
    end if;
    if not exists (select 1 from authoring.event v where v.id = (pl ->> 'approval_event_id')::uuid and v.workspace_id = ws and v.kind = 'reviewed' and v.actor_kind = 'human'
        and v.payload ->> 'closure_sha256' = rel.closure_sha256
        and ((d.channel = 'official_catalog' and v.payload ->> 'reviewType' = 'official_publication'
              and v.payload -> 'terms' = pl -> 'terms'
              and exists (select 1 from authoring.publisher_grant pg where pg.principal_id = v.actor_id and pg.revoked_at is null))
          or (d.channel <> 'official_catalog' and v.payload ->> 'reviewType' = 'release_review'))) then
      perform product.fail('FORBIDDEN', 'offer approval does not match this release/channel');
    end if;
    select coalesce(max(offer_no), 0) + 1 into n from authoring.distribution_offer where distribution_id = d.id;
    insert into authoring.distribution_offer(tenant_id, workspace_id, distribution_id, release_id, offer_no, terms_schema, terms, approval_event_id, offered_by)
    values (t, ws, d.id, rel.id, n, 'aieng.use-terms.v1', pl -> 'terms', (pl ->> 'approval_event_id')::uuid, p) returning * into o;
    return jsonb_build_object('offerId', o.id, 'offerNo', n);

  when 'end_offer' then
    perform product.require_role(ws, p, array['owner','editor']);
    ev := product.new_event(ws, p, null, null, 'withdrawn', jsonb_build_object('offer_id', pl ->> 'offer_id', 'reason', pl ->> 'reason'),
                            'end_offer:' || (pl ->> 'offer_id'), case when human then 'human' else 'agent' end, surface, 'maintainer');
    update authoring.distribution_offer set ended_at = now(), end_kind = pl ->> 'end_kind', end_event_id = ev
     where id = (pl ->> 'offer_id')::uuid and workspace_id = ws and ended_at is null;
    get diagnostics cnt = row_count;
    if cnt = 0 then perform product.fail('NOT_FOUND', 'open offer'); end if;
    return jsonb_build_object('ended', pl ->> 'end_kind');

  when 'enroll' then
    perform product.require_role(ws, p, array['owner']);
    if (select kind from authoring.workspace where id = ws) <> 'personal' then perform product.fail('VALIDATION', 'enroll in your personal workspace'); end if;
    select * into d from authoring.distribution where id = (pl ->> 'distribution_id')::uuid and closed_at is null;
    if d.id is null or (select kind from authoring.work where id = d.root_work_id) <> 'course'
       or not exists (select 1 from authoring.distribution_offer o2 where o2.distribution_id = d.id and o2.ended_at is null and product.can_read_offer(o2, p)) then
      perform product.fail('NOT_FOUND', 'distribution');
    end if;
    insert into learning.enrollment(tenant_id, workspace_id, learner_id, source_workspace_id, distribution_id, update_policy)
    values (t, ws, p, d.workspace_id, d.id, coalesce(pl ->> 'update_policy', 'manual')) returning * into e;
    return jsonb_build_object('enrollmentId', e.id);

  when 'adopt_release' then
    select * into e from learning.enrollment where id = (pl ->> 'enrollment_id')::uuid and workspace_id = ws and learner_id = p;
    select * into o from authoring.distribution_offer where id = (pl ->> 'offer_id')::uuid;
    if e.id is null or o.id is null or o.distribution_id <> e.distribution_id or not product.can_read_offer(o, p) or o.ended_at is not null then
      perform product.fail('NOT_FOUND', 'enrollment/offer');
    end if;
    select coalesce(max(sequence_no), 0) + 1 into n from learning.release_adoption where enrollment_id = e.id;
    insert into learning.release_adoption(tenant_id, workspace_id, enrollment_id, sequence_no, previous_adoption_id, source_workspace_id, offer_id, transition_id, actor_id, basis, reason)
    values (t, ws, e.id, n, (select id from learning.release_adoption where enrollment_id = e.id and sequence_no = n - 1), e.source_workspace_id, o.id,
            (pl ->> 'transition_id')::uuid, p, 'explicit', coalesce(pl ->> 'reason', 'learner choice')) returning id into rid;
    return jsonb_build_object('adoptionId', rid, 'sequenceNo', n);

  when 'register_asset' then
    perform product.require_role(ws, p, array['owner','editor']);
    if pl ->> 'artifact_type' not in ('authored_work_asset','uploaded_document','experience_bundle','project_bundle','course_source_capture') then
      perform product.fail('VALIDATION', 'artifact type');
    end if;
    if (pl ->> 'size_bytes')::bigint > 26214400 then perform product.fail('LIMIT_EXCEEDED', '25 MiB per object'); end if;
    aid := product.register_artifact(ws, p, pl ->> 'artifact_type', pl ->> 'sha256', (pl ->> 'size_bytes')::bigint, pl ->> 'media_type',
                                     pl ->> 'usage', pl ->> 'rights_basis', coalesce(pl ->> 'retention', 'durable'));
    return jsonb_build_object('artifactId', aid, 'objectPath', (select object_path from orchestration.artifact where id = aid));

  when 'revoke_asset' then
    perform product.require_role(ws, p, array['owner']);
    update authoring.asset_scope set revoked_at = now() where workspace_id = ws and artifact_id = (pl ->> 'artifact_id')::uuid and revoked_at is null;
    return jsonb_build_object('revoked', true);

  when 'set_control' then
    perform product.require_role(ws, p, array['owner','editor']);
    if coalesce((pl ->> 'semantic_index')::boolean, false)
       and not product.processing_allowed(p, 'embedding', coalesce(pl ->> 'embedding_processor', 'openai')) then
      perform product.fail('CONSENT_REQUIRED', 'embedding processing is not authorized for this account');
    end if;
    insert into library.resource_control(tenant_id, workspace_id, work_id, excluded_at, excluded_by, semantic_index, updated_by)
    values (t, ws, (pl ->> 'work_id')::uuid, case when (pl ->> 'exclude')::boolean then now() end, case when (pl ->> 'exclude')::boolean then p end,
            coalesce((pl ->> 'semantic_index')::boolean, false), p)
    on conflict (tenant_id, workspace_id, work_id) do update set
      excluded_at = case when (pl ->> 'exclude')::boolean then coalesce(library.resource_control.excluded_at, now()) end,
      excluded_by = case when (pl ->> 'exclude')::boolean then coalesce(library.resource_control.excluded_by, p) end,
      semantic_index = coalesce((pl ->> 'semantic_index')::boolean, library.resource_control.semantic_index), updated_by = p, updated_at = now();
    return jsonb_build_object('updated', true);

  when 'create_connection' then
    perform product.require_role(ws, p, array['owner','editor']);
    if product.band_rank(product.band(p)) < product.band_rank(coalesce(product.policy() ->> 'connector_min_band', 'teen'))
       or not product.processing_allowed(p, 'connector', pl ->> 'provider') then
      perform product.fail('CONSENT_REQUIRED', 'connector not permitted for this account');
    end if;
    insert into library.connection(tenant_id, workspace_id, provider, account_label, capabilities, credential_handle, status, connected_by)
    values (t, ws, pl ->> 'provider', pl ->> 'account_label', array(select jsonb_array_elements_text(pl -> 'capabilities')), pl ->> 'credential_handle', 'active', p)
    returning id into rid;
    return jsonb_build_object('connectionId', rid);

  when 'create_thread' then
    perform product.require_role(ws, p, array['owner','editor','reader']);
    insert into conversation.thread(tenant_id, workspace_id, owner_id, visibility, title, purpose, mode)
    values (t, ws, p, coalesce(pl ->> 'visibility', 'private'), pl ->> 'title', pl ->> 'purpose', coalesce(pl ->> 'mode', 'coach')) returning id into rid;
    return jsonb_build_object('threadId', rid);

  when 'append_message' then
    if not exists (select 1 from conversation.thread th where th.id = (pl ->> 'thread_id')::uuid and th.workspace_id = ws
                   and (th.owner_id = p or (th.visibility = 'workspace' and product.role_in(ws, p) is not null))) then
      perform product.fail('NOT_FOUND', 'thread');
    end if;
    perform 1 from conversation.thread where id = (pl ->> 'thread_id')::uuid for update;
    rid := null;
    if pl ? 'context' then
      k := product.sha256_text((pl -> 'context')::text);
      insert into conversation.context_snapshot(tenant_id, workspace_id, digest, body) values (t, ws, k, pl -> 'context')
      on conflict (tenant_id, workspace_id, digest) do nothing;
      select id into rid from conversation.context_snapshot where workspace_id = ws and digest = k;
      for x in select * from jsonb_array_elements(coalesce(pl -> 'context' -> 'items', '[]')) loop
        if x ? 'revision_id' and not product.readable_revision((x ->> 'revision_id')::uuid, p) then perform product.fail('NOT_FOUND', 'context item'); end if;
        -- released material from another workspace is referenced through its release item (lab finding F-08)
        aid := null;
        if x ? 'revision_id' and not exists (select 1 from authoring.work_revision rv where rv.id = (x ->> 'revision_id')::uuid and rv.workspace_id = ws) then
          select ri.id into aid from authoring.release_item ri join authoring.distribution_offer o2 on o2.release_id = ri.release_id
           where ri.revision_id = (x ->> 'revision_id')::uuid and ri.disposition in ('include','snapshot') and product.can_read_offer(o2, p)
           order by ri.created_at desc limit 1;
        end if;
        insert into conversation.context_item(tenant_id, workspace_id, snapshot_id, item_key, reason, revision_id, release_item_id, passage_id)
        values (t, ws, rid, x ->> 'item_key', x ->> 'reason', case when aid is null then (x ->> 'revision_id')::uuid end, aid, (x ->> 'passage_id')::uuid)
        on conflict (tenant_id, workspace_id, snapshot_id, item_key) do nothing;
      end loop;
    end if;
    select coalesce(max(seq), 0) + 1 into n from conversation.message where thread_id = (pl ->> 'thread_id')::uuid;
    insert into conversation.message(tenant_id, workspace_id, thread_id, seq, role, author_id, agent_identity, client_surface, content, content_sha256, context_snapshot_id, runtime_ref)
    values (t, ws, (pl ->> 'thread_id')::uuid, n, pl ->> 'role', case when pl ->> 'role' = 'user' then p end, pl ->> 'agent_identity',
            case when g.id is null then 'web' else 'harness' end, pl -> 'content', product.sha256_text((pl -> 'content')::text), rid, coalesce(pl -> 'runtime_ref', '{}'))
    returning id into aid;
    return jsonb_build_object('messageId', aid, 'seq', n, 'contextSnapshotId', rid);

  when 'start_attempt' then
    perform product.require_role(ws, p, array['owner']);
    if pl ->> 'purpose' = 'official' then
      select * into e from learning.enrollment where id = (pl ->> 'enrollment_id')::uuid and workspace_id = ws and learner_id = p;
      if e.id is null or not exists (
          select 1 from learning.release_adoption ad join authoring.distribution_offer o2 on o2.id = ad.offer_id
            join curriculum.requirement_option op on op.id = (pl ->> 'option_id')::uuid and op.approval_state = 'approved'
            join curriculum.requirement rq on rq.id = op.requirement_id and rq.requirement_key = (pl ->> 'requirement_key')::uuid
            join authoring.release_item ri on ri.release_id = o2.release_id and ri.revision_id = rq.revision_id
           where ad.id = (pl ->> 'adoption_id')::uuid and ad.enrollment_id = e.id) then
        perform product.fail('VALIDATION', 'official attempt needs an approved option of a requirement in the adopted release');
      end if;
      -- the task must be the one the route names (lab finding F-15)
      select route, activity_revision_id into k, aid from curriculum.requirement_option where id = (pl ->> 'option_id')::uuid;
      if k in ('standard','test_out') and not exists (select 1 from authoring.release_item ri where ri.id = (pl ->> 'task_release_item_id')::uuid and ri.revision_id = aid) then
        perform product.fail('VALIDATION', 'task does not match the option''s activity');
      end if;
      if k in ('learner_project','alternative') and not exists (select 1 from learning.equivalence_request q where q.id = (pl ->> 'equivalence_request_id')::uuid
            and q.learner_id = p and q.enrollment_id = e.id and q.state = 'approved' and q.work_revision_id = (pl ->> 'task_revision_id')::uuid
            and (pl ->> 'requirement_key')::uuid = any(q.requirement_keys)) then
        perform product.fail('VALIDATION', 'a learner project or challenge counts only under an approved equivalence request');
      end if;
    end if;
    if pl ? 'task_release_item_id' and not exists (select 1 from authoring.release_item ri join authoring.distribution_offer o2 on o2.release_id = ri.release_id
         where ri.id = (pl ->> 'task_release_item_id')::uuid and ri.disposition in ('include','snapshot') and product.can_read_offer(o2, p)) then
      perform product.fail('NOT_FOUND', 'task');
    end if;
    if pl ? 'environment_session_id' and not exists (select 1 from learning.environment_session es where es.id = (pl ->> 'environment_session_id')::uuid and es.learner_id = p) then
      perform product.fail('NOT_FOUND', 'environment session');
    end if;
    insert into learning.attempt(tenant_id, workspace_id, learner_id, task_revision_id, task_release_item_id, enrollment_id, adoption_id, requirement_key, option_id, purpose, conditions,
                                 equivalence_request_id, environment_session_id)
    values (t, ws, p, (pl ->> 'task_revision_id')::uuid, (pl ->> 'task_release_item_id')::uuid, (pl ->> 'enrollment_id')::uuid, (pl ->> 'adoption_id')::uuid,
            (pl ->> 'requirement_key')::uuid, (pl ->> 'option_id')::uuid, pl ->> 'purpose', pl -> 'conditions',
            (pl ->> 'equivalence_request_id')::uuid, (pl ->> 'environment_session_id')::uuid) returning * into a;
    return jsonb_build_object('attemptId', a.id);

  when 'submit_attempt' then
    select * into a from learning.attempt where id = (pl ->> 'attempt_id')::uuid and workspace_id = ws and learner_id = p for update;
    if a.id is null then perform product.fail('NOT_FOUND', 'attempt'); end if;
    if a.state <> 'started' then perform product.fail('CONFLICT', 'attempt already ' || a.state); end if;
    tok := jsonb_build_object('attempt', a.id, 'items', (select jsonb_agg(i order by i ->> 'item_key') from jsonb_array_elements(pl -> 'items') i))::text;
    k := product.sha256_text(tok);
    aid := product.register_artifact(ws, p, 'submission_manifest', k, octet_length(tok), 'application/json', 'private_copy', 'learner submission');
    insert into learning.submission(tenant_id, workspace_id, attempt_id, learner_id, manifest_artifact_id, closure_sha256, observed_conditions, submitted_via)
    values (t, ws, a.id, p, aid, k, coalesce(pl -> 'observed_conditions', '{}'), case when g.id is null then 'web' else 'harness' end) returning * into s;
    for x in select * from jsonb_array_elements(pl -> 'items') loop
      if x ? 'revision_id' and not exists (select 1 from authoring.work_revision rv where rv.id = (x ->> 'revision_id')::uuid and rv.workspace_id = ws) then
        perform product.fail('NOT_FOUND', 'evidence revision');
      end if;
      insert into learning.evidence_item(tenant_id, workspace_id, submission_id, item_key, kind, revision_id, artifact_id, message_id, file_set_id, deployment_id,
                                         external_ref, sha256, availability)
      values (t, ws, s.id, x ->> 'item_key', x ->> 'kind', (x ->> 'revision_id')::uuid, (x ->> 'artifact_id')::uuid, (x ->> 'message_id')::uuid,
              (x ->> 'file_set_id')::uuid, (x ->> 'deployment_id')::uuid, x -> 'external_ref', x ->> 'sha256', coalesce(x ->> 'availability', 'preserved'));
    end loop;
    update learning.attempt set state = 'submitted', ended_at = now() where id = a.id;
    return jsonb_build_object('submissionId', s.id, 'manifestArtifactId', aid, 'closureSha256', k, 'manifestText', tok, 'objectPath', (select object_path from orchestration.artifact where id = aid));

  when 'finalize_result' then
    -- the maintainer of the course an official submission was made to (review scope limited to that submission)
    select r2.* into r from learning.assessment_result r2 where r2.id = (pl ->> 'result_id')::uuid;
    select en.source_workspace_id into srcws from learning.submission sb join learning.attempt at on at.id = sb.attempt_id
      join learning.enrollment en on en.id = at.enrollment_id where sb.id = r.submission_id and at.purpose = 'official';
    if r.id is null or srcws is null or coalesce(product.role_in(srcws, p), '') not in ('owner','editor') then perform product.fail('NOT_FOUND', 'result'); end if;
    if r.status <> 'provisional' or not human then perform product.fail('CONFLICT', 'only provisional results are finalized by a human'); end if;
    perform product.finalize(r.id, 'human', null);
    return jsonb_build_object('finalized', true);

  when 'open_appeal' then
    select * into r from learning.assessment_result where id = (pl ->> 'result_id')::uuid and workspace_id = ws;
    if r.id is null or not exists (select 1 from learning.submission sb where sb.id = r.submission_id and sb.learner_id = p) then perform product.fail('NOT_FOUND', 'result'); end if;
    insert into learning.appeal(tenant_id, workspace_id, result_id, learner_id, grounds, new_evidence_submission_id, state)
    values (t, ws, r.id, p, pl ->> 'grounds', (pl ->> 'new_evidence_submission_id')::uuid, 'open') returning id into rid;
    return jsonb_build_object('appealId', rid);

  when 'resolve_appeal' then
    select * into ap from learning.appeal where id = (pl ->> 'appeal_id')::uuid for update;
    select * into r from learning.assessment_result where id = ap.result_id;
    select en.source_workspace_id into srcws from learning.submission sb join learning.attempt at on at.id = sb.attempt_id
      join learning.enrollment en on en.id = at.enrollment_id where sb.id = r.submission_id;
    if ap.id is null or srcws is null or coalesce(product.role_in(srcws, p), '') not in ('owner','editor') then perform product.fail('NOT_FOUND', 'appeal'); end if;
    if ap.state not in ('open','under_review') or not human then perform product.fail('CONFLICT', 'appeal not open'); end if;
    if pl ->> 'decision' = 'modified' then
      select coalesce(max(sequence_no), 0) + 1 into n from learning.assessment_result where submission_id = r.submission_id;
      insert into learning.assessment_result(tenant_id, workspace_id, submission_id, sequence_no, outcomes, status, supersedes_id, reason)
      values (t, ap.workspace_id, r.submission_id, n, pl -> 'outcomes', 'provisional', r.id, 'appeal: ' || (pl ->> 'resolution')) returning id into rid;
      perform product.finalize(rid, 'human', null);
      update learning.assessment_result set status = 'superseded' where id = r.id;
    end if;
    update learning.appeal set state = pl ->> 'decision', reviewer_id = p, resolution = pl ->> 'resolution', resolution_result_id = rid, resolved_at = now() where id = ap.id;
    return jsonb_build_object('state', pl ->> 'decision', 'newResultId', rid);

  when 'grant_evidence' then
    perform product.require_role(ws, p, array['owner']);
    if pl ? 'guardian_link_id' and not exists (select 1 from access.guardian_link gl where gl.id = (pl ->> 'guardian_link_id')::uuid and gl.youth_id = p
         and gl.guardian_id = (pl ->> 'grantee_id')::uuid and gl.state = 'consented'
         and array(select jsonb_array_elements_text(pl -> 'includes')) <@ (gl.help_scope || array['mastery','goals','submissions'])) then
      perform product.fail('FORBIDDEN', 'guardian grant exceeds the consented help scope');
    end if;
    insert into learning.evidence_grant(tenant_id, workspace_id, learner_id, grantee_id, scope_kind, enrollment_id, includes, guardian_link_id)
    values (t, ws, p, (pl ->> 'grantee_id')::uuid, pl ->> 'scope_kind', (pl ->> 'enrollment_id')::uuid, array(select jsonb_array_elements_text(pl -> 'includes')),
            (pl ->> 'guardian_link_id')::uuid) returning id into rid;
    return jsonb_build_object('grantId', rid);

  when 'preview_removal' then
    perform product.require_role(ws, p, array['owner']);
    select * into w from authoring.work where id = (pl ->> 'work_id')::uuid and workspace_id = ws;
    if w.id is null then perform product.fail('NOT_FOUND', 'work'); end if;
    ex := jsonb_build_object(
      'revisions', (select count(*) from authoring.work_revision where work_id = w.id),
      'linked_from', (select coalesce(jsonb_agg(distinct b.revision_id), '[]') from authoring.revision_binding b join authoring.work_revision rv on rv.id = b.target_revision_id
                       where rv.work_id = w.id or b.target_work_id = w.id),
      'released_in_active_offers', (select coalesce(jsonb_agg(distinct o2.id), '[]') from authoring.release_item ri join authoring.work_revision rv on rv.id = ri.revision_id
                       join authoring.distribution_offer o2 on o2.release_id = ri.release_id where rv.work_id = w.id and ri.disposition in ('include','snapshot')
                       and coalesce(o2.end_kind, '') <> 'revoke'),
      'conversation_contexts', (select count(*) from conversation.context_item ci join authoring.work_revision rv on rv.id = ci.revision_id where rv.work_id = w.id),
      'retained_submission_evidence', (select count(*) from learning.evidence_item ei join authoring.work_revision rv on rv.id = ei.revision_id where rv.work_id = w.id),
      'passages', (select count(*) from library.passage pa join authoring.work_revision rv on rv.id = pa.revision_id where rv.work_id = w.id),
      'legal_hold', false);
    insert into library.removal(tenant_id, workspace_id, requested_by, targets, impact, state)
    values (t, ws, p, jsonb_build_object('work_id', w.id), ex,
            case when jsonb_array_length(ex -> 'released_in_active_offers') > 0 then 'blocked' else 'previewed' end) returning id into rid;
    return jsonb_build_object('removalId', rid, 'impact', ex,
                              'state', case when jsonb_array_length(ex -> 'released_in_active_offers') > 0 then 'blocked' else 'previewed' end);

  when 'confirm_removal' then
    perform product.require_role(ws, p, array['owner']);
    select * into rm from library.removal where id = (pl ->> 'removal_id')::uuid and workspace_id = ws for update;
    if rm.id is null then perform product.fail('NOT_FOUND', 'removal'); end if;
    if rm.state <> 'previewed' then perform product.fail('CONFLICT', 'removal is ' || rm.state); end if;
    if exists (select 1 from learning.evidence_item ei join authoring.work_revision rv on rv.id = ei.revision_id
                where rv.work_id = (rm.targets ->> 'work_id')::uuid) and coalesce((pl ->> 'include_retained_evidence')::boolean, false) = false then
      null;   -- submissions keep their evidence (Build 03 A4): revisions they cite are purged of body only if the learner also withdraws them
    end if;
    ev := product.new_event(ws, p, (rm.targets ->> 'work_id')::uuid, null, 'removal_impact_acknowledged', jsonb_build_object('removal_id', rm.id),
                            'removal:' || rm.id, 'human', surface, 'learner');
    perform pg_catalog.set_config('product.purge', 'on', true);
    update authoring.work_revision set body = jsonb_build_object('formatVersion', 1, 'blocks', '[]'::jsonb, 'metadata', jsonb_build_object('purged', true)),
           purged_at = now(), purged_by_removal_id = rm.id
     where work_id = (rm.targets ->> 'work_id')::uuid and purged_at is null
       and id not in (select ei.revision_id from learning.evidence_item ei where ei.revision_id is not null);
    get diagnostics n = row_count;
    -- Build 08: the passages' vector items (one retrieval stack) are retired; embeddings stay bound to retired items and never match again
    perform retrieval.retire_items_for_passages(array(select pa.id from library.passage pa join authoring.work_revision rv on rv.id = pa.revision_id
     where rv.work_id = (rm.targets ->> 'work_id')::uuid and rv.purged_at is not null));
    delete from library.passage pa using authoring.work_revision rv where pa.revision_id = rv.id and rv.work_id = (rm.targets ->> 'work_id')::uuid and rv.purged_at is not null;
    get diagnostics cnt = row_count;
    update library.connected_item set suppressed_at = now(), updated_at = now() where work_id = (rm.targets ->> 'work_id')::uuid;
    perform pg_catalog.set_config('product.purge', 'off', true);
    update library.removal set impact_acknowledged_event_id = ev, state = 'completed', completed_at = now(),
           steps = jsonb_build_array(jsonb_build_object('step', 'purge_revisions', 'count', n), jsonb_build_object('step', 'delete_passages', 'count', cnt),
                                     jsonb_build_object('step', 'suppress_connected_items'))
     where id = rm.id;
    return jsonb_build_object('removalId', rm.id, 'purgedRevisions', n, 'deletedPassages', cnt);

  when 'register_file_set' then
    perform product.require_role(ws, p, array['owner','editor']);
    if exists (select 1 from jsonb_array_elements(pl -> 'files') f where not exists (
         select 1 from authoring.asset_scope sc join orchestration.artifact ar on ar.id = sc.artifact_id
          where sc.workspace_id = ws and sc.artifact_id = (f ->> 'artifact_id')::uuid and sc.revoked_at is null and ar.storage_state = 'available')) then
      perform product.fail('NOT_FOUND', 'every file must be an available artifact admitted to this workspace');
    end if;
    if not exists (select 1 from jsonb_array_elements(pl -> 'files') f where f ->> 'path' = pl ->> 'entrypoint') then
      perform product.fail('VALIDATION', 'entrypoint is not one of the files');
    end if;
    insert into authoring.file_set(tenant_id, workspace_id, entrypoint, tree_sha256, file_count, total_bytes, origin, created_by)
    select t, ws, pl ->> 'entrypoint',
           product.sha256_text(string_agg((f ->> 'path') || ':' || ar.sha256, E'\n' order by f ->> 'path')), count(*), sum(ar.size_bytes),
           case when g.id is null then 'web' else g.client_kind end, p
      from jsonb_array_elements(pl -> 'files') f join orchestration.artifact ar on ar.id = (f ->> 'artifact_id')::uuid
    returning id into rid;
    insert into authoring.file_set_entry(tenant_id, workspace_id, file_set_id, path, artifact_id, sha256, size_bytes, media_type)
    select t, ws, rid, f ->> 'path', ar.id, ar.sha256, ar.size_bytes, coalesce(ar.media_type, 'application/octet-stream')
      from jsonb_array_elements(pl -> 'files') f join orchestration.artifact ar on ar.id = (f ->> 'artifact_id')::uuid;
    return jsonb_build_object('fileSetId', rid, 'treeSha256', (select tree_sha256 from authoring.file_set where id = rid));

  when 'record_deployment' then
    perform product.require_role(ws, p, array['owner','editor']);
    aid := util.uuidv7();
    insert into authoring.deployment(id, tenant_id, workspace_id, revision_id, file_set_id, target, environment, url, external_ref, snapshot_file_set_id, status, origin, created_by)
    values (aid, t, ws, (pl ->> 'revision_id')::uuid, (pl ->> 'file_set_id')::uuid, pl ->> 'target', coalesce(pl ->> 'environment', 'preview'),
            case when pl ->> 'target' = 'platform_static' then format('https://%s.%s.workspaces.aieng.invalid/', aid, coalesce(pl ->> 'environment', 'preview')) else pl ->> 'url' end,
            pl -> 'external_ref', (pl ->> 'snapshot_file_set_id')::uuid,
            case when pl ->> 'target' = 'platform_static' then 'pending' else 'live' end, case when g.id is null then 'web' else g.client_kind end, p);
    return jsonb_build_object('deploymentId', aid, 'url', (select url from authoring.deployment where id = aid), 'status', (select status from authoring.deployment where id = aid));

  when 'propose_equivalence' then
    select * into e from learning.enrollment where id = (pl ->> 'enrollment_id')::uuid and workspace_id = ws and learner_id = p;
    if e.id is null or not exists (select 1 from authoring.work_revision rv where rv.id = (pl ->> 'work_revision_id')::uuid and rv.workspace_id = ws) then
      perform product.fail('NOT_FOUND', 'enrollment or own work');
    end if;
    insert into learning.equivalence_request(tenant_id, workspace_id, learner_id, enrollment_id, work_revision_id, requirement_keys, evidence_plan, state)
    values (t, ws, p, e.id, (pl ->> 'work_revision_id')::uuid, array(select (jsonb_array_elements_text(pl -> 'requirement_keys'))::uuid), pl ->> 'evidence_plan', 'proposed')
    returning id into rid;
    if product.role_in(e.source_workspace_id, p) = 'owner' then        -- the learner's own course: approval is automatic
      update learning.equivalence_request set state = 'approved', decided_by = p, decision = 'owner_course_auto', decided_at = now(),
             decision_reason = 'learner owns the course' where id = rid;
    end if;
    return jsonb_build_object('equivalenceRequestId', rid, 'state', (select state from learning.equivalence_request where id = rid));

  when 'decide_equivalence' then
    select en.source_workspace_id into srcws from learning.equivalence_request q join learning.enrollment en on en.id = q.enrollment_id where q.id = (pl ->> 'request_id')::uuid;
    if srcws is null or coalesce(product.role_in(srcws, p), '') not in ('owner','editor') then perform product.fail('NOT_FOUND', 'equivalence request'); end if;
    if not human then perform product.fail('FORBIDDEN', 'a person decides equivalence'); end if;
    update learning.equivalence_request set state = case when pl ->> 'decision' = 'approve' then 'approved' else 'rejected' end,
           decided_by = p, decision = 'maintainer', decision_reason = pl ->> 'reason', decided_at = now()
     where id = (pl ->> 'request_id')::uuid and state in ('proposed','checked');
    get diagnostics cnt = row_count;
    if cnt = 0 then perform product.fail('CONFLICT', 'request already decided'); end if;
    return jsonb_build_object('state', case when pl ->> 'decision' = 'approve' then 'approved' else 'rejected' end);

  when 'request_environment' then
    perform product.require_role(ws, p, array['owner']);
    if pl ? 'spec_revision_id' and not product.readable_revision((pl ->> 'spec_revision_id')::uuid, p) then perform product.fail('NOT_FOUND', 'environment spec'); end if;
    if exists (select 1 from jsonb_array_elements(coalesce(pl -> 'key_handles', '[]')) h where h ->> 'source' = 'platform' and not exists (
         select 1 from access.provided_credential c where c.id = (h ->> 'provided_credential_id')::uuid and c.principal_id = p and c.revoked_at is null and c.expires_at > now())) then
      perform product.fail('NOT_FOUND', 'platform-provided credential');
    end if;
    if exists (select 1 from jsonb_array_elements(coalesce(pl -> 'key_handles', '[]')) h where (h::text) ~ '(sk-|ghp_|xox[bp]-|AKIA|-----BEGIN)') then
      perform product.fail('VALIDATION', 'key handles must never contain secret values');
    end if;
    insert into learning.environment_session(tenant_id, workspace_id, learner_id, project_work_id, spec_revision_id, provider, adapter, status, key_handles, spend_limit_usd, expires_at)
    values (t, ws, p, (pl ->> 'project_work_id')::uuid, (pl ->> 'spec_revision_id')::uuid, pl ->> 'provider', pl ->> 'adapter',
            case when pl ->> 'provider' in ('local_harness','browser_runtime') then 'ready' else 'requested' end,
            coalesce(pl -> 'key_handles', '[]'), (pl ->> 'spend_limit_usd')::numeric, now() + interval '12 hours')
    returning id into rid;
    return jsonb_build_object('environmentSessionId', rid, 'status', (select status from learning.environment_session where id = rid));

  when 'create_client_grant' then
    tok := 'aiec_' || pg_catalog.encode(extensions.gen_random_bytes(24), 'hex');
    insert into access.client_grant(tenant_id, principal_id, client_kind, label, token_sha256, scopes, workspace_ids, expires_at)
    values (t, p, pl ->> 'client_kind', pl ->> 'label', product.sha256_text(tok), array(select jsonb_array_elements_text(pl -> 'scopes')),
            case when pl ? 'workspace_ids' then array(select (jsonb_array_elements_text(pl -> 'workspace_ids'))::uuid) end,
            now() + make_interval(hours => coalesce((pl ->> 'ttl_hours')::int, 720))) returning id into rid;
    return jsonb_build_object('grantId', rid, 'token', tok);

  when 'revoke_client_grant' then
    update access.client_grant set revoked_at = now() where id = (pl ->> 'grant_id')::uuid and principal_id = p and revoked_at is null;
    return jsonb_build_object('revoked', true);

  when 'invite_guardian' then
    insert into access.guardian_link(tenant_id, youth_id, guardian_id, state) values (t, p, (pl ->> 'guardian_id')::uuid, 'invited') returning id into rid;
    return jsonb_build_object('guardianLinkId', rid);

  when 'consent_guardian' then
    update access.guardian_link set state = 'consented', consented_at = now(), consent_method = pl ->> 'consent_method',
           help_scope = array(select jsonb_array_elements_text(coalesce(pl -> 'help_scope', '[]')))
     where id = (pl ->> 'guardian_link_id')::uuid and guardian_id = p and state = 'invited';
    get diagnostics cnt = row_count;
    if cnt = 0 then perform product.fail('NOT_FOUND', 'guardian invitation'); end if;
    return jsonb_build_object('consented', true);

  when 'authorize_processing' then
    -- self consent, or guardian consent for a youth with a consented link
    if (pl ->> 'principal_id')::uuid = p then
      if product.band(p) = 'child' or product.band_rank(product.band(p)) < product.band_rank(coalesce(product.policy() ->> 'self_consent_min_band', 'teen')) then
        perform product.fail('CONSENT_REQUIRED', 'guardian consent required for this account');
      end if;
      insert into access.processing_authorization(tenant_id, principal_id, processor_class, processor_key, purpose, basis, policy_version_id, granted_by)
      values (t, p, pl ->> 'processor_class', pl ->> 'processor_key', pl ->> 'purpose', 'self', (product.policy() ->> 'policy_version_id')::uuid, p) returning id into rid;
    else
      select gl.id into aid from access.guardian_link gl where gl.youth_id = (pl ->> 'principal_id')::uuid and gl.guardian_id = p and gl.state = 'consented';
      if aid is null then perform product.fail('NOT_FOUND', 'guardian link'); end if;
      insert into access.processing_authorization(tenant_id, principal_id, processor_class, processor_key, purpose, basis, guardian_link_id, policy_version_id, granted_by)
      values (t, (pl ->> 'principal_id')::uuid, pl ->> 'processor_class', pl ->> 'processor_key', pl ->> 'purpose', 'guardian', aid,
              (product.policy() ->> 'policy_version_id')::uuid, p) returning id into rid;
    end if;
    return jsonb_build_object('authorizationId', rid);

  else
    return product.dispatch_research_command(ws, op, head, pl, p, g, human, surface);
  end case;
end $$;
create or replace function api.modules_using_software(p_software uuid) returns table(
  work_id uuid, work_kind text, work_slug text, revision_id uuid, revision_title text, revision_created_at timestamptz, binding text, version_spec text, software text,
  latest_release text, latest_release_at timestamptz, latest_release_breaking boolean, releases_since_revision bigint)
language sql stable security definer set search_path = '' as $$
  with b as (
    select x.revision_id, 'binding:'||x.relation binding, null::text version_spec from authoring.revision_binding x where x.entity_id = p_software
    union all select q.revision_id, 'runtime_requirement', q.version_spec from authoring.runtime_requirement q where q.entity_id = p_software
  ), rel as (select r.* from api.software_releases r where r.software_id = p_software)
  select w.id, w.kind, w.slug, rv.id, rv.title, rv.created_at, b.binding, b.version_spec, s.display_name,
    (select r.release from rel r order by r.released_at desc nulls last limit 1), (select r.released_at from rel r order by r.released_at desc nulls last limit 1),
    (select r.breaking from rel r order by r.released_at desc nulls last limit 1), (select count(*) from rel r where r.released_at > rv.created_at)
  from b join authoring.work_revision rv on rv.id = b.revision_id join authoring.work w on w.id = rv.work_id and w.head_revision_id = rv.id join catalog.entity s on s.id = p_software
  order by w.slug
$$;
comment on function api.modules_using_software is 'L2 flywheel (time-independent): our head revisions that bind or require a software thing, with its latest known release and how many releases landed after the revision was authored.';
grant execute on function api.modules_using_software(uuid) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
grant usage on schema retrieval, content, catalog, guidance, acquisition, verification to app_reader, pipeline_agent, verifier_agent, control_plane;
grant select on content.document, content.document_version, content.document_representation, content.document_node, content.document_about_entity, content.document_type, content.document_digest, content.digest_item, content.unit_change, content.refresh_check, content.unit_entity_role to app_reader;

create or replace function api.talk_segments(p_talk uuid, p_from_ms integer default null, p_to_ms integer default null, p_query text default null) returns table(
  node_id uuid, unit_kind text, start_ms integer, end_ms integer, slide_n integer, text text, document_id uuid, representation_id uuid, logical_key text)
language sql stable security definer set search_path = '' as $$
  select n.id, n.unit_kind, n.start_ms, n.end_ms, (n.attributes->>'slide_n')::integer, n.inline_text, d.id, n.representation_id, n.logical_key
  from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and (d.work_entity_id = p_talk or exists (select 1 from content.document_about_entity a where a.document_id = d.id and a.entity_id = p_talk and a.role = 'primary'))
    and n.unit_kind in ('transcript_segment','slide','talk_writeup')
    and (p_from_ms is null or coalesce(n.end_ms, n.start_ms) >= p_from_ms) and (p_to_ms is null or n.start_ms <= p_to_ms)
    and (p_query is null or to_tsvector('english', coalesce(n.inline_text,'')) @@ websearch_to_tsquery('english', p_query))
  order by n.start_ms nulls last, n.ordinal
$$;
create or replace view api.talks as
  select w.id as talk_id, w.title, e.slug, w.attributes->>'talk_kind' talk_kind, w.attributes->>'track' track, w.attributes->>'level' level,
    ev.display_name event, ev.id event_id, (ev.attributes->>'starts_on') event_starts_on,
    api.names((select array_agg(x) from api.related(w.id, 'presented_by', 'outgoing') x)) speakers,
    (select array_agg(distinct org.display_name) from api.related(w.id, 'presented_by', 'outgoing') sp join catalog.relationship r on r.from_entity_id = sp and r.kind = 'employed_by' and r.k_to is null join catalog.entity org on org.id = r.to_entity_id) speaker_affiliations,
    api.names((select array_agg(x) from api.related(w.id, 'about', 'outgoing') x)) topics,
    api.names((select array_agg(x) from api.related(w.id, 'has_code', 'outgoing') x)) repositories,
    w.published_at recorded_at, w.duration_ms, w.canonical_url, w.attributes->>'video_url' video_url, w.attributes->>'slides_url' slides_url, w.attributes->>'session_id' session_id,
    (select count(*) from content.document d where d.work_entity_id = w.id or exists (select 1 from content.document_about_entity a where a.document_id = d.id and a.entity_id = w.id and a.role = 'primary')) document_count,
    e.summary
  from catalog.work w join catalog.entity e on e.id = w.id
  left join lateral (select x.* from catalog.entity x where x.id in (select api.related(w.id, 'presented_at', 'outgoing')) limit 1) ev on true
  where w.tenant_id = util.current_tenant_id() and w.kind = 'talk' and e.lifecycle = 'active';
grant select on api.talks to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
create or replace view api.claim_candidates as
  select c.id as claim_id, c.claim_type, c.statement, c.status::text as status, c.structured->>'path' as path, c.structured->>'source_role' as source_role,
    (c.structured->>'subject_resolved')::boolean as subject_resolved, c.structured->'speakers' as speakers, c.structured->>'attribution' as attribution,
    c.structured->>'learned_at' as learned_at, c.structured->>'agrees_with_first_party_claim' as agrees_with_first_party_claim,
    api.names((select array_agg(s.entity_id) from evidence.claim_subject s where s.claim_id = c.id)) as subjects,
    (select x.document_node_id from evidence.extraction_record x where x.claim_id = c.id limit 1) as document_node_id,
    (select d.canonical_title from evidence.extraction_record x join content.document_node n on n.id = x.document_node_id join content.document_representation r on r.id = n.representation_id
       join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id where x.claim_id = c.id limit 1) as document_title,
    c.created_at
  from evidence.claim c where c.tenant_id = util.current_tenant_id();
comment on view api.claim_candidates is 'L3/evidence: every claim with its path (deterministic_first_party = cheap path, L1_candidate = prose/media candidate awaiting verification), status, subjects and the document it was read from. Candidates are never facts.';
create or replace view api.claim_conflicts as
  select x.id as conflict_id, x.conflict_kind, x.detected_by, x.detected_at,
    a.id as first_party_claim_id, a.statement as first_party_statement, a.status::text as first_party_status,
    b.id as other_claim_id, b.statement as other_statement, b.status::text as other_status, b.structured->>'source_role' as other_source_role, b.structured->>'provenance' as other_provenance,
    (select r.outcome from evidence.conflict_reconciliation r where r.conflict_id = x.id order by r.decided_at desc limit 1) as reconciliation
  from evidence.claim_conflict x join evidence.claim a on a.id = x.claim_a_id join evidence.claim b on b.id = x.claim_b_id where a.tenant_id = util.current_tenant_id();
comment on view api.claim_conflicts is 'Kept disagreements between a first-party claim and another statement (value, scope or subject ambiguity); never averaged away, reconciled only by an explicit decision.';
grant select on api.claim_candidates, api.claim_conflicts to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
commit;
