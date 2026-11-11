"""Build 08 knowledge loop 3: assemble the lab draft migration.

Two objects are edits of functions/views that already exist (api.search_unified, api.api_symbols); their current text is read
from the lab and patched, so the draft never carries a hand-copied body. Everything else is the hand-written SQL below.
Run once before applying: python -I -X utf8 scripts/knowledge-lab/loop3_build_draft.py
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa

OUT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "supabase", "drafts", "20261110140000_build08_loop3_libraries_talks_capabilities.sql"))
ROLES = "app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role"

HEAD = r"""-- Build 08 knowledge loop 3 draft (lab disposable-aieng-build04 only; pre-approved by John 2026-11-10, selection in
-- reviews/BUILD-08-LOOP-3-SELECTION.md §6). LangChain v1 + Deep Agents through the schema, two World's Fair talks connected
-- through anchored digests and unverified claim candidates, and the capability slice (CAP-D12). No new schema, no new
-- knowledge table: vocabulary rows, one column on retrieval.projection_target, api views/functions, and the D-40 repair.
begin;

-- ====================================================================================================== RV04 symbols
update content.unit_kind set attributes_schema = jsonb_set(attributes_schema, '{properties}', (attributes_schema->'properties') || '{"overloads":{"type":"array","items":{"type":"string"}},"overload_count":{"type":"integer"},"uses_external":{"type":"array","items":{"type":"string"}}}'::jsonb)
 where code = 'api_symbol';
alter table content.unit_link drop constraint if exists unit_link_kind_check;
alter table content.unit_link add constraint unit_link_kind_check check (kind in ('documents','cites','supersedes','implements','mentions','same_symbol','imports'));
comment on column content.unit_link.kind is 'documents | cites | supersedes | implements | mentions | same_symbol | imports (a symbol whose body uses a symbol of another library; loop 3).';

create or replace function api.release_order(p_tag text) returns integer[] language sql immutable set search_path = '' as $$
  select coalesce(array(select (m)[1]::integer from regexp_matches(coalesce(p_tag, ''), '(\d+)', 'g') m), '{}')
$$;

create or replace function api.symbol_history(p_repository text, p_package text default null)
returns table(qualified_name text, symbol_kind text, package text, first_tag text, first_released_on text, last_tag text, releases_present integer, releases_total integer, in_latest boolean, latest_node_id uuid)
language sql stable security definer set search_path = '' as $$
  with s as (
    select d.attributes->>'package' as package, d.attributes->>'release_tag' as tag, d.attributes->>'released_on' as released_on, n.id as node_id,
           n.attributes->>'qualified_name' as qn, n.attributes->>'kind' as kind
      from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id
      join content.document_node n on n.representation_id = r.id
     where d.tenant_id = util.current_tenant_id() and d.document_type_code = 'api_surface' and n.unit_kind = 'api_symbol'
       and d.attributes->>'repository' = p_repository and (p_package is null or d.attributes->>'package' = p_package)
  ), tags as (
    select package, tag, max(released_on) released_on, row_number() over (partition by package order by api.release_order(tag)) as ord, count(*) over (partition by package) as total
      from s group by package, tag
  ), per as (
    select s.package, s.qn, min(s.kind) kind, min(t.ord) first_ord, max(t.ord) last_ord, count(distinct s.tag)::integer present, max(t.total)::integer total
      from s join tags t on t.package = s.package and t.tag = s.tag group by s.package, s.qn
  )
  select p.qn, p.kind, p.package, f.tag, f.released_on, l.tag, p.present, p.total, p.last_ord = p.total,
         (select min(s2.node_id::text)::uuid from s s2 where s2.package = p.package and s2.qn = p.qn and s2.tag = l.tag)
    from per p join tags f on f.package = p.package and f.ord = p.first_ord join tags l on l.package = p.package and l.ord = p.last_ord
   order by p.package, p.qn
$$;
comment on function api.symbol_history is 'L2: per public symbol of a repository, the first and the last ingested release that defines it (release order by tag digits). Only as complete as the releases ingested as api_surface documents.';

create or replace view api.symbol_docs as
 select s.id as symbol_node_id, sd.attributes->>'repository' as repository, sd.attributes->>'release_tag' as release_tag, sd.attributes->>'package' as package,
        s.attributes->>'qualified_name' as qualified_name, s.attributes->>'kind' as symbol_kind, l.kind as link_kind, l.method as link_method, l.confidence,
        n.id as docs_node_id, n.unit_kind as docs_unit_kind, n.attributes->>'heading' as heading, n.attributes->>'path' as section_path, left(n.inline_text, 400) as excerpt,
        d.id as document_id, d.canonical_title as document_title, d.document_type_code, src.canonical_url as url, v.version_label, n.attributes->>'version_note' as version_note
   from content.unit_link l
   join content.document_node s on s.id = l.to_node_id and s.unit_kind = 'api_symbol'
   join content.document_representation sr on sr.id = s.representation_id join content.document_version sv on sv.id = sr.document_version_id join content.document sd on sd.id = sv.document_id
   join content.document_node n on n.id = l.from_node_id
   join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
   left join evidence.source src on src.id = d.canonical_source_id
  where l.tenant_id = util.current_tenant_id() and l.kind in ('documents','mentions');
