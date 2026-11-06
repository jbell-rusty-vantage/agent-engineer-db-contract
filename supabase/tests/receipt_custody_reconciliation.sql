begin;
create extension if not exists pgtap with schema extensions;
set local search_path=public,extensions;
select plan(15);
grant usage on schema extensions to executor_service;
set local app.tenant_id='97000000-0000-4000-8000-000000000001';
-- Scoped synthetic producer lineage, matching the accepted current-schema fixture.
insert into orchestration.mission(id,tenant_id,goal) values('97000000-0000-4000-8000-000000000050',util.current_tenant_id(),'Synthetic isolated receipt custody proof');
insert into orchestration.work_item(id,tenant_id,mission_id,kind) values('97000000-0000-4000-8000-000000000051',util.current_tenant_id(),'97000000-0000-4000-8000-000000000050','build_vectors');
insert into orchestration.attempt(id,tenant_id,work_item_id,attempt_no,agent_deployment_id) values('97000000-0000-4000-8000-000000000052',util.current_tenant_id(),'97000000-0000-4000-8000-000000000051',1,'service:synthetic-receipt-custody-producer');
insert into orchestration.operation_intent(id,tenant_id,intent_type,payload,idempotency_key) values
 ('97000000-0000-4000-8000-000000000010',util.current_tenant_id(),'knowledge_ingestion','{}','receipt-custody-test'),
 ('97000000-0000-4000-8000-000000000011','98000000-0000-4000-8000-000000000001','knowledge_ingestion','{}','receipt-custody-other-tenant');
select lives_ok($q$
 set constraints corpus.entity_created_by_receipt_id_fkey,staging.resolution_decision_receipt_id_fkey,evidence.claim_created_by_receipt_id_fkey,corpus.entity_receipt_tenant deferred;
 insert into corpus.entity(id,kind,display_name,slug,created_by_receipt_id) values('97000000-0000-4000-8000-000000000020','organization','Receipt custody test','receipt-custody-test','97000000-0000-4000-8000-000000000030');
 insert into evidence.claim(id,tenant_id,claim_type,statement,created_by_receipt_id,producer_attempt_id) select '97000000-0000-4000-8000-000000000021',util.current_tenant_id(),code,'Receipt custody claim','97000000-0000-4000-8000-000000000030','97000000-0000-4000-8000-000000000052' from evidence.claim_type order by code limit 1;
 insert into staging.candidate(id,proposed_kind,proposed_payload) values('97000000-0000-4000-8000-000000000022','organization','{}');
 insert into staging.resolution_decision(candidate_id,entity_id,decision,receipt_id) values('97000000-0000-4000-8000-000000000022','97000000-0000-4000-8000-000000000020','create','97000000-0000-4000-8000-000000000030');
 insert into orchestration.operation_receipt(id,intent_id,executor_version,outcome,affected_refs) values('97000000-0000-4000-8000-000000000030','97000000-0000-4000-8000-000000000010','test','applied','[{"schema":"corpus","table":"entity","id":"97000000-0000-4000-8000-000000000020"},{"schema":"evidence","table":"claim","id":"97000000-0000-4000-8000-000000000021"}]');
 set constraints all immediate;
$q$,'apply entity, claim and resolution before inserting the immutable final receipt');
select is((select jsonb_array_length(affected_refs) from orchestration.operation_receipt where id='97000000-0000-4000-8000-000000000030'),2,'final receipt contains actual effects');
select throws_ok($q$update orchestration.operation_receipt set affected_refs='[]' where id='97000000-0000-4000-8000-000000000030'$q$,'23001',null,'final receipt remains immutable');
select throws_ok($q$
 set constraints corpus.entity_created_by_receipt_id_fkey,corpus.entity_receipt_tenant deferred;
 insert into corpus.entity(kind,display_name,slug,created_by_receipt_id) values('organization','Missing receipt','receipt-custody-missing','97000000-0000-4000-8000-000000000099');
 set constraints all immediate;
$q$,'23503',null,'deferred writes cannot commit without their final receipt');
select is((select count(*) from corpus.entity where slug='receipt-custody-missing'),0::bigint,'failed finalization rolls back entity effects');
insert into orchestration.operation_receipt(id,intent_id,executor_version,outcome) values('97000000-0000-4000-8000-000000000031','97000000-0000-4000-8000-000000000011','test','noop');
select throws_ok($q$
 set constraints corpus.entity_created_by_receipt_id_fkey,corpus.entity_receipt_tenant deferred;
 insert into corpus.entity(kind,display_name,slug,created_by_receipt_id) values('organization','Wrong tenant','receipt-custody-cross-tenant','97000000-0000-4000-8000-000000000031');
 set constraints all immediate;
$q$,'P0001','entity/record receipt tenant mismatch','deferred tenant guard rejects cross-tenant receipt');
insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes,storage_state,available_at)
 values('97000000-0000-4000-8000-000000000040',util.current_tenant_id(),'knowledge_ingestion_receipt',repeat('a',64),'ledger','research-ingestion-intents',util.current_tenant_id()::text||'/aa/'||repeat('a',64),'application/json',10,'pending',null);
set local role executor_service;
select throws_ok($q$select orchestration.reconcile_legacy_artifact_custody('97000000-0000-4000-8000-000000000040',null,10,'research-ingestion-intents','97000000-0000-4000-8000-000000000001')$q$,'23514',null,'NULL digest cannot reconcile pending custody');
select throws_ok($q$select orchestration.reconcile_legacy_artifact_custody('97000000-0000-4000-8000-000000000040',repeat('a',64),10,null,'97000000-0000-4000-8000-000000000001')$q$,'23514',null,'NULL bucket cannot reconcile pending custody');
select is((select storage_state from orchestration.artifact where id='97000000-0000-4000-8000-000000000040'),'pending','NULL identity inputs leave original registration pending');
select lives_ok($q$select orchestration.reconcile_legacy_artifact_custody('97000000-0000-4000-8000-000000000040',repeat('a',64),10,'research-ingestion-intents','97000000-0000-4000-8000-000000000001')$q$,'bounded executor reconciles original pending registration');
select is((select storage_state from orchestration.artifact where id='97000000-0000-4000-8000-000000000040'),'available','verified custody transition becomes available');
select lives_ok($q$select orchestration.reconcile_legacy_artifact_custody('97000000-0000-4000-8000-000000000040',repeat('a',64),10,'research-ingestion-intents','97000000-0000-4000-8000-000000000001')$q$,'reconciliation is idempotent');
select throws_ok($q$select orchestration.reconcile_legacy_artifact_custody('97000000-0000-4000-8000-000000000040',repeat('b',64),10,'research-ingestion-intents','97000000-0000-4000-8000-000000000001')$q$,'23514',null,'conflicting digest cannot reconcile');
select throws_ok($q$select orchestration.reconcile_legacy_artifact_custody('97000000-0000-4000-8000-000000000040',repeat('a',64),10,'research-ingestion-intents','98000000-0000-4000-8000-000000000001')$q$,'42501',null,'cross-tenant reconciliation denied');
reset role;
select ok(not has_function_privilege('pipeline_agent','orchestration.reconcile_legacy_artifact_custody(uuid,text,bigint,text,uuid)','EXECUTE'),'reader cannot acknowledge remote custody');
select * from finish();
rollback;
