begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(18);

reset app.tenant_id;
select extensions.throws_ok(
  $$select * from knowledge_service.claim_outbox('worker-a',1,30000,null)$$,
  '42501',null,'claiming fails closed without tenant context');

select set_config('app.tenant_id','40000000-0000-7000-8000-000000000001',true);
insert into knowledge_service.operation
 (id,tenant_id,operation_kind,idempotency_key,correlation_id,actor_identity,request,request_sha256) values
 ('40000000-0000-7000-8000-000000000010','40000000-0000-7000-8000-000000000001','test','op-a','40000000-0000-7000-8000-000000000011','tester','{}',repeat('a',64)),
 ('40000000-0000-7000-8000-000000000020','40000000-0000-7000-8000-000000000002','test','op-b','40000000-0000-7000-8000-000000000021','tester','{}',repeat('b',64));
insert into knowledge_service.operation_event
 (id,tenant_id,operation_id,event_kind,actor_identity,correlation_id,payload) values
 ('40000000-0000-7000-8000-000000000101','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000010','test.one','tester','40000000-0000-7000-8000-000000000011','{}'),
 ('40000000-0000-7000-8000-000000000102','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000010','test.two','tester','40000000-0000-7000-8000-000000000011','{}'),
 ('40000000-0000-7000-8000-000000000103','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000010','test.expired','tester','40000000-0000-7000-8000-000000000011','{}'),
 ('40000000-0000-7000-8000-000000000104','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000010','test.poison','tester','40000000-0000-7000-8000-000000000011','{}'),
 ('40000000-0000-7000-8000-000000000201','40000000-0000-7000-8000-000000000002','40000000-0000-7000-8000-000000000020','test.foreign','tester','40000000-0000-7000-8000-000000000021','{}');
insert into knowledge_service.outbox
 (id,tenant_id,operation_id,event_id,topic,payload,payload_sha256,available_at,max_delivery_attempts,
  claim_owner,claim_token,claimed_at,visibility_expires_at,delivery_attempts) values
 ('40000000-0000-7000-8000-000000000301','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000010','40000000-0000-7000-8000-000000000101','test.one','{}',repeat('1',64),clock_timestamp()-interval '4 seconds',3,null,null,null,null,0),
 ('40000000-0000-7000-8000-000000000302','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000010','40000000-0000-7000-8000-000000000102','test.two','{}',repeat('2',64),clock_timestamp()-interval '3 seconds',3,null,null,null,null,0),
 ('40000000-0000-7000-8000-000000000303','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000010','40000000-0000-7000-8000-000000000103','test.expired','{}',repeat('3',64),clock_timestamp()-interval '2 seconds',3,'old-worker','40000000-0000-7000-8000-000000000399',clock_timestamp()-interval '2 seconds',clock_timestamp()-interval '1 second',1),
 ('40000000-0000-7000-8000-000000000304','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000010','40000000-0000-7000-8000-000000000104','test.poison','{}',repeat('4',64),clock_timestamp()-interval '1 second',1,null,null,null,null,1),
 ('40000000-0000-7000-8000-000000000401','40000000-0000-7000-8000-000000000002','40000000-0000-7000-8000-000000000020','40000000-0000-7000-8000-000000000201','test.foreign','{}',repeat('5',64),clock_timestamp()-interval '5 seconds',3,null,null,null,null,0);

create temporary table claim_a on commit drop as
  select * from knowledge_service.claim_outbox('worker-a',1,30000,null);
select extensions.is((select count(*) from claim_a),1::bigint,'first consumer claims one message');
select extensions.is((select id from claim_a),'40000000-0000-7000-8000-000000000301'::uuid,'claim order is deterministic');
create temporary table claim_b on commit drop as
  select * from knowledge_service.claim_outbox('worker-b',1,30000,null);
select extensions.is((select id from claim_b),'40000000-0000-7000-8000-000000000302'::uuid,'second consumer skips the first live claim');
select extensions.is((select delivery_attempts from claim_a),1,'claim increments delivery attempts exactly once');

select extensions.throws_ok(
  $$select knowledge_service.ack_outbox('40000000-0000-7000-8000-000000000301','worker-b',(select claim_token from claim_a))$$,
  '55000',null,'ack is fenced by owner');
select extensions.throws_ok(
  $$update knowledge_service.outbox set event_id='40000000-0000-7000-8000-000000000102' where id='40000000-0000-7000-8000-000000000301'$$,
  '23001',null,'event linkage is immutable');
select extensions.throws_ok(
  $$delete from knowledge_service.operation_event where id='40000000-0000-7000-8000-000000000101'$$,
  '23001',null,'an outbox-linked immutable event cannot be deleted');
select extensions.lives_ok(
  $$select knowledge_service.ack_outbox('40000000-0000-7000-8000-000000000301','worker-a',(select claim_token from claim_a))$$,
  'live owner and token can acknowledge');
select extensions.ok((select published_at is not null from knowledge_service.outbox where id='40000000-0000-7000-8000-000000000301'),'ack records publication');
select extensions.lives_ok(
  $$select knowledge_service.nack_outbox('40000000-0000-7000-8000-000000000302','worker-b',(select claim_token from claim_b),'temporary_failure',60000)$$,
  'live owner can nack with backoff');
select extensions.ok((select claim_token is null and available_at>clock_timestamp() from knowledge_service.outbox where id='40000000-0000-7000-8000-000000000302'),'nack clears ownership and schedules retry');

create temporary table reclaimed on commit drop as
  select * from knowledge_service.claim_outbox('worker-c',10,30000,null);
select extensions.ok(exists(select 1 from reclaimed where id='40000000-0000-7000-8000-000000000303'),'expired claim is reclaimed');
select extensions.throws_ok(
  $$select knowledge_service.ack_outbox('40000000-0000-7000-8000-000000000303','old-worker','40000000-0000-7000-8000-000000000399')$$,
  '55000',null,'expired claim token cannot acknowledge after reclaim');
select extensions.ok((select archived_at is not null from knowledge_service.outbox where id='40000000-0000-7000-8000-000000000304'),'exhausted poison message is archived');
select extensions.ok(not exists(select 1 from reclaimed where id='40000000-0000-7000-8000-000000000401'),'claiming is tenant scoped');

insert into retrieval.retrieval_plan(id,tenant_id,query_intent)
 values('40000000-0000-7000-8000-000000000501','40000000-0000-7000-8000-000000000001','packet materialization');
insert into retrieval.retrieval_run(id,tenant_id,plan_id)
 values('40000000-0000-7000-8000-000000000502','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000501');
insert into retrieval.evidence_packet
 (id,tenant_id,run_id,packet,normalized_query,authorization_context,coverage,abstention,event_ids)
 values('40000000-0000-7000-8000-000000000503','40000000-0000-7000-8000-000000000001','40000000-0000-7000-8000-000000000502',
  '{"schemaVersion":"v1","members":[]}','packet materialization','{"allowed":true}','[]','{"recommended":true}',
  array['40000000-0000-7000-8000-000000000101'::uuid]);
select extensions.ok((select packet_sha256 ~ '^[0-9a-f]{64}$' and normalized_query='packet materialization' from retrieval.evidence_packet where id='40000000-0000-7000-8000-000000000503'),'normalized packet envelope materializes with immutable digest');
select extensions.ok(exists(
  select 1 from pg_constraint where conrelid='retrieval.packet_member'::regclass
    and conname='packet_member_packet_restrict_fk' and confdeltype='r'
),'packet members use RESTRICT parent linkage');

select * from extensions.finish();
rollback;