comment on view api.symbol_docs is 'L3: the docs sections and code examples that document or mention a public API symbol (R4), one call: filter by qualified_name or repository.';

-- ====================================================================================================== RV12 retrieval: D-40 and digest items as targets
alter table retrieval.projection_target add column digest_item_id uuid references content.digest_item(id);
alter table retrieval.projection_target drop constraint projection_target_exactly_one, drop constraint projection_target_kind_matches, drop constraint projection_target_target_kind_check, drop constraint projection_target_one_row_per_target;
alter table retrieval.projection_target
  add constraint projection_target_target_kind_check check (target_kind in ('entity','record','chunk','claim','summary','unit','digest','authored','passage','digest_item')),
  add constraint projection_target_exactly_one check (num_nonnulls(entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id) = 1),
  add constraint projection_target_kind_matches check ((target_kind = 'entity' and entity_id is not null) or (target_kind = 'record' and record_id is not null) or (target_kind = 'chunk' and chunk_id is not null)
     or (target_kind = 'claim' and claim_id is not null) or (target_kind = 'summary' and summary_id is not null) or (target_kind = 'unit' and document_node_id is not null) or (target_kind = 'digest' and digest_id is not null)
     or (target_kind = 'authored' and authored_revision_id is not null) or (target_kind = 'passage' and passage_id is not null) or (target_kind = 'digest_item' and digest_item_id is not null)),
  add constraint projection_target_one_row_per_target unique nulls not distinct (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id);
comment on column retrieval.projection_target.digest_item_id is 'One digest item is one retrieval target (loop 3, owner refinement 2a.1): the item resolves to its anchor units through content.digest_item.node_ids.';

create or replace function retrieval.index_text_item(p_space_slug text, p_target_kind text, p_target_id uuid, p_text text, p_lens text, p_source_tier smallint, p_content_kind text, p_entity_id uuid DEFAULT NULL::uuid, p_secondary_entity_ids uuid[] DEFAULT '{}'::uuid[], p_document_type_code text DEFAULT NULL::text, p_unit_kind text DEFAULT NULL::text, p_document_id uuid DEFAULT NULL::uuid, p_document_version_id uuid DEFAULT NULL::uuid, p_source_role_code text DEFAULT NULL::text, p_valid_during tstzrange DEFAULT NULL::tstzrange, p_knowledge_seq bigint DEFAULT NULL::bigint, p_workspace_id uuid DEFAULT NULL::uuid, p_language text DEFAULT 'en'::text, p_observed_at timestamp with time zone DEFAULT NULL::timestamp with time zone, p_start_ms integer DEFAULT NULL::integer, p_end_ms integer DEFAULT NULL::integer, p_contextual_prefix text DEFAULT ''::text, p_assurance_rank smallint DEFAULT NULL::smallint)
 returns uuid language plpgsql security definer set search_path to '' as $function$
declare t uuid := util.default_tenant_id(); vsv uuid; target uuid; proj uuid; item uuid; proc uuid; sha text := encode(sha256(convert_to(p_text,'UTF8')),'hex'); esha text := encode(sha256(convert_to(p_contextual_prefix||p_text,'UTF8')),'hex'); psha text := encode(sha256(convert_to(coalesce(p_contextual_prefix,''),'UTF8')),'hex'); created timestamptz;
begin
 if p_text is null or btrim(p_text) = '' then raise exception 'empty text cannot be indexed' using errcode='invalid_parameter_value'; end if;
 if p_lens = 'private' and p_workspace_id is null then raise exception 'private items need a workspace' using errcode='invalid_parameter_value'; end if;
 select v.id into vsv from retrieval.vector_space_version v join retrieval.vector_space s on s.id = v.vector_space_id where s.tenant_id = t and s.slug = p_space_slug order by v.version desc limit 1;
 if vsv is null then raise exception 'unknown vector space %', p_space_slug; end if;
 select id into proc from retrieval.projection_procedure where slug = 'build08-text' and version = 1;
 insert into retrieval.projection_target(tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id)
 values (t, p_target_kind,
   case when p_target_kind='entity' then p_target_id end, case when p_target_kind='record' then p_target_id end, case when p_target_kind='chunk' then p_target_id end,
   case when p_target_kind='claim' then p_target_id end, case when p_target_kind='summary' then p_target_id end, case when p_target_kind='unit' then p_target_id end,
   case when p_target_kind='digest' then p_target_id end, case when p_target_kind='authored' then p_target_id end, case when p_target_kind='passage' then p_target_id end,
   case when p_target_kind='digest_item' then p_target_id end)
 on conflict (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id) do update set retired_at = null
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
 returning id, created_at into item, created;
 -- D-40: one active item per target and space. A target of kind 'digest' is exempt (legacy: many items shared one digest target before digest_item existed).
 if p_target_kind <> 'digest' then
   update retrieval.vector_item set superseded_by_id = item where tenant_id = t and space_version_id = vsv and projection_target_id = target and id <> item and lifecycle = 'active' and superseded_by_id is null and created_at < created;
   update retrieval.vector_item set lifecycle = 'superseded' where tenant_id = t and space_version_id = vsv and projection_target_id = target and id <> item and lifecycle = 'active';
 end if;
 return item;
