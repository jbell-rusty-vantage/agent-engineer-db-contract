begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(17);

insert into orchestration.artifact
  (id, tenant_id, artifact_type, sha256, bucket_class, storage_bucket, object_path, media_type)
values
  ('60000000-0000-7000-8000-000000000010', '60000000-0000-7000-8000-000000000001',
   'source_capture', repeat('1', 64), 'source_captures', 'source-captures', 'packet-source/tenant-one', 'text/html'),
  ('60000000-0000-7000-8000-000000000020', '60000000-0000-7000-8000-000000000002',
   'source_capture', repeat('2', 64), 'source_captures', 'source-captures', 'packet-source/tenant-two', 'text/html');

insert into content.document (id, tenant_id, document_kind, canonical_title) values
  ('60000000-0000-7000-8000-000000000101', '60000000-0000-7000-8000-000000000001', 'documentation', 'Tenant one source'),
  ('60000000-0000-7000-8000-000000000102', '60000000-0000-7000-8000-000000000002', 'documentation', 'Tenant two source');

insert into content.document_version
  (id, tenant_id, document_id, version_label, manifest_sha256)
values
  ('60000000-0000-7000-8000-000000000111', '60000000-0000-7000-8000-000000000001',
   '60000000-0000-7000-8000-000000000101', 'v1', repeat('3', 64)),
  ('60000000-0000-7000-8000-000000000112', '60000000-0000-7000-8000-000000000002',
   '60000000-0000-7000-8000-000000000102', 'v1', repeat('4', 64));

insert into content.document_representation
  (id, tenant_id, document_version_id, artifact_id, representation_kind,
   representation_class, media_type, content_sha256, acceptance_state, source_native_byte_identical)
values
  ('60000000-0000-7000-8000-000000000121', '60000000-0000-7000-8000-000000000001',
   '60000000-0000-7000-8000-000000000111', '60000000-0000-7000-8000-000000000010',
   'html', 'source_native', 'text/html', repeat('5', 64), 'accepted', true),
  ('60000000-0000-7000-8000-000000000122', '60000000-0000-7000-8000-000000000001',
   '60000000-0000-7000-8000-000000000111', '60000000-0000-7000-8000-000000000010',
   'normalized_text', 'faithful_normalization', 'text/plain', repeat('6', 64), 'accepted', false),
  ('60000000-0000-7000-8000-000000000123', '60000000-0000-7000-8000-000000000001',
   '60000000-0000-7000-8000-000000000111', '60000000-0000-7000-8000-000000000010',
   'semantic', 'semantic_projection', 'application/json', repeat('7', 64), 'accepted', false),
  ('60000000-0000-7000-8000-000000000124', '60000000-0000-7000-8000-000000000001',
   '60000000-0000-7000-8000-000000000111', '60000000-0000-7000-8000-000000000010',
   'html', 'source_native', 'text/html', repeat('8', 64), 'pending', true),
  ('60000000-0000-7000-8000-000000000125', '60000000-0000-7000-8000-000000000001',
   '60000000-0000-7000-8000-000000000111', '60000000-0000-7000-8000-000000000010',
   'html', 'source_native', 'text/html', repeat('9', 64), 'accepted', true),
  ('60000000-0000-7000-8000-000000000126', '60000000-0000-7000-8000-000000000002',
   '60000000-0000-7000-8000-000000000112', '60000000-0000-7000-8000-000000000020',
   'html', 'source_native', 'text/html', repeat('a', 64), 'accepted', true),
  ('60000000-0000-7000-8000-000000000127', '60000000-0000-7000-8000-000000000001',
   '60000000-0000-7000-8000-000000000111', '60000000-0000-7000-8000-000000000010',
   'html', 'source_native', 'text/html', repeat('d', 64), 'accepted', false);

insert into content.document_node
  (id, tenant_id, representation_id, ordinal, stable_local_key, node_kind, inline_text, normalized_content_sha256)
values
  ('60000000-0000-7000-8000-000000000131', '60000000-0000-7000-8000-000000000001',
   '60000000-0000-7000-8000-000000000121', 0, 'section-one', 'section', 'Source section one', repeat('b', 64)),
  ('60000000-0000-7000-8000-000000000132', '60000000-0000-7000-8000-000000000001',
   '60000000-0000-7000-8000-000000000125', 0, 'section-two', 'section', 'Source section two', repeat('c', 64));

insert into retrieval.evidence_packet (id, tenant_id, packet)
values ('60000000-0000-7000-8000-000000000201', '60000000-0000-7000-8000-000000000001', '{"schemaVersion":"v1","members":[]}');

select extensions.has_column(
  'retrieval', 'packet_member', 'source_representation_id',
  'packet members expose a source representation identity');
select extensions.has_column(
  'retrieval', 'packet_member', 'source_document_node_id',
  'packet members expose an optional source section identity');

