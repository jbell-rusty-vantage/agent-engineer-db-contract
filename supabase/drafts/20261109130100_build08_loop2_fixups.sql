-- Build 08 loop 2 draft, fixup 1 (in-loop deltas found while the first grammars ran, 2026-11-09):
-- D-17 price rows on compute pages name the device they price (role vocabulary); D-18 per-GB meters (data transfer, drive reads);
-- D-19 content.document is append-only, so a paper's document is linked to its work through content.document_about_entity (role 'work'),
--      and api.papers reads the ingestion level from there; D-20 the aggregator label for who measured.
begin;
update content.unit_kind set entity_roles = array['offering','provider','device'] where code = 'price_row' and version = 1;
update content.unit_kind set entity_roles = array['subject','benchmark','leaderboard','harness','publisher','system','device'] where code = 'leaderboard_row' and version = 1;
update temporal.stream_kind set unit_values = array(select distinct x from unnest(unit_values || array['USD_per_GB','USD_per_1K_images']) x) where code = 'offering_price';

drop view if exists api.papers;
create view api.papers as
 with doc as (
   select a.entity_id, d.id as document_id, d.attributes, d.document_type_code, row_number() over (partition by a.entity_id order by d.created_at desc) rn
   from content.document_about_entity a join content.document d on d.id = a.document_id where a.role = 'work'
 )
 select w.id as paper_id, w.title, w.attributes->>'arxiv_id' as arxiv_id, w.attributes->>'doi' as doi, w.published_at, w.canonical_url,
    api.names((select array_agg(x.x) from api.related(w.id, 'authored_by', 'outgoing') x(x))) as authors,
    api.names((select array_agg(x.x) from api.related(w.id, 'published_by', 'outgoing') x(x))) as publishers,
    api.names((select array_agg(x.x) from api.related(w.id, 'has_code', 'outgoing') x(x))) as repositories,
    api.names((select array_agg(x.x) from api.related(w.id, 'introduces_technique', 'outgoing') x(x))) as techniques,
    (select count(*) from catalog.relationship r join catalog.entity t on t.id = r.from_entity_id where r.to_entity_id = w.id and r.kind in ('about','cites') and t.kind = 'talk' and r.k_to is null) as talks_about,
    (select count(*) from catalog.relationship r where r.to_entity_id = w.id and r.kind = 'cites' and r.k_to is null) as cited_by_count,
    api.fact_amount(w.id, 'paper_citations') as citations, w.abstract,
    coalesce(doc.attributes->>'ingestion_level', w.attributes->>'ingestion_level', 'P0') as ingestion_level,
    coalesce(doc.attributes->'promotion', w.attributes->'promotion') as promotion,
    doc.document_id, doc.document_type_code, w.attributes->>'publication_form' as publication_form
   from catalog.work w join catalog.entity e on e.id = w.id left join doc on doc.entity_id = w.id and doc.rn = 1
  where w.tenant_id = util.current_tenant_id() and w.kind = 'paper' and e.lifecycle = 'active';
comment on view api.papers is 'L1: papers with authors, code, citing talks/papers and the ingestion level (P0 reference / P1 digest / P2 full) with its recorded promotion decision (document linked through document_about_entity role work).';
grant select on api.papers to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
commit;
