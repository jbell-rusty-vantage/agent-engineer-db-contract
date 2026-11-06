begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(19);

select extensions.has_table('retrieval','vector_store_lifecycle_event','lifecycle audit ledger exists');
select extensions.trigger_is('retrieval','vector_store','vector_store_configuration_immutable','retrieval','reject_vector_store_identity_mutation','store configuration remains immutable');
select extensions.trigger_is('retrieval','vector_store','vector_store_lifecycle_guard','retrieval','guard_vector_store_lifecycle_transition','lifecycle updates are guarded');
select extensions.trigger_is('retrieval','vector_store_document','vector_store_document_active_parent','retrieval','require_active_vector_store_reference','attachments require an active parent');
select extensions.trigger_is('retrieval','vector_store_ingestion_run','vector_store_ingestion_active_parent','retrieval','require_active_vector_store_reference','ingestion requires an active parent');

insert into knowledge_service.operation(id,tenant_id,operation_kind,idempotency_key,correlation_id,actor_identity,request,request_sha256,status) values
 ('76000000-0000-7000-8000-000000000010','76000000-0000-7000-8000-000000000001','vector_store_create','lifecycle-create-a','76000000-0000-7000-8000-000000000011','service:owner','{}',repeat('a',64),'running'),
 ('76000000-0000-7000-8000-000000000012','76000000-0000-7000-8000-000000000001','vector_store_create','lifecycle-create-b','76000000-0000-7000-8000-000000000013','service:owner','{}',repeat('b',64),'running'),
 ('76000000-0000-7000-8000-000000000014','76000000-0000-7000-8000-000000000001','vector_store_create','lifecycle-create-c','76000000-0000-7000-8000-000000000015','service:owner','{}',repeat('c',64),'running'),
 ('76000000-0000-7000-8000-000000000016','76000000-0000-7000-8000-000000000001','vector_store_create','lifecycle-create-d','76000000-0000-7000-8000-000000000017','service:owner','{}',repeat('d',64),'running'),
 ('76000000-0000-7000-8000-000000000018','76000000-0000-7000-8000-000000000001','vector_store_create','lifecycle-create-e','76000000-0000-7000-8000-000000000019','service:owner','{}',repeat('e',64),'running'),
 ('76000000-0000-7000-8000-000000000020','76000000-0000-7000-8000-000000000001','vector_store_documents','lifecycle-attach','76000000-0000-7000-8000-000000000021','service:owner','{}',repeat('f',64),'running'),
 ('76000000-0000-7000-8000-000000000022','76000000-0000-7000-8000-000000000001','vector_store_ingestion','lifecycle-ingest','76000000-0000-7000-8000-000000000023','service:owner','{}',repeat('1',64),'running');

insert into retrieval.vector_store(id,tenant_id,owner_identity,store_class,slug,name,purpose,visibility,quota_profile,retention_policy,deletion_policy,created_by_operation_id,supersedes_id) values
 ('76000000-0000-7000-8000-000000000030','76000000-0000-7000-8000-000000000001','service:owner','exploratory','lifecycle-a','A','suspension','tenant','{}','{}','{"mode":"tombstone_only","minimumRetentionDays":0}','76000000-0000-7000-8000-000000000010',null),
 ('76000000-0000-7000-8000-000000000031','76000000-0000-7000-8000-000000000001','service:owner','exploratory','lifecycle-retention','Retention','retention','tenant','{}','{}','{"mode":"tombstone_only","minimumRetentionDays":30}','76000000-0000-7000-8000-000000000012',null),
 ('76000000-0000-7000-8000-000000000032','76000000-0000-7000-8000-000000000001','service:owner','exploratory','lifecycle-old','Old','supersession','tenant','{}','{}','{"mode":"tombstone_only","minimumRetentionDays":0}','76000000-0000-7000-8000-000000000014',null),
 ('76000000-0000-7000-8000-000000000033','76000000-0000-7000-8000-000000000001','service:owner','exploratory','lifecycle-successor','Successor','supersession','tenant','{}','{}','{"mode":"tombstone_only","minimumRetentionDays":0}','76000000-0000-7000-8000-000000000016','76000000-0000-7000-8000-000000000032'),
 ('76000000-0000-7000-8000-000000000034','76000000-0000-7000-8000-000000000001','service:owner','exploratory','lifecycle-delete','Delete','deletion','tenant','{}','{}','{"mode":"tombstone_only","minimumRetentionDays":0}','76000000-0000-7000-8000-000000000018',null);
