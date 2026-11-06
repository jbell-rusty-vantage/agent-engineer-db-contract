begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(5);

insert into evaluation.eval_dataset(id,tenant_id,slug,purpose) values
 ('71000000-0000-7000-8000-000000000001','71000000-0000-7000-8000-000000000010','dataset-manifest-test','contract test'),
 ('72000000-0000-7000-8000-000000000001','72000000-0000-7000-8000-000000000010','dataset-manifest-other','contract test');
insert into orchestration.artifact(id,tenant_id,artifact_type,sha256,bucket_class,storage_bucket,object_path,media_type,size_bytes,storage_state,available_at) values
 ('71000000-0000-7000-8000-000000000101','71000000-0000-7000-8000-000000000010','evaluation_dataset_manifest',repeat('a',64),'ledger','test','test/a','application/json',1,'available',now()),
 ('71000000-0000-7000-8000-000000000102','71000000-0000-7000-8000-000000000010','evaluation_case_input',repeat('b',64),'ledger','test','test/b','application/json',1,'available',now()),
 ('72000000-0000-7000-8000-000000000101','72000000-0000-7000-8000-000000000010','evaluation_dataset_manifest',repeat('a',64),'ledger','test','test/c','application/json',1,'available',now());

select extensions.lives_ok($test$
 insert into evaluation.eval_dataset_version(id,tenant_id,dataset_id,version,manifest_sha256,manifest)
 values('71000000-0000-7000-8000-000000000201','71000000-0000-7000-8000-000000000010','71000000-0000-7000-8000-000000000001',1,repeat('0',64),'{}')
$test$,'populated legacy dataset versions remain accepted without verification bindings');
select extensions.lives_ok($test$
 insert into evaluation.eval_dataset_version(id,tenant_id,dataset_id,version,manifest_sha256,manifest,contract_version,manifest_artifact_id,frozen_at,label_provenance,case_count)
 values('71000000-0000-7000-8000-000000000202','71000000-0000-7000-8000-000000000010','71000000-0000-7000-8000-000000000001',2,repeat('a',64),'{}','verification.v1','71000000-0000-7000-8000-000000000101',now(),'agent_generated',1)
$test$,'verification dataset version accepts the exact same-tenant dataset manifest');
select extensions.throws_ok($test$
 insert into evaluation.eval_dataset_version(tenant_id,dataset_id,version,manifest_sha256,manifest,contract_version,manifest_artifact_id,frozen_at,label_provenance,case_count)
 values('71000000-0000-7000-8000-000000000010','71000000-0000-7000-8000-000000000001',3,repeat('b',64),'{}','verification.v1','71000000-0000-7000-8000-000000000102',now(),'agent_generated',1)
$test$,'23503',null,'wrong artifact type is rejected');
select extensions.throws_ok($test$
 insert into evaluation.eval_dataset_version(tenant_id,dataset_id,version,manifest_sha256,manifest,contract_version,manifest_artifact_id,frozen_at,label_provenance,case_count)
 values('71000000-0000-7000-8000-000000000010','71000000-0000-7000-8000-000000000001',4,repeat('c',64),'{}','verification.v1','71000000-0000-7000-8000-000000000101',now(),'agent_generated',1)
$test$,'23503',null,'wrong manifest digest is rejected');
select extensions.throws_ok($test$
 insert into evaluation.eval_dataset_version(tenant_id,dataset_id,version,manifest_sha256,manifest,contract_version,manifest_artifact_id,frozen_at,label_provenance,case_count)
 values('71000000-0000-7000-8000-000000000010','71000000-0000-7000-8000-000000000001',5,repeat('a',64),'{}','verification.v1','72000000-0000-7000-8000-000000000101',now(),'agent_generated',1)
$test$,'23503',null,'cross-tenant manifest artifact is rejected');

select * from extensions.finish();
rollback;