end $function$;

create or replace function retrieval.supersede_duplicate_items() returns integer language plpgsql security definer set search_path = '' as $$
declare n integer := 0; g record; keep uuid; keep_created timestamptz;
begin
 for g in select vi.tenant_id, vi.space_version_id, vi.projection_target_id from retrieval.vector_item vi join retrieval.projection_target pt on pt.id = vi.projection_target_id
           where vi.lifecycle = 'active' and pt.target_kind <> 'digest' group by 1, 2, 3 having count(*) > 1 loop
   select id, created_at into keep, keep_created from retrieval.vector_item where tenant_id = g.tenant_id and space_version_id = g.space_version_id and projection_target_id = g.projection_target_id and lifecycle = 'active' order by created_at desc, id desc limit 1;
   update retrieval.vector_item set superseded_by_id = keep where tenant_id = g.tenant_id and space_version_id = g.space_version_id and projection_target_id = g.projection_target_id and id <> keep and lifecycle = 'active' and superseded_by_id is null and created_at < keep_created;
   with u as (update retrieval.vector_item set lifecycle = 'superseded' where tenant_id = g.tenant_id and space_version_id = g.space_version_id and projection_target_id = g.projection_target_id and id <> keep and lifecycle = 'active' returning 1)
   select n + count(*) into n from u;
 end loop;
 return n;
end $$;
comment on function retrieval.supersede_duplicate_items is 'Repair for D-40 (Build 08 loop 2): keeps the newest active vector item per target and space and marks the older ones superseded. Idempotent.';
revoke all on function retrieval.supersede_duplicate_items() from public;
grant execute on function retrieval.supersede_duplicate_items() to pipeline_agent, control_plane, service_role;

-- ====================================================================================================== RV11 digests, RV06 talks, RV10 claims
alter table content.digest_item drop constraint if exists digest_item_item_kind_check;
alter table content.digest_item add constraint digest_item_item_kind_check check (item_kind in ('key_point','entity_role','assertion_ref','change','open_question','limitation','research_direction','problem','method','key_result','artifact','practitioner_change','recommendation'));
comment on column content.digest_item.item_kind is 'key_point | entity_role | assertion_ref | change | open_question | limitation | research_direction | problem | method | key_result | artifact | practitioner_change | recommendation (what a source recommends doing, kept apart from what it asserts; loop 3).';

create or replace function api.document_work(p_document uuid) returns uuid language sql stable security definer set search_path = '' as $$
  select coalesce((select d.work_entity_id from content.document d where d.id = p_document),
                  (select a.entity_id from content.document_about_entity a join catalog.work w on w.id = a.entity_id where a.document_id = p_document and a.role = 'primary' limit 1))
$$;
create or replace function api.timecode_link(p_url text, p_start_ms integer) returns text language sql immutable set search_path = '' as $$
  select case when p_url is null or p_start_ms is null then p_url else p_url || case when position('?' in p_url) > 0 then '&' else '?' end || 't=' || (p_start_ms / 1000)::text || 's' end
$$;

create or replace view api.digest_items as
 select i.id as item_id, g.id as digest_id, g.scope, g.scope_node_id, (select sn.attributes->>'heading' from content.document_node sn where sn.id = g.scope_node_id) as scope_heading,
        d.id as document_id, d.canonical_title as document_title, d.document_type_code, v.id as document_version_id, v.version_label,
        i.ordinal, i.item_kind, i.text, i.payload, i.node_ids, cardinality(i.node_ids) as anchor_count, i.entity_id, (select e.display_name from catalog.entity e where e.id = i.entity_id) as entity,
        i.payload->>'role' as entity_role, i.claim_id, i.unit_change_id, i.confidence, g.producer_kind, g.producer_identity,
        (select min(n.start_ms) from content.document_node n where n.id = any(i.node_ids)) as start_ms,
        (select max(coalesce(n.end_ms, n.start_ms)) from content.document_node n where n.id = any(i.node_ids)) as end_ms,
        api.document_work(d.id) as work_id,
        api.timecode_link((select w.canonical_url from catalog.work w where w.id = api.document_work(d.id)), (select min(n.start_ms) from content.document_node n where n.id = any(i.node_ids))) as deep_link
   from content.digest_item i join content.document_digest g on g.id = i.digest_id join content.document_version v on v.id = g.document_version_id join content.document d on d.id = v.document_id
  where i.tenant_id = util.current_tenant_id() and g.lifecycle = 'active';
