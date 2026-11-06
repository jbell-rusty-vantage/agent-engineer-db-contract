begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(14);

select extensions.has_column('retrieval','vector_store_document','created_by_operation_id','document membership records creator operation');
select extensions.has_index('retrieval','vector_store_document','vector_store_document_active_membership_uq','active membership is unique per store and document');
select extensions.trigger_is('retrieval','vector_store_document','vector_store_document_identity_immutable','retrieval','reject_vector_store_document_identity_mutation','attachment identity is immutable');
select extensions.has_table('retrieval','vector_store_ingestion_run','ingestion manifest table exists');
select extensions.has_table('retrieval','vector_store_ingestion_checkpoint','ingestion checkpoint table exists');
select extensions.trigger_is('retrieval','vector_store_ingestion_run','vector_store_ingestion_operation_guard','retrieval','validate_vector_store_ingestion_operation','ingestion manifest requires the matching active operation actor');
select extensions.trigger_is('retrieval','vector_store_ingestion_run','vector_store_ingestion_run_immutable','util','reject_mutation','ingestion manifest is immutable');
select extensions.trigger_is('retrieval','vector_store_ingestion_checkpoint','vector_store_ingestion_checkpoint_immutable','util','reject_mutation','ingestion checkpoint is immutable');

insert into knowledge_service.operation(id,tenant_id,operation_kind,idempotency_key,correlation_id,actor_identity,request,request_sha256,status) values
 ('75000000-0000-7000-8000-000000000010','75000000-0000-7000-8000-000000000001','vector_store_create','ingestion-store-create','75000000-0000-7000-8000-000000000011','service:owner','{}',repeat('a',64),'running'),
 ('75000000-0000-7000-8000-000000000012','75000000-0000-7000-8000-000000000001','vector_store_ingestion','ingestion-proof','75000000-0000-7000-8000-000000000013','service:owner','{}',repeat('b',64),'running');
insert into retrieval.vector_store(id,tenant_id,owner_identity,store_class,slug,name,purpose,visibility,quota_profile,retention_policy,deletion_policy,created_by_operation_id)
 values('75000000-0000-7000-8000-000000000020','75000000-0000-7000-8000-000000000001','service:owner','exploratory','ingestion-proof','Ingestion proof','pgTAP','tenant','{}','{}','{}','75000000-0000-7000-8000-000000000010');

select extensions.lives_ok($test$
 insert into retrieval.vector_store_ingestion_run(id,tenant_id,operation_id,vector_store_id,actor_identity,request_sha256,manifest)
 values('75000000-0000-7000-8000-000000000030','75000000-0000-7000-8000-000000000001','75000000-0000-7000-8000-000000000012','75000000-0000-7000-8000-000000000020','service:owner',repeat('c',64),'{}')
$test$,'matching ingestion operation is accepted');
select extensions.throws_ok($test$
 insert into retrieval.vector_store_ingestion_run(id,tenant_id,operation_id,vector_store_id,actor_identity,request_sha256,manifest)
 values('75000000-0000-7000-8000-000000000031','75000000-0000-7000-8000-000000000001','75000000-0000-7000-8000-000000000012','75000000-0000-7000-8000-000000000020','service:substituted',repeat('d',64),'{}')
$test$,'42501',null,'actor substitution is rejected');
select extensions.throws_ok($test$
 update retrieval.vector_store_ingestion_run set request_sha256=repeat('e',64) where id='75000000-0000-7000-8000-000000000030'
$test$,null,null,'ingestion manifest mutation is rejected');
select extensions.lives_ok($test$
 insert into retrieval.vector_store_ingestion_checkpoint(id,tenant_id,ingestion_run_id,stage,evidence_sha256,evidence)
 values('75000000-0000-7000-8000-000000000040','75000000-0000-7000-8000-000000000001','75000000-0000-7000-8000-000000000030','prepared',repeat('f',64),'[]')
$test$,'immutable prepared checkpoint is accepted');
select extensions.throws_ok($test$
 update retrieval.vector_store_ingestion_checkpoint set evidence='[1]' where id='75000000-0000-7000-8000-000000000040'
$test$,null,null,'checkpoint mutation is rejected');
select extensions.throws_ok($test$
 delete from retrieval.vector_store_ingestion_checkpoint where id='75000000-0000-7000-8000-000000000040'
$test$,null,null,'checkpoint deletion is rejected');

select * from extensions.finish();
rollback;
