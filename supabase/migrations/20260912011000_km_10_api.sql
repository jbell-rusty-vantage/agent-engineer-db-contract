-- Knowledge model v2: api. See docs/knowledge-model/FINAL-RECOMMENDATION.md.
begin;
set local lock_timeout = '15s';

create function api.resolve_entity(p_text text) returns table(entity_id uuid,kind text,display_name text,score real) language sql stable security definer set search_path='' as $$
 select e.id,e.kind,e.display_name,greatest(extensions.similarity(e.display_name,p_text),coalesce((select max(extensions.similarity(a.alias,p_text)) from corpus.entity_alias a where a.entity_id=e.id and a.tenant_id=e.tenant_id),0),case when exists(select 1 from corpus.entity_identifier i where i.entity_id=e.id and i.tenant_id=e.tenant_id and i.value=p_text) then 1 else 0 end)::real score
 from corpus.entity e where e.tenant_id=util.current_tenant_id() and e.lifecycle='active' and (e.display_name operator(extensions.%) p_text or exists(select 1 from corpus.entity_alias a where a.entity_id=e.id and a.alias operator(extensions.%) p_text) or exists(select 1 from corpus.entity_identifier i where i.entity_id=e.id and i.value=p_text)) order by score desc,e.id limit 25
$$;
create function api.entity_at(p_entity uuid,p_at timestamptz default now(),p_k bigint default null) returns table(segment_id uuid,stream_kind text,scope_key text,valid_during tstzrange,status text,amount numeric,currency text,unit text,ref_entity_id uuid,ref_display_name text,payload jsonb,belief text,k_from bigint,k_to bigint) language sql stable security definer set search_path='' as $$
 select s.id,st.kind,st.scope_key,s.valid_during,s.status,s.amount,s.currency::text,s.unit,s.ref_entity_id,e.display_name,s.payload,s.belief,s.k_from,s.k_to from temporal.segment s join temporal.stream st on st.id=s.stream_id and st.tenant_id=s.tenant_id left join corpus.entity e on e.id=s.ref_entity_id and e.tenant_id=s.tenant_id
 where s.tenant_id=util.current_tenant_id() and st.subject_entity_id=p_entity and s.valid_during @> p_at and s.k_from<=coalesce(p_k,(select knowledge_seq from temporal.knowledge_head where tenant_id=s.tenant_id)) and (s.k_to is null or s.k_to>coalesce(p_k,(select knowledge_seq from temporal.knowledge_head where tenant_id=s.tenant_id)))
$$;
create function api.relationships(p_entity uuid,p_kind text default null,p_at timestamptz default now(),p_k bigint default null,p_direction text default 'both') returns setof corpus.relationship language sql stable security definer set search_path='' as $$
 select r.* from corpus.relationship r join taxonomy.relationship_kind rk on rk.code=r.kind
 where r.tenant_id=util.current_tenant_id() and (p_kind is null or r.kind=p_kind) and ((p_direction in ('both','outgoing') and r.from_entity_id=p_entity) or(p_direction in ('both','incoming') and r.to_entity_id=p_entity)) and r.k_from<=coalesce(p_k,(select knowledge_seq from temporal.knowledge_head where tenant_id=r.tenant_id)) and (r.k_to is null or r.k_to>coalesce(p_k,(select knowledge_seq from temporal.knowledge_head where tenant_id=r.tenant_id))) and (not rk.temporal or exists(select 1 from temporal.stream st join temporal.segment s on s.stream_id=st.id where st.subject_relationship_id=r.id and st.kind='relationship_active' and s.status='active' and s.valid_during @> p_at and s.k_from<=coalesce(p_k,(select knowledge_seq from temporal.knowledge_head where tenant_id=r.tenant_id)) and (s.k_to is null or s.k_to>coalesce(p_k,(select knowledge_seq from temporal.knowledge_head where tenant_id=r.tenant_id)))))
