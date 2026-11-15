-- Build 08 knowledge loop 7 (candidate J): D-77 one search hit per target (api.search_unified collapses items of one claim, passage
-- or unit across spaces and lists the others in channel_scores.collapsed; p_collapse = false keeps the uncollapsed order); D-80
-- restatements of attribution-framed claims are readable through api.claim_restatements. Promoted 2026-11-15 from the lab drafts
-- 20261115120000 and 20261115120100 (the window-ordering fix folded in; kept in supabase/drafts/). Lab-proven on
-- disposable-aieng-build04; cycle record: Build 08 §28 in the AI Engineer review workspace.
begin;
drop function if exists api.search_unified(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, uuid[], text[], text[], integer, integer, integer, double precision);
CREATE OR REPLACE FUNCTION api.search_unified(p_query text, p_query_embedding halfvec DEFAULT NULL::halfvec, p_lenses text[] DEFAULT ARRAY['corpus'::text, 'ours'::text], p_tiers smallint[] DEFAULT NULL::smallint[], p_space_slugs text[] DEFAULT NULL::text[], p_document_types text[] DEFAULT NULL::text[], p_unit_kinds text[] DEFAULT NULL::text[], p_entity_ids uuid[] DEFAULT NULL::uuid[], p_as_of timestamp with time zone DEFAULT NULL::timestamp with time zone, p_workspace_ids uuid[] DEFAULT NULL::uuid[], p_source_roles text[] DEFAULT NULL::text[], p_content_kinds text[] DEFAULT NULL::text[], p_limit integer DEFAULT 20, p_candidate_limit integer DEFAULT 100, p_rrf_k integer DEFAULT 60, p_evidence_weight double precision DEFAULT 0.15, p_collapse boolean DEFAULT true)
 RETURNS TABLE(vector_item_id uuid, lens text, source_tier smallint, content_kind text, document_type_code text, unit_kind text, entity_id uuid, document_id uuid, document_version_id uuid, target_kind text, target_id uuid, workspace_id uuid, snippet text, start_ms integer, end_ms integer, observed_at timestamp with time zone, valid_during tstzrange, space_slug text, fused_score double precision, channel_scores jsonb)
 LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
declare t uuid := util.default_tenant_id(); q tsquery := websearch_to_tsquery('english', p_query);
begin
  if coalesce(length(btrim(p_query)),0) < 1 or length(p_query) > 4096 then raise exception 'query text length must be between 1 and 4096' using errcode='invalid_parameter_value'; end if;
  if p_limit not between 1 and 200 or p_candidate_limit not between p_limit and 2000 then raise exception 'result/candidate bounds are invalid' using errcode='invalid_parameter_value'; end if;
  if p_evidence_weight is null or p_evidence_weight not between 0 and 1 then raise exception 'evidence weight must be between 0 and 1' using errcode='invalid_parameter_value'; end if;
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
  ), judged as (
    select f.id, f.score, f.details, e2.source_tier tier_,
           case when p_evidence_weight > 0 then retrieval.evidence_signal(pt.claim_id, e2.document_id, e2.unit_kind) end ev
      from fused f join eligible e2 on e2.id = f.id left join retrieval.projection_target pt on pt.id = e2.projection_target_id
  ), ranked as (
    select j.*, j.score * (1 + coalesce(0.1 * (3 - j.tier_), 0)) * (1 + p_evidence_weight * coalesce((j.ev ->> 'signal')::double precision, 0)) final_
      from judged j
  ), keyed as (
    -- D-77 (loop 7): one hit per target. Items of one claim, passage, chunk ... in several spaces share a key; an item without a
    -- projection target is its own key.
    select r.*, e.space_slug_ sp_, pt.target_kind tk_,
           coalesce(pt.entity_id, pt.record_id, pt.chunk_id, pt.claim_id, pt.summary_id, pt.document_node_id, pt.digest_item_id, pt.digest_id, pt.authored_revision_id, pt.passage_id) tid_
      from ranked r join eligible e on e.id = r.id left join retrieval.projection_target pt on pt.id = e.projection_target_id
  ), grouped as (
    select k.*, row_number() over (partition by coalesce(k.tk_ || ':' || k.tid_::text, 'item:' || k.id::text) order by k.final_ desc, k.id) rn_,
           jsonb_agg(jsonb_build_object('vector_item_id', k.id, 'space_slug', k.sp_, 'score', round(k.final_::numeric, 6)))
             over (partition by coalesce(k.tk_ || ':' || k.tid_::text, 'item:' || k.id::text) order by k.final_ desc, k.id
                   rows between unbounded preceding and unbounded following) members_
      from keyed k
  )
  select e.id, e.lens, e.source_tier, e.content_kind, e.document_type_code, e.unit_kind, e.entity_id, e.document_id, e.document_version_id,
         g.tk_, g.tid_, e.workspace_id, left(e.search_text, 320), e.start_ms, e.end_ms, e.observed_at, e.valid_during, e.space_slug_, g.final_,
         (case when g.ev is null then g.details else g.details || jsonb_build_object('evidence', g.ev || jsonb_build_object('weight', p_evidence_weight,
              'factor', round((1 + p_evidence_weight * coalesce((g.ev ->> 'signal')::double precision, 0))::numeric, 4))) end)
         || case when p_collapse and jsonb_array_length(g.members_) > 1 then jsonb_build_object('collapsed', g.members_ - 0) else '{}'::jsonb end
  from grouped g join eligible e on e.id = g.id
  where not p_collapse or g.rn_ = 1
  order by g.final_ desc, e.id limit p_limit;
end $function$;
comment on function api.search_unified is
  'One search stack: RRF over FTS + trigram + ANN within lens/tier/space/facet filters, a small source-tier boost, an evidence factor 1 + weight x signal (loop 5, D-62, reported as channel_scores.evidence) and (loop 7, D-77) one hit per target: items of one claim, passage or unit in several spaces collapse to the best-ranked one, the others listed in channel_scores.collapsed (best first, the returned item at index 0 removed). p_collapse = false and p_evidence_weight = 0 reproduce the loop-4 order.';
grant execute on function api.search_unified(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, uuid[], text[], text[], integer, integer, integer, double precision, boolean)
  to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

-- D-80: a restatement is a claim atomized from an attribution-framed claim ("The post states that X" -> X); the probe verifies X.
create or replace view api.claim_restatements with (security_invoker = false) as
select r.id as claim_id, r.statement, r.status::text as status, (r.structured->>'qualified')::boolean as qualified, r.structured->>'dropped' as dropped,
       r.structured->>'probe' as probe, o.id as original_claim_id, o.statement as original_statement, o.status::text as original_status, r.created_at
  from evidence.claim r join evidence.claim o on o.id = r.atomized_from_id
 where r.structured->>'path' = 'restatement';
comment on view api.claim_restatements is 'Loop 7 (D-80): restated claims and the attribution-framed originals they were atomized from (the original stays proposed as the record of what a source said).';
revoke all on api.claim_restatements from public, anon;
grant select on api.claim_restatements to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
commit;