comment on view api.digest_items is 'L3 summary level: one row per structured digest item with its anchor units, entity role, claim candidate, timecode range and (for talks) a video deep link. The item, not a prose summary, is the unit of retrieval.';

create or replace function api.digest_item_passages(p_item uuid)
returns table(node_id uuid, unit_kind text, start_ms integer, end_ms integer, text text, logical_key text, document_id uuid, deep_link text)
language sql stable security definer set search_path = '' as $$
  select n.id, n.unit_kind, n.start_ms, n.end_ms, n.inline_text, n.logical_key, d.id,
         api.timecode_link((select w.canonical_url from catalog.work w where w.id = api.document_work(d.id)), n.start_ms)
    from content.digest_item i join lateral unnest(i.node_ids) with ordinality a(node_id, ord) on true join content.document_node n on n.id = a.node_id
    join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
   where i.id = p_item and i.tenant_id = util.current_tenant_id() order by n.start_ms nulls last, a.ord
$$;
comment on function api.digest_item_passages is 'Open the passage behind a digest item: its anchor units in source order, with a timecode deep link for talks.';

drop function if exists api.talk_segments(uuid, integer, integer, text);
create function api.talk_segments(p_talk uuid, p_from_ms integer default null, p_to_ms integer default null, p_query text default null)
returns table(node_id uuid, unit_kind text, start_ms integer, end_ms integer, slide_n integer, text text, document_id uuid, representation_id uuid, logical_key text, deep_link text)
language sql stable security definer set search_path = '' as $$
  select n.id, n.unit_kind, n.start_ms, n.end_ms, (n.attributes->>'slide_n')::integer, n.inline_text, d.id, n.representation_id, n.logical_key,
         api.timecode_link((select w.canonical_url from catalog.work w where w.id = p_talk), n.start_ms)
    from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
   where d.tenant_id = util.current_tenant_id() and (d.work_entity_id = p_talk or exists (select 1 from content.document_about_entity a where a.document_id = d.id and a.entity_id = p_talk and a.role = 'primary'))
     and n.unit_kind in ('transcript_segment','slide','talk_writeup')
     and (p_from_ms is null or coalesce(n.end_ms, n.start_ms) >= p_from_ms) and (p_to_ms is null or n.start_ms <= p_to_ms)
     and (p_query is null or to_tsvector('english', coalesce(n.inline_text,'')) @@ websearch_to_tsquery('english', p_query))
   order by n.start_ms nulls last, n.ordinal
$$;
comment on function api.talk_segments is 'Transcript segments, slides and write-up chapters of a talk in time order; deep_link is the video URL at the segment start (the video is a link, never bytes).';

create or replace function api.talks_about(p_entity uuid)
returns table(talk_id uuid, talk text, level text, entity_role text, item_kind text, text text, start_ms integer, end_ms integer, deep_link text, item_id uuid, node_id uuid, document_id uuid)
language sql stable security definer set search_path = '' as $$
  with docs as (
    select d.id as document_id, api.document_work(d.id) as talk_id from content.document d
     where d.tenant_id = util.current_tenant_id() and d.document_type_code = 'aie_talk' and api.document_work(d.id) is not null
  )
  select k.talk_id, w.title, 'document'::text, a.role, null::text, null::text, null::integer, null::integer, w.canonical_url, null::uuid, null::uuid, k.document_id
    from docs k join catalog.work w on w.id = k.talk_id join content.document_about_entity a on a.document_id = k.document_id and a.entity_id = p_entity and a.role in ('primary','secondary')
  union all
  select k.talk_id, w.title, 'summary', i.entity_role, i.item_kind, i.text, i.start_ms, i.end_ms, i.deep_link, i.item_id, null::uuid, k.document_id
    from docs k join catalog.work w on w.id = k.talk_id join api.digest_items i on i.document_id = k.document_id and i.entity_id = p_entity
  union all
  select k.talk_id, w.title, 'passage', r.role, null, left(n.inline_text, 300), n.start_ms, n.end_ms, api.timecode_link(w.canonical_url, n.start_ms), null::uuid, n.id, k.document_id
    from docs k join catalog.work w on w.id = k.talk_id join content.document_version v on v.document_id = k.document_id join content.document_representation rp on rp.document_version_id = v.id
    join content.document_node n on n.representation_id = rp.id and n.unit_kind in ('transcript_segment','talk_writeup','slide') join content.unit_entity_role r on r.node_id = n.id and r.entity_id = p_entity
   order by 1, 3, 7 nulls first
