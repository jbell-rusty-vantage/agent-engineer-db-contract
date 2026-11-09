-- Build 08 R2 draft, fixup 4 (loop-1 deltas D-07/D-16): knowledge readers need schema usage on retrieval to use the one stack under RLS;
-- a talk's documents are linked through content.document_about_entity (documents are append-only, so work_entity_id cannot be set later).
begin;
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
commit;
