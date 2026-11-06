begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(16);

select extensions.has_table('retrieval','search_projection_chunk_support','typed chunk projection support exists');
select extensions.has_table('retrieval','authorized_publication_execution','authorized publication execution ledger exists');
select extensions.has_column('retrieval','vector_item','retrieval_chunk_id','vector items support faithful chunk identity');
select extensions.has_column('retrieval','vector_item_embedding_1536','physical_embedding_sha256','physical halfvec digest is generated');
select extensions.has_column('knowledge_service','review_decision','decision_operation_id','review decisions bind their authenticated operation');
select extensions.has_column('retrieval','embedding_run','promotion_decision_id','embedding runs bind promotion authority');
select extensions.has_column('retrieval','space_publication','operation_id','publication rows bind their control-plane operation');

select extensions.ok((select relrowsecurity and relforcerowsecurity from pg_class c join pg_namespace n on n.oid=c.relnamespace
 where n.nspname='retrieval' and c.relname='search_projection_chunk_support'),'chunk support forces RLS');
select extensions.ok((select relrowsecurity and relforcerowsecurity from pg_class c join pg_namespace n on n.oid=c.relnamespace
 where n.nspname='retrieval' and c.relname='authorized_publication_execution'),'publication authorization ledger forces RLS');

select extensions.has_fk('retrieval','search_projection_chunk_support','chunk support has foreign keys');
select extensions.has_fk('retrieval','authorized_publication_execution','publication authorization has foreign keys');
select extensions.has_fk('retrieval','vector_item','vector items retain typed foreign keys');

select extensions.throws_ok($test$
 insert into retrieval.content_promotion_proposal
 (tenant_id,proposal_sha256,source_manifest,chunk_manifest,projection_manifest,target_domains,expected_value,procedures,reason,proposed_by)
 values('73000000-0000-7000-8000-000000000001',repeat('a',64),'{}','{}','{}','{test}','value','{}','reason','curator')
$test$,'23514',null,'new promotion proposals cannot omit durable operation provenance');

select extensions.throws_ok($test$
 insert into knowledge_service.review_decision
 (tenant_id,review_subject_id,guarded_sha256,reviewer_identity,reviewer_role,decision,rationale,legacy_provenance)
 values('73000000-0000-7000-8000-000000000001','73000000-0000-7000-8000-000000000002',repeat('b',64),'forged','human_reviewer','approve','forged',true)
$test$,'42501',null,'callers cannot assert the migration-only legacy provenance escape');

select extensions.throws_ok($test$
 insert into retrieval.vector_item(id,tenant_id,space_version_id,content_sha256)
 values('73000000-0000-7000-8000-000000000010','73000000-0000-7000-8000-000000000001','73000000-0000-7000-8000-000000000011',repeat('c',64))
$test$,'23514',null,'vector items still require exactly one typed source');

select extensions.ok((select count(*)=2 from pg_constraint where conrelid='retrieval.search_projection_chunk_support'::regclass
 and contype='f' and confrelid in ('retrieval.search_projection'::regclass,'retrieval.retrieval_chunk'::regclass)),
 'chunk support has tenant-composite projection and chunk foreign keys');

select * from extensions.finish();
rollback;