$$;
create function api.entity_timeline(p_entity uuid,p_from timestamptz,p_to timestamptz,p_k bigint default null) returns table(item_kind text,item_id uuid,world_interval tstzrange,details jsonb) language sql stable security definer set search_path='' as $$
 with head as(select coalesce(p_k,knowledge_seq) k from temporal.knowledge_head where tenant_id=util.current_tenant_id()),facts as(select s.*,st.kind,st.scope_key from temporal.segment s join temporal.stream st on st.id=s.stream_id,head where s.tenant_id=util.current_tenant_id() and st.subject_entity_id=p_entity and s.k_from<=head.k and(s.k_to is null or s.k_to>head.k) and s.valid_during && tstzrange(p_from,p_to,'[)'))
 select 'segment',id,valid_during,jsonb_build_object('kind',kind,'scope',scope_key,'status',status,'amount',amount,'payload',payload,'belief',belief) from facts
 union all select 'event',o.id,o.occurred_during,jsonb_build_object('kind',e.kind,'mode',o.occurrence_mode,'payload',o.payload) from temporal.event e join temporal.event_occurrence o on o.event_id=e.id,head where e.tenant_id=util.current_tenant_id() and e.subject_entity_id=p_entity and o.k_from<=head.k and(o.k_to is null or o.k_to>head.k) and o.occurred_during && tstzrange(p_from,p_to,'[)')
 union all select 'unknown',st.id,gap,jsonb_build_object('kind',st.kind,'scope',st.scope_key,'belief','unknown') from temporal.stream st cross join lateral unnest(tstzmultirange(tstzrange(p_from,p_to,'[)'))-coalesce((select range_agg(f.valid_during) from facts f where f.stream_id=st.id),'{}'::tstzmultirange)) gap where st.tenant_id=util.current_tenant_id() and st.subject_entity_id=p_entity
$$;
create function api.what_changed(p_entity uuid,p_k1 bigint,p_k2 bigint) returns table(change_kind text,item_kind text,item_id uuid,knowledge_seq bigint,details jsonb) language sql stable security definer set search_path='' as $$
 with items as(select 'segment' kind,s.id,s.k_from,s.k_to,to_jsonb(s) data from temporal.segment s join temporal.stream st on st.id=s.stream_id where s.tenant_id=util.current_tenant_id() and(st.subject_entity_id=p_entity or st.subject_relationship_id in(select id from corpus.relationship where from_entity_id=p_entity or to_entity_id=p_entity))
 union all select 'event',o.id,o.k_from,o.k_to,to_jsonb(o) from temporal.event_occurrence o join temporal.event e on e.id=o.event_id where e.tenant_id=util.current_tenant_id() and e.subject_entity_id=p_entity
 union all select 'relationship',r.id,r.k_from,r.k_to,to_jsonb(r) from corpus.relationship r where r.tenant_id=util.current_tenant_id() and(p_entity=r.from_entity_id or p_entity=r.to_entity_id))
 select 'opened',kind,id,k_from,data from items where k_from>p_k1 and k_from<=p_k2 union all select 'closed',kind,id,k_to,data from items where k_to>p_k1 and k_to<=p_k2
$$;
create function api.entity_card(p_entity uuid) returns jsonb language sql stable security definer set search_path='' as $$
 select jsonb_build_object('entity',to_jsonb(e),'aliases',coalesce((select jsonb_agg(alias) from corpus.entity_alias where entity_id=e.id),'[]'::jsonb),'facts',coalesce((select jsonb_agg(to_jsonb(f)) from api.entity_at(e.id) f),'[]'::jsonb),'relationships',coalesce((select jsonb_agg(to_jsonb(r)) from api.relationships(e.id) r),'[]'::jsonb),'events',coalesce((select jsonb_agg(x) from(select ev.kind,o.occurred_during,o.occurrence_mode from temporal.event ev join temporal.event_occurrence o on o.event_id=ev.id where ev.subject_entity_id=e.id and o.k_to is null order by lower(o.occurred_during) desc limit 20)x),'[]'::jsonb),'sources',coalesce((select jsonb_agg(jsonb_build_object('source_id',s.id,'last_seen_at',s.last_seen_at,'next_revisit_after',s.next_revisit_after)) from evidence.source s where s.publisher_entity_id=e.id),'[]'::jsonb)) from corpus.entity e where e.id=p_entity and e.tenant_id=util.current_tenant_id()