select extensions.lives_ok($test$
  insert into retrieval.packet_member
    (id, tenant_id, packet_id, source_representation_id, source_document_node_id)
  values
    ('60000000-0000-7000-8000-000000000301', '60000000-0000-7000-8000-000000000001',
     '60000000-0000-7000-8000-000000000201', '60000000-0000-7000-8000-000000000121',
     '60000000-0000-7000-8000-000000000131')
$test$, 'an accepted source-native section is a valid packet member');

select extensions.is(
  (select member_kind from retrieval.packet_member where id = '60000000-0000-7000-8000-000000000301'),
  'source_representation', 'source-only members have a stable generated kind');

select extensions.lives_ok($test$
  insert into retrieval.packet_member
    (id, tenant_id, packet_id, source_representation_id)
  values
    ('60000000-0000-7000-8000-000000000302', '60000000-0000-7000-8000-000000000001',
     '60000000-0000-7000-8000-000000000201', '60000000-0000-7000-8000-000000000122')
$test$, 'an accepted faithful normalization is valid without a section qualifier');

select extensions.throws_ok($test$
  insert into retrieval.packet_member
    (tenant_id, packet_id, source_representation_id)
  values
    ('60000000-0000-7000-8000-000000000001', '60000000-0000-7000-8000-000000000201',
     '60000000-0000-7000-8000-000000000124')
$test$, '23001', null, 'pending source representations fail the evidence gate');

select extensions.throws_ok($test$
  insert into retrieval.packet_member
    (tenant_id, packet_id, source_representation_id)
  values
    ('60000000-0000-7000-8000-000000000001', '60000000-0000-7000-8000-000000000201',
     '60000000-0000-7000-8000-000000000123')
$test$, '23001', null, 'semantic projections are not source-only evidence');

select extensions.throws_ok($test$
  insert into retrieval.packet_member
    (tenant_id, packet_id, source_representation_id)
  values
    ('60000000-0000-7000-8000-000000000001', '60000000-0000-7000-8000-000000000201',
     '60000000-0000-7000-8000-000000000127')
$test$, '23001', null, 'source-native evidence must assert byte identity');

select extensions.throws_ok($test$
  insert into retrieval.packet_member
    (tenant_id, packet_id, source_representation_id, source_document_node_id)
  values
    ('60000000-0000-7000-8000-000000000001', '60000000-0000-7000-8000-000000000201',
     '60000000-0000-7000-8000-000000000121', '60000000-0000-7000-8000-000000000132')
$test$, '23503', null, 'a source section must belong to its representation');

select extensions.throws_ok($test$
  insert into retrieval.packet_member
    (tenant_id, packet_id, source_representation_id)
  values
    ('60000000-0000-7000-8000-000000000001', '60000000-0000-7000-8000-000000000201',
     '60000000-0000-7000-8000-000000000126')
$test$, '23001', null, 'the source representation target is tenant scoped');

select extensions.throws_ok($test$
  insert into retrieval.packet_member
    (tenant_id, packet_id, source_document_node_id)
  values
    ('60000000-0000-7000-8000-000000000001', '60000000-0000-7000-8000-000000000201',
     '60000000-0000-7000-8000-000000000131')
$test$, '23001', null, 'a section cannot exist without its representation target');

select extensions.throws_ok($test$
  update retrieval.packet_member set coverage_role = 'mutated'
   where id = '60000000-0000-7000-8000-000000000301'
$test$, '23001', null, 'source-only packet members remain immutable');

select extensions.ok(exists(
  select 1 from pg_constraint
   where conrelid = 'retrieval.packet_member'::regclass
     and conname = 'packet_member_source_representation_fk'
     and confdeltype = 'r'
), 'source representation linkage is a tenant-composite RESTRICT foreign key');

select extensions.ok(exists(
  select 1 from pg_constraint
   where conrelid = 'retrieval.packet_member'::regclass
     and conname = 'packet_member_source_document_node_fk'
     and confdeltype = 'r'
), 'source section linkage is a tenant-composite RESTRICT foreign key');

select extensions.ok(
  (select relrowsecurity from pg_class where oid = 'retrieval.packet_member'::regclass)
  and exists (
    select 1 from pg_policy
     where polrelid = 'retrieval.packet_member'::regclass
       and polname = 'bounded_role_access'
  ), 'packet-member row-level security remains enabled and tenant-policy backed');

select extensions.ok(
  has_table_privilege('executor_service', 'retrieval.packet_member', 'SELECT')
  and has_table_privilege('executor_service', 'retrieval.packet_member', 'INSERT'),
  'existing bounded service grants cover the additive source columns');

select extensions.is(
  (select count(*)::integer from pg_constraint
    where conrelid='retrieval.packet_member'::regclass and contype='f'
      and conname like 'packet_member_%_tenant_fk'),
  10, 'all claim and canonical packet-member subjects use tenant-composite foreign keys');

select * from extensions.finish();
rollback;
