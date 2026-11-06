begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(18);

-- Fail closed before even resolving a guessed publication UUID.
reset app.tenant_id;
select extensions.throws_ok(
  $$select retrieval.publish_vector_space('30000000-0000-7000-8000-000000000001',repeat('a',64),'reason','tester','missing-tenant')$$,
  '42501',null,'publication fails closed without tenant context');

select set_config('app.tenant_id','30000000-0000-7000-8000-000000000000',true);

insert into orchestration.mission(id,tenant_id,goal)
 values('30000000-0000-7000-8000-000000000090','30000000-0000-7000-8000-000000000000','publication fixture');
insert into orchestration.work_item(id,tenant_id,mission_id,kind)
 values('30000000-0000-7000-8000-000000000091','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000090','build_vectors');
insert into orchestration.attempt(id,tenant_id,work_item_id,attempt_no,agent_deployment_id)
 values('30000000-0000-7000-8000-000000000092','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000091',1,'contract-test');
insert into evidence.claim(id,tenant_id,claim_type,statement,producer_attempt_id) values
 ('30000000-0000-7000-8000-000000000101','30000000-0000-7000-8000-000000000000','recommendation','durable agent state','30000000-0000-7000-8000-000000000092'),
 ('30000000-0000-7000-8000-000000000102','30000000-0000-7000-8000-000000000000','recommendation','ephemeral browser session','30000000-0000-7000-8000-000000000092'),
 ('30000000-0000-7000-8000-000000000103','30000000-0000-7000-8000-000000000000','recommendation','replacement version','30000000-0000-7000-8000-000000000092');
insert into retrieval.projection_procedure(id,slug,version,description)
 values('30000000-0000-7000-8000-000000000110','contract-test',1,'contract fixture');
insert into retrieval.projection_target(id,tenant_id,target_kind,schema_version,canonical_table,canonical_record_id,eligibility_validator) values
 ('30000000-0000-7000-8000-000000000111','30000000-0000-7000-8000-000000000000','claim',1,'evidence.claim','30000000-0000-7000-8000-000000000101','util.current_tenant_id()'),
 ('30000000-0000-7000-8000-000000000112','30000000-0000-7000-8000-000000000000','claim',1,'evidence.claim','30000000-0000-7000-8000-000000000102','util.current_tenant_id()'),
 ('30000000-0000-7000-8000-000000000113','30000000-0000-7000-8000-000000000000','claim',1,'evidence.claim','30000000-0000-7000-8000-000000000103','util.current_tenant_id()');
insert into retrieval.search_projection
 (id,tenant_id,projection_target_id,projection_procedure_id,purpose,source_text,embedding_text,
  source_text_sha256,contextual_prefix_sha256,embedding_text_sha256,content_kind,visibility,classification) values
 ('30000000-0000-7000-8000-000000000121','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000111','30000000-0000-7000-8000-000000000110','identity','durable agent state','durable agent state',repeat('1',64),repeat('2',64),repeat('3',64),'claim','public','public'),
 ('30000000-0000-7000-8000-000000000122','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000112','30000000-0000-7000-8000-000000000110','identity','ephemeral browser session','ephemeral browser session',repeat('4',64),repeat('5',64),repeat('6',64),'claim','internal','public'),
 ('30000000-0000-7000-8000-000000000123','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000113','30000000-0000-7000-8000-000000000110','identity','replacement version','replacement version',repeat('7',64),repeat('8',64),repeat('9',64),'claim','public','public');

insert into retrieval.vector_space(id,tenant_id,slug,purpose,class)
 values('30000000-0000-7000-8000-000000000130','30000000-0000-7000-8000-000000000000','engineering','contract test','exploratory');
