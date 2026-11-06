begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(8);

select extensions.has_column('retrieval','vector_store','created_by_operation_id','vector store records their durable creator operation');
select extensions.has_index('retrieval','vector_store','vector_store_created_by_operation_uq','one vector store is bound to each creator operation');
select extensions.trigger_is('retrieval','vector_store','vector_store_identity_immutable','retrieval','reject_vector_store_identity_mutation','owner and store identity are immutable');
select extensions.trigger_is('retrieval','vector_store','vector_store_delete_forbidden','retrieval','reject_vector_store_identity_mutation','vector stores are tombstoned rather than physically deleted');

insert into knowledge_service.operation(id,tenant_id,operation_kind,idempotency_key,correlation_id,actor_identity,request,request_sha256) values
 ('73000000-0000-7000-8000-000000000010','73000000-0000-7000-8000-000000000001','vector_store_create','vector-store-proof-a','73000000-0000-7000-8000-000000000011','service:control-plane','{}',repeat('a',64)),
 ('74000000-0000-7000-8000-000000000010','74000000-0000-7000-8000-000000000001','vector_store_create','vector-store-proof-b','74000000-0000-7000-8000-000000000011','service:control-plane','{}',repeat('b',64));

select extensions.lives_ok($test$
 insert into retrieval.vector_store(id,tenant_id,owner_identity,store_class,slug,name,purpose,visibility,quota_profile,retention_policy,deletion_policy,created_by_operation_id)
 values('73000000-0000-7000-8000-000000000020','73000000-0000-7000-8000-000000000001','service:control-plane','official','official-evidence','Official evidence','canonical evidence','tenant','{}','{}','{}','73000000-0000-7000-8000-000000000010')
$test$,'same-tenant durable operation provenance is accepted');

select extensions.throws_ok($test$
 insert into retrieval.vector_store(id,tenant_id,owner_identity,store_class,slug,name,purpose,visibility,quota_profile,retention_policy,deletion_policy,created_by_operation_id)
 values('73000000-0000-7000-8000-000000000021','73000000-0000-7000-8000-000000000001','service:control-plane','official','cross-tenant','Cross tenant','must fail','tenant','{}','{}','{}','74000000-0000-7000-8000-000000000010')
$test$,'23503',null,'cross-tenant operation provenance is rejected');

select extensions.throws_ok($test$
 update retrieval.vector_store set owner_identity='service:attacker' where id='73000000-0000-7000-8000-000000000020'
$test$,'55000',null,'owner substitution is rejected');

select extensions.throws_ok($test$
 delete from retrieval.vector_store where id='73000000-0000-7000-8000-000000000020'
$test$,'55000',null,'physical deletion is rejected');

select * from extensions.finish();
rollback;
