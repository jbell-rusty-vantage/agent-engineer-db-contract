-- Build 08 D-82: a signed-in PostgREST session reads the deployment's shared knowledge and nothing more
-- (migration 20261115130000_build08_d82_signed_in_knowledge_reads.sql).
-- Fixtures are created here and rolled back. On a populated database (the lab) the same assertions also compare the rows
-- that are already there: a signed-in read must equal the read of a session that sets app.tenant_id.
-- Reads made as another role are taken with \gset and asserted after `reset role`, because pgTAP's own tables belong to the
-- role that opened the plan.
begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(77);

\set tenant '00000000-0000-7000-8000-000000000001'
\set other_tenant 'd0820000-0000-7000-8000-0000000000b2'
\set user_a 'd0820000-0000-4000-8000-00000000000a'
\set user_b 'd0820000-0000-4000-8000-00000000000b'
\set claims_a '{"role":"authenticated","sub":"d0820000-0000-4000-8000-00000000000a"}'
\set claims_b '{"role":"authenticated","sub":"d0820000-0000-4000-8000-00000000000b"}'
\set as_of '2026-11-16T00:00:00Z'
\set since '2026-11-01T00:00:00Z'

-- The resolver as the api views reach it: named by the view's owner, executed by whoever reads the view. API roles cannot name
-- the util schema themselves, and nothing here grants it to them.
create temp view d82_tenant as select util.current_tenant_id() as tenant;
grant select on d82_tenant to public;

-- SQLSTATE of a statement run as the current role ('ok' when it succeeds).
create function pg_temp.d82_state(p_sql text) returns text language plpgsql as $f$
begin execute p_sql; return 'ok'; exception when others then return sqlstate; end $f$;
-- The message of a statement's error ('ok' when it succeeds); product errors carry their code as the message.
create function pg_temp.d82_error(p_sql text) returns text language plpgsql as $f$
begin execute p_sql; return 'ok'; exception when others then return sqlerrm; end $f$;
-- One digest per reader, taken as the current role.
create function pg_temp.d82_digest(p_sql text) returns text language plpgsql as $f$
declare r text; begin
 execute format('select count(*) || '':'' || md5(coalesce(string_agg(md5(t::text), '''' order by md5(t::text)), '''')) from (%s) t', p_sql) into r;
 return r;
end $f$;
create function pg_temp.d82_readers(p_claim uuid, p_entity uuid, p_as_of timestamptz, p_since timestamptz) returns jsonb language plpgsql as $f$
begin
 return jsonb_build_object(
  'knowledge_head', (select knowledge_seq from api.knowledge_head()),
  'verified_claims', pg_temp.d82_digest('select * from api.verified_claims'),
  'claim_candidates', pg_temp.d82_digest('select * from api.claim_candidates'),
  'claim_conflicts', pg_temp.d82_digest('select * from api.claim_conflicts'),
  'claim_verdicts_of_claim', pg_temp.d82_digest(format('select * from api.claim_verdicts where claim_id = %L', p_claim)),
  'verified_verdicts_of_claim', pg_temp.d82_digest(format('select verdicts from api.verified_claims where claim_id = %L', p_claim)),
  'entity_card', pg_temp.d82_digest(format('select api.entity_card(%L) as card where api.entity_card(%L) is not null', p_entity, p_entity)),
  'software_releases', pg_temp.d82_digest('select * from api.software_releases'),
  'probe_revalidation_due', pg_temp.d82_digest(format('select * from api.probe_revalidation_due(%L)', p_as_of)),
  'releases_needing_review', pg_temp.d82_digest('select * from api.releases_needing_review()'),
  'attention_due', pg_temp.d82_digest(format('select * from api.attention_due(%L)', p_as_of)),
  'changes_since', pg_temp.d82_digest(format('select * from api.changes_since(%L)', p_since)));
end $f$;
grant execute on function pg_temp.d82_state(text), pg_temp.d82_error(text), pg_temp.d82_digest(text), pg_temp.d82_readers(uuid, uuid, timestamptz, timestamptz) to public;