insert into retrieval.vector_space_version
 (id,tenant_id,vector_space_id,version,embedding_model,dims,projection_procedure_id,backend,precision) values
 ('30000000-0000-7000-8000-000000000131','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000130',1,'openai/text-embedding-3-small',1536,'30000000-0000-7000-8000-000000000110','pgvector','halfvec'),
 ('30000000-0000-7000-8000-000000000132','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000130',2,'openai/text-embedding-3-small',1536,'30000000-0000-7000-8000-000000000110','pgvector','halfvec');
insert into retrieval.vector_store(id,tenant_id,owner_identity,store_class,slug,name,purpose,visibility)
 values('30000000-0000-7000-8000-000000000140','30000000-0000-7000-8000-000000000000','control-plane','official','official','Official','test','public');
select extensions.throws_ok($$
 insert into retrieval.vector_store_space(id,tenant_id,vector_store_id,vector_space_id,authority_class)
 values('30000000-0000-7000-8000-000000000142','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000140','30000000-0000-7000-8000-000000000130','exploratory')
$$,'23514',null,'vector-store authority cannot silently cross its parent store class');
insert into retrieval.vector_store_space(id,tenant_id,vector_store_id,vector_space_id,authority_class)
 values('30000000-0000-7000-8000-000000000141','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000140','30000000-0000-7000-8000-000000000130','official');

insert into retrieval.vector_item
 (id,tenant_id,space_version_id,claim_id,search_projection_id,content_sha256,search_text,language,visibility,classification,authority_level,freshness_at) values
 ('30000000-0000-7000-8000-000000000151','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000131','30000000-0000-7000-8000-000000000101','30000000-0000-7000-8000-000000000121',repeat('a',64),'durable agent state','en','public','public','verified',now()),
 ('30000000-0000-7000-8000-000000000152','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000131','30000000-0000-7000-8000-000000000102','30000000-0000-7000-8000-000000000122',repeat('b',64),'ephemeral browser session','en','internal','public','context_only',now()),
 ('30000000-0000-7000-8000-000000000153','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000132','30000000-0000-7000-8000-000000000103','30000000-0000-7000-8000-000000000123',repeat('c',64),'replacement version','en','public','public','verified',now());
