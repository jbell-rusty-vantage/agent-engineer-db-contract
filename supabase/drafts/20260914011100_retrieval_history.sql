begin;
set local lock_timeout = '15s';

-- K is the canonical belief clock. Publication is a separately pinned, currently
-- authorized index of that belief; it need not have been published at K.
create function retrieval.history_world_matches(p_interval tstzrange,p_at timestamptz,p_from timestamptz,p_to timestamptz)
returns boolean language sql immutable set search_path='' as $$
  select case
    when p_at is not null and (p_from is not null or p_to is not null) then false
    when (p_from is null) <> (p_to is null) then false
    when p_from is not null and p_from >= p_to then false
    when p_at is not null then coalesce(p_interval @> p_at,false)
    when p_from is not null then coalesce(p_interval && tstzrange(p_from,p_to,'[)'),false)
    else true end
$$;

create function retrieval.history_receipt_k(p_receipt uuid) returns bigint
language sql stable security definer set search_path='' as $$
  select b.knowledge_seq from temporal.knowledge_batch b
  join orchestration.operation_receipt r on r.id=b.receipt_id
  join orchestration.operation_intent i on i.id=r.intent_id and i.tenant_id=b.tenant_id
  where b.tenant_id=util.current_tenant_id() and b.receipt_id=p_receipt
    and r.outcome in ('applied','partial','noop')
$$;

-- Current authorization deliberately remains in force for historical queries.
-- This is a database predicate; citation readers still authenticate sealed bytes.
create function retrieval.history_claim_authorized(p_claim uuid) returns boolean
language sql stable security definer set search_path='' as $$
  select exists(select 1 from evidence.claim c
    join evidence.verification_run r on r.tenant_id=c.tenant_id
      and r.id::text=c.structured #>> '{verification,admission,run,runId}'
    join orchestration.artifact a on a.tenant_id=r.tenant_id and a.id=r.run_manifest_artifact_id
    where c.tenant_id=util.current_tenant_id() and c.id=p_claim
      and c.status::text in ('verified','superseded') and r.status='succeeded'
      and c.structured #>> '{verification,admission,outcome}' in ('pass','pass_with_warnings')
      and c.structured #>> '{verification,admission,tenantId}'=c.tenant_id::text
      and c.structured #>> '{verification,admission,auditArtifactId}'=a.id::text
      and c.structured #>> '{verification,admission,run,auditDigest}'='sha256:'||a.sha256
      and a.storage_state='available' and a.sha256=r.manifest_sha256
      and exists(select 1 from evidence.claim_evidence_link l
        join evidence.claim_evidence_assessment x on x.tenant_id=l.tenant_id and x.claim_evidence_link_id=l.id and x.run_id=r.id
        join evidence.locator loc on loc.tenant_id=l.tenant_id and loc.id=l.locator_id
        join evidence.source_capture cap on cap.tenant_id=loc.tenant_id and cap.id=loc.capture_id
        join orchestration.artifact ca on ca.tenant_id=cap.tenant_id and ca.id=cap.artifact_id
        where l.tenant_id=c.tenant_id and l.claim_id=c.id and l.role='supports'
          and x.verdict in ('directly_supported','supported_with_qualification','derived_verified')
          and x.replay_signature_match and loc.resolution_state='resolved'
          and ca.storage_state='available' and ca.sha256=cap.content_sha256))
$$;