$$;
comment on function api.talks_about is 'Two levels in one call: level document/summary = the talk is about the entity in a stated role (document_about_entity, digest items of kind entity_role); level passage = the entity is mentioned in that transcript segment (unit_entity_role), with timecode and deep link.';

create or replace function api.release_digest(p_release uuid)
returns table(item_id uuid, ordinal integer, item_kind text, text text, change_items jsonb, symbols jsonb, document_id uuid)
language sql stable security definer set search_path = '' as $$
  select i.id, i.ordinal, i.item_kind, i.text,
         (select jsonb_agg(jsonb_build_object('node_id', n.id, 'kind', n.attributes->>'kind', 'text', left(n.inline_text, 240)) order by n.ordinal) from content.document_node n where n.id = any(i.node_ids) and n.unit_kind = 'change_item'),
         (select jsonb_agg(jsonb_build_object('node_id', n.id, 'qualified_name', n.attributes->>'qualified_name', 'signature', n.attributes->>'signature') order by n.attributes->>'qualified_name') from content.document_node n where n.id = any(i.node_ids) and n.unit_kind = 'api_symbol'),
         v.document_id
    from content.document_digest g join content.digest_item i on i.digest_id = g.id join content.document_version v on v.id = g.document_version_id
   where g.tenant_id = util.current_tenant_id() and g.lifecycle = 'active' and g.scope = 'section'
     and exists (select 1 from content.unit_entity_role r where r.node_id = g.scope_node_id and r.entity_id = p_release and r.role = 'release')
   order by i.ordinal
$$;
comment on function api.release_digest is 'What changed in a release, as digest items anchored to change_item units and to the changed api_symbol units.';

create or replace view api.claim_surfaces as
 select c.id as claim_id, c.claim_type, c.statement, (c.status)::text as status, c.structured->>'path' as path, c.structured->>'assertion_mode' as assertion_mode,
        c.structured->'speakers' as speakers, c.structured->>'quote' as quote, (c.structured->>'t0_ms')::integer as start_ms, c.structured->>'deep_link' as deep_link,
        (c.structured->>'talk_id')::uuid as talk_id, (select w.title from catalog.work w where w.id = (c.structured->>'talk_id')::uuid) as talk,
        c.structured->>'consistency' as consistency, c.structured->>'consistency_note' as consistency_note, c.structured->>'compared_by' as compared_by,
        api.names((select array_agg(s.entity_id) from evidence.claim_subject s where s.claim_id = c.id)) as subjects,
        (select jsonb_agg(jsonb_build_object('node_id', n.id, 'unit_kind', n.unit_kind, 'label', coalesce(n.attributes->>'qualified_name', n.attributes->>'heading', left(n.inline_text, 80)),
                 'document', d.canonical_title, 'url', src.canonical_url, 'role', l.role) order by d.canonical_title)
           from evidence.claim_evidence_link l join evidence.locator lo on lo.id = l.locator_id join content.document_node n on n.id = (lo.selector->>'node_id')::uuid
           join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
           left join evidence.source src on src.id = d.canonical_source_id
          where l.claim_id = c.id and l.role = 'context') as surfaces,
        (select count(*) from evidence.claim_conflict x where x.claim_a_id = c.id or x.claim_b_id = c.id) as conflicts
   from evidence.claim c
  where c.tenant_id = util.current_tenant_id() and c.structured->>'path' = 'L1_candidate' and c.structured ? 'quote';
comment on view api.claim_surfaces is 'Claim candidates from talks (speaker, timecode, exact quote; always proposed, never adjudicated) with the library surfaces they concern (evidence links of role context) and the recorded reading: appears_consistent | appears_inconsistent | not_addressed | not_compared.';

-- ====================================================================================================== capability slice (CAP-D1..D7, D12)
do $$ declare c text; begin
  for c in select conname from pg_constraint where conrelid = 'catalog.entity_identifier'::regclass and contype = 'c' and pg_get_constraintdef(oid) like '%wikidata%' loop
    execute format('alter table catalog.entity_identifier drop constraint %I', c);
  end loop;
end $$;
alter table catalog.entity_identifier add constraint entity_identifier_scheme_check check (scheme in ('wikidata','ror','orcid','github','huggingface','npm','pypi','crates','go_module','doi','arxiv','openreview','mcp_registry','cve','ghsa','spdx','crunchbase','pitchbook','linkedin','x','youtube_channel','youtube_playlist','youtube_video','spotify','apple_podcasts','domain','sec_cik','lei','isin','skills_sh','oci','belllabs','other'));
comment on column catalog.entity_identifier.scheme is 'Upstream identifier scheme. Capabilities share identity with Mission Control by (scheme, value): mcp_registry, skills_sh, github (owner/repo#path), npm, pypi, oci, belllabs (CAP-D1). No foreign key crosses databases.';

