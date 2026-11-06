begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(8);

select extensions.has_column('evidence','source_capture','knowledge_operation_id','source captures expose standalone operation provenance');
select extensions.col_is_null('evidence','source_capture','produced_by_attempt_id','Mission Control attempt is nullable when standalone operation is authoritative');

insert into orchestration.mission(id,tenant_id,goal) values
 ('71000000-0000-7000-8000-000000000001','71000000-0000-7000-8000-000000000001','capture provenance test');
insert into orchestration.work_item(id,tenant_id,mission_id,kind) values
 ('71000000-0000-7000-8000-000000000002','71000000-0000-7000-8000-000000000001','71000000-0000-7000-8000-000000000001','capture_source');
insert into orchestration.attempt(id,tenant_id,work_item_id,attempt_no,agent_deployment_id) values
 ('71000000-0000-7000-8000-000000000003','71000000-0000-7000-8000-000000000001','71000000-0000-7000-8000-000000000002',1,'capture-test');
insert into knowledge_service.operation(id,tenant_id,operation_kind,idempotency_key,correlation_id,actor_identity,request,request_sha256) values
 ('71000000-0000-7000-8000-000000000010','71000000-0000-7000-8000-000000000001','capture','capture-proof-a','71000000-0000-7000-8000-000000000011','knowledge_api','{}',repeat('a',64)),
 ('72000000-0000-7000-8000-000000000010','72000000-0000-7000-8000-000000000001','capture','capture-proof-b','72000000-0000-7000-8000-000000000011','knowledge_api','{}',repeat('b',64));
insert into evidence.source(id,tenant_id,source_class,canonical_url) values
 ('71000000-0000-7000-8000-000000000020','71000000-0000-7000-8000-000000000001','web_page','https://example.com/capture-provenance');
insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes) values
 ('71000000-0000-7000-8000-000000000030','71000000-0000-7000-8000-000000000001','source_capture',repeat('c',64),'source_captures','source-captures','proof/c','text/plain',1),
 ('71000000-0000-7000-8000-000000000031','71000000-0000-7000-8000-000000000001','source_capture',repeat('d',64),'source_captures','source-captures','proof/d','text/plain',1),
 ('71000000-0000-7000-8000-000000000032','71000000-0000-7000-8000-000000000001','source_capture',repeat('e',64),'source_captures','source-captures','proof/e','text/plain',1);

select extensions.lives_ok($test$
 insert into evidence.source_capture(id,tenant_id,source_id,artifact_id,content_sha256,media_type,capture_method,capture_method_version,knowledge_operation_id)
 values('71000000-0000-7000-8000-000000000040','71000000-0000-7000-8000-000000000001','71000000-0000-7000-8000-000000000020','71000000-0000-7000-8000-000000000030',repeat('c',64),'text/plain','direct-http','1','71000000-0000-7000-8000-000000000010')
$test$,'standalone capture accepts a same-tenant durable operation producer');

select extensions.lives_ok($test$
 insert into evidence.source_capture(id,tenant_id,source_id,artifact_id,content_sha256,media_type,capture_method,capture_method_version,produced_by_attempt_id)
 values('71000000-0000-7000-8000-000000000041','71000000-0000-7000-8000-000000000001','71000000-0000-7000-8000-000000000020','71000000-0000-7000-8000-000000000031',repeat('d',64),'text/plain','mission-control','1','71000000-0000-7000-8000-000000000003')
$test$,'Mission Control capture retains the existing attempt producer path');

select extensions.throws_ok($test$
 insert into evidence.source_capture(id,tenant_id,source_id,artifact_id,content_sha256,media_type,capture_method,capture_method_version)
 values('71000000-0000-7000-8000-000000000042','71000000-0000-7000-8000-000000000001','71000000-0000-7000-8000-000000000020','71000000-0000-7000-8000-000000000030',repeat('c',64),'text/plain','unattributed','1')
$test$,'23514',null,'capture rejects missing producer provenance');

select extensions.throws_ok($test$
 insert into evidence.source_capture(id,tenant_id,source_id,artifact_id,content_sha256,media_type,capture_method,capture_method_version,produced_by_attempt_id,knowledge_operation_id)
 values('71000000-0000-7000-8000-000000000043','71000000-0000-7000-8000-000000000001','71000000-0000-7000-8000-000000000020','71000000-0000-7000-8000-000000000030',repeat('c',64),'text/plain','ambiguous','1','71000000-0000-7000-8000-000000000003','71000000-0000-7000-8000-000000000010')
$test$,'23514',null,'capture rejects ambiguous dual producer provenance');

select extensions.throws_ok($test$
 insert into evidence.source_capture(id,tenant_id,source_id,artifact_id,content_sha256,media_type,capture_method,capture_method_version,knowledge_operation_id)
 values('71000000-0000-7000-8000-000000000044','71000000-0000-7000-8000-000000000001','71000000-0000-7000-8000-000000000020','71000000-0000-7000-8000-000000000032',repeat('e',64),'text/plain','cross-tenant','1','72000000-0000-7000-8000-000000000010')
$test$,'23503',null,'capture rejects a cross-tenant operation producer');

select extensions.ok((select knowledge_operation_id='71000000-0000-7000-8000-000000000010'::uuid and produced_by_attempt_id is null
 from evidence.source_capture where id='71000000-0000-7000-8000-000000000040'),'standalone lineage stores only the operation producer');

select * from extensions.finish();
rollback;