create function retrieval.history_representation_authorized(p_representation uuid) returns boolean
language sql stable security definer set search_path='' as $$
  select coalesce((select d.decision='accept' and not d.legacy_provenance and not r.legacy_provenance
    and d.guarded_sha256=v.content_sha256 and r.guarded_sha256=v.content_sha256 and s.guarded_sha256=v.content_sha256
    and r.decision='approve' and r.decision_operation_id=d.decision_operation_id
    and o.operation_kind='representation_decision' and o.status='succeeded'
    and d.reviewer_identity=r.reviewer_identity and o.actor_identity=r.reviewer_identity
    and s.subject_kind in ('conversion','representation') and s.subject_ref->>'representationId'=v.id::text
    and s.subject_ref->>'artifactDigest'='sha256:'||v.content_sha256
    and s.quorum_required=1 and r.reviewer_role=any(s.eligible_roles)
    and (d.expires_at is null or d.expires_at>now()) and (s.expires_at is null or s.expires_at>now())
    and a.storage_state='available' and a.sha256=v.content_sha256
    and dv.correction_state not in ('retracted','withdrawn')
    and (t.operation_id is null or t.operation_id=s.operation_id)
    and length(btrim(p.actor_identity))>0
    and case when v.representation_kind='summary' or t.transformation_kind='summarize' then
      t.transformation_kind='summarize' and pa.id=t.attempt_id and length(btrim(pa.agent_deployment_id))>0
      and r.reviewer_identity<>pa.id::text and r.reviewer_identity<>pa.agent_deployment_id
      and (o.attempt_id is null or (ra.id=o.attempt_id and length(btrim(ra.agent_deployment_id))>0
        and ra.id<>pa.id and ra.agent_deployment_id<>pa.agent_deployment_id))
    else p.actor_identity<>r.reviewer_identity and (o.attempt_id is null or
      (pa.id=t.attempt_id and length(btrim(pa.agent_deployment_id))>0 and ra.id=o.attempt_id
       and length(btrim(ra.agent_deployment_id))>0 and ra.id<>pa.id and ra.agent_deployment_id<>pa.agent_deployment_id
       and r.reviewer_identity<>pa.id::text and r.reviewer_identity<>pa.agent_deployment_id)) end
    from content.document_representation v
    join content.document_version dv on dv.tenant_id=v.tenant_id and dv.id=v.document_version_id
    join orchestration.artifact a on a.tenant_id=v.tenant_id and a.id=v.artifact_id
    join lateral (select x.* from content.representation_decision x where x.tenant_id=v.tenant_id and x.representation_id=v.id
      order by x.created_at desc,x.id desc limit 1) d on true
    join knowledge_service.review_decision r on r.tenant_id=d.tenant_id and r.id=d.knowledge_review_decision_id
    join knowledge_service.review_subject s on s.tenant_id=r.tenant_id and s.id=r.review_subject_id
    join knowledge_service.operation o on o.tenant_id=d.tenant_id and o.id=d.decision_operation_id
    join knowledge_service.operation p on p.tenant_id=s.tenant_id and p.id=s.operation_id
    left join content.transformation_run t on t.tenant_id=v.tenant_id and t.id=v.transformation_run_id
    left join orchestration.attempt pa on pa.tenant_id=t.tenant_id and pa.id=t.attempt_id
    left join orchestration.attempt ra on ra.tenant_id=o.tenant_id and ra.id=o.attempt_id
    where v.tenant_id=util.current_tenant_id() and v.id=p_representation),false)
$$;

