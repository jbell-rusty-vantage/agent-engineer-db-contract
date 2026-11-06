begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(7);

select set_config('app.tenant_id','50000000-0000-7000-8000-000000000001',true);
insert into knowledge_service.operation
 (id,tenant_id,operation_kind,idempotency_key,correlation_id,actor_identity,request,request_sha256) values
 ('50000000-0000-7000-8000-000000000010','50000000-0000-7000-8000-000000000001','retrieval_run','retry-op','50000000-0000-7000-8000-000000000011','operator','{}',repeat('a',64)),
 ('50000000-0000-7000-8000-000000000020','50000000-0000-7000-8000-000000000001','retrieval_run','immutable-op','50000000-0000-7000-8000-000000000021','operator','{}',repeat('b',64)),
 ('50000000-0000-7000-8000-000000000030','50000000-0000-7000-8000-000000000001','retrieval_run','succeeded-op','50000000-0000-7000-8000-000000000031','operator','{}',repeat('c',64));
insert into knowledge_service.operation_step
 (id,tenant_id,operation_id,step_key,step_kind,input,input_sha256) values
 ('50000000-0000-7000-8000-000000000110','50000000-0000-7000-8000-000000000001','50000000-0000-7000-8000-000000000010','retrieve','retrieve','{}',repeat('d',64));

update knowledge_service.operation_step set status='failed',attempt_count=3,completed_at=clock_timestamp()
 where id='50000000-0000-7000-8000-000000000110';
update knowledge_service.operation set status='failed',completed_at=clock_timestamp()
 where id in ('50000000-0000-7000-8000-000000000010','50000000-0000-7000-8000-000000000020');
update knowledge_service.operation set status='succeeded',completed_at=clock_timestamp()
 where id='50000000-0000-7000-8000-000000000030';
insert into knowledge_service.receipt
 (id,tenant_id,operation_id,step_id,receipt_kind,idempotency_key,executor_identity,input_sha256,outcome,body) values
 ('50000000-0000-7000-8000-000000000210','50000000-0000-7000-8000-000000000001','50000000-0000-7000-8000-000000000010','50000000-0000-7000-8000-000000000110','failure','retry-receipt','worker',repeat('d',64),'failed','{}');

select extensions.lives_ok($test$
 update knowledge_service.operation_step set status='queued',max_attempts=max_attempts+max_attempts,available_at=clock_timestamp(),completed_at=null
 where id='50000000-0000-7000-8000-000000000110'
$test$,'failed step execution state can be reset for an authorized retry');
select extensions.lives_ok($test$
 update knowledge_service.operation set status='queued',completed_at=null
 where id='50000000-0000-7000-8000-000000000010'
$test$,'failed operation execution state can be reset for an authorized retry');
select extensions.is((select status from knowledge_service.operation where id='50000000-0000-7000-8000-000000000010'),'queued','operation is queued after retry');
select extensions.ok((select attempt_count=3 and max_attempts=6 from knowledge_service.operation_step where id='50000000-0000-7000-8000-000000000110'),'retry preserves attempt identity and adds one bounded attempt cycle');
select extensions.is((select count(*) from knowledge_service.receipt where operation_id='50000000-0000-7000-8000-000000000010'),1::bigint,'retry preserves immutable receipt history');
select extensions.throws_ok($test$
 update knowledge_service.operation set status='queued',completed_at=null,request='{"changed":true}' where id='50000000-0000-7000-8000-000000000020'
$test$,'23001',null,'retry cannot alter the immutable operation request');
select extensions.throws_ok($test$
 update knowledge_service.operation set status='queued',completed_at=null where id='50000000-0000-7000-8000-000000000030'
$test$,'23001',null,'successful terminal operations remain immutable');

select * from extensions.finish();
rollback;
