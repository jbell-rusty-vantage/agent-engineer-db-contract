begin;
create extension if not exists pgtap with schema extensions;
set local search_path=public,extensions;
select plan(12);
set local app.tenant_id='95000000-0000-4000-8000-000000000001';
insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes,storage_state,available_at,verification_contract_version)
select ('95000000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid,'95000000-0000-4000-8000-000000000001',
 'source_capture',repeat(case when n<4 then n::text else '4' end,64),'source_captures','ai-engineer-cloud-bucket',
 '95000000-0000-4000-8000-000000000001/'||repeat(case when n<4 then n::text else '4' end,2)||'/'||repeat(case when n<4 then n::text else '4' end,64),
 'text/plain',10,'pending',null,'verification.v1' from generate_series(2,5) n;
insert into orchestration.verification_artifact_metadata(tenant_id,artifact_id,producer_activity_id,producer_version,encryption_class,retention_class,data_classification)
select '95000000-0000-4000-8000-000000000001',('95000000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid,
 'test','v1','managed','audit','restricted' from generate_series(2,3) n;
update orchestration.artifact set storage_state='available',available_at=now() where id in('95000000-0000-4000-8000-000000000002','95000000-0000-4000-8000-000000000003');
insert into orchestration.verification_artifact_metadata(tenant_id,artifact_id,producer_activity_id,producer_version,encryption_class,retention_class,data_classification,parent_artifact_ids,transformation_signature,logical_object_key)
select '95000000-0000-4000-8000-000000000001',('95000000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid,
 'test','v1','managed','audit','restricted',array[('95000000-0000-4000-8000-'||lpad((n-2)::text,12,'0'))::uuid],repeat('a',64),'artifacts/local-'||n||'.json' from generate_series(4,5) n;
insert into orchestration.artifact_lineage(tenant_id,from_artifact_id,to_artifact_id,relation_kind,activity_id,activity_version,transformation_signature)
select '95000000-0000-4000-8000-000000000001',('95000000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid,
 ('95000000-0000-4000-8000-'||lpad((n-2)::text,12,'0'))::uuid,'generated','test','v1',repeat('a',64) from generate_series(4,5) n;
set constraints all immediate;
select is((select count(*) from orchestration.artifact where tenant_id=util.current_tenant_id() and sha256=repeat('4',64)),2::bigint,'two logical artifacts share one remote address');
select is((select count(distinct parent_artifact_ids) from orchestration.verification_artifact_metadata where tenant_id=util.current_tenant_id() and logical_object_key is not null),2::bigint,'each logical identity preserves its own parents');
select is((select count(distinct logical_object_key) from orchestration.verification_artifact_metadata where tenant_id=util.current_tenant_id()),2::bigint,'original local keys remain distinct');
select throws_ok($q$update orchestration.verification_artifact_metadata set logical_object_key='rewritten' where artifact_id='95000000-0000-4000-8000-000000000004'$q$,'23001',null,'logical mapping is immutable');
select ok(not orchestration.verification_artifact_is_admitted(util.current_tenant_id(),'95000000-0000-4000-8000-000000000004'),'pending logical artifact is not admitted');
update orchestration.artifact set storage_state='available',available_at=now() where id='95000000-0000-4000-8000-000000000004';
select ok(orchestration.verification_artifact_is_admitted(util.current_tenant_id(),'95000000-0000-4000-8000-000000000004'),'available logical artifact is admitted');
select ok(not orchestration.verification_artifact_is_admitted('96000000-0000-4000-8000-000000000001','95000000-0000-4000-8000-000000000004'),'other tenant cannot adopt logical artifact');
select throws_ok($q$insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes)
 values('95000000-0000-4000-8000-000000000006','95000000-0000-4000-8000-000000000001','source_capture',repeat('4',64),'source_captures','ai-engineer-cloud-bucket','95000000-0000-4000-8000-000000000001/44/'||repeat('4',64),'text/plain',10)$q$,'23505',null,'legacy artifact cannot alias a verification object');
insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes)
 values('95000000-0000-4000-8000-000000000010','95000000-0000-4000-8000-000000000001','source_capture',repeat('7',64),'source_captures','ai-engineer-cloud-bucket','95000000-0000-4000-8000-000000000001/77/'||repeat('7',64),'text/plain',10);
select lives_ok($q$insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes)
 values('95000000-0000-4000-8000-000000000011','95000000-0000-4000-8000-000000000001','source_capture',repeat('7',64),'source_captures','ai-engineer-cloud-bucket','95000000-0000-4000-8000-000000000001/77/'||repeat('7',64),'text/plain',10)
 on conflict(storage_bucket,object_path) where verification_contract_version is null do update set object_path=excluded.object_path$q$,'legacy duplicate reaches its ON CONFLICT handler');
select is((select count(*) from orchestration.artifact where storage_bucket='ai-engineer-cloud-bucket' and object_path='95000000-0000-4000-8000-000000000001/77/'||repeat('7',64)),1::bigint,'legacy duplicate preserves one registration');
select is((select id from orchestration.artifact where storage_bucket='ai-engineer-cloud-bucket' and object_path='95000000-0000-4000-8000-000000000001/77/'||repeat('7',64)),'95000000-0000-4000-8000-000000000010'::uuid,'legacy duplicate retains the original identity');
select throws_ok($q$insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes,verification_contract_version)
 values('95000000-0000-4000-8000-000000000012','95000000-0000-4000-8000-000000000001','source_capture',repeat('7',64),'source_captures','ai-engineer-cloud-bucket','95000000-0000-4000-8000-000000000001/77/'||repeat('7',64),'text/plain',10,'verification.v1')
 on conflict do nothing$q$,'23505',null,'verification cannot alias a legacy object even with ON CONFLICT');
select * from finish();
rollback;