-- A support withdrawn while its subject remains live is revocation, not a
-- historical correction. Closed support survives only with its matching closure.
create function retrieval.claim_history_witnesses(p_claim uuid,p_k bigint)
returns table(claim_id uuid,segment_id uuid,event_occurrence_id uuid,support_id uuid,entity_ids uuid[],world_interval tstzrange,k_from bigint,k_to bigint)
language sql stable security definer set search_path='' as $$
  with clock as(select h.knowledge_seq from temporal.knowledge_head h where h.tenant_id=util.current_tenant_id()
    and p_k between 0 and h.knowledge_seq), links as (
    select s.id segment_id,null::uuid event_occurrence_id,null::uuid support_id,s.primary_claim_id claim_id,s.k_from,s.k_to
    from temporal.segment s where s.tenant_id=util.current_tenant_id() and s.primary_claim_id=p_claim
    union all select null,o.id,null,o.primary_claim_id,o.k_from,o.k_to from temporal.event_occurrence o
      where o.tenant_id=util.current_tenant_id() and o.primary_claim_id=p_claim
    union all select x.segment_id,x.event_occurrence_id,x.id,x.claim_id,x.k_from,x.k_to from evidence.segment_support x
      where x.tenant_id=util.current_tenant_id() and x.claim_id=p_claim and x.role in ('supports','challenges','context')
  )
  select l.claim_id,s.id,null::uuid,l.support_id,
    array_remove(array[st.subject_entity_id,rel.from_entity_id,rel.to_entity_id,s.ref_entity_id],null),s.valid_during,
    greatest(s.k_from,l.k_from),least(s.k_to,l.k_to)
  from links l join temporal.segment s on s.tenant_id=util.current_tenant_id() and s.id=l.segment_id
  join temporal.stream st on st.tenant_id=s.tenant_id and st.id=s.stream_id
  left join corpus.relationship rel on rel.tenant_id=st.tenant_id and rel.id=st.subject_relationship_id
  cross join clock
  where s.belief='accepted' and s.k_from<=p_k and (s.k_to is null or s.k_to>p_k)
    and l.k_from<=p_k and (l.k_to is null or l.k_to>p_k)
    and (l.support_id is null or l.k_to is null or l.k_to=s.k_to)
    and (st.subject_relationship_id is null or (rel.k_from<=p_k and (rel.k_to is null or rel.k_to>p_k)))
  union all
  select l.claim_id,null,o.id,l.support_id,array_remove(array[e.subject_entity_id,e.object_entity_id],null),o.occurred_during,
    greatest(o.k_from,l.k_from),least(o.k_to,l.k_to)
  from links l join temporal.event_occurrence o on o.tenant_id=util.current_tenant_id() and o.id=l.event_occurrence_id
  join temporal.event e on e.tenant_id=o.tenant_id and e.id=o.event_id cross join clock
  where o.belief='accepted' and o.k_from<=p_k and (o.k_to is null or o.k_to>p_k)
    and l.k_from<=p_k and (l.k_to is null or l.k_to>p_k)
    and (l.support_id is null or l.k_to is null or l.k_to=o.k_to)
$$;