insert into content.document(id,tenant_id,document_kind,canonical_title)
 values('76000000-0000-7000-8000-000000000040','76000000-0000-7000-8000-000000000001','article','Lifecycle fixture');

select set_config('app.tenant_id','76000000-0000-7000-8000-000000000001',true);
create function pg_temp.control_transition(uuid,text,text,text,uuid) returns uuid
language sql security definer set search_path='' as $$
  select retrieval.transition_vector_store_lifecycle($1,$2,$3,$4,$5)
$$;
alter function pg_temp.control_transition(uuid,text,text,text,uuid) owner to control_plane;

select extensions.ok(not has_function_privilege('executor_service','retrieval.transition_vector_store_lifecycle(uuid,text,text,text,uuid)','execute'),
  'executor role cannot execute store lifecycle transitions');

select extensions.lives_ok($test$
 select pg_temp.control_transition('76000000-0000-7000-8000-000000000030','suspended','service:control-plane','maintenance',null)
$test$,'control plane can suspend an active store');
select extensions.results_eq($test$select lifecycle from retrieval.vector_store where id='76000000-0000-7000-8000-000000000030'$test$,array['suspended'],'suspension persists');
select extensions.results_eq($test$select previous_lifecycle||'->'||new_lifecycle from retrieval.vector_store_lifecycle_event where vector_store_id='76000000-0000-7000-8000-000000000030'$test$,array['active->suspended'],'transition appends an audit event');
select extensions.throws_ok($test$
 select pg_temp.control_transition('76000000-0000-7000-8000-000000000030','suspended','service:control-plane','illegal replay',null)
$test$,'55000',null,'same-state transition is rejected');
select extensions.throws_ok($test$
 select pg_temp.control_transition('76000000-0000-7000-8000-000000000031','deleted','service:control-plane','too early',null)
$test$,'55000',null,'minimum retention denies early deletion');
select extensions.throws_ok($test$
 select pg_temp.control_transition('76000000-0000-7000-8000-000000000032','superseded','service:control-plane','missing successor',null)
$test$,'55000',null,'supersession requires an explicit compatible successor');
select extensions.lives_ok($test$
 select pg_temp.control_transition('76000000-0000-7000-8000-000000000032','superseded','service:control-plane','replacement ready','76000000-0000-7000-8000-000000000033')
$test$,'compatible successor permits supersession');
select extensions.throws_ok($test$
 select pg_temp.control_transition('76000000-0000-7000-8000-000000000032','active','service:control-plane','terminal reversal',null)
$test$,'55000',null,'superseded is terminal');
select extensions.lives_ok($test$
 select pg_temp.control_transition('76000000-0000-7000-8000-000000000034','deleted','service:control-plane','retention satisfied',null)
$test$,'tombstone-only store may transition to deleted after retention');
select extensions.throws_ok($test$
 select pg_temp.control_transition('76000000-0000-7000-8000-000000000034','active','service:control-plane','terminal reversal',null)
$test$,'55000',null,'deleted is terminal');
select extensions.throws_ok($test$
 update retrieval.vector_store_lifecycle_event set reason='tampered'
$test$,null,null,'lifecycle events are immutable');
select extensions.throws_ok($test$
 insert into retrieval.vector_store_document(id,tenant_id,vector_store_id,document_id,admission_state,requested_profile,created_by_operation_id)
 values('76000000-0000-7000-8000-000000000041','76000000-0000-7000-8000-000000000001','76000000-0000-7000-8000-000000000030','76000000-0000-7000-8000-000000000040','requested','{}','76000000-0000-7000-8000-000000000020')
$test$,'55000',null,'suspended store rejects document attachment');
select extensions.throws_ok($test$
 insert into retrieval.vector_store_ingestion_run(id,tenant_id,operation_id,vector_store_id,actor_identity,request_sha256,manifest)
 values('76000000-0000-7000-8000-000000000042','76000000-0000-7000-8000-000000000001','76000000-0000-7000-8000-000000000022','76000000-0000-7000-8000-000000000034','service:owner',repeat('2',64),'{}')
$test$,'55000',null,'deleted store rejects ingestion');

select * from extensions.finish();
rollback;
