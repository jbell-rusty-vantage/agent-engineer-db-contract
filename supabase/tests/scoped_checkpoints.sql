begin;
create extension if not exists pgtap with schema extensions;
set local search_path=public,extensions;
select plan(15);
select set_config('app.tenant_id','95000000-0000-4000-8000-000000000001',true);
insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes,storage_state,available_at)
select ('95000000-0000-4000-8000-0000000000'||n)::uuid,util.current_tenant_id(),'workspace_file',repeat(right(n,1),64),'candidate','ai-engineer-cloud-bucket',util.current_tenant_id()::text||'/'||right(n,1)||right(n,1)||'/'||repeat(right(n,1),64),'application/json',10,'available',clock_timestamp() from unnest(array['10','11','12']) n;
select throws_ok($q$insert into knowledge_service.checkpoint_scope(tenant_id,id,scope) values(util.current_tenant_id(),'95000000-0000-4000-8000-000000000020','{}')$q$,'23514',null,'missing scope tenant cannot bypass check');
insert into knowledge_service.checkpoint_scope(tenant_id,id,scope) values(util.current_tenant_id(),'95000000-0000-4000-8000-000000000020',jsonb_build_object('tenantId',util.current_tenant_id(),'runId','run','producerAttemptId','attempt','sessionId','session','sandboxId','sandbox','namespace','root'));
select throws_ok($q$insert into knowledge_service.scoped_checkpoint(tenant_id,id,scope_id,revision,idempotency_key,request_digest,manifest_artifact_id,manifest_handle,mode) values(util.current_tenant_id(),'95000000-0000-4000-8000-000000000030','95000000-0000-4000-8000-000000000020',1,'missing-handle','sha256:'||repeat('a',64),'95000000-0000-4000-8000-000000000010','{}','archive')$q$,'23514',null,'missing manifest handle identity cannot bypass check');
select throws_ok($q$insert into knowledge_service.scoped_checkpoint(tenant_id,id,scope_id,revision,idempotency_key,request_digest,manifest_artifact_id,manifest_handle,mode) values(util.current_tenant_id(),'95000000-0000-4000-8000-000000000030','95000000-0000-4000-8000-000000000020',1,'partial','sha256:'||repeat('a',64),'95000000-0000-4000-8000-000000000010',jsonb_build_object('artifactId','95000000-0000-4000-8000-000000000010','tenantId',util.current_tenant_id()),'archive');set constraints knowledge_service.scoped_checkpoint_complete immediate$q$,'23514',null,'partial checkpoint cannot commit without manifest reference and head');
select lives_ok($q$
 insert into knowledge_service.scoped_checkpoint(tenant_id,id,scope_id,revision,idempotency_key,request_digest,manifest_artifact_id,manifest_handle,mode) values(util.current_tenant_id(),'95000000-0000-4000-8000-000000000030','95000000-0000-4000-8000-000000000020',1,'full','sha256:'||repeat('a',64),'95000000-0000-4000-8000-000000000010',jsonb_build_object('artifactId','95000000-0000-4000-8000-000000000010','tenantId',util.current_tenant_id()),'archive');
 insert into knowledge_service.checkpoint_artifact_reference(tenant_id,checkpoint_id,artifact_id) values(util.current_tenant_id(),'95000000-0000-4000-8000-000000000030','95000000-0000-4000-8000-000000000010');
 update knowledge_service.checkpoint_scope set head_checkpoint_id='95000000-0000-4000-8000-000000000030',revision=1 where tenant_id=util.current_tenant_id();
 set constraints all immediate;
$q$,'full immutable receipt and head commit together');
select throws_ok($q$update knowledge_service.scoped_checkpoint set mode='continuation' where tenant_id=util.current_tenant_id()$q$,'23001',null,'checkpoint receipt is immutable');
select throws_ok($q$update knowledge_service.checkpoint_scope set head_checkpoint_id=null,revision=0 where tenant_id=util.current_tenant_id()$q$,'23514',null,'head cannot move backward');
select throws_ok($q$update orchestration.artifact set custody_registered_at=clock_timestamp()-interval '31 days' where id='95000000-0000-4000-8000-000000000011'$q$,'23001',null,'caller cannot forge registration age');
select throws_ok($q$insert into orchestration.artifact_tombstone(tenant_id,artifact_id,reason) values(util.current_tenant_id(),'95000000-0000-4000-8000-000000000011','expired')$q$,'23514',null,'fresh orphan retains minimum custody period');
-- Disposable-only elapsed-time fixture, guarded by this transaction's exclusive table lock.
-- Re-enable the clock guard before exercising any retirement operation; rollback restores fixture age.
alter table orchestration.artifact disable trigger artifact_registration_clock;
alter table orchestration.artifact disable trigger artifact_immutable;
update orchestration.artifact set custody_registered_at=clock_timestamp()-interval '31 days' where tenant_id=util.current_tenant_id();
alter table orchestration.artifact enable trigger artifact_immutable;
alter table orchestration.artifact enable trigger artifact_registration_clock;
select throws_ok($q$insert into orchestration.artifact_tombstone(tenant_id,artifact_id,reason) values(util.current_tenant_id(),'95000000-0000-4000-8000-000000000010','expired')$q$,'23514','artifact has retained canonical references','historical checkpoint reference retains expired bytes');
select lives_ok($q$insert into orchestration.artifact_tombstone(tenant_id,artifact_id,reason) values(util.current_tenant_id(),'95000000-0000-4000-8000-000000000011','expired')$q$,'expired unreferenced orphan can retire');
select is((select storage_state from orchestration.artifact where id='95000000-0000-4000-8000-000000000011'),'failed','retirement fails closed for existing artifact readers');
select throws_ok($q$update orchestration.artifact set storage_state='available',available_at=clock_timestamp(),registration_error_class=null where id='95000000-0000-4000-8000-000000000011'$q$,'23514',null,'retired logical handle cannot resurrect');
select throws_ok($q$insert into evidence.source_query(tenant_id,provider_code,query_text,purpose,parameters,response_artifact_id) select util.current_tenant_id(),code,'retired','test','{}','95000000-0000-4000-8000-000000000011' from evidence.search_provider order by code limit 1$q$,'23514',null,'canonical cached reference cannot bind retired handle');
select throws_ok($q$delete from knowledge_service.checkpoint_artifact_reference where tenant_id=util.current_tenant_id()$q$,'23001',null,'historical references cannot be silently removed');
select throws_ok($q$delete from orchestration.artifact_tombstone where tenant_id=util.current_tenant_id()$q$,'23001',null,'retirement audit remains immutable');
select * from finish();
rollback;