$$;
create view api.entities with(security_invoker=true) as select e.*,coalesce((select array_agg(a.alias) from corpus.entity_alias a where a.entity_id=e.id),'{}') aliases from corpus.entity e;
create view api.current_facts with(security_invoker=true) as select s.*,st.kind stream_kind,st.subject_entity_id,st.subject_relationship_id,st.scope_key from temporal.segment s join temporal.stream st on st.id=s.stream_id where s.k_to is null and s.valid_during @> now();
create view api.current_relationships with(security_invoker=true) as select r.* from corpus.relationship r join taxonomy.relationship_kind k on k.code=r.kind where r.k_to is null and(not k.temporal or exists(select 1 from temporal.stream st join temporal.segment s on s.stream_id=st.id where st.subject_relationship_id=r.id and st.kind='relationship_active' and s.k_to is null and s.valid_during @> now() and s.status='active'));
create view api.events_current with(security_invoker=true) as select e.id event_id,e.tenant_id,e.kind,e.subject_entity_id,e.object_entity_id,o.id occurrence_id,o.occurred_during,o.occurrence_mode,o.payload from temporal.event e join temporal.event_occurrence o on o.event_id=e.id where o.k_to is null;
create view api.library_profile with(security_invoker=true) as select e.*,l.ecosystem,l.package_name from corpus.entity e join corpus.library l on l.id=e.id;
create view api.technical_record_search with(security_invoker=true) as select * from knowledge.record;
create view api.review_queue with(security_invoker=true) as select * from evaluation.review_task;
create function api.leaderboard(p_limit integer default 20) returns setof ranking.ranking_result language sql stable security definer set search_path='' as $$select * from ranking.ranking_result where tenant_id=util.current_tenant_id() order by rank limit least(greatest(p_limit,1),200)$$;
drop function api.evidence_packet(uuid);
create function api.evidence_packet(p_packet uuid) returns jsonb language sql stable security definer set search_path='' as $$
 select jsonb_build_object('packet',to_jsonb(p),'members',coalesce((select jsonb_agg(to_jsonb(m)||jsonb_build_object('start_ms',n.start_ms,'end_ms',n.end_ms)) from retrieval.packet_member m left join content.document_node n on n.id=m.source_document_node_id where m.packet_id=p.id and m.tenant_id=p.tenant_id),'[]'::jsonb)) from retrieval.evidence_packet p where p.id=p_packet and p.tenant_id=util.current_tenant_id()
$$;
create function api.summary_evidence(p_summary uuid) returns table(node_id uuid,chunk_id uuid,locator_id uuid,start_ms integer,end_ms integer) language sql stable security definer set search_path='' as $$
 select n.id,sp.chunk_id,sp.locator_id,n.start_ms,n.end_ms from content.document_summary_source ss join content.document_node n on n.id=ss.node_id left join retrieval.chunk_span sp on sp.document_node_id=n.id where ss.summary_id=p_summary and ss.tenant_id=util.current_tenant_id()
$$;

CREATE OR REPLACE FUNCTION api.hybrid_knowledge_search_1536(p_vector_space_version_id uuid, p_query_text text, p_query_embedding extensions.halfvec, p_filters jsonb DEFAULT '{}'::jsonb, p_result_limit integer DEFAULT 20, p_candidate_limit integer DEFAULT 100, p_rrf_k integer DEFAULT 60,p_spaces text[] default null,p_entity_ids uuid[] default null,p_document_types text[] default null,p_content_kinds text[] default null,p_as_of timestamptz default null,p_knowledge_seq bigint default null,p_min_assurance smallint default null,p_publication_id uuid default null)
 RETURNS TABLE(vector_item_id uuid, search_projection_id uuid, search_text text, source_kind text, fused_score double precision, channel_scores jsonb)
 LANGUAGE plpgsql
 VOLATILE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_tenant uuid := util.current_tenant_id();
