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
