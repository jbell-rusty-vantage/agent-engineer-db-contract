begin;

-- Rollback-only proof for 20260914011100_retrieval_history.sql.
-- It builds genuine temporal history through the canonical batch API, then checks the
-- historical retrieval predicates. It never admits a claim, never publishes a vector
-- space and never leaves a row behind: deferred constraints are forced immediate before
-- the final rollback so sealed-batch and closed-head invariants are actually evaluated.

-- Probe-local helpers. They are created inside the aborted transaction and never ship.
create function pg_temp.probe_receipt(p_tenant uuid,p_mission uuid,p_attempt uuid) returns uuid
language plpgsql as $$
declare intent uuid := util.uuidv7(); receipt uuid := util.uuidv7();
begin
  insert into orchestration.operation_intent(id,tenant_id,intent_type,schema_version,payload,preconditions,
      idempotency_key,proposed_by_attempt,mission_id,approval_state,policy_decision)
    values(intent,p_tenant,'knowledge_ingestion',1,'{"probe":"retrieval-history"}'::jsonb,'{}'::jsonb,
      'retrieval-history-probe:'||intent::text,p_attempt,p_mission,'approved','{"mode":"rollback-only-probe"}'::jsonb);
  insert into orchestration.operation_receipt(id,intent_id,executor_version,outcome,changes_summary,affected_refs)
    values(receipt,intent,'retrieval-history-probe/1','applied','{"probe":true}'::jsonb,'[]'::jsonb);
  return receipt;
end $$;

-- Returns the rejection message of a bounded query, or null when it unexpectedly succeeded.
create function pg_temp.probe_rejection(p_sql text) returns text language plpgsql as $$
declare message text;
begin
  execute p_sql;
  return null;
exception when others then get stacked diagnostics message = message_text; return message;
end $$;

do $$
declare
  tenant uuid := util.uuidv7();
  other_tenant uuid := util.uuidv7();
  mission uuid := util.uuidv7(); work_item uuid := util.uuidv7(); producer uuid := util.uuidv7();
  product uuid := util.uuidv7();
  claim_announce uuid := util.uuidv7(); claim_preview uuid := util.uuidv7(); claim_ga uuid := util.uuidv7();
  receipt_seed uuid; receipt_k1 uuid; receipt_k2 uuid;
  k0 bigint; k1 bigint; k2 bigint;
  occurrence_announce uuid; occurrence_ga uuid;
  witness_count integer;
  space uuid := util.uuidv7(); space_version uuid := util.uuidv7();
  store uuid := util.uuidv7(); store_space uuid := util.uuidv7();
  procedure_id uuid := util.uuidv7(); target uuid := util.uuidv7(); projection uuid := util.uuidv7();
  chunk_set uuid := util.uuidv7(); chunk uuid := util.uuidv7(); chunk_procedure uuid := util.uuidv7();
  document uuid := util.uuidv7(); document_version uuid := util.uuidv7(); representation uuid := util.uuidv7();
  capture uuid := util.uuidv7(); source_id uuid := util.uuidv7(); artifact uuid := util.uuidv7();
  empty_digest text := encode(extensions.digest('','sha256'),'hex');
  text_digest text := encode(extensions.digest('preview only','sha256'),'hex');
  embedding extensions.halfvec := array_fill(0.01::real,array[1536])::extensions.vector::extensions.halfvec;
  rejection text; expected text;