insert into retrieval.vector_item_embedding_1536
 (tenant_id,vector_space_key,vector_space_version_id,vector_item_id,embedding,embedding_sha256) values
 ('30000000-0000-7000-8000-000000000000','engineering-v1','30000000-0000-7000-8000-000000000131','30000000-0000-7000-8000-000000000151',('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536),repeat('d',64)),
 ('30000000-0000-7000-8000-000000000000','engineering-v1','30000000-0000-7000-8000-000000000131','30000000-0000-7000-8000-000000000152',('['||'0,1,'||array_to_string(array_fill(0.0::real,array[1534]),',')||']')::extensions.halfvec(1536),repeat('e',64)),
 ('30000000-0000-7000-8000-000000000000','engineering-v2','30000000-0000-7000-8000-000000000132','30000000-0000-7000-8000-000000000153',('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536),repeat('f',64));

insert into evaluation.eval_dataset(id,tenant_id,slug,purpose) values
 ('30000000-0000-7000-8000-000000000160','30000000-0000-7000-8000-000000000000','publication-test','publication gates');
insert into evaluation.eval_run(id,tenant_id,dataset_id,space_version_id) values
 ('30000000-0000-7000-8000-000000000161','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000160','30000000-0000-7000-8000-000000000131'),
 ('30000000-0000-7000-8000-000000000162','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000160','30000000-0000-7000-8000-000000000132');
insert into evaluation.promotion_gate_version(id,tenant_id,slug,version,definition,definition_sha256)
 values('30000000-0000-7000-8000-000000000163','30000000-0000-7000-8000-000000000000','publication',1,'{}',repeat('1',64));
insert into evaluation.promotion_gate_result(id,tenant_id,gate_version_id,eval_run_id,passed,observations,result_sha256) values
 ('30000000-0000-7000-8000-000000000164','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000163','30000000-0000-7000-8000-000000000161',true,'{}',repeat('2',64)),
 ('30000000-0000-7000-8000-000000000165','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000163','30000000-0000-7000-8000-000000000162',true,'{}',repeat('3',64));
-- These rows intentionally exercise the pre-governance publication RPC. Mark
-- them as historical fixtures explicitly; production callers cannot assert the
-- compatibility marker because the insert trigger remains enabled outside this
-- tightly scoped test setup.
alter table retrieval.content_promotion_proposal disable trigger promotion_proposal_no_new_legacy;
insert into retrieval.content_promotion_proposal
 (id,tenant_id,proposal_sha256,source_manifest,chunk_manifest,projection_manifest,target_domains,expected_value,procedures,reason,proposed_by,legacy_provenance) values
 ('30000000-0000-7000-8000-000000000170','30000000-0000-7000-8000-000000000000',repeat('4',64),'{}','{}','{}','{engineering}','test','{}','test','agent',true),
 ('30000000-0000-7000-8000-000000000171','30000000-0000-7000-8000-000000000000',repeat('5',64),'{}','{}','{}','{engineering}','test','{}','test','agent',true);
alter table retrieval.content_promotion_proposal enable trigger promotion_proposal_no_new_legacy;
alter table retrieval.content_promotion_decision disable trigger promotion_decision_no_new_legacy;
insert into retrieval.content_promotion_decision
 (id,tenant_id,proposal_id,guarded_sha256,decision,gates,reviewer_identity,policy_version,rationale,legacy_provenance) values
 ('30000000-0000-7000-8000-000000000172','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000170',repeat('6',64),'accept','{}','reviewer','v1','passes',true),
 ('30000000-0000-7000-8000-000000000173','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000171',repeat('7',64),'accept','{}','reviewer','v1','passes',true);
alter table retrieval.content_promotion_decision enable trigger promotion_decision_no_new_legacy;
alter table retrieval.space_publication disable trigger space_publication_no_new_legacy;
insert into retrieval.space_publication
 (id,tenant_id,vector_store_space_id,vector_space_version_id,vector_item_manifest_sha256,embedding_manifest_sha256,index_manifest_sha256,evaluation_result_id,publication_decision_id,status,expected_item_count,legacy_provenance) values
 ('30000000-0000-7000-8000-000000000180','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000141','30000000-0000-7000-8000-000000000131',repeat('8',64),repeat('9',64),repeat('a',64),'30000000-0000-7000-8000-000000000164','30000000-0000-7000-8000-000000000172','approved',2,true),
 ('30000000-0000-7000-8000-000000000181','30000000-0000-7000-8000-000000000000','30000000-0000-7000-8000-000000000141','30000000-0000-7000-8000-000000000132',repeat('b',64),repeat('c',64),repeat('d',64),'30000000-0000-7000-8000-000000000165','30000000-0000-7000-8000-000000000173','approved',1,true);
alter table retrieval.space_publication enable trigger space_publication_no_new_legacy;

insert into knowledge_service.operation(id,tenant_id,operation_kind,idempotency_key,correlation_id,actor_identity,request,request_sha256,status) values
 ('30000000-0000-7000-8000-000000000190','30000000-0000-7000-8000-000000000000','publication_rollback','rollback-operation-v1',
  '30000000-0000-7000-8000-000000000191','service:control-plane','{}',repeat('e',64),'running');

select extensions.lives_ok($$select retrieval.publish_vector_space('30000000-0000-7000-8000-000000000180',repeat('6',64),'initial publish','control-plane','publish-v1')$$,'initial publication succeeds atomically');
select extensions.is((select active_space_version_id from retrieval.vector_store_space where id='30000000-0000-7000-8000-000000000141'),'30000000-0000-7000-8000-000000000131'::uuid,'initial active pointer is v1');
select extensions.is((select reason from retrieval.publication_switch_receipt where idempotency_key='publish-v1'),'initial publish','publication receipt retains its reason');
select extensions.lives_ok($$select retrieval.publish_vector_space('30000000-0000-7000-8000-000000000181',repeat('7',64),'upgrade','control-plane','publish-v2')$$,'second publication atomically switches pointer');
select extensions.is((select status from retrieval.space_publication where id='30000000-0000-7000-8000-000000000180'),'superseded','previous publication is superseded');
select extensions.is((select active_space_version_id from retrieval.vector_store_space where id='30000000-0000-7000-8000-000000000141'),'30000000-0000-7000-8000-000000000132'::uuid,'active pointer is v2');
select extensions.lives_ok($$select retrieval.rollback_vector_space('30000000-0000-7000-8000-000000000181','30000000-0000-7000-8000-000000000180',repeat('6',64),'recall regression','control-plane','rollback-v1','30000000-0000-7000-8000-000000000190')$$,'reason-bearing rollback succeeds');
select extensions.is((select active_space_version_id from retrieval.vector_store_space where id='30000000-0000-7000-8000-000000000141'),'30000000-0000-7000-8000-000000000131'::uuid,'rollback atomically restores v1 pointer');
select extensions.is((select action||':'||reason from retrieval.publication_switch_receipt where idempotency_key='rollback-v1'),'rollback:recall regression','rollback receipt preserves action and reason');

select extensions.is(
 (select vector_item_id from api.hybrid_knowledge_search_1536('30000000-0000-7000-8000-000000000131','durable agent state',('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536),'{"visibility":"public"}',1,10,60)),
 '30000000-0000-7000-8000-000000000151'::uuid,'hybrid RRF returns the exact and ANN-nearest public item');
select extensions.is(
 (select count(*) from api.hybrid_knowledge_search_1536('30000000-0000-7000-8000-000000000131','durable agent state',('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536),'{"visibility":"internal"}',10,10,60)),
 1::bigint,'hard visibility filter is applied before bounded fusion');
select extensions.throws_ok(
 $$select * from api.hybrid_knowledge_search_1536('30000000-0000-7000-8000-000000000131','query',('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536),'{"unknown":true}',10,10,60)$$,
 '22023',null,'unknown hard filters are rejected');
select extensions.throws_ok(
 $$select * from api.hybrid_knowledge_search_1536('30000000-0000-7000-8000-000000000131','query',('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536),'{}',201,201,60)$$,
 '22023',null,'result bounds are enforced');
select extensions.is(
 (select array_agg(vector_item_id order by fused_score desc,vector_item_id) from api.hybrid_knowledge_search_1536('30000000-0000-7000-8000-000000000131','durable agent state',('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536),'{}',10,10,60)),
 (select array_agg(vector_item_id order by fused_score desc,vector_item_id) from api.hybrid_knowledge_search_1536('30000000-0000-7000-8000-000000000131','durable agent state',('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536),'{}',10,10,60)),
 'deterministic RRF produces repeatable ordering');
select extensions.ok(exists(select 1 from pg_indexes where schemaname='retrieval' and indexname='vector_item_embedding_1536_hnsw' and indexdef ilike '%hnsw%halfvec_cosine_ops%'),'HNSW cosine index exists for ANN');
select extensions.is(
 (select vector_item_id from retrieval.vector_item_embedding_1536 where vector_space_version_id='30000000-0000-7000-8000-000000000131' order by embedding operator(extensions.<=>) (('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536)) limit 1),
 (select vector_item_id from retrieval.vector_item_embedding_1536 where vector_space_version_id='30000000-0000-7000-8000-000000000131' order by 1-(embedding operator(extensions.<=>) (('['||'1,'||array_to_string(array_fill(0.0::real,array[1535]),',')||']')::extensions.halfvec(1536))) desc,vector_item_id limit 1),
 'bounded ANN ordering agrees with exact cosine ordering');

select * from extensions.finish();
rollback;