insert into taxonomy.entity_kind(code, label, canonical_schema, canonical_table, description, attributes_schema, parent_kind, lens, is_work) values
  ('agent_plugin', 'Agent Plugin', 'catalog', 'entity', 'A harness plugin: a named bundle of skills, MCP servers, hooks, commands and prompts installed as one unit (CAP-D6). Hooks and commands are units of its manifest, not entities',
   '{"type":"object","properties":{"name":{"type":"string"},"description":{"type":"string"},"version":{"type":"string"},"author":{"type":"string"},"license":{"type":"string"},"harnesses":{"type":"array","items":{"type":"string"}},"source_repository":{"type":"string"},"source_path":{"type":"string"},"components":{"type":"object"}},"additionalProperties":true}'::jsonb, null, 'corpus', false)
on conflict (code) do nothing;
update taxonomy.entity_kind set attributes_schema = '{"type":"object","properties":{"name":{"type":"string"},"description":{"type":"string"},"license":{"type":"string"},"entry_path":{"type":"string"},"declared_tools":{"type":"array","items":{"type":"string"}},"declared_clis":{"type":"array","items":{"type":"string"}},"source_repository":{"type":"string"},"source_path":{"type":"string"},"shipped_with":{"type":"string"}},"additionalProperties":true}'::jsonb
 where code = 'agent_skill';

insert into taxonomy.relationship_kind(code, from_kinds, to_kinds, temporal, "symmetric", inverse_label, description, property_schema) values
  ('bundles', array['agent_plugin'], array['agent_skill','mcp_server'], false, false, 'bundled_in', 'A plugin bundles a skill or an MCP server (exact member, by identifier)', '{"type":"object","properties":{"config_path":{"type":"string"},"transport":{"type":"string"}}}'::jsonb)
on conflict (code) do nothing;
update taxonomy.relationship_kind set from_kinds = array(select distinct x from unnest(from_kinds || array['agent_plugin','agent_skill']) x) where code in ('listed_in','backed_by_repository','instance_of_concept');
update taxonomy.relationship_kind set from_kinds = array(select distinct x from unnest(from_kinds || array['mcp_server']) x) where code in ('backed_by_repository');
update taxonomy.relationship_kind set from_kinds = array(select distinct x from unnest(from_kinds || array['agent_plugin','agent_skill']) x), to_kinds = array(select distinct x from unnest(to_kinds || array['product']) x) where code = 'compatible_with';
update taxonomy.relationship_kind set to_kinds = array(select distinct x from unnest(to_kinds || array['agent_plugin']) x) where code in ('develops','about');

insert into content.document_type(code, family, description, is_primary_source, default_chunking_slug, default_extraction_kinds, default_spaces, default_summary_kinds, work_entity_kind, published_at_is_world_time, status, axis_note)
 select 'agent_plugin_manifest', family, 'The manifest of a harness plugin at one commit (plugin.json, hooks, commands, MCP configuration) with its file manifest; custody level recorded in attributes', is_primary_source, default_chunking_slug, default_extraction_kinds, default_spaces, default_summary_kinds, null, published_at_is_world_time, 'active', 'capability manifest: attributes carry identifier, commit, custody_level (C0|C1|C2)'
   from content.document_type where code = 'agent_skill_manifest'
on conflict (code) do nothing;

insert into content.unit_kind(code, description, is_universal, applicable_document_types, parent_kinds, attributes_schema, logical_key_attributes, selector_kind, retrieval_role, entity_roles) values
  ('mcp_tool', 'One tool an MCP server exposes at one version, keyed by server and name so version diffs work (CAP-D5). From a published manifest; a live tool list is a Mission Control inspection', false, array['mcp_server_manifest'], array['section','document_root'],
   '{"type":"object","required":["server","name"],"properties":{"server":{"type":"string"},"name":{"type":"string"},"description":{"type":"string"},"toolset":{"type":"string"},"input_schema":{"type":"object"},"required":{"type":"array","items":{"type":"string"}},"scopes":{"type":"array","items":{"type":"string"}},"read_only":{"type":"boolean"},"availability":{"type":"string"}},"additionalProperties":true}'::jsonb,
   array['server','name'], 'text_quote', 'embed', array['server']),
  ('mcp_prompt', 'One prompt an MCP server exposes at one version, keyed by server and name', false, array['mcp_server_manifest'], array['section','document_root'],
   '{"type":"object","required":["server","name"],"properties":{"server":{"type":"string"},"name":{"type":"string"},"description":{"type":"string"},"arguments":{"type":"array"}},"additionalProperties":true}'::jsonb,
   array['server','name'], 'text_quote', 'embed', array['server']),
  ('mcp_resource', 'One resource or resource template an MCP server exposes at one version, keyed by server and name', false, array['mcp_server_manifest'], array['section','document_root'],
   '{"type":"object","required":["server","name"],"properties":{"server":{"type":"string"},"name":{"type":"string"},"description":{"type":"string"},"uri_template":{"type":"string"},"mime_type":{"type":"string"}},"additionalProperties":true}'::jsonb,
   array['server','name'], 'text_quote', 'embed', array['server']),
  ('bundle_file', 'One file of a capability bundle (skill or plugin directory) at a pinned commit: the C1 file manifest (CAP-D3). A stated exception to rule R1, limited to capability bundles', false, array['agent_skill_manifest','agent_plugin_manifest','mcp_server_manifest'], array['section','document_root'],
   '{"type":"object","required":["path"],"properties":{"path":{"type":"string"},"size":{"type":"integer"},"mode":{"type":"string"},"executable":{"type":"boolean"},"symlink":{"type":"boolean"},"git_blob_id":{"type":"string"},"sha256":{"type":"string"},"role":{"type":"string","enum":["entry","instructions","script","cli","asset","config","binary","other"]},"commit":{"type":"string"}},"additionalProperties":true}'::jsonb,
   array['path'], 'repository', 'filter', array['capability']),
  ('hook_entry', 'One hook registration inside a plugin or harness configuration: event, matcher, command (CAP-D6)', false, array['agent_plugin_manifest'], array['section','document_root'],
   '{"type":"object","required":["event"],"properties":{"event":{"type":"string"},"matcher":{"type":"string"},"hook_type":{"type":"string"},"command":{"type":"string"},"timeout":{"type":"number"},"config_path":{"type":"string"},"ordinal":{"type":"integer"}},"additionalProperties":true}'::jsonb,
   array['config_path','event','matcher','ordinal'], 'json_pointer', 'embed', array['capability'])