begin
  perform set_config('app.tenant_id',tenant::text,true);

  -- 1. World-time predicate: point containment, half-open overlap, and rejected bounds.
  if retrieval.history_world_matches(tstzrange('2026-01-01Z','2026-06-01Z','[)'),'2026-03-01Z',null,null) is not true
     or retrieval.history_world_matches(tstzrange('2026-01-01Z','2026-06-01Z','[)'),'2026-06-01Z',null,null) is not false
     or retrieval.history_world_matches(tstzrange('2026-01-01Z','2026-06-01Z','[)'),'2026-01-01Z',null,null) is not true
     or retrieval.history_world_matches(tstzrange('2026-01-01Z','2026-06-01Z','[)'),null,'2026-06-01Z','2026-07-01Z') is not false
     or retrieval.history_world_matches(tstzrange('2026-01-01Z','2026-06-01Z','[)'),null,'2026-05-01Z','2026-07-01Z') is not true
     or retrieval.history_world_matches(tstzrange('2026-01-01Z','2026-06-01Z','[)'),'2026-03-01Z','2026-05-01Z','2026-07-01Z') is not false
     or retrieval.history_world_matches(tstzrange('2026-01-01Z','2026-06-01Z','[)'),null,'2026-07-01Z','2026-05-01Z') is not false
     or retrieval.history_world_matches(tstzrange('2026-01-01Z','2026-06-01Z','[)'),null,'2026-05-01Z',null) is not false
     or retrieval.history_world_matches(tstzrange('2026-01-01Z','2026-06-01Z','[)'),null,null,null) is not true
     or retrieval.history_world_matches(null,'2026-03-01Z',null,null) is not false then
    raise exception 'world-time predicate semantics changed';
  end if;

  -- 2. Canonical parents and one subject entity.
  insert into orchestration.mission(id,tenant_id,goal) values(mission,tenant,'Rollback-only historical retrieval proof');
  insert into orchestration.work_item(id,tenant_id,mission_id,kind) values(work_item,tenant,mission,'build_vectors');
  insert into orchestration.attempt(id,tenant_id,work_item_id,attempt_no,agent_deployment_id)
    values(producer,tenant,work_item,1,'retrieval-history-probe');
  receipt_seed := pg_temp.probe_receipt(tenant,mission,producer);
  insert into corpus.entity(id,tenant_id,kind,display_name,slug,created_by_receipt_id)
    values(product,tenant,'product','Synthetic preview product','synthetic-preview-product-'||replace(tenant::text,'-',''),receipt_seed);
  insert into evidence.claim(id,tenant_id,claim_type,statement,status,producer_attempt_id) values
    (claim_announce,tenant,'capability','The product was announced.','proposed',producer),
    (claim_preview,tenant,'capability','The product entered preview.','proposed',producer),
    (claim_ga,tenant,'capability','The product became generally available.','proposed',producer);

  -- 3. K1 believes announcement and preview; K2 adds separately scoped general availability.
  k0 := coalesce((select knowledge_seq from temporal.knowledge_head where tenant_id=tenant),0);
  k1 := temporal.begin_batch();
  occurrence_announce := temporal.assert_event('product_announced',product,tstzrange('2026-01-15Z','2026-01-16Z','[)'),
    'actual',null,null,'announce',null,claim_announce);
  perform temporal.assert_event('product_announced',product,tstzrange('2026-02-01Z','2026-02-02Z','[)'),
    'actual',null,null,'preview',null,claim_preview);
  receipt_k1 := pg_temp.probe_receipt(tenant,mission,producer);
  perform temporal.commit_batch(receipt_k1,'retrieval-history-k1:'||tenant::text,empty_digest,'{"probe":"k1"}'::jsonb);

  k2 := temporal.begin_batch();
  occurrence_ga := temporal.assert_event('product_generally_available',product,tstzrange('2026-06-10Z','2026-06-11Z','[)'),
    'actual',null,null,'api-ga',null,claim_ga);
  receipt_k2 := pg_temp.probe_receipt(tenant,mission,producer);
  perform temporal.commit_batch(receipt_k2,'retrieval-history-k2:'||tenant::text,empty_digest,'{"probe":"k2"}'::jsonb);

  if k1 <> k0+1 or k2 <> k1+1 then raise exception 'knowledge sequence did not advance by one per batch'; end if;

  -- 4. Sealed receipts resolve to their own knowledge sequence; unknown receipts resolve to null.
  if retrieval.history_receipt_k(receipt_k1) <> k1 or retrieval.history_receipt_k(receipt_k2) <> k2
     or retrieval.history_receipt_k(util.uuidv7()) is not null then
    raise exception 'receipt knowledge-sequence resolution is wrong';
  end if;

  -- 5. Witness windowing is k_from <= K < k_to, and scopes stay separate.
  select count(*) into witness_count from retrieval.claim_history_witnesses(claim_ga,k1) w;
  if witness_count <> 0 then raise exception 'general availability was believed before it was recorded'; end if;
  select count(*) into witness_count from retrieval.claim_history_witnesses(claim_ga,k2) w
    where w.event_occurrence_id=occurrence_ga and w.k_from=k2;
  if witness_count <> 1 then raise exception 'general availability witness is missing at its own K'; end if;
  select count(*) into witness_count from retrieval.claim_history_witnesses(claim_announce,k1) w
    where w.event_occurrence_id=occurrence_announce
      and retrieval.history_world_matches(w.world_interval,'2026-01-15T12:00:00Z',null,null);
  if witness_count <> 1 then raise exception 'announcement witness is missing at K1'; end if;
  select count(*) into witness_count from retrieval.claim_history_witnesses(claim_announce,k1) w
    where retrieval.history_world_matches(w.world_interval,'2026-06-10T12:00:00Z',null,null);
  if witness_count <> 0 then raise exception 'announcement was conflated with the general-availability date'; end if;
  select count(*) into witness_count from retrieval.claim_history_witnesses(claim_announce,k1) w
    where w.entity_ids @> array[product];
  if witness_count <> 1 then raise exception 'witness entity anchor is missing'; end if;
  select count(*) into witness_count from retrieval.claim_history_witnesses(claim_announce,k2+1) w;
  if witness_count <> 0 then raise exception 'a knowledge sequence past the head returned witnesses'; end if;

  -- 6. Admission is separate from belief: none of these claims is currently authorized.
  if retrieval.history_claim_authorized(claim_announce) or retrieval.history_claim_authorized(claim_ga)
     or retrieval.history_claim_authorized(util.uuidv7()) then
    raise exception 'a claim without a sealed verification run was authorized';
  end if;

  -- 7. Publication gating: an unreviewed, unswitched publication never resolves.
  insert into retrieval.vector_space(id,tenant_id,slug,purpose,class)
    values(space,tenant,'history-probe-'||replace(tenant::text,'-',''),'Rollback-only history probe','canonical');
  insert into retrieval.vector_space_version(id,tenant_id,vector_space_id,version,embedding_model,dims,backend,precision,publication_lifecycle)
    values(space_version,tenant,space,1,'history-probe',1536,'pgvector','halfvec','published');
  insert into retrieval.vector_store(id,tenant_id,owner_identity,store_class,slug,name,purpose,visibility,lifecycle)
    values(store,tenant,'history-probe-owner','official','history-probe-store','History probe','Rollback-only history probe','internal','active');
  insert into retrieval.vector_store_space(id,tenant_id,vector_store_id,vector_space_id,active_space_version_id,authority_class)
    values(store_space,tenant,store,space,space_version,'official');
  if retrieval.history_publication_authorized(space_version,null) is not null then
    raise exception 'a vector-space version without any publication resolved';
  end if;

  -- 8. The public historical query fails closed on every bound and on missing publication.
  if pg_temp.probe_rejection('select 1') is not null then
    raise exception 'the rejection probe reports failure for a valid statement';
  end if;
  for rejection, expected in
    select pg_temp.probe_rejection(probe.sql), probe.expected from unnest(
      array[
        format('select * from api.hybrid_knowledge_search_history_1536(%L,%L,%L::extensions.halfvec,''{}''::jsonb,20,100,60,%s)',
          space_version,'preview only',embedding::text,k2+1),
        format('select * from api.hybrid_knowledge_search_history_1536(%L,%L,%L::extensions.halfvec,''{}''::jsonb,20,100,60,-1)',
          space_version,'preview only',embedding::text),
        format('select * from api.hybrid_knowledge_search_history_1536(%L,%L,%L::extensions.halfvec,''{}''::jsonb,20,100,60,%s,null,%L,%L,%L)',
          space_version,'preview only',embedding::text,k2,'2026-01-01Z','2026-01-01Z','2026-02-01Z'),
        format('select * from api.hybrid_knowledge_search_history_1536(%L,%L,%L::extensions.halfvec,''{}''::jsonb,20,100,60,%s,null,null,%L,%L)',
          space_version,'preview only',embedding::text,k2,'2026-03-01Z','2026-02-01Z'),
        format('select * from api.hybrid_knowledge_search_history_1536(%L,%L,%L::extensions.halfvec,''{}''::jsonb,20,100,60,%s,null,null,%L,null)',
          space_version,'preview only',embedding::text,k2,'2026-03-01Z'),
        format('select * from api.hybrid_knowledge_search_history_1536(%L,%L,%L::extensions.halfvec,''{"unsupported":"x"}''::jsonb,20,100,60,%s)',
          space_version,'preview only',embedding::text,k2),
        format('select * from api.hybrid_knowledge_search_history_1536(%L,%L,%L::extensions.halfvec,''{}''::jsonb,20,10,60,%s)',
          space_version,'preview only',embedding::text,k2),
        format('select * from api.hybrid_knowledge_search_history_1536(%L,%L,%L::extensions.halfvec,''{}''::jsonb,20,100,60,%s)',
          space_version,'preview only',embedding::text,k2)
      ],
      array[
        'knowledge sequence is outside sealed history',
        'knowledge sequence is outside sealed history',
        'invalid bounded history query',
        'invalid bounded history query',
        'invalid bounded history query',
        'invalid bounded history query',
        'invalid bounded history query',
        'currently authorized publication required'
      ]) as probe(sql,expected)
  loop
    if rejection is distinct from expected then
      raise exception 'bounded history query rejection changed: expected %, observed %',expected,coalesce(rejection,'success');
    end if;
  end loop;

  -- 9. Projection eligibility fails closed while the representation review is absent.
  insert into evidence.source(id,tenant_id,source_class,canonical_url)
    values(source_id,tenant,'web_page','https://synthetic.invalid/history/'||tenant::text);
  insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes,storage_state)
    values(artifact,tenant,'source_capture',text_digest,'source_captures','ai-engineer-cloud-bucket',tenant::text||'/probe','text/plain',12,'available');
  insert into evidence.source_capture(id,tenant_id,source_id,artifact_id,content_sha256,media_type,capture_method,capture_method_version,produced_by_attempt_id)
    values(capture,tenant,source_id,artifact,text_digest,'text/plain','manual','1',producer);
  insert into content.document(id,tenant_id,document_type_code,canonical_title,canonical_source_id)
    values(document,tenant,'api_reference','Synthetic preview source',source_id);
  insert into content.document_version(id,tenant_id,document_id,version_label,manifest_sha256)
    values(document_version,tenant,document,'v1',text_digest);
  insert into content.document_representation(id,tenant_id,document_version_id,artifact_id,representation_kind,representation_class,media_type,content_sha256)
    values(representation,tenant,document_version,artifact,'structural_document','structural_extraction','application/json',text_digest);
  insert into retrieval.chunking_procedure_version(id,tenant_id,slug,version,tokenizer,code_sha256,status,supported_content_classes,schema_contract)
    values(chunk_procedure,tenant,'history-probe','1','probe',text_digest,'admitted','[]'::jsonb,'{}'::jsonb);
  insert into retrieval.chunk_set(id,tenant_id,representation_id,procedure_version_id,frozen_config,tokenizer,input_manifest_sha256,chunk_set_sha256,status)
    values(chunk_set,tenant,representation,chunk_procedure,'{}'::jsonb,'probe',text_digest,text_digest,'succeeded');
  insert into retrieval.retrieval_chunk(id,tenant_id,chunk_set_id,ordinal,source_text,embedding_text,source_text_sha256,
      contextual_prefix_sha256,embedding_text_sha256,source_token_count,embedding_token_count,retrieval_role)
    values(chunk,tenant,chunk_set,0,'preview only','preview only',text_digest,empty_digest,text_digest,2,2,'primary');
  insert into retrieval.projection_target(id,tenant_id,target_kind,chunk_id) values(target,tenant,'chunk',chunk);
  insert into retrieval.projection_procedure(id,slug,version) values(procedure_id,'history-probe-'||replace(tenant::text,'-',''),1);
  insert into retrieval.search_projection(id,tenant_id,projection_target_id,projection_procedure_id,purpose,source_text,embedding_text,
      source_text_sha256,contextual_prefix_sha256,embedding_text_sha256,content_kind,visibility,classification)
    values(projection,tenant,target,procedure_id,'History probe','preview only','preview only',text_digest,empty_digest,text_digest,'chunk','internal','internal');
  insert into retrieval.search_projection_chunk_support(tenant_id,search_projection_id,ordinal,chunk_id,support_kind,selected_text_sha256)
    values(tenant,projection,0,chunk,'faithful_source',text_digest);

  if retrieval.history_representation_authorized(representation) then
    raise exception 'an unreviewed representation was authorized';
  end if;
  if retrieval.history_projection_matches(projection,k2,null,null,null,null) then
    raise exception 'a projection over an unauthorized representation matched';
  end if;
  if retrieval.history_projection_matches(util.uuidv7(),k2,null,null,null,null) then
    raise exception 'an unknown projection matched';
  end if;

  -- 10. Tenant isolation: another tenant context sees no witnesses and no eligibility.
  perform set_config('app.tenant_id',other_tenant::text,true);
  select count(*) into witness_count from retrieval.claim_history_witnesses(claim_announce,k1) w;
  if witness_count <> 0 then raise exception 'witnesses leaked across tenants'; end if;
  if retrieval.history_claim_authorized(claim_announce)
     or retrieval.history_projection_matches(projection,k2,null,null,null,null)
     or retrieval.history_receipt_k(receipt_k1) is not null
     or retrieval.history_publication_authorized(space_version,null) is not null then
    raise exception 'historical predicates leaked across tenants';
  end if;
  perform set_config('app.tenant_id',tenant::text,true);
end;
$$;

-- Evaluate every deferred temporal constraint before discarding the probe.
set constraints all immediate;

rollback;