create function retrieval.history_projection_matches(p_projection uuid,p_k bigint,p_entities uuid[],p_at timestamptz,p_from timestamptz,p_to timestamptz)
returns boolean language sql stable security definer set search_path='' as $$
  with projection as (
    select p.*,t.target_kind,t.entity_id,t.claim_id,t.record_id,t.summary_id,t.chunk_id target_chunk
    from retrieval.search_projection p join retrieval.projection_target t on t.tenant_id=p.tenant_id and t.id=p.projection_target_id
    where p.tenant_id=util.current_tenant_id() and p.id=p_projection and t.retired_at is null
  ), sources as (
    select x.chunk_id,x.locator_id,x.support_kind,x.selected_text_sha256,c.source_text_sha256,cs.representation_id
    from retrieval.search_projection_chunk_support x
    join retrieval.retrieval_chunk c on c.tenant_id=x.tenant_id and c.id=x.chunk_id and c.lifecycle='active'
    join retrieval.chunk_set cs on cs.tenant_id=c.tenant_id and cs.id=c.chunk_set_id and cs.status='succeeded'
    where x.tenant_id=util.current_tenant_id() and x.search_projection_id=p_projection
      and retrieval.history_representation_authorized(cs.representation_id)
  ), claims as (
    select distinct c.id,c.status,c.created_by_receipt_id from projection p cross join sources src
    join retrieval.chunk_claim_link cc on cc.tenant_id=p.tenant_id and cc.chunk_id=src.chunk_id and cc.verb in ('supports','challenges','context')
    join evidence.claim c on c.tenant_id=cc.tenant_id and c.id=cc.claim_id
    where retrieval.history_claim_authorized(c.id)
      and retrieval.history_receipt_k(c.created_by_receipt_id)<=p_k
      and case p.target_kind
        when 'claim' then c.id=p.claim_id
        when 'record' then exists(select 1 from knowledge.record r join evidence.claim_record cr on cr.tenant_id=r.tenant_id and cr.record_id=r.id and cr.claim_id=r.provenance_claim_id
          where r.tenant_id=p.tenant_id and r.id=p.record_id and r.provenance_claim_id=c.id and retrieval.history_receipt_k(r.created_by_receipt_id)<=p_k)
        when 'entity' then exists(select 1 from corpus.entity e join evidence.claim_subject s on s.tenant_id=e.tenant_id and s.entity_id=e.id
          join retrieval.chunk_entity_mention m on m.tenant_id=e.tenant_id and m.entity_id=e.id and m.chunk_id=src.chunk_id
          where e.tenant_id=p.tenant_id and e.id=p.entity_id and e.lifecycle='active' and s.claim_id=c.id
            and retrieval.history_receipt_k(e.created_by_receipt_id)<=p_k)
        when 'chunk' then p.target_chunk=src.chunk_id
        when 'summary' then exists(select 1 from content.document_summary sm
          join content.document_summary_source ss on ss.tenant_id=sm.tenant_id and ss.summary_id=sm.id
          join retrieval.chunk_span sp on sp.tenant_id=ss.tenant_id and sp.document_node_id=ss.node_id and sp.chunk_id=src.chunk_id
          where sm.tenant_id=p.tenant_id and sm.id=p.summary_id and sm.lifecycle in ('active','superseded')
            and retrieval.history_representation_authorized(sm.representation_id)
            and retrieval.history_representation_authorized(sm.derived_from_representation_id)
            and exists(select 1 from orchestration.operation_intent oi join orchestration.operation_receipt rr on rr.intent_id=oi.id
              join temporal.knowledge_batch kb on kb.tenant_id=oi.tenant_id and kb.receipt_id=rr.id
              cross join lateral jsonb_array_elements(oi.payload->'operations') op
              where oi.tenant_id=sm.tenant_id and oi.intent_type='content_link' and kb.knowledge_seq<=p_k
                and rr.outcome in ('applied','partial') and op->>'kind'='summary.materialize' and op->>'summaryId'=sm.id::text
                and op->>'text'=sm.text and exists(select 1 from jsonb_array_elements(op->'evidence') ev where ev->>'claimId'=c.id::text)))
        else false end
  )
  select exists(select 1 from projection)
    and exists(select 1 from sources)
    and (select count(*) from sources)=(select count(*) from retrieval.search_projection_chunk_support x where x.tenant_id=util.current_tenant_id() and x.search_projection_id=p_projection)
    and exists(select 1 from claims c where
      exists(select 1 from retrieval.claim_history_witnesses(c.id,p_k) w
        where retrieval.history_world_matches(w.world_interval,p_at,p_from,p_to)
          and (p_entities is null or w.entity_ids && p_entities))
      or (p_at is null and p_from is null and p_to is null and c.status::text='verified'
        and not exists(select 1 from temporal.segment s where s.tenant_id=util.current_tenant_id() and s.primary_claim_id=c.id)
        and not exists(select 1 from temporal.event_occurrence e where e.tenant_id=util.current_tenant_id() and e.primary_claim_id=c.id)
        and not exists(select 1 from evidence.segment_support s where s.tenant_id=util.current_tenant_id() and s.claim_id=c.id)
        and (p_entities is null or exists(select 1 from evidence.claim_subject s
          where s.tenant_id=util.current_tenant_id() and s.claim_id=c.id and s.entity_id=any(p_entities)))))
$$;