begin
  if v_tenant is null then raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege'; end if;
  if coalesce(length(btrim(p_query_text)),0) < 1 or length(p_query_text) > 4096 then
    raise exception 'query text length must be between 1 and 4096' using errcode='invalid_parameter_value';
  end if;
  if p_result_limit not between 1 and 200 or p_candidate_limit not between p_result_limit and 1000
     or p_rrf_k not between 1 and 1000 then
    raise exception 'result/candidate/RRF bounds are invalid' using errcode='invalid_parameter_value';
  end if;
  if jsonb_typeof(coalesce(p_filters,'{}'::jsonb)) <> 'object' or
     (coalesce(p_filters,'{}'::jsonb) - array['language','visibility','classification','source_kind','authority_level','freshness_after']) <> '{}'::jsonb then
    raise exception 'unsupported hard filter' using errcode='invalid_parameter_value';
  end if;
  if not exists (
    select 1 from retrieval.vector_store_space ss
    join retrieval.space_publication p on p.tenant_id=ss.tenant_id and p.vector_store_space_id=ss.id
      and p.vector_space_version_id=ss.active_space_version_id and p.status='published'
    where ss.tenant_id=v_tenant and ss.active_space_version_id=p_vector_space_version_id
  ) then raise exception 'vector-space version is not actively published for this tenant' using errcode='insufficient_privilege'; end if;

  perform set_config('hnsw.iterative_scan','strict_order',true);
  return query
  with eligible as materialized (
    select vi.* from retrieval.vector_item vi
    where vi.tenant_id=v_tenant and vi.space_version_id=p_vector_space_version_id and vi.lifecycle='active'
      and (p_entity_ids is null or vi.entity_id=any(p_entity_ids) or vi.secondary_entity_ids && p_entity_ids)
      and (p_document_types is null or vi.document_type_code=any(p_document_types))
      and (p_content_kinds is null or vi.content_kind=any(p_content_kinds))
      and (p_as_of is null or vi.valid_during @> p_as_of)
      and (p_knowledge_seq is null or vi.knowledge_seq<=p_knowledge_seq)
      and (p_min_assurance is null or vi.assurance_rank>=p_min_assurance)
      and (p_spaces is null or exists(select 1 from retrieval.vector_space_version vsv join retrieval.vector_space vs on vs.id=vsv.vector_space_id where vsv.id=vi.space_version_id and vs.slug=any(p_spaces)))
      and (p_publication_id is null or exists(select 1 from retrieval.space_publication p where p.id=p_publication_id and p.tenant_id=vi.tenant_id and p.vector_space_version_id=vi.space_version_id and p.status='published'))
      and (not (p_filters?'language') or vi.language=p_filters->>'language')
      and (not (p_filters?'visibility') or vi.visibility=p_filters->>'visibility')
      and (not (p_filters?'classification') or vi.classification=p_filters->>'classification')
      and (not (p_filters?'source_kind') or vi.content_kind=p_filters->>'source_kind')
      and (not (p_filters?'authority_level') or vi.authority_level=p_filters->>'authority_level')
      and (not (p_filters?'freshness_after') or vi.freshness_at >= (p_filters->>'freshness_after')::timestamptz)
  ), exact_channel as (
    select e.id,1.0::double precision raw_score,row_number() over(order by e.id)::bigint channel_rank
    from eligible e where lower(e.search_text)=lower(p_query_text) limit p_candidate_limit
  ), fts_channel as (
    select e.id,ts_rank_cd(e.search_tsv,plainto_tsquery('simple',p_query_text))::double precision raw_score,
      row_number() over(order by ts_rank_cd(e.search_tsv,plainto_tsquery('simple',p_query_text)) desc,e.id)::bigint channel_rank
    from eligible e where e.search_tsv @@ plainto_tsquery('simple',p_query_text)
    order by raw_score desc,e.id limit p_candidate_limit
  ), trigram_channel as (
    select e.id,extensions.similarity(e.search_text,p_query_text)::double precision raw_score,
      row_number() over(order by extensions.similarity(e.search_text,p_query_text) desc,e.id)::bigint channel_rank
    from eligible e where length(p_query_text)>=3 and extensions.similarity(e.search_text,p_query_text)>0
    order by raw_score desc,e.id limit p_candidate_limit
  ), ann_channel as (
    select e.vector_item_id as id,(1-(e.embedding operator(extensions.<=>) p_query_embedding))::double precision raw_score,
      row_number() over(order by e.embedding operator(extensions.<=>) p_query_embedding,e.vector_item_id)::bigint channel_rank
    from retrieval.vector_item_embedding_1536 e
    join retrieval.vector_item vi on vi.tenant_id=e.tenant_id and vi.id=e.vector_item_id
    where e.tenant_id=v_tenant and e.vector_space_version_id=p_vector_space_version_id
      and vi.space_version_id=p_vector_space_version_id and vi.lifecycle='active'
      and (p_entity_ids is null or vi.entity_id=any(p_entity_ids) or vi.secondary_entity_ids && p_entity_ids)
      and (p_document_types is null or vi.document_type_code=any(p_document_types))
      and (p_content_kinds is null or vi.content_kind=any(p_content_kinds))
      and (p_as_of is null or vi.valid_during @> p_as_of)
      and (p_knowledge_seq is null or vi.knowledge_seq<=p_knowledge_seq)
      and (p_min_assurance is null or vi.assurance_rank>=p_min_assurance)
      and (p_spaces is null or exists(select 1 from retrieval.vector_space_version vsv join retrieval.vector_space vs on vs.id=vsv.vector_space_id where vsv.id=vi.space_version_id and vs.slug=any(p_spaces)))
      and (p_publication_id is null or exists(select 1 from retrieval.space_publication p where p.id=p_publication_id and p.tenant_id=vi.tenant_id and p.vector_space_version_id=vi.space_version_id and p.status='published'))
      and (not (p_filters?'language') or vi.language=p_filters->>'language')
      and (not (p_filters?'visibility') or vi.visibility=p_filters->>'visibility')
      and (not (p_filters?'classification') or vi.classification=p_filters->>'classification')
      and (not (p_filters?'source_kind') or vi.content_kind=p_filters->>'source_kind')
      and (not (p_filters?'authority_level') or vi.authority_level=p_filters->>'authority_level')
      and (not (p_filters?'freshness_after') or vi.freshness_at >= (p_filters->>'freshness_after')::timestamptz)
    order by e.embedding operator(extensions.<=>) p_query_embedding,e.vector_item_id limit p_candidate_limit
  ), channels as (
    select id,'exact'::text channel,raw_score,channel_rank from exact_channel union all
    select id,'fts',raw_score,channel_rank from fts_channel union all
    select id,'trigram',raw_score,channel_rank from trigram_channel union all
    select id,'ann',raw_score,channel_rank from ann_channel
  ), fused as (
    select id,sum(1.0/(p_rrf_k+channel_rank))::double precision score,
      jsonb_object_agg(channel,jsonb_build_object('score',raw_score,'rank',channel_rank) order by channel) details
    from channels group by id
  )
  select vi.id,vi.search_projection_id,vi.search_text,vi.content_kind,f.score,f.details
  from fused f join eligible vi on vi.id=f.id
  order by f.score desc,vi.id limit p_result_limit;
