begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(14);

select extensions.lives_ok($test$
  insert into evidence.source(id,tenant_id,source_class,canonical_url)
  values('10000000-0000-7000-8000-000000000010','10000000-0000-7000-8000-000000000001','web_page','https://contract.test/cross-tenant')
$test$,'same-tenant source fixture is accepted');

select extensions.throws_ok($test$
  insert into content.document(tenant_id,document_kind,canonical_title,canonical_source_id)
  values('20000000-0000-7000-8000-000000000002','documentation','must fail','10000000-0000-7000-8000-000000000010')
$test$,'23503',null,'composite FK rejects a cross-tenant source');

insert into content.document(id,tenant_id,document_kind,canonical_title,created_at) values
 ('10000000-0000-7000-8000-000000000020','10000000-0000-7000-8000-000000000001','documentation','immutable',clock_timestamp()),
 ('10000000-0000-7000-8000-000000000021','10000000-0000-7000-8000-000000000001','documentation','predecessor',clock_timestamp());

select extensions.throws_ok($test$
 update content.document set canonical_title='mutated' where id='10000000-0000-7000-8000-000000000020'
$test$,'23001',null,'content identities are immutable');

select extensions.lives_ok($test$
 insert into content.document(id,tenant_id,document_kind,canonical_title,supersedes_id,created_at)
 values('10000000-0000-7000-8000-000000000022','10000000-0000-7000-8000-000000000001','documentation','successor','10000000-0000-7000-8000-000000000021',clock_timestamp()+interval '1 second')
$test$,'a newer immutable row may supersede its predecessor');

select extensions.throws_ok($test$
 insert into content.document(id,tenant_id,document_kind,canonical_title,supersedes_id,created_at)
 values('10000000-0000-7000-8000-000000000023','10000000-0000-7000-8000-000000000001','documentation','time reversal','10000000-0000-7000-8000-000000000022',clock_timestamp()-interval '1 day')
$test$,'23514',null,'supersession cannot point forward in time');

select extensions.throws_ok(
 $$select ('[' || array_to_string(array_fill(0.0::real,array[1535]),',') || ']')::extensions.halfvec(1536)$$,
 '22000',null,'halfvec rejects 1535 dimensions');
select extensions.throws_ok(
 $$select ('[' || array_to_string(array_fill(0.0::real,array[1537]),',') || ']')::extensions.halfvec(1536)$$,
 '22000',null,'halfvec rejects 1537 dimensions');

reset app.tenant_id;
select extensions.ok(util.current_tenant_id() is null,'missing tenant context fails closed');
select set_config('app.tenant_id','not-a-uuid',true);
select extensions.ok(util.current_tenant_id() is null,'malformed tenant context fails closed');

reset app.tenant_id;
set local role executor_service;
select set_config('app.tenant_id','20000000-0000-7000-8000-000000000002',true);
select count(*) as visible_source_count from evidence.source
where canonical_url='https://contract.test/cross-tenant' \gset
reset role;
select extensions.is(:'visible_source_count'::bigint,0::bigint,'RLS hides another tenant from a bounded role');

select extensions.ok(
 not has_schema_privilege('anon','content','USAGE')
 and not has_schema_privilege('authenticated','knowledge_service','USAGE'),
 'client roles have no direct knowledge schema usage');
select extensions.ok(
 not has_table_privilege('anon','content.document','SELECT')
 and not has_table_privilege('authenticated','retrieval.vector_item_embedding_1536','SELECT'),
 'client roles have no direct content or embedding table grants');
select extensions.ok(exists(
 select 1 from pg_trigger where tgrelid='retrieval.space_publication'::regclass
 and tgname='space_publication_guard' and not tgisinternal
),'publication has a database gate trigger');
select extensions.ok(exists(
 select 1 from pg_constraint where conrelid='knowledge_service.outbox'::regclass and contype='f'
 and pg_get_constraintdef(oid) ilike 'FOREIGN KEY (tenant_id, event_id)%'
),'outbox has a composite tenant-bound foreign key');

select * from extensions.finish();
rollback;
