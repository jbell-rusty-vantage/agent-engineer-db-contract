-- Authoritative publication pointer switching and bounded server-side hybrid retrieval.
begin;

alter table retrieval.space_publication drop constraint space_publication_check1;
alter table retrieval.space_publication add constraint space_publication_published_timestamp_ck
  check ((status in ('published','superseded','withdrawn')) = (published_at is not null));

create table retrieval.publication_switch_receipt (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.default_tenant_id(),
  vector_store_space_id uuid not null,
  from_publication_id uuid,
  to_publication_id uuid not null,
  action text not null check (action in ('publish','rollback')),
  reason text not null check (length(btrim(reason)) > 0),
  guarded_sha256 text not null check (guarded_sha256 ~ '^[0-9a-f]{64}$'),
  actor_identity text not null,
  idempotency_key text not null,
  created_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, idempotency_key),
  foreign key (tenant_id, vector_store_space_id)
    references retrieval.vector_store_space(tenant_id, id) on delete restrict,
  foreign key (tenant_id, from_publication_id)
    references retrieval.space_publication(tenant_id, id) on delete restrict,
  foreign key (tenant_id, to_publication_id)
    references retrieval.space_publication(tenant_id, id) on delete restrict
);

alter table retrieval.publication_switch_receipt enable row level security;
create policy bounded_role_access on retrieval.publication_switch_receipt
  for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id())
  with check (tenant_id = util.current_tenant_id());
create trigger publication_switch_receipt_immutable
  before update or delete on retrieval.publication_switch_receipt
  for each row execute function util.reject_mutation();

-- The stable store-space row is immutable except for its authoritative active pointer.
drop trigger vector_store_space_immutable on retrieval.vector_store_space;
create function retrieval.guard_vector_store_space_pointer() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE' then
    raise exception 'vector store spaces cannot be deleted' using errcode = 'restrict_violation';
  end if;
  if (to_jsonb(new) - 'active_space_version_id') is distinct from
     (to_jsonb(old) - 'active_space_version_id') then
    raise exception 'only the active vector-space pointer may change' using errcode = 'restrict_violation';
  end if;
  return new;
end $$;
create trigger vector_store_space_pointer_guard
  before update or delete on retrieval.vector_store_space
  for each row execute function retrieval.guard_vector_store_space_pointer();

-- Permit only the forward terminal transition published -> superseded/withdrawn;
-- every other column remains immutable and rollback creates a fresh publication.
create or replace function retrieval.guard_space_publication() returns trigger
language plpgsql set search_path = '' as $$
declare
  v_dims int; v_precision text; v_decision text; v_gate_passed boolean; v_actual bigint;
begin
  if tg_op = 'DELETE' then
    raise exception 'publications cannot be deleted' using errcode = 'restrict_violation';
  end if;
  if old.status in ('superseded','withdrawn') then
    raise exception 'terminal publication is immutable' using errcode = 'restrict_violation';
  end if;
  if old.status = 'published' then
    if new.status not in ('superseded','withdrawn') or
       (to_jsonb(new) - 'status') is distinct from (to_jsonb(old) - 'status') then
      raise exception 'published rows may only transition to superseded or withdrawn'
        using errcode = 'restrict_violation';
    end if;
    return new;
  end if;
  if new.status = 'published' then
    select dims, precision into v_dims, v_precision
      from retrieval.vector_space_version
      where tenant_id = new.tenant_id and id = new.vector_space_version_id;
    select decision into v_decision
      from retrieval.content_promotion_decision
      where tenant_id = new.tenant_id and id = new.publication_decision_id
        and (expires_at is null or expires_at > now());
    select passed into v_gate_passed
      from evaluation.promotion_gate_result
      where tenant_id = new.tenant_id and id = new.evaluation_result_id;
    select count(*) into v_actual
      from retrieval.vector_item_embedding_1536
      where tenant_id = new.tenant_id
        and vector_space_version_id = new.vector_space_version_id;
    if v_dims <> 1536 or v_precision <> 'halfvec' or v_decision <> 'accept'
       or v_gate_passed is distinct from true or v_actual <> new.expected_item_count then
      raise exception 'publication gate failed (dims %, precision %, decision %, gate %, embeddings %/%)',
        v_dims, v_precision, v_decision, v_gate_passed, v_actual, new.expected_item_count
        using errcode = 'check_violation';
    end if;
  end if;
  return new;
end $$;

