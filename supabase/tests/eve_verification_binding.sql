begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(5);

select set_config('app.tenant_id','e1000000-0000-7000-8000-000000000001',true);
insert into orchestration.mission(id,tenant_id,slug,goal) values
 ('e1000000-0000-7000-8000-000000000010','e1000000-0000-7000-8000-000000000001','eve-binding-native-sql','Eve binding SQL fixture');
insert into orchestration.work_item(id,tenant_id,mission_id,kind) values
 ('e1000000-0000-7000-8000-000000000020','e1000000-0000-7000-8000-000000000001','e1000000-0000-7000-8000-000000000010',(select code from orchestration.work_item_kind order by code limit 1));
insert into orchestration.agent_session(id,tenant_id,eve_session_id,mission_id,agent_deployment) values
 ('e1000000-0000-7000-8000-000000000030','e1000000-0000-7000-8000-000000000001','eve-native-session','e1000000-0000-7000-8000-000000000010','eve-native-deployment');
insert into orchestration.attempt(id,tenant_id,work_item_id,attempt_no,agent_deployment_id,agent_session_id,eve_turn_ids) values
 ('e1000000-0000-7000-8000-000000000040','e1000000-0000-7000-8000-000000000001','e1000000-0000-7000-8000-000000000020',1,'eve-native-deployment','e1000000-0000-7000-8000-000000000030',array['eve-native-turn']);

select extensions.lives_ok($test$
 insert into knowledge_service.eve_operation_binding(tenant_id,operation_id,idempotency_key,grant_id,use_case,request_sha256,actor_identity,mission_id,work_item_id,attempt_id,agent_deployment_id,capability_version,original_external_execution,issuer,original_key_id,original_jti,original_payload_sha256)
 values('e1000000-0000-7000-8000-000000000001','e1000000-0000-7000-8000-000000000050','eve-native-key','eve-native-grant','verifyClaims',repeat('a',64),'service:e1000000-0000-7000-8000-000000000060:knowledge_api','e1000000-0000-7000-8000-000000000010','e1000000-0000-7000-8000-000000000020','e1000000-0000-7000-8000-000000000040','eve-native-deployment','eve-native.v1','{"runtime":"eve","runId":"eve-native-session:eve-native-turn","sessionId":"eve-native-session","turnId":"eve-native-turn","toolCallId":"tool"}','eve.native','key-1','e1000000-0000-7000-8000-000000000070',repeat('b',64))
$test$,'first immutable Eve binding accepts a tenant-owned attempt chain');

select extensions.lives_ok($test$
 insert into knowledge_service.eve_operation_invocation(tenant_id,operation_id,issuer,key_id,jti,invocation_kind,envelope,envelope_sha256,lineage_sha256,observed_external_execution,issued_at,expires_at)
 values('e1000000-0000-7000-8000-000000000001','e1000000-0000-7000-8000-000000000050','eve.native','key-1','e1000000-0000-7000-8000-000000000070','original','{"payload":{},"signatureBase64":"proof"}',repeat('c',64),repeat('d',64),'{"runtime":"eve","runId":"eve-native-session:eve-native-turn","sessionId":"eve-native-session","turnId":"eve-native-turn","toolCallId":"tool"}',clock_timestamp(),clock_timestamp()+interval '60 seconds')
$test$,'first signed public envelope is retained');

select extensions.lives_ok($test$
 insert into knowledge_service.eve_operation_invocation(tenant_id,operation_id,issuer,key_id,jti,invocation_kind,envelope,envelope_sha256,lineage_sha256,observed_external_execution,issued_at,expires_at)
 values('e1000000-0000-7000-8000-000000000001','e1000000-0000-7000-8000-000000000050','eve.native','key-2','e1000000-0000-7000-8000-000000000071','retry','{"payload":{},"signatureBase64":"proof2"}',repeat('e',64),repeat('d',64),'{"runtime":"eve","runId":"eve-native-session:eve-native-turn","sessionId":"eve-native-session","turnId":"eve-native-turn","toolCallId":"tool"}',clock_timestamp(),clock_timestamp()+interval '60 seconds')
$test$,'new JTI with the same immutable lineage appends a retry invocation');
select extensions.throws_ok($test$
 update knowledge_service.eve_operation_binding set capability_version='tampered' where operation_id='e1000000-0000-7000-8000-000000000050'
$test$,'23001',null,'binding remains append-only');
select extensions.throws_ok($test$
 insert into knowledge_service.eve_operation_invocation(tenant_id,operation_id,issuer,key_id,jti,invocation_kind,envelope,envelope_sha256,lineage_sha256,observed_external_execution,issued_at,expires_at)
 values('e1000000-0000-7000-8000-000000000001','e1000000-0000-7000-8000-000000000050','eve.native','key-1','e1000000-0000-7000-8000-000000000070','retry','{"payload":{},"signatureBase64":"other"}',repeat('f',64),repeat('d',64),'{"runtime":"eve","runId":"eve-native-session:eve-native-turn","sessionId":"eve-native-session","turnId":"eve-native-turn","toolCallId":"tool"}',clock_timestamp(),clock_timestamp()+interval '60 seconds')
$test$,'23505',null,'issuer and JTI cannot be reused with altered data');
select * from extensions.finish();
rollback;