-- Current permission and exact reviewed membership apply equally to an active
-- index and an explicitly pinned superseded index. Withdrawn indexes never pass.
create function retrieval.history_publication_authorized(p_version uuid,p_publication uuid) returns uuid
language sql stable security definer set search_path='' as $$
  select p.id from retrieval.space_publication p
  join retrieval.vector_store_space ss on ss.tenant_id=p.tenant_id and ss.id=p.vector_store_space_id
  join retrieval.vector_store st on st.tenant_id=ss.tenant_id and st.id=ss.vector_store_id and st.lifecycle='active'
  join retrieval.vector_space_version v on v.tenant_id=p.tenant_id and v.id=p.vector_space_version_id
  join retrieval.content_promotion_decision d on d.tenant_id=p.tenant_id and d.id=p.publication_decision_id
  join retrieval.content_promotion_proposal pp on pp.tenant_id=d.tenant_id and pp.id=d.proposal_id
  join knowledge_service.review_decision rd on rd.tenant_id=d.tenant_id and rd.id=d.knowledge_review_decision_id
  join knowledge_service.review_subject rs on rs.tenant_id=rd.tenant_id and rs.id=rd.review_subject_id
  join knowledge_service.operation ro on ro.tenant_id=d.tenant_id and ro.id=d.decision_operation_id
  join evaluation.promotion_gate_result g on g.tenant_id=p.tenant_id and g.id=p.evaluation_result_id and g.passed
  where p.tenant_id=util.current_tenant_id() and p.vector_space_version_id=p_version
    and p.status in ('published','superseded') and p.published_at is not null and not p.legacy_provenance
    and v.publication_lifecycle in ('published','superseded') and v.dims=1536 and v.precision='halfvec'
    and ((p_publication is null and p.status='published' and ss.active_space_version_id=p_version) or p.id=p_publication)
    and d.decision='accept' and not d.legacy_provenance and not pp.legacy_provenance
    and (d.expires_at is null or d.expires_at>now()) and d.guarded_sha256=pp.proposal_sha256
    and not exists(select 1 from retrieval.content_promotion_decision newer where newer.tenant_id=d.tenant_id and newer.proposal_id=d.proposal_id
      and (newer.created_at,newer.id)>(d.created_at,d.id))
    and rd.decision='approve' and not rd.legacy_provenance and rd.guarded_sha256=d.guarded_sha256
    and rd.reviewer_identity=d.reviewer_identity and rd.decision_operation_id=ro.id
    and ro.status='succeeded' and ro.actor_identity=rd.reviewer_identity
    and rs.subject_kind='content_promotion' and rs.guarded_sha256=d.guarded_sha256
    and rs.quorum_required=1 and rd.reviewer_role=any(rs.eligible_roles) and (rs.expires_at is null or rs.expires_at>now())
    and rd.reviewer_identity<>pp.proposed_by
    and exists(select 1 from retrieval.publication_switch_receipt sw
      join retrieval.authorized_publication_execution ae on ae.tenant_id=sw.tenant_id and ae.switch_receipt_id=sw.id
      join knowledge_service.operation po on po.tenant_id=ae.tenant_id and po.id=ae.operation_id
      where sw.tenant_id=p.tenant_id and sw.to_publication_id=p.id and sw.vector_store_space_id=ss.id
        and sw.guarded_sha256=d.guarded_sha256 and ae.guarded_sha256=d.guarded_sha256 and ae.action=sw.action
        and po.status='succeeded' and po.actor_identity=ae.publisher_identity and sw.actor_identity=ae.publisher_identity
        and ae.publisher_identity<>d.reviewer_identity)
    and p.expected_item_count>0
    and p.expected_item_count=(select count(*) from retrieval.vector_item vi where vi.tenant_id=p.tenant_id and vi.space_version_id=v.id)
    and not exists(select 1 from retrieval.vector_item vi
      left join retrieval.embedding_item ei on ei.tenant_id=vi.tenant_id and ei.id=vi.embedding_item_id and ei.search_projection_id=vi.search_projection_id
      left join retrieval.embedding_run er on er.tenant_id=ei.tenant_id and er.id=ei.embedding_run_id and er.vector_space_version_id=v.id
      left join retrieval.vector_item_embedding_1536 eb on eb.tenant_id=vi.tenant_id and eb.vector_item_id=vi.id and eb.vector_space_version_id=v.id
      where vi.tenant_id=p.tenant_id and vi.space_version_id=v.id and
        (ei.id is null or ei.status<>'succeeded' or er.status<>'succeeded' or er.legacy_provenance
          or er.promotion_decision_id is distinct from d.id or eb.vector_item_id is null or eb.embedding_sha256<>ei.output_sha256
          or not coalesce(pp.projection_manifest->'projectionIds' ? vi.search_projection_id::text,false)))
  order by p.published_at desc,p.id desc limit 1