on conflict do nothing;
update content.unit_kind set applicable_document_types = array(select distinct x from unnest(applicable_document_types || array['agent_skill_manifest','agent_plugin_manifest','mcp_server_manifest']) x) where code in ('docs_section','code_example') and applicable_document_types is not null;

create or replace view api.mcp_tools as
 select n.id as node_id, d.id as document_id, v.id as document_version_id, v.version_label, n.attributes->>'server' as server, n.attributes->>'name' as name, n.attributes->>'description' as description,
        n.attributes->>'toolset' as toolset, n.attributes->'input_schema' as input_schema, n.attributes->'required' as required, n.attributes->'scopes' as scopes, n.attributes->>'availability' as availability,
        (select r.entity_id from content.unit_entity_role r where r.node_id = n.id and r.role = 'server' limit 1) as server_id, d.attributes->>'custody_level' as custody_level, n.logical_key
   from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and n.unit_kind = 'mcp_tool';
comment on view api.mcp_tools is 'L1: tools an MCP server exposes per captured version (from a published manifest). Version diffs: content.unit_change by logical key.';
create or replace view api.mcp_prompts as
 select n.id as node_id, d.id as document_id, v.version_label, n.attributes->>'server' as server, n.attributes->>'name' as name, n.attributes->>'description' as description, n.attributes->'arguments' as arguments,
        (select r.entity_id from content.unit_entity_role r where r.node_id = n.id and r.role = 'server' limit 1) as server_id
   from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and n.unit_kind = 'mcp_prompt';
create or replace view api.mcp_resources as
 select n.id as node_id, d.id as document_id, v.version_label, n.attributes->>'server' as server, n.attributes->>'name' as name, n.attributes->>'description' as description, n.attributes->>'uri_template' as uri_template,
        (select r.entity_id from content.unit_entity_role r where r.node_id = n.id and r.role = 'server' limit 1) as server_id
   from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and n.unit_kind = 'mcp_resource';
create or replace view api.bundle_files as
 select n.id as node_id, d.id as document_id, v.version_label, (select r.entity_id from content.unit_entity_role r where r.node_id = n.id and r.role = 'capability' limit 1) as capability_id,
        (select e.display_name from content.unit_entity_role r join catalog.entity e on e.id = r.entity_id where r.node_id = n.id and r.role = 'capability' limit 1) as capability,
        n.attributes->>'path' as path, (n.attributes->>'size')::bigint as size, n.attributes->>'mode' as mode, (n.attributes->>'executable')::boolean as executable, n.attributes->>'git_blob_id' as git_blob_id,
        n.attributes->>'sha256' as sha256, n.attributes->>'role' as file_role, n.attributes->>'commit' as commit, d.attributes->>'custody_level' as custody_level
   from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and n.unit_kind = 'bundle_file';
comment on view api.bundle_files is 'L1: the C1 file manifest of a capability bundle at a pinned commit (path, size, mode, executable, git blob id; sha256 only when bytes were fetched). A later materialize can verify fetched bytes against git_blob_id.';
create or replace view api.hook_entries as
 select n.id as node_id, d.id as document_id, v.version_label, (select r.entity_id from content.unit_entity_role r where r.node_id = n.id and r.role = 'capability' limit 1) as plugin_id,
        (select e.display_name from content.unit_entity_role r join catalog.entity e on e.id = r.entity_id where r.node_id = n.id and r.role = 'capability' limit 1) as plugin,
        n.attributes->>'event' as event, n.attributes->>'matcher' as matcher, n.attributes->>'hook_type' as hook_type, n.attributes->>'command' as command, n.attributes->>'config_path' as config_path
   from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id
  where d.tenant_id = util.current_tenant_id() and n.unit_kind = 'hook_entry';