create function retrieval.publish_vector_space(
  p_publication_id uuid,
  p_expected_guarded_sha256 text,
  p_reason text,
  p_actor_identity text,
  p_idempotency_key text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_tenant uuid := util.current_tenant_id();
  v_publication retrieval.space_publication%rowtype;
  v_store_space retrieval.vector_store_space%rowtype;
  v_decision_digest text;
  v_previous_publication_id uuid;
  v_receipt_id uuid;
begin
  if v_tenant is null then
    raise exception 'valid app.tenant_id context is required' using errcode = 'insufficient_privilege';
  end if;
  if coalesce(btrim(p_reason),'') = '' or coalesce(btrim(p_actor_identity),'') = ''
     or coalesce(btrim(p_idempotency_key),'') = '' then
    raise exception 'reason, actor identity, and idempotency key are required' using errcode = 'invalid_parameter_value';
  end if;
  select id into v_receipt_id from retrieval.publication_switch_receipt
    where tenant_id = v_tenant and idempotency_key = p_idempotency_key;
  if v_receipt_id is not null then return v_receipt_id; end if;

  select * into v_publication from retrieval.space_publication
    where tenant_id = v_tenant and id = p_publication_id for update;
  if v_publication.id is null or v_publication.status <> 'approved' then
    raise exception 'publication must exist and be approved' using errcode = 'object_not_in_prerequisite_state';
  end if;
  select guarded_sha256 into v_decision_digest from retrieval.content_promotion_decision
    where tenant_id = v_tenant and id = v_publication.publication_decision_id;
  if v_decision_digest is distinct from p_expected_guarded_sha256 then
    raise exception 'guarded publication digest changed' using errcode = 'check_violation';
  end if;
  select * into v_store_space from retrieval.vector_store_space
    where tenant_id = v_tenant and id = v_publication.vector_store_space_id for update;
  select id into v_previous_publication_id from retrieval.space_publication
    where tenant_id = v_tenant and vector_store_space_id = v_store_space.id and status = 'published'
    order by published_at desc, id desc limit 1 for update;

  update retrieval.space_publication set status = 'published', published_at = clock_timestamp()
    where tenant_id = v_tenant and id = v_publication.id;
  if v_previous_publication_id is not null and v_previous_publication_id <> v_publication.id then
    update retrieval.space_publication set status = 'superseded'
      where tenant_id = v_tenant and id = v_previous_publication_id;
  end if;
  update retrieval.vector_store_space set active_space_version_id = v_publication.vector_space_version_id
    where tenant_id = v_tenant and id = v_store_space.id;
  update retrieval.vector_space_version set publication_lifecycle = 'superseded'
    where tenant_id = v_tenant and id = v_store_space.active_space_version_id
      and id <> v_publication.vector_space_version_id;
  update retrieval.vector_space_version
    set publication_lifecycle = 'published', publication_decision_id = v_publication.publication_decision_id
    where tenant_id = v_tenant and id = v_publication.vector_space_version_id;

  insert into retrieval.publication_switch_receipt
    (tenant_id,vector_store_space_id,from_publication_id,to_publication_id,action,reason,
     guarded_sha256,actor_identity,idempotency_key)
  values (v_tenant,v_store_space.id,v_previous_publication_id,v_publication.id,'publish',p_reason,
          p_expected_guarded_sha256,p_actor_identity,p_idempotency_key)
  returning id into v_receipt_id;
  return v_receipt_id;
end $$;

create function retrieval.rollback_vector_space(
  p_current_publication_id uuid,
  p_target_publication_id uuid,
  p_expected_guarded_sha256 text,
  p_reason text,
  p_actor_identity text,
  p_idempotency_key text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_tenant uuid := util.current_tenant_id();
  v_current retrieval.space_publication%rowtype;
  v_target retrieval.space_publication%rowtype;
  v_new_publication_id uuid := util.uuidv7();
  v_receipt_id uuid;
begin
  if v_tenant is null then raise exception 'valid app.tenant_id context is required' using errcode='insufficient_privilege'; end if;
  if coalesce(btrim(p_reason),'') = '' or coalesce(btrim(p_actor_identity),'') = ''
     or coalesce(btrim(p_idempotency_key),'') = '' then
    raise exception 'rollback reason, actor identity, and idempotency key are required' using errcode='invalid_parameter_value';
  end if;
  select id into v_receipt_id from retrieval.publication_switch_receipt
    where tenant_id=v_tenant and idempotency_key=p_idempotency_key;
  if v_receipt_id is not null then return v_receipt_id; end if;
  select * into v_current from retrieval.space_publication
    where tenant_id=v_tenant and id=p_current_publication_id and status='published' for update;
  select * into v_target from retrieval.space_publication
    where tenant_id=v_tenant and id=p_target_publication_id
      and vector_store_space_id=v_current.vector_store_space_id for update;
  if v_current.id is null or v_target.id is null or v_current.id=v_target.id then
    raise exception 'current and rollback target publications are invalid' using errcode='object_not_in_prerequisite_state';
  end if;
  if not exists(select 1 from retrieval.content_promotion_decision d
    where d.tenant_id=v_tenant and d.id=v_target.publication_decision_id
      and d.guarded_sha256=p_expected_guarded_sha256 and d.decision='accept') then
    raise exception 'rollback target guarded digest is invalid' using errcode='check_violation';
  end if;

  insert into retrieval.space_publication
    (id,tenant_id,vector_store_space_id,vector_space_version_id,vector_item_manifest_sha256,
     embedding_manifest_sha256,index_manifest_sha256,evaluation_result_id,publication_decision_id,
     predecessor_id,status,expected_item_count)
  values (v_new_publication_id,v_tenant,v_target.vector_store_space_id,v_target.vector_space_version_id,
     v_target.vector_item_manifest_sha256,v_target.embedding_manifest_sha256,v_target.index_manifest_sha256,
     v_target.evaluation_result_id,v_target.publication_decision_id,v_current.id,'approved',v_target.expected_item_count);
  update retrieval.space_publication set status='published',published_at=clock_timestamp()
    where tenant_id=v_tenant and id=v_new_publication_id;
  update retrieval.space_publication set status='superseded'
    where tenant_id=v_tenant and id=v_current.id;
  update retrieval.vector_store_space set active_space_version_id=v_target.vector_space_version_id
    where tenant_id=v_tenant and id=v_target.vector_store_space_id;
  update retrieval.vector_space_version set publication_lifecycle='superseded'
    where tenant_id=v_tenant and id=v_current.vector_space_version_id;
  update retrieval.vector_space_version set publication_lifecycle='published',publication_decision_id=v_target.publication_decision_id
    where tenant_id=v_tenant and id=v_target.vector_space_version_id;
  insert into retrieval.publication_switch_receipt
    (tenant_id,vector_store_space_id,from_publication_id,to_publication_id,action,reason,
     guarded_sha256,actor_identity,idempotency_key)
  values(v_tenant,v_target.vector_store_space_id,v_current.id,v_new_publication_id,'rollback',p_reason,
     p_expected_guarded_sha256,p_actor_identity,p_idempotency_key)
  returning id into v_receipt_id;
  return v_receipt_id;
end $$;

create index vector_item_search_exact_idx on retrieval.vector_item
  (tenant_id, space_version_id, lower(search_text), id) where lifecycle = 'active';
create index vector_item_search_trgm_idx on retrieval.vector_item
  using gin (search_text extensions.gin_trgm_ops) where lifecycle = 'active';
create index vector_item_hard_filters_idx on retrieval.vector_item
  (tenant_id,space_version_id,visibility,classification,language,source_kind,freshness_at desc,id)
  where lifecycle = 'active';

create function api.hybrid_knowledge_search_1536(
  p_vector_space_version_id uuid,
  p_query_text text,
  p_query_embedding extensions.halfvec(1536),
  p_filters jsonb default '{}'::jsonb,
  p_result_limit integer default 20,
  p_candidate_limit integer default 100,
  p_rrf_k integer default 60
) returns table (
  vector_item_id uuid,
  search_projection_id uuid,
  search_text text,
  source_kind text,
  fused_score double precision,
  channel_scores jsonb
)
language plpgsql stable security definer set search_path = '' as $$
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

  return query
  with eligible as materialized (
    select vi.* from retrieval.vector_item vi
    where vi.tenant_id=v_tenant and vi.space_version_id=p_vector_space_version_id and vi.lifecycle='active'
      and (not (p_filters?'language') or vi.language=p_filters->>'language')
      and (not (p_filters?'visibility') or vi.visibility=p_filters->>'visibility')
      and (not (p_filters?'classification') or vi.classification=p_filters->>'classification')
      and (not (p_filters?'source_kind') or vi.source_kind=p_filters->>'source_kind')
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
      and (not (p_filters?'language') or vi.language=p_filters->>'language')
      and (not (p_filters?'visibility') or vi.visibility=p_filters->>'visibility')
      and (not (p_filters?'classification') or vi.classification=p_filters->>'classification')
      and (not (p_filters?'source_kind') or vi.source_kind=p_filters->>'source_kind')
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
  select vi.id,vi.search_projection_id,vi.search_text,vi.source_kind,f.score,f.details
  from fused f join eligible vi on vi.id=f.id
  order by f.score desc,vi.id limit p_result_limit;
end $$;

revoke all on function retrieval.publish_vector_space(uuid,text,text,text,text) from public,anon,authenticated;
revoke all on function retrieval.rollback_vector_space(uuid,uuid,text,text,text,text) from public,anon,authenticated;
grant execute on function retrieval.publish_vector_space(uuid,text,text,text,text) to executor_service,control_plane,service_role;
grant execute on function retrieval.rollback_vector_space(uuid,uuid,text,text,text,text) to executor_service,control_plane,service_role;
revoke all on function api.hybrid_knowledge_search_1536(uuid,text,extensions.halfvec,jsonb,integer,integer,integer) from public,anon;
grant execute on function api.hybrid_knowledge_search_1536(uuid,text,extensions.halfvec,jsonb,integer,integer,integer)
  to authenticated,app_reader,service_role;
grant select,insert on retrieval.publication_switch_receipt to executor_service,control_plane;

comment on function retrieval.publish_vector_space(uuid,text,text,text,text) is
  'Atomically validates and publishes a version, supersedes the prior publication, changes the active pointer, and appends a receipt.';
comment on function retrieval.rollback_vector_space(uuid,uuid,text,text,text,text) is
  'Reason-bearing rollback that creates and activates a fresh publication of a previously proven version.';
comment on function api.hybrid_knowledge_search_1536(uuid,text,extensions.halfvec,jsonb,integer,integer,integer) is
  'Tenant-safe bounded exact/FTS/trigram/ANN retrieval with hard prefilters and deterministic reciprocal-rank fusion.';
commit;