$$;

create function api.hybrid_knowledge_search_history_1536(
  p_vector_space_version_id uuid,p_query_text text,p_query_embedding extensions.halfvec,
  p_filters jsonb default '{}'::jsonb,p_result_limit integer default 20,p_candidate_limit integer default 100,p_rrf_k integer default 60,
  p_knowledge_seq bigint default null,p_entity_ids uuid[] default null,p_world_at timestamptz default null,
  p_world_from timestamptz default null,p_world_to timestamptz default null,p_publication_id uuid default null)
returns table(vector_item_id uuid,search_projection_id uuid,search_text text,source_kind text,fused_score double precision,channel_scores jsonb)
language plpgsql volatile security definer set search_path='' as $$
declare tenant uuid:=util.current_tenant_id(); head bigint; k bigint; publication uuid;
begin
  if tenant is null then raise exception 'tenant context required' using errcode='42501'; end if;
  select knowledge_seq into head from temporal.knowledge_head where tenant_id=tenant;
  k:=coalesce(p_knowledge_seq,head);
  if head is null or k is null or k<0 or k>head then raise exception 'knowledge sequence is outside sealed history' using errcode='22023'; end if;
  if p_query_text is null or length(btrim(p_query_text)) not between 1 and 4096
    or p_result_limit is null or p_result_limit not between 1 and 200
    or p_candidate_limit is null or p_candidate_limit not between p_result_limit and 1000
    or p_rrf_k is null or p_rrf_k not between 1 and 1000
    or p_query_embedding is null or extensions.vector_dims(p_query_embedding)<>1536
    or jsonb_typeof(p_filters) is distinct from 'object'
    or (p_filters-array['language','visibility','classification','source_kind','authority_level','freshness_after'])<>'{}'::jsonb
    or (p_entity_ids is not null and (cardinality(p_entity_ids) not between 1 and 64 or array_position(p_entity_ids,null) is not null))
    or (p_world_at is not null and (p_world_from is not null or p_world_to is not null))
    or ((p_world_from is null)<>(p_world_to is null)) or p_world_from>=p_world_to
    or (p_world_at is not null and not isfinite(p_world_at))
    or (p_world_from is not null and (not isfinite(p_world_from) or not isfinite(p_world_to)))
  then raise exception 'invalid bounded history query' using errcode='22023'; end if;
  publication:=retrieval.history_publication_authorized(p_vector_space_version_id,p_publication_id);
  if publication is null then raise exception 'currently authorized publication required' using errcode='42501'; end if;
  perform set_config('hnsw.iterative_scan','strict_order',true);
  return query
  with eligible as materialized (
    select vi.* from retrieval.vector_item vi
    join retrieval.search_projection sp on sp.tenant_id=vi.tenant_id and sp.id=vi.search_projection_id and sp.projection_target_id=vi.projection_target_id
    where vi.tenant_id=tenant and vi.space_version_id=p_vector_space_version_id
      and vi.lifecycle='active' and vi.verification_state='verified'
      and retrieval.history_projection_matches(sp.id,k,p_entity_ids,p_world_at,p_world_from,p_world_to)
      and (not(p_filters?'language') or vi.language=p_filters->>'language')
      and (not(p_filters?'visibility') or vi.visibility=p_filters->>'visibility')
      and (not(p_filters?'classification') or vi.classification=p_filters->>'classification')
      and (not(p_filters?'source_kind') or vi.content_kind=p_filters->>'source_kind')
      and (not(p_filters?'authority_level') or vi.authority_level=p_filters->>'authority_level')
      and (not(p_filters?'freshness_after') or vi.freshness_at>=(p_filters->>'freshness_after')::timestamptz)
  ), exact_channel as (
    select e.id,1.0::double precision raw_score,row_number() over(order by e.id) channel_rank from eligible e
    where lower(e.search_text)=lower(p_query_text) order by e.id limit p_candidate_limit
  ), fts_channel as (
    select e.id,ts_rank_cd(e.search_tsv,plainto_tsquery('simple',p_query_text))::double precision raw_score,
      row_number() over(order by ts_rank_cd(e.search_tsv,plainto_tsquery('simple',p_query_text)) desc,e.id) channel_rank
    from eligible e where e.search_tsv @@ plainto_tsquery('simple',p_query_text) order by raw_score desc,e.id limit p_candidate_limit
  ), trigram_channel as (
    select e.id,extensions.similarity(e.search_text,p_query_text)::double precision raw_score,
      row_number() over(order by extensions.similarity(e.search_text,p_query_text) desc,e.id) channel_rank
    from eligible e where length(p_query_text)>=3 and extensions.similarity(e.search_text,p_query_text)>0 order by raw_score desc,e.id limit p_candidate_limit
  ), ann_channel as (
    select e.id,(1-(emb.embedding operator(extensions.<=>) p_query_embedding))::double precision raw_score,
      row_number() over(order by emb.embedding operator(extensions.<=>) p_query_embedding,e.id) channel_rank
    from eligible e join retrieval.vector_item_embedding_1536 emb on emb.tenant_id=e.tenant_id and emb.vector_item_id=e.id
      and emb.vector_space_version_id=e.space_version_id
    order by emb.embedding operator(extensions.<=>) p_query_embedding,e.id limit p_candidate_limit
  ), channels as (
    select id,'exact'::text channel,raw_score,channel_rank from exact_channel union all select id,'fts',raw_score,channel_rank from fts_channel
    union all select id,'trigram',raw_score,channel_rank from trigram_channel union all select id,'ann',raw_score,channel_rank from ann_channel
  ), fused as (
    select id,sum(1.0/(p_rrf_k+channel_rank))::double precision score,
      jsonb_object_agg(channel,jsonb_build_object('score',raw_score,'rank',channel_rank) order by channel) details from channels group by id
  )
  select e.id,e.search_projection_id,e.search_text,e.content_kind,f.score,f.details from fused f join eligible e on e.id=f.id
  order by f.score desc,e.id limit p_result_limit;
end $$;

revoke all on function retrieval.history_world_matches(tstzrange,timestamptz,timestamptz,timestamptz),
  retrieval.history_receipt_k(uuid),retrieval.history_claim_authorized(uuid),retrieval.history_representation_authorized(uuid),
  retrieval.claim_history_witnesses(uuid,bigint),retrieval.history_projection_matches(uuid,bigint,uuid[],timestamptz,timestamptz,timestamptz),
  retrieval.history_publication_authorized(uuid,uuid) from public,anon,authenticated,service_role,pipeline_agent,verifier_agent,app_reader;
grant execute on function retrieval.claim_history_witnesses(uuid,bigint) to executor_service,control_plane;
revoke all on function api.hybrid_knowledge_search_history_1536(uuid,text,extensions.halfvec,jsonb,integer,integer,integer,bigint,uuid[],timestamptz,timestamptz,timestamptz,uuid) from public,anon;
grant execute on function api.hybrid_knowledge_search_history_1536(uuid,text,extensions.halfvec,jsonb,integer,integer,integer,bigint,uuid[],timestamptz,timestamptz,timestamptz,uuid) to app_reader,authenticated,executor_service,control_plane,service_role;
commit;