end $function$;

-- Function-backed invoker views let app roles read the API without table grants.
create function api.entity_rows() returns setof corpus.entity language sql stable security definer set search_path='' as $$ select * from corpus.entity where tenant_id=util.current_tenant_id() $$;
create function api.entity_aliases(p_entity uuid) returns text[] language sql stable security definer set search_path='' as $$ select coalesce(array_agg(alias),'{}') from corpus.entity_alias where tenant_id=util.current_tenant_id() and entity_id=p_entity $$;
create or replace view api.entities with(security_invoker=true) as select e.*,api.entity_aliases(e.id) aliases from api.entity_rows() e;
create function api.current_fact_rows() returns table(id uuid,tenant_id uuid,stream_id uuid,valid_during tstzrange,belief text,temporal_basis text,status text,amount numeric,currency character(3),unit text,ref_entity_id uuid,payload jsonb,extent_id uuid,caused_by_event_id uuid,replaces_segment_id uuid,primary_claim_id uuid,k_from bigint,k_to bigint,created_at timestamptz,specification_id uuid,stream_kind text,subject_entity_id uuid,subject_relationship_id uuid,scope_key text) language sql stable security definer set search_path='' as $$ select s.*,st.kind,st.subject_entity_id,st.subject_relationship_id,st.scope_key from temporal.segment s join temporal.stream st on st.id=s.stream_id where s.tenant_id=util.current_tenant_id() and s.k_to is null and s.valid_during @> now() $$;
drop view api.current_facts;
create view api.current_facts with(security_invoker=true) as select * from api.current_fact_rows();
create function api.current_relationship_rows() returns setof corpus.relationship language sql stable security definer set search_path='' as $$ select r.* from corpus.relationship r join taxonomy.relationship_kind k on k.code=r.kind where r.tenant_id=util.current_tenant_id() and r.k_to is null and(not k.temporal or exists(select 1 from temporal.stream st join temporal.segment s on s.stream_id=st.id where st.subject_relationship_id=r.id and st.kind='relationship_active' and s.k_to is null and s.valid_during @> now() and s.status='active')) $$;
create or replace view api.current_relationships with(security_invoker=true) as select * from api.current_relationship_rows();
create function api.current_event_rows() returns table(event_id uuid,tenant_id uuid,kind text,subject_entity_id uuid,object_entity_id uuid,occurrence_id uuid,occurred_during tstzrange,occurrence_mode text,payload jsonb) language sql stable security definer set search_path='' as $$ select e.id,e.tenant_id,e.kind,e.subject_entity_id,e.object_entity_id,o.id,o.occurred_during,o.occurrence_mode,o.payload from temporal.event e join temporal.event_occurrence o on o.event_id=e.id where e.tenant_id=util.current_tenant_id() and o.k_to is null $$;
create or replace view api.events_current with(security_invoker=true) as select * from api.current_event_rows();

commit;