-- ------------------------------------------------------------------ 1. tenant resolution, one definition point
-- First of all, before any definer function has resolved a tenant on this connection: a signed-in read through a view. (A
-- resolver that needed the caller's own privilege on schema util passed everywhere else and failed exactly here.)
reset app.tenant_id;
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select pg_temp.d82_state('select tenant from pg_temp.d82_tenant') as first_read \gset
reset role;
set local request.jwt.claims = '';
select extensions.is(:'first_read'::text, 'ok', 'a signed-in read through a view resolves on a fresh connection');
select extensions.ok(not has_schema_privilege('authenticated', 'util', 'usage') and not has_schema_privilege('anon', 'util', 'usage'), 'API roles hold no privilege on schema util');
select extensions.is((select tenant from pg_temp.d82_tenant), null::uuid, 'postgres without app.tenant_id resolves to no tenant (unchanged)');

set local role pipeline_agent;
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as v \gset
set local app.tenant_id = :'other_tenant';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as w \gset
set local app.tenant_id = '';
reset role;
select extensions.is(:'v'::text, 'null', 'pipeline_agent without app.tenant_id resolves to no tenant (unchanged)');
select extensions.is(:'w'::text, :'other_tenant', 'pipeline_agent with app.tenant_id resolves to that tenant (unchanged)');

set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as v \gset
set local request.jwt.claims = :'claims_a';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as w \gset
reset role;
select extensions.is(:'v'::text, 'null', 'anon resolves to no tenant');
select extensions.is(:'w'::text, 'null', 'the anon role resolves to no tenant whatever the claims say');

set local role service_role;
set local request.jwt.claims = '{"role":"service_role"}';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as v \gset
reset role;
select extensions.is(:'v'::text, 'null', 'service_role without app.tenant_id resolves to no tenant (unchanged)');

set local role authenticated;
set local request.jwt.claims = '';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as no_claims \gset
set local request.jwt.claims = '{"role":"authenticated"}';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as no_subject \gset
set local request.jwt.claims = '{"role":"anon","sub":"d0820000-0000-4000-8000-00000000000a"}';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as wrong_role_claim \gset
set local request.jwt.claims = :'claims_a';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as signed_in \gset
set local debug_parallel_query = on;
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as signed_in_parallel \gset
set local debug_parallel_query = off;
set local app.tenant_id = :'other_tenant';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as variable_wins \gset
set local app.tenant_id = '00000000-0000-0000-0000-000000000000';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as nil_variable \gset
set local app.tenant_id = 'not-a-uuid';
select coalesce((select tenant::text from pg_temp.d82_tenant), 'null') as malformed_variable \gset
set local app.tenant_id = '';
reset role;
select extensions.is(:'no_claims'::text, 'null', 'role authenticated without a JWT resolves to no tenant');
select extensions.is(:'no_subject'::text, 'null', 'role authenticated without a subject resolves to no tenant');
select extensions.is(:'wrong_role_claim'::text, 'null', 'role authenticated with another role claim resolves to no tenant');
select extensions.is(:'signed_in'::text, :'tenant', 'a signed-in session without app.tenant_id resolves to the deployment tenant');
select extensions.is(:'signed_in_parallel'::text, :'tenant', 'the same in a parallel worker');
select extensions.is(:'variable_wins'::text, :'other_tenant', 'app.tenant_id still wins when it is set');
select extensions.is(:'nil_variable'::text, 'null', 'a nil app.tenant_id still resolves to no tenant, signed in or not');
select extensions.is(:'malformed_variable'::text, 'null', 'a malformed app.tenant_id still resolves to no tenant, signed in or not');

-- ------------------------------------------------------------------ 2. grants
select extensions.is((select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'api' and c.relkind in ('r','v','m','p') and has_table_privilege('anon', c.oid, 'select')), 0::bigint, 'anon selects no api relation');
select extensions.ok(not has_function_privilege('anon', 'api.search_unified(text, extensions.halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamptz, uuid[], text[], text[], integer, integer, integer, double precision, boolean)', 'execute'),
  'anon cannot execute the scope-taking search');
select extensions.ok(not has_function_privilege('anon', 'api.search_knowledge(text, extensions.halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamptz, text[], text[], integer, integer, integer, double precision, boolean)', 'execute'),
  'anon cannot execute the shared search');
select extensions.ok(not has_function_privilege('authenticated', 'api.search_unified(text, extensions.halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamptz, uuid[], text[], text[], integer, integer, integer, double precision, boolean)', 'execute'),
  'authenticated cannot execute the scope-taking search');
select extensions.ok(has_function_privilege('authenticated', 'api.search_knowledge(text, extensions.halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamptz, text[], text[], integer, integer, integer, double precision, boolean)', 'execute'),
  'authenticated executes the shared search');
select extensions.ok(not has_function_privilege('authenticated', 'api.search_knowledge_1536(uuid, extensions.halfvec, integer)', 'execute')
  and not has_function_privilege('authenticated', 'api.hybrid_knowledge_search_1536(uuid, text, extensions.halfvec, jsonb, integer, integer, integer, text[], uuid[], text[], text[], timestamptz, bigint, smallint, uuid)', 'execute')
  and not has_function_privilege('authenticated', 'api.hybrid_knowledge_search_history_1536(uuid, text, extensions.halfvec, jsonb, integer, integer, integer, bigint, uuid[], timestamptz, timestamptz, timestamptz, uuid)', 'execute'),
  'authenticated cannot execute the per-space-version searches');
select extensions.is((select count(*) from unnest(array['product_api_owner','app_reader','pipeline_agent','verifier_agent','control_plane','executor_service','service_role']) r
   where has_function_privilege(r, 'api.search_unified(text, extensions.halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamptz, uuid[], text[], text[], integer, integer, integer, double precision, boolean)', 'execute')), 7::bigint,
  'the product path and the bounded roles keep the scope-taking search');
select extensions.is((select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where c.relkind in ('r','v','m','p','S') and n.nspname !~ '^pg_' and n.nspname not in ('information_schema','public','auth','storage','realtime','_realtime','extensions','graphql','graphql_public','vault','pgsodium','net','cron','supabase_functions','supabase_migrations','pgbouncer')
     and (has_table_privilege('authenticated', c.oid, 'insert') or has_table_privilege('authenticated', c.oid, 'update') or has_table_privilege('authenticated', c.oid, 'delete') or has_table_privilege('authenticated', c.oid, 'truncate'))),
  0::bigint, 'authenticated holds no write privilege on any relation of this contract');
select extensions.ok(not has_function_privilege('authenticated', 'api.submit_intent(text, jsonb, text, uuid, uuid, jsonb)', 'execute'), 'authenticated cannot submit a knowledge intent');

-- ------------------------------------------------------------------ 3. the product write path does not consult the resolver
select extensions.is((select count(*) from pg_proc p join pg_roles r on r.oid = p.proowner where r.rolname = 'product_api_owner' and p.prosrc ~ 'current_tenant_id'),
  0::bigint, 'no product function reads the session tenant');
select extensions.is((select count(*) from pg_policy p join pg_class c on c.oid = p.polrelid
   where (p.polroles = '{0}' or 'product_api_owner'::regrole::oid = any(p.polroles))
     and (coalesce(pg_get_expr(p.polqual, p.polrelid), '') || coalesce(pg_get_expr(p.polwithcheck, p.polrelid), '')) ~ 'util\.current_tenant_id'
     and (has_table_privilege('product_api_owner', c.oid, 'insert') or has_table_privilege('product_api_owner', c.oid, 'update') or has_table_privilege('product_api_owner', c.oid, 'delete'))),
  0::bigint, 'no row policy on a table the product path writes reads the session tenant');
select extensions.is((select count(*) from pg_trigger t join pg_class c on c.oid = t.tgrelid join pg_proc f on f.oid = t.tgfoid
   where not t.tgisinternal and f.prosrc ~ 'util\.current_tenant_id'
     and (has_table_privilege('product_api_owner', c.oid, 'insert') or has_table_privilege('product_api_owner', c.oid, 'update') or has_table_privilege('product_api_owner', c.oid, 'delete'))),
  0::bigint, 'no trigger on a table the product path writes reads the session tenant');
select extensions.is((select coalesce(string_agg(d.adrelid::regclass::text, ',' order by d.adrelid::regclass::text), '') from pg_attrdef d
   where pg_get_expr(d.adbin, d.adrelid) ~ 'current_tenant_id' and has_table_privilege('product_api_owner', d.adrelid, 'insert')),
  'retrieval.projection_target', 'one column default on a product-writable table reads the session tenant, and retrieval.index_text_item passes the tenant itself');

-- ------------------------------------------------------------------ 4. fixtures: one entity and one claim in each of two tenants
set local app.tenant_id = :'other_tenant';
insert into orchestration.operation_intent(id, tenant_id, intent_type, schema_version, payload, preconditions, idempotency_key, approval_state, origin_digest, origin_kind)
 values ('d0820000-0000-7000-8000-0000000000e1', :'other_tenant', 'knowledge_ingestion', 1, '{"label":"d82 fixture"}', '[]', 'd82-fixture-other', 'approved', 'sha256:' || repeat('b', 64), 'standalone');
insert into orchestration.operation_receipt(id, intent_id, executor_version, precondition_results, outcome, changes_summary, affected_refs, requires_admission, origin_digest)
 values ('d0820000-0000-7000-8000-0000000000e2', 'd0820000-0000-7000-8000-0000000000e1', 'd82-test', '[]', 'applied', '{}', '[]', false, 'sha256:' || repeat('b', 64));
insert into catalog.entity(id, tenant_id, kind, display_name, slug, created_by_receipt_id)
 values ('d0820000-0000-7000-8000-0000000000e3', :'other_tenant', 'organization', 'Quillfeather Other Tenant Org', 'd82-other-tenant-org', 'd0820000-0000-7000-8000-0000000000e2');
insert into evidence.claim(id, tenant_id, claim_type, statement, producer_origin_digest)
 values ('d0820000-0000-7000-8000-0000000000e4', :'other_tenant', 'recommendation', 'quillfeather claim of the other tenant', 'sha256:' || repeat('b', 64));
set local app.tenant_id = :'tenant';
insert into orchestration.operation_intent(id, tenant_id, intent_type, schema_version, payload, preconditions, idempotency_key, approval_state, origin_digest, origin_kind)
 values ('d0820000-0000-7000-8000-0000000000f1', :'tenant', 'knowledge_ingestion', 1, '{"label":"d82 fixture"}', '[]', 'd82-fixture-own', 'approved', 'sha256:' || repeat('d', 64), 'standalone');
insert into orchestration.operation_receipt(id, intent_id, executor_version, precondition_results, outcome, changes_summary, affected_refs, requires_admission, origin_digest)
 values ('d0820000-0000-7000-8000-0000000000f2', 'd0820000-0000-7000-8000-0000000000f1', 'd82-test', '[]', 'applied', '{}', '[]', false, 'sha256:' || repeat('d', 64));
insert into catalog.entity(id, tenant_id, kind, display_name, slug, created_by_receipt_id)
 values ('d0820000-0000-7000-8000-0000000000f3', :'tenant', 'organization', 'Marrowgate Deployment Org', 'd82-deployment-org', 'd0820000-0000-7000-8000-0000000000f2');
insert into evidence.claim(id, tenant_id, claim_type, statement, producer_origin_digest)
 values ('d0820000-0000-7000-8000-0000000000f4', :'tenant', 'recommendation', 'marrowgate ledgers settle through a tessellated quorum', 'sha256:' || repeat('d', 64));
select retrieval.index_text_item('assertions', 'claim', 'd0820000-0000-7000-8000-0000000000f4', 'marrowgate ledgers settle through a tessellated quorum', 'evidence', 2::smallint, 'claim') is not null as indexed \gset

-- The claim whose verdicts are compared: the first verified claim when the database has one, else the fixture claim.
select coalesce((select claim_id from api.verified_claims order by verified_at, claim_id limit 1), 'd0820000-0000-7000-8000-0000000000f4') as claim_x \gset

-- ------------------------------------------------------------------ 5. what each session reads
-- the reference: a database session that sets app.tenant_id, as the pipeline does
select pg_temp.d82_readers(:'claim_x', 'd0820000-0000-7000-8000-0000000000f3', :'as_of', :'since')::text as trusted \gset
select (select count(*) from api.verified_claims) as trusted_verified,
       (select count(*) from api.changes_since(:'since')) as trusted_changes,
       (select count(*) from api.claim_verdicts where claim_id = :'claim_x') as trusted_verdict_rows \gset

-- the other tenant, with its own app.tenant_id (control: the fixture is readable by its tenant, and only by it)
set local role app_reader;
set local app.tenant_id = :'other_tenant';
select (select count(*) from api.entities where id = 'd0820000-0000-7000-8000-0000000000e3') as other_own_entity,
       (select count(*) from api.entities where id = 'd0820000-0000-7000-8000-0000000000f3') as other_sees_deployment_entity,
       (select count(*) from api.claim_candidates where claim_id = 'd0820000-0000-7000-8000-0000000000e4') as other_own_claim \gset
reset role;
set local app.tenant_id = '';

-- postgres without the variable (the psql case D-82 recorded): still nothing
select (select count(*) from api.entities where id = 'd0820000-0000-7000-8000-0000000000f3') as postgres_novar_entity,
       (select count(*) from api.verified_claims) as postgres_novar_verified \gset

-- a signed-in session, no variable
set local role authenticated;
set local request.jwt.claims = :'claims_b';
select pg_temp.d82_readers(:'claim_x', 'd0820000-0000-7000-8000-0000000000f3', :'as_of', :'since')::text as signed_in_readers \gset
select (select count(*) from api.verified_claims) as signed_in_verified,
       (api.entity_card('d0820000-0000-7000-8000-0000000000f3') -> 'entity' ->> 'display_name') as signed_in_card_name,
       (select count(*) from api.claim_candidates where claim_id = 'd0820000-0000-7000-8000-0000000000f4') as signed_in_own_claim,
       (select count(*) from api.entities where id = 'd0820000-0000-7000-8000-0000000000e3') as signed_in_other_entity,
       (api.entity_card('d0820000-0000-7000-8000-0000000000e3') is null) as signed_in_other_card_null,
       (select count(*) from api.claim_candidates where claim_id = 'd0820000-0000-7000-8000-0000000000e4') as signed_in_other_claim,
       (select count(*) from api.resolve_entity('Quillfeather Other Tenant Org') where entity_id = 'd0820000-0000-7000-8000-0000000000e3') as signed_in_other_resolve,
       (select count(*) from api.resolve_entity('Marrowgate Deployment Org') where entity_id = 'd0820000-0000-7000-8000-0000000000f3') as signed_in_own_resolve \gset
-- the same session with the variable set to the deployment tenant, then to the other tenant
set local app.tenant_id = :'tenant';
select pg_temp.d82_readers(:'claim_x', 'd0820000-0000-7000-8000-0000000000f3', :'as_of', :'since')::text as signed_in_with_variable \gset
set local app.tenant_id = :'other_tenant';
select (select count(*) from api.entities where id = 'd0820000-0000-7000-8000-0000000000e3') as signed_in_variable_other_entity \gset
set local app.tenant_id = '';
reset role;

-- anon, no variable
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select pg_temp.d82_state('select * from api.verified_claims') as anon_verified,
       pg_temp.d82_state('select api.entity_card(''d0820000-0000-7000-8000-0000000000f3'')') as anon_card,
       pg_temp.d82_state('select api.knowledge_head()') as anon_head,
       pg_temp.d82_state(format('select * from api.changes_since(%L)', :'since')) as anon_changes,
       pg_temp.d82_state(format('select * from api.probe_revalidation_due(%L)', :'as_of')) as anon_due,
       pg_temp.d82_state('select * from api.releases_needing_review()') as anon_releases \gset
reset role;

select extensions.is(:'other_own_entity'::bigint, 1::bigint, 'control: the other tenant reads its own entity with its app.tenant_id');
select extensions.is(:'other_own_claim'::bigint, 1::bigint, 'control: the other tenant reads its own claim');
select extensions.is(:'other_sees_deployment_entity'::bigint, 0::bigint, 'control: the other tenant does not read the deployment tenant');
select extensions.is(:'postgres_novar_entity'::bigint + :'postgres_novar_verified'::bigint, 0::bigint, 'a database session without app.tenant_id still reads nothing (unchanged)');

select extensions.is(:'signed_in_readers'::jsonb -> 'knowledge_head', :'trusted'::jsonb -> 'knowledge_head', 'signed in: the knowledge head of the deployment tenant');
select extensions.is(:'signed_in_readers'::jsonb -> 'verified_claims', :'trusted'::jsonb -> 'verified_claims',
  format('signed in: verified claims equal the tenant-scoped read (%s rows)', :'trusted_verified'));
select case when :'trusted_verified'::bigint > 0
  then extensions.cmp_ok(:'signed_in_verified'::bigint, '>', 0::bigint, 'signed in: verified claims are readable')
  else extensions.skip('this database holds no verified claim') end;
select extensions.is(:'signed_in_readers'::jsonb -> 'verified_verdicts_of_claim', :'trusted'::jsonb -> 'verified_verdicts_of_claim', 'signed in: the verdicts on a verified claim');
select extensions.is(:'signed_in_readers'::jsonb -> 'claim_verdicts_of_claim', :'trusted'::jsonb -> 'claim_verdicts_of_claim',
  format('signed in: the latest verdict of that claim (%s row)', :'trusted_verdict_rows'));
select extensions.is(:'signed_in_readers'::jsonb -> 'claim_candidates', :'trusted'::jsonb -> 'claim_candidates', 'signed in: claim candidates');
select extensions.is(:'signed_in_readers'::jsonb -> 'claim_conflicts', :'trusted'::jsonb -> 'claim_conflicts', 'signed in: claim conflicts');
select extensions.is(:'signed_in_readers'::jsonb -> 'entity_card', :'trusted'::jsonb -> 'entity_card', 'signed in: an entity card');
select extensions.is(:'signed_in_card_name'::text, 'Marrowgate Deployment Org', 'signed in: the entity card carries the entity');
select extensions.is(:'signed_in_own_claim'::bigint + :'signed_in_own_resolve'::bigint, 2::bigint, 'signed in: a claim and an entity of the deployment tenant are found');
select extensions.is(:'signed_in_readers'::jsonb -> 'software_releases', :'trusted'::jsonb -> 'software_releases', 'signed in: software releases');
select extensions.is(:'signed_in_readers'::jsonb -> 'probe_revalidation_due', :'trusted'::jsonb -> 'probe_revalidation_due', 'signed in: due list, probes to revalidate');
-- since 20261116120000 the release review list is the queue of a workspace's members; this user is a member of none
-- (supabase/tests/api_default_closed.sql covers the member)
select extensions.is(:'signed_in_readers'::jsonb -> 'releases_needing_review', to_jsonb('0:' || md5('')), 'signed in, a member of no workspace: due list, no release needing review');
select extensions.is(:'signed_in_readers'::jsonb -> 'attention_due', :'trusted'::jsonb -> 'attention_due', 'signed in: due list, attention policies');
select extensions.is(:'signed_in_readers'::jsonb -> 'changes_since', :'trusted'::jsonb -> 'changes_since',
  format('signed in: changes since a date (%s rows)', :'trusted_changes'));
select extensions.is(:'signed_in_with_variable'::jsonb - 'releases_needing_review', :'trusted'::jsonb - 'releases_needing_review',
  'with app.tenant_id set, a signed-in session reads the shared knowledge exactly as the session that sets it does');

select extensions.is(:'signed_in_other_entity'::bigint, 0::bigint, 'signed in: another tenant''s entity is not listed');
select extensions.ok(:'signed_in_other_card_null', 'signed in: another tenant''s entity card is not readable');
select extensions.is(:'signed_in_other_claim'::bigint, 0::bigint, 'signed in: another tenant''s claim is not readable');
select extensions.is(:'signed_in_other_resolve'::bigint, 0::bigint, 'signed in: another tenant''s entity does not resolve');
select extensions.is(:'signed_in_variable_other_entity'::bigint, 1::bigint, 'control: only app.tenant_id reaches the other tenant');

select extensions.is(:'anon_verified' || ' ' || :'anon_card' || ' ' || :'anon_head', '42501 42501 42501', 'anon: the views and the granted functions stay denied');
select extensions.is(:'anon_changes' || ' ' || :'anon_due' || ' ' || :'anon_releases', '42501 42501 42501',
  'anon: the tenant-filtered functions PUBLIC could execute before 20261116120000 are denied too');

-- ------------------------------------------------------------------ 6. private passages and the search
insert into auth.users(id, instance_id, aud, role, email) values
 (:'user_a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'd82-a@lab.invalid'),
 (:'user_b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'd82-b@lab.invalid');

-- the product write path, as a signed-in member with no app.tenant_id
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select api.product_command(null, 'ensure_personal_workspace', 'd82-a-workspace', null, '{}') ->> 'workspaceId' as ws_a \gset
select api.product_command(:'ws_a', 'create_work', 'd82-a-note', null,
  '{"kind":"note","slug":"d82-private-note","revision":{"title":"D82 private note","body":{"formatVersion":1,"blocks":[{"id":"d0820000-0000-4000-8000-0000000000c1","kind":"markdown","content":{"text":"zebrafinch quorum ledger is private to workspace A"}}],"metadata":{}}}}')::text as note \gset
select api.product_command(:'ws_a', 'create_work', 'd82-a-note', null,
  '{"kind":"note","slug":"d82-private-note","revision":{"title":"D82 private note","body":{"formatVersion":1,"blocks":[{"id":"d0820000-0000-4000-8000-0000000000c1","kind":"markdown","content":{"text":"zebrafinch quorum ledger is private to workspace A"}}],"metadata":{}}}}') ->> 'replayed' as replayed \gset
reset role;
set local role service_role;
set local request.jwt.claims = '{"role":"service_role"}';
select api.product_worker('index_passages', jsonb_build_object('workspace_id', :'ws_a', 'revision_id', :'note'::jsonb ->> 'revisionId', 'procedure_version', 'd82-test-1',
  'passages', jsonb_build_array(jsonb_build_object('text', 'zebrafinch quorum ledger is private to workspace A', 'locator', jsonb_build_object('schema', 'aieng.locator.v1', 'block', 0))))) ->> 'lens' as indexed_lens \gset
reset role;

select extensions.is((select w.tenant_id::text || ' ' || (select count(*) from authoring.command c where c.actor_id = :'user_a' and c.tenant_id = w.tenant_id)
                        from authoring.work w where w.id = (:'note'::jsonb ->> 'workId')::uuid), :'tenant' || ' 2',
  'product write path: a signed-in member creates a workspace and a note in the deployment tenant, two commands recorded');
select extensions.is(:'replayed'::text, 'true', 'product write path: the same idempotency key replays');
select extensions.is(:'indexed_lens'::text, 'private', 'the note is indexed in the private lens');
select extensions.is((select count(*) from api.search_unified('zebrafinch quorum', null, array['private'], p_workspace_ids => array[:'ws_a']::uuid[]) where lens = 'private'), 1::bigint,
  'a trusted caller still reads the private passage with the workspace it passes (function unchanged)');

set local role authenticated;
set local request.jwt.claims = :'claims_a';
select api.product_read(null, 'search', '{"query":"zebrafinch quorum"}') -> 0 ->> 'label' as member_label \gset
set local request.jwt.claims = :'claims_b';
select jsonb_array_length(api.product_read(null, 'search', '{"query":"zebrafinch quorum"}')) as outsider_hits \gset
select pg_temp.d82_state(format('select * from api.search_unified(''zebrafinch quorum'', null, array[''private''], p_workspace_ids => array[%L]::uuid[])', :'ws_a')) as outsider_scope_search,
       pg_temp.d82_state('select * from api.search_knowledge(''zebrafinch quorum'', p_lenses => array[''private''])') as outsider_private_lens,
       pg_temp.d82_state('select * from api.search_knowledge(''zebrafinch quorum'', p_lenses => array[''corpus'',''ours''])') as outsider_ours_lens,
       pg_temp.d82_state('select * from api.search_knowledge(''zebrafinch quorum'', p_lenses => array[]::text[])') as outsider_no_lens,
       (select count(*) from api.search_knowledge('zebrafinch quorum') where snippet ilike '%zebrafinch%') as outsider_shared_hits_for_private_text,
       (select count(*) from api.search_knowledge('marrowgate tessellated quorum') where lens = 'evidence' and target_id = 'd0820000-0000-7000-8000-0000000000f4') as outsider_evidence_hit,
       (select count(*) from api.search_knowledge('marrowgate tessellated quorum') where lens not in ('corpus','evidence') or workspace_id is not null) as outsider_scoped_rows \gset
reset role;
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select pg_temp.d82_state(format('select * from api.search_unified(''zebrafinch quorum'', null, array[''private''], p_workspace_ids => array[%L]::uuid[])', :'ws_a')) as anon_scope_search,
       pg_temp.d82_state('select * from api.search_knowledge(''marrowgate tessellated quorum'')') as anon_shared_search \gset
reset role;

select extensions.is(:'member_label'::text, 'private_note', 'the member finds the note through the product search');
select extensions.is(:'outsider_hits'::bigint, 0::bigint, 'another signed-in user does not find it through the product search');
select extensions.is(:'outsider_scope_search'::text, '42501', 'another signed-in user cannot pass the workspace id to the scope-taking search');
select extensions.is(:'anon_scope_search'::text, '42501', 'anon cannot pass the workspace id to the scope-taking search');
select extensions.is(:'outsider_private_lens' || ' ' || :'outsider_ours_lens' || ' ' || :'outsider_no_lens', '22023 22023 22023', 'the shared search refuses every lens but corpus and evidence');
select extensions.is(:'outsider_shared_hits_for_private_text'::bigint, 0::bigint, 'the shared search does not return the private passage');
select extensions.ok(:'indexed' and :'outsider_evidence_hit'::bigint = 1, 'the shared search returns a claim of the evidence lens to a signed-in user');
select extensions.is(:'outsider_scoped_rows'::bigint, 0::bigint, 'the shared search returns no workspace-scoped row');
select extensions.is(:'anon_shared_search'::text, '42501', 'anon cannot execute the shared search');

-- ------------------------------------------------------------------ 7. a client grant covers the reads composed outside product_read
-- api.product_scope is the check api.product_read makes; the service calls it before a knowledge read that carries a client token.
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select api.product_command(null, 'create_client_grant', 'd82-grant-read', null, '{"client_kind":"mcp","label":"d82 read","scopes":["read"]}')::text as grant_read \gset
select api.product_command(null, 'create_client_grant', 'd82-grant-learn', null, '{"client_kind":"mcp","label":"d82 learn","scopes":["learn"]}')::text as grant_learn \gset
select jsonb_build_object('x-aieng-client-token', :'grant_read'::jsonb ->> 'token')::text as header_read,
       jsonb_build_object('x-aieng-client-token', :'grant_learn'::jsonb ->> 'token')::text as header_learn \gset
select (api.product_scope('read') ->> 'clientGrantId') is null as no_token \gset
set local request.headers = :'header_read';
select (api.product_scope('read') ->> 'clientGrantId') = (:'grant_read'::jsonb ->> 'grantId') as read_grant_reads,
       pg_temp.d82_error('select api.product_scope(''author'')') as read_grant_authors,
       pg_temp.d82_error('select api.product_scope(''everything'')') as unknown_scope \gset
set local request.headers = :'header_learn';
select pg_temp.d82_error('select api.product_scope(''read'')') as learn_grant_reads \gset
set local request.jwt.claims = :'claims_b';
set local request.headers = :'header_read';
select pg_temp.d82_error('select api.product_scope(''read'')') as foreign_token \gset
set local request.jwt.claims = :'claims_a';
set local request.headers = '';
select api.product_command(null, 'revoke_client_grant', 'd82-grant-revoke', null, jsonb_build_object('grant_id', :'grant_read'::jsonb ->> 'grantId')) ->> 'revoked' as revoked \gset
set local request.headers = :'header_read';
select pg_temp.d82_error('select api.product_scope(''read'')') as revoked_token \gset
set local request.headers = '';
reset role;
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select pg_temp.d82_state('select api.product_scope(''read'')') as anon_scope \gset
reset role;

select extensions.ok(:'no_token', 'without a client token no grant applies');
select extensions.ok(:'read_grant_reads', 'a grant with the read scope passes the read check and is named');
select extensions.is(:'read_grant_authors'::text, 'CLIENT_SCOPE_DENIED', 'a grant without the scope is refused');
select extensions.is(:'unknown_scope'::text, 'VALIDATION', 'an unknown scope is refused');
select extensions.is(:'learn_grant_reads'::text, 'CLIENT_SCOPE_DENIED', 'a grant without the read scope cannot read');
select extensions.is(:'foreign_token'::text, 'CLIENT_GRANT_INVALID', 'another user''s grant is refused');
select extensions.is(:'revoked' || ' ' || :'revoked_token', 'true CLIENT_GRANT_INVALID', 'a revoked grant is refused');
select extensions.is(:'anon_scope'::text, '42501', 'anon cannot execute the check');

select * from extensions.finish();
rollback;