create or replace view api.capabilities as
 select e.id as capability_id, e.kind, e.display_name as capability, e.slug,
        (select jsonb_agg(jsonb_build_object('scheme', i.scheme, 'value', i.value) order by i.scheme) from catalog.entity_identifier i where i.entity_id = e.id) as identifiers,
        coalesce(m.custody_level, 'C0') as custody_level, m.document_id as manifest_document_id, m.commit, m.version_label,
        e.attributes->>'description' as description,
        (select count(*) from api.bundle_files f where f.capability_id = e.id and f.document_id = m.document_id) as files,
        (select count(*) from api.bundle_files f where f.capability_id = e.id and f.document_id = m.document_id and f.executable) as executable_files,
        (select count(*) from api.mcp_tools t where t.server_id = e.id and t.document_version_id = m.document_version_id) as tools,
        (select count(*) from api.hook_entries h where h.plugin_id = e.id) as hooks,
        api.names((select array_agg(x.x) from api.related(e.id, 'bundles', 'outgoing') x(x))) as bundles,
        api.names((select array_agg(x.x) from api.related(e.id, 'bundles', 'incoming') x(x))) as bundled_in,
        api.names((select array_agg(x.x) from api.related(e.id, 'compatible_with', 'outgoing') x(x))) as compatible_with,
        api.names((select array_agg(x.x) from api.related(e.id, 'listed_in', 'outgoing') x(x))) as listed_in,
        api.names((select array_agg(x.x) from api.related(e.id, 'backed_by_repository', 'outgoing') x(x))) as repositories
   from catalog.entity e
   left join lateral (select d.id as document_id, d.attributes->>'custody_level' as custody_level, d.attributes->>'commit' as commit, v.id as document_version_id, v.version_label
                        from content.document_about_entity a join content.document d on d.id = a.document_id join content.document_version v on v.document_id = d.id
                       where a.entity_id = e.id and a.role = 'primary' and d.document_type_code in ('agent_skill_manifest','mcp_server_manifest','agent_plugin_manifest')
                       order by v.created_at desc limit 1) m on true
  where e.tenant_id = util.current_tenant_id() and e.kind in ('agent_skill','mcp_server','agent_plugin') and e.lifecycle = 'active';
comment on view api.capabilities is 'L1: researched capabilities (skills, MCP servers, plugins) with shared upstream identifiers and the custody level of the latest manifest (C0 reference, C1 manifest, C2 bundle; recorded on the manifest document like ingestion_level).';
"""

TAIL = f"""
grant select on api.symbol_docs, api.digest_items, api.claim_surfaces, api.mcp_tools, api.mcp_prompts, api.mcp_resources, api.bundle_files, api.hook_entries, api.capabilities, api.api_symbols
  to {ROLES};
grant execute on function api.release_order(text), api.symbol_history(text, text), api.document_work(uuid), api.timecode_link(text, integer), api.digest_item_passages(uuid), api.talk_segments(uuid, integer, integer, text),
  api.talks_about(uuid), api.release_digest(uuid)
  to {ROLES};
commit;
"""


def main():
    su = one("select pg_get_functiondef(p.oid) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'api' and p.proname = 'search_unified'")
    out, _ = sql("select pg_get_functiondef(p.oid) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'api' and p.proname = 'search_unified'")
    su = out
    old = "pt.document_node_id, pt.digest_id, pt.authored_revision_id, pt.passage_id)"
    assert su.count(old) == 1, "search_unified body changed: patch point not found"
    su = su.replace(old, "pt.document_node_id, pt.digest_item_id, pt.digest_id, pt.authored_revision_id, pt.passage_id)")
    out, _ = sql("select pg_get_viewdef('api.api_symbols'::regclass, true)")
    vw = out.rstrip().rstrip(";")
    marker = "AS docs_links"
    assert vw.count(marker) == 1, "api.api_symbols changed: patch point not found"
    vw = vw.replace(marker, marker + ",\n    n.attributes -> 'overloads'::text AS overloads,\n    n.attributes -> 'uses_external'::text AS uses_external,\n    d.attributes ->> 'released_on'::text AS released_on")
    body = HEAD + "\n-- api.search_unified: a digest item is a first-class target (patched from the live definition)\n" + su.rstrip() + ";\n" \
        + "\n-- api.api_symbols: overloads, external uses and the release date (columns appended to the live definition)\ncreate or replace view api.api_symbols as\n" + vw + ";\n" + TAIL
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(body)
    print("wrote", OUT, len(body))


if __name__ == "__main__":
    main()
