begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(8);

select set_config('app.tenant_id','51000000-0000-7000-8000-000000000001',true);
insert into knowledge_service.operation
 (id,tenant_id,operation_kind,idempotency_key,correlation_id,actor_identity,request,request_sha256)
 values
 ('51000000-0000-7000-8000-000000000010','51000000-0000-7000-8000-000000000001','retrieval_run','callback-operation','51000000-0000-7000-8000-000000000011','service:receiver','{}',repeat('a',64));

select extensions.lives_ok($test$
 insert into knowledge_service.callback_delivery
  (callback_id,tenant_id,task_id,operation_id,correlation_id,causation_id,signing_key_reference,receiver_identity,payload_sha256,signature,occurred_at,received_at)
 values
  ('51000000-0000-7000-8000-000000000020','51000000-0000-7000-8000-000000000001','51000000-0000-7000-8000-000000000021','51000000-0000-7000-8000-000000000010','nested-correlation','parent-operation','secret://callback-signing','service:receiver','sha256:'||repeat('b',64),'sha256='||repeat('c',64),clock_timestamp(),clock_timestamp())
$test$,'first authenticated callback receipt is accepted');
select extensions.is((select count(*) from knowledge_service.callback_delivery),1::bigint,'one callback receipt is recorded');
select extensions.throws_ok($test$
 insert into knowledge_service.callback_delivery
  (callback_id,tenant_id,task_id,operation_id,correlation_id,signing_key_reference,receiver_identity,payload_sha256,signature,occurred_at,received_at)
 values
  ('51000000-0000-7000-8000-000000000020','51000000-0000-7000-8000-000000000001','51000000-0000-7000-8000-000000000021','51000000-0000-7000-8000-000000000010','nested-correlation','secret://callback-signing','service:receiver','sha256:'||repeat('b',64),'sha256='||repeat('c',64),clock_timestamp(),clock_timestamp())
$test$,'23505',null,'database uniqueness rejects replay even after a process restart');
select extensions.throws_ok($test$
 update knowledge_service.callback_delivery set correlation_id='tampered'
$test$,'23001',null,'callback receipts are immutable');
select extensions.throws_ok($test$
 delete from knowledge_service.callback_delivery
$test$,'23001',null,'callback receipts cannot be deleted');
select extensions.throws_ok($test$
 insert into knowledge_service.callback_delivery
  (callback_id,tenant_id,task_id,operation_id,correlation_id,signing_key_reference,receiver_identity,payload_sha256,signature,occurred_at,received_at)
 values
  ('51000000-0000-7000-8000-000000000030','51000000-0000-7000-8000-000000000001','51000000-0000-7000-8000-000000000031','51000000-0000-7000-8000-000000000010','stale','secret://callback-signing','service:receiver','sha256:'||repeat('d',64),'sha256='||repeat('e',64),clock_timestamp()-interval '6 minutes',clock_timestamp())
$test$,'23514',null,'stale callbacks fail closed at the database boundary');

set local role executor_service;
select set_config('app.tenant_id','51000000-0000-7000-8000-000000000002',true);
select count(*) as visible_callback_count from knowledge_service.callback_delivery \gset
reset role;
select extensions.is(:'visible_callback_count'::bigint,0::bigint,'another tenant cannot read callback receipt metadata');
select extensions.throws_ok($test$
 insert into knowledge_service.callback_delivery
  (callback_id,tenant_id,task_id,operation_id,correlation_id,signing_key_reference,receiver_identity,payload_sha256,signature,occurred_at,received_at)
 values
  ('51000000-0000-7000-8000-000000000040','51000000-0000-7000-8000-000000000002','51000000-0000-7000-8000-000000000041','51000000-0000-7000-8000-000000000010','cross-tenant','secret://callback-signing','service:receiver','sha256:'||repeat('f',64),'sha256='||repeat('1',64),clock_timestamp(),clock_timestamp())
$test$,'23503',null,'callback cannot bind to another tenant operation');

select * from extensions.finish();
rollback;
