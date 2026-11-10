-- Build 08 loop 2 draft, fixup 2 (2026-11-09): D-19 corrected — content.document_about_entity.role is constrained to
-- primary | secondary | mention, so a paper's document links to its work with role 'primary'; api.papers reads it that way.
-- D-21: benchmark_score may take a paper as its subject when a paper reports aggregate results of its own system
-- (UndoBench's 83.54 % nominal / 46.72 % recovery are the paper's numbers, not a catalogued model's).
begin;
drop view if exists api.papers;
create view api.papers as
 with doc as (
   select a.entity_id, d.id as document_id, d.attributes, d.document_type_code, row_number() over (partition by a.entity_id order by d.created_at desc) rn
   from content.document_about_entity a join content.document d on d.id = a.document_id
   where a.role = 'primary' and d.document_type_code in ('arxiv_paper','conference_paper','journal_article','tech_report','model_card','system_card','dataset_card','research_report')
 )
 select w.id as paper_id, w.title, w.attributes->>'arxiv_id' as arxiv_id, w.attributes->>'doi' as doi, w.published_at, w.canonical_url,
    api.names((select array_agg(x.x) from api.related(w.id, 'authored_by', 'outgoing') x(x))) as authors,
    api.names((select array_agg(x.x) from api.related(w.id, 'published_by', 'outgoing') x(x))) as publishers,
    api.names((select array_agg(x.x) from api.related(w.id, 'has_code', 'outgoing') x(x))) as repositories,
    api.names((select array_agg(x.x) from api.related(w.id, 'introduces_technique', 'outgoing') x(x))) as techniques,
    (select count(*) from catalog.relationship r join catalog.entity t on t.id = r.from_entity_id where r.to_entity_id = w.id and r.kind in ('about','cites') and t.kind = 'talk' and r.k_to is null) as talks_about,
    (select count(*) from catalog.relationship r where r.to_entity_id = w.id and r.kind = 'cites' and r.k_to is null) as cited_by_count,
    (select count(*) from catalog.relationship r where r.from_entity_id = w.id and r.kind = 'cites' and r.k_to is null) as cites_count,
    api.fact_amount(w.id, 'paper_citations') as citations, w.abstract,
    coalesce(doc.attributes->>'ingestion_level', w.attributes->>'ingestion_level', 'P0') as ingestion_level,
    coalesce(doc.attributes->'promotion', w.attributes->'promotion') as promotion,
    doc.document_id, doc.document_type_code, w.attributes->>'publication_form' as publication_form
   from catalog.work w join catalog.entity e on e.id = w.id left join doc on doc.entity_id = w.id and doc.rn = 1
  where w.tenant_id = util.current_tenant_id() and w.kind = 'paper' and e.lifecycle = 'active';
comment on view api.papers is 'L1: papers with authors, code, citing talks/papers, cited papers and the ingestion level (P0 reference / P1 digest / P2 full) with its recorded promotion decision (document linked through document_about_entity role primary).';
grant select on api.papers to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
update temporal.stream_kind set subject_kinds = array(select distinct x from unnest(subject_kinds || array['paper']) x) where code = 'benchmark_score';
commit;
