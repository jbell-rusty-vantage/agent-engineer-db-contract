-- Build 08: the api surface is closed by default, and a signed-in user reads another workspace's works and releases only when
-- the product access model entitles them (migration 20261116120000_build08_api_default_closed.sql).
-- Fixtures are created here and rolled back; the suite passes on an empty installation and on a populated one.
-- Reads made as another role are taken with \gset and asserted after `reset role`, because pgTAP's own tables belong to the
-- role that opened the plan.
begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(52);

\set tenant '00000000-0000-7000-8000-000000000001'
\set user_a 'adc00000-0000-4000-8000-00000000000a'
\set user_b 'adc00000-0000-4000-8000-00000000000b'
\set user_c 'adc00000-0000-4000-8000-00000000000c'
\set claims_a '{"role":"authenticated","sub":"adc00000-0000-4000-8000-00000000000a"}'
\set claims_b '{"role":"authenticated","sub":"adc00000-0000-4000-8000-00000000000b"}'
\set claims_c '{"role":"authenticated","sub":"adc00000-0000-4000-8000-00000000000c"}'
\set software 'adc00000-0000-7000-8000-0000000000d1'
\set release  'adc00000-0000-7000-8000-0000000000d2'
\set claim    'adc00000-0000-7000-8000-0000000000d3'
\set probe    'adc00000-0000-7000-8000-0000000000d4'
\set as_of '2026-11-16T00:00:00Z'

-- SQLSTATE of a statement run as the current role ('ok' when it succeeds).
create function pg_temp.adc_state(p_sql text) returns text language plpgsql as $f$
begin execute p_sql; return 'ok'; exception when others then return sqlstate; end $f$;
-- Every api routine called with null arguments and every api relation read, as the current role: one SQLSTATE each.
create function pg_temp.adc_sweep() returns table(kind text, name text, state text) language plpgsql as $f$
declare r record;
begin
 for r in
  select 'routine'::text k, p.oid::regprocedure::text n,
         format('select * from %s(%s)', p.oid::regproc,
                (select coalesce(string_agg(format('null::%s', pg_catalog.format_type(a.t, null)), ', ' order by a.ord), '') from unnest(p.proargtypes::oid[]) with ordinality a(t, ord))) q
    from pg_proc p where p.pronamespace = 'api'::regnamespace
  union all
  select 'relation', c.oid::regclass::text, format('select 1 from %s limit 1', c.oid::regclass)
    from pg_class c where c.relnamespace = 'api'::regnamespace and c.relkind in ('r','v','m','p')
 loop
  kind := r.k; name := r.n;
  begin execute r.q; state := 'ok'; exception when others then state := sqlstate; end;
  return next;
 end loop;
end $f$;
grant execute on function pg_temp.adc_state(text), pg_temp.adc_sweep() to public;

-- ------------------------------------------------------------------ 1. grants: closed by default
select extensions.is((select coalesce(string_agg(p.oid::regprocedure::text, ', ' order by p.oid::regprocedure::text), '') from pg_proc p
   where p.pronamespace = 'api'::regnamespace
     and exists (select 1 from aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a where a.grantee = 0)),
  '', 'no api routine is executable by PUBLIC (a migration that creates one must revoke it)');
select extensions.is((select coalesce(string_agg(p.oid::regprocedure::text, ', ' order by p.oid::regprocedure::text), '') from pg_proc p
   where p.pronamespace = 'api'::regnamespace and has_function_privilege('anon', p.oid, 'execute')),
  '', 'no api routine is executable by anon');
select extensions.is((select coalesce(string_agg(c.oid::regclass::text, ', ' order by c.oid::regclass::text), '') from pg_class c
   where c.relnamespace = 'api'::regnamespace and c.relkind in ('r','v','m','p','S')
     and (has_table_privilege('anon', c.oid, 'select') or has_table_privilege('anon', c.oid, 'insert') or has_table_privilege('anon', c.oid, 'update') or has_table_privilege('anon', c.oid, 'delete')
          or exists (select 1 from aclexplode(coalesce(c.relacl, acldefault('r', c.relowner))) a where a.grantee = 0))),
  '', 'no api relation grants anything to PUBLIC or anon');
select extensions.cmp_ok((select count(*) from pg_proc p where p.pronamespace = 'api'::regnamespace), '>=', 68::bigint, 'the api schema holds its routines, the nine governed chain writes included (the checks above are not vacuous)');
-- The governed chain writes (20261116130000) change shared knowledge: no API role holds one, directly or through PUBLIC, and
-- each is held by name by at least one bounded service role (supabase/tests/governed_chain_writes.sql has the exact table).
select extensions.is((select coalesce(string_agg(p.proname || case when not exists (select 1 from pg_roles r where r.rolname in ('pipeline_agent','verifier_agent','executor_service','control_plane') and has_function_privilege(r.oid, p.oid, 'execute')) then ' (no bounded role)' else '' end, ', ' order by p.proname)
      filter (where has_function_privilege('anon', p.oid, 'execute') or has_function_privilege('authenticated', p.oid, 'execute') or has_function_privilege('app_reader', p.oid, 'execute')
                 or has_function_privilege('product_api_owner', p.oid, 'execute')
                 or not exists (select 1 from pg_roles r where r.rolname in ('pipeline_agent','verifier_agent','executor_service','control_plane') and has_function_privilege(r.oid, p.oid, 'execute'))), '')
      || ' / ' || count(*)
   from pg_proc p where p.pronamespace = 'api'::regnamespace
    and p.proname in ('record_claim','restate_claim','register_probe','record_probe_run','propose_verdict','record_triage','record_source_assessment','raise_attention_sweep','settle_attention_sweep')),
  ' / 9', 'the nine governed chain writes are held by bounded service roles only: not by anon, a signed-in user, app_reader or the product owner');
-- A view runs the functions it names as the role that reads it: no role may be left with a view it cannot evaluate.
select extensions.is((select coalesce(string_agg(r.rolname || ' reads ' || x.v::regclass || ' without ' || x.f::regprocedure, '; ' order by r.rolname, x.v::regclass::text, x.f::regprocedure::text), '')
   from (select distinct rw.ev_class v, d.refobjid f from pg_depend d join pg_rewrite rw on rw.oid = d.objid join pg_class c on c.oid = rw.ev_class
          where d.classid = 'pg_rewrite'::regclass and d.refclassid = 'pg_proc'::regclass and c.relnamespace = 'api'::regnamespace) x
   cross join pg_roles r
  where r.rolname = any(array['authenticated','service_role','app_reader','pipeline_agent','executor_service','verifier_agent','control_plane','product_api_owner'])
    and has_table_privilege(r.oid, x.v, 'select') and not has_function_privilege(r.oid, x.f, 'execute')),
  '', 'every role that selects an api view can execute every function the view names');
select extensions.ok(has_function_privilege('app_reader', 'api.leaderboard(text, integer)', 'execute') and not has_function_privilege('authenticated', 'api.leaderboard(text, integer)', 'execute'),
  'api.leaderboard, reachable through PUBLIC only before, is granted to the role of its named query and to no API role');
select extensions.ok(has_function_privilege('executor_service', 'api.current_fact_rows()', 'execute')
  and not has_function_privilege('product_api_owner', 'api.current_fact_rows()', 'execute')
  and not has_function_privilege('executor_service', 'api.releases_needing_review()', 'execute')
  and not has_function_privilege('executor_service', 'api.probe_revalidation_due(timestamptz)', 'execute'),
  'a role left out of a grant on purpose no longer gets the function through PUBLIC; grants held by name are kept');
select extensions.is((select count(*) from pg_proc p where p.pronamespace = 'product'::regnamespace and p.proname like 'session_%'
     and (has_function_privilege('anon', p.oid, 'execute') or exists (select 1 from aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a where a.grantee = 0))),
  0::bigint, 'the entitlement checks are not executable by PUBLIC or anon');
select extensions.ok(not has_schema_privilege('authenticated', 'product', 'usage') and not has_schema_privilege('anon', 'product', 'usage')
  and not has_schema_privilege('app_reader', 'product', 'usage'), 'no reading role can name the product schema');
-- The reads the AI Engineer service performs as the caller (ai-engineer-service packages/application/src/knowledge and the
-- product gateway): every one stays granted to authenticated.
select extensions.is((select coalesce(string_agg(f, ', ' order by f), '') from unnest(array[
    'api.knowledge_head()', 'api.what_changed(uuid, bigint, bigint)', 'api.probe_matrix(text)', 'api.attention_due(timestamptz)', 'api.probe_revalidation_due(timestamptz)',
    'api.releases_needing_review()', 'api.changes_since(timestamptz, text[], text[], text[])', 'api.modules_affected_by_release(uuid)', 'api.library_dossier(text)', 'api.entity_card(uuid)',
    'api.fact_locators(uuid, text, text)', 'api.summary_evidence(uuid)',
    'api.search_knowledge(text, extensions.halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamptz, text[], text[], integer, integer, integer, double precision, boolean)',
    'api.product_command(uuid, text, text, uuid, jsonb)', 'api.product_read(uuid, text, jsonb)', 'api.product_scope(text)']) f
   where not has_function_privilege('authenticated', f, 'execute')), '', 'authenticated executes every function the service calls');
select extensions.is((select coalesce(string_agg(v, ', ' order by v), '') from unnest(array['api.claim_candidates', 'api.verified_claims', 'api.claim_verdicts', 'api.claim_restatements',
    'api.claim_conflicts', 'api.source_registry', 'api.source_track_record']) v where not has_table_privilege('authenticated', v, 'select')), '', 'authenticated selects every view the service reads');

-- ------------------------------------------------------------------ 2. anon at run time: every routine and every relation is denied
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select count(*) as anon_probed, count(*) filter (where state = '42501') as anon_denied,
       coalesce(string_agg(name, ', ' order by name) filter (where state <> '42501'), '') as anon_open from pg_temp.adc_sweep() \gset
select pg_temp.adc_state('select api.library_dossier(''langchain'')') as anon_dossier,
       pg_temp.adc_state('select * from api.changes_since(''2026-11-01T00:00:00Z'')') as anon_changes,
       pg_temp.adc_state('select * from api.works_authored') as anon_works,
       pg_temp.adc_state('select * from api.releases_needing_review()') as anon_releases \gset
reset role;
set local request.jwt.claims = '';
select extensions.is(:'anon_open'::text, '', 'anon: no api routine and no api relation answers');
select extensions.is(:'anon_denied'::bigint, (select count(*) from pg_proc p where p.pronamespace = 'api'::regnamespace) + (select count(*) from pg_class c where c.relnamespace = 'api'::regnamespace and c.relkind in ('r','v','m','p')),
  format('anon: permission denied on each of the %s routines and relations probed', :'anon_probed'));
select extensions.is(:'anon_dossier' || ' ' || :'anon_changes' || ' ' || :'anon_works' || ' ' || :'anon_releases', '42501 42501 42501 42501',
  'anon: the library dossier, the change feed, authored works and the release review list are denied');

-- ------------------------------------------------------------------ 3. fixtures: shared knowledge the works bind to
set local app.tenant_id = :'tenant';
insert into orchestration.operation_intent(id, tenant_id, intent_type, schema_version, payload, preconditions, idempotency_key, approval_state, origin_digest, origin_kind)
 values ('adc00000-0000-7000-8000-0000000000e1', :'tenant', 'knowledge_ingestion', 1, '{"label":"api default closed fixture"}', '[]', 'adc-fixture', 'approved', 'sha256:' || repeat('a', 64), 'standalone');
insert into orchestration.operation_receipt(id, intent_id, executor_version, precondition_results, outcome, changes_summary, affected_refs, requires_admission, origin_digest)
 values ('adc00000-0000-7000-8000-0000000000e2', 'adc00000-0000-7000-8000-0000000000e1', 'adc-test', '[]', 'applied', '{}', '[]', false, 'sha256:' || repeat('a', 64));
insert into catalog.entity(id, tenant_id, kind, display_name, slug, attributes, created_by_receipt_id) values
 (:'software', :'tenant', 'library', 'Thornwick Orchestrator', 'adc-thornwick', '{}', 'adc00000-0000-7000-8000-0000000000e2'),
 (:'release', :'tenant', 'library_release', 'Thornwick Orchestrator 9.0.0', 'adc-thornwick-9-0-0', '{"version_label":"9.0.0","released_on":"2099-01-01T00:00:00Z","breaking":true}', 'adc00000-0000-7000-8000-0000000000e2');
select temporal.begin_batch() is not null as batch_open \gset
select temporal.assert_relationship('version_of', :'release', :'software') is not null as related \gset
select temporal.commit_batch('adc00000-0000-7000-8000-0000000000e2', 'adc-fixture-batch', repeat('a', 64), '{"label":"api default closed fixture"}') is not null as batch_sealed \gset
insert into evidence.claim(id, tenant_id, claim_type, statement, producer_origin_digest)
 values (:'claim', :'tenant', 'recommendation', 'thornwick retries are idempotent by default', 'sha256:' || repeat('a', 64));
insert into verification.probe(id, tenant_id, slug, title, hypothesis, kind, designed_by)
 values (:'probe', :'tenant', 'adc-thornwick-retries', 'Thornwick retries', 'retries are idempotent by default', 'static_docs', 'adc-test');
insert into verification.probe_verdict(tenant_id, claim_id, probe_id, verdict, rationale, decided_by, decided_at)
 values (:'tenant', :'claim', :'probe', 'directly_supported', 'fixture: holds before the release', 'adc-test', now() - interval '1 day');
set local app.tenant_id = '';

insert into auth.users(id, instance_id, aud, role, email) values
 (:'user_a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'adc-a@lab.invalid'),
 (:'user_b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'adc-b@lab.invalid'),
 (:'user_c', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'adc-c@lab.invalid');

-- ------------------------------------------------------------------ 4. user A authors a lesson in a shared workspace
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select api.product_command(null, 'create_workspace', 'adc-a-workspace', null, '{"name":"ADC authoring"}') ->> 'workspaceId' as ws_a \gset
select api.product_command(:'ws_a', 'create_work', 'adc-a-lesson', null, jsonb_build_object('kind', 'lesson', 'slug', 'adc-thornwick-retries', 'revision', jsonb_build_object(
   'title', 'Thornwick retries', 'body', '{"formatVersion":1,"blocks":[{"id":"adc00000-0000-4000-8000-0000000000c1","kind":"markdown","content":{"text":"Retries with Thornwick."}}],"metadata":{}}'::jsonb,
   'bindings', jsonb_build_array(jsonb_build_object('local_key', 'thornwick', 'relation', 'uses', 'target', jsonb_build_object('kind', 'entity', 'id', :'software')),
                                 jsonb_build_object('local_key', 'retries-claim', 'relation', 'supports', 'target', jsonb_build_object('kind', 'claim', 'id', :'claim'))))))::text as lesson \gset
reset role;
select (:'lesson'::jsonb ->> 'workId') as work, (:'lesson'::jsonb ->> 'revisionId') as rev1 \gset

-- what each session reads before any release
create function pg_temp.adc_reads(p_work uuid, p_software uuid, p_release uuid) returns jsonb language plpgsql as $f$
begin
 return jsonb_build_object(
  'works', (select count(*) from api.works_authored w where w.work_id = p_work),
  'using', (select count(*) from api.modules_using_software(p_software) m where m.work_id = p_work),
  'affected', (select count(*) from api.modules_affected_by_release(p_release) m where m.work_id = p_work),
  'review', (select count(*) from api.releases_needing_review() r where r.root_work_id = p_work));
end $f$;
grant execute on function pg_temp.adc_reads(uuid, uuid, uuid) to public;

set local role authenticated;
set local request.jwt.claims = :'claims_a';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as a0 \gset
set local request.jwt.claims = :'claims_b';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as b0 \gset
select (select count(*) from api.works_authored w where w.workspace_id = :'ws_a') as b0_workspace_rows \gset
set local app.tenant_id = :'tenant';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as b0_with_tenant \gset
set local app.tenant_id = '';
set local request.jwt.claims = '';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as no_jwt \gset
set local request.jwt.claims = '{"role":"authenticated"}';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as no_subject \gset
set local request.jwt.claims = '{"role":"authenticated","sub":"not-a-uuid"}';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as bad_subject \gset
set local request.jwt.claims = '{"role":"service_role","sub":"adc00000-0000-4000-8000-00000000000a"}';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as wrong_role_claim \gset
reset role;
set local request.jwt.claims = '';
set local app.tenant_id = :'tenant';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as owner0 \gset
set local role app_reader;
select pg_temp.adc_reads(:'work', :'software', :'release')::text as reader0 \gset
reset role;
set local role pipeline_agent;
select pg_temp.adc_reads(:'work', :'software', :'release')::text as pipeline0 \gset
reset role;
set local role verifier_agent;
select pg_temp.adc_reads(:'work', :'software', :'release')::text as verifier0 \gset
reset role;
set local role control_plane;
select pg_temp.adc_reads(:'work', :'software', :'release')::text as control0 \gset
reset role;
set local role executor_service;
select (select count(*) from api.works_authored w where w.work_id = :'work') as executor_works,
       (select count(*) from api.modules_using_software(:'software') m where m.work_id = :'work') as executor_using \gset
reset role;
set local role service_role;
set local request.jwt.claims = '{"role":"service_role"}';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as service0 \gset
reset role;
set local request.jwt.claims = '';
set local app.tenant_id = '';

select extensions.is(:'a0'::jsonb, '{"works":1,"using":1,"affected":1,"review":0}', 'the author reads their own work in the three readers that list head revisions');
select extensions.is(:'b0'::jsonb, '{"works":0,"using":0,"affected":0,"review":0}', 'a signed-in non-member reads none of it');
select extensions.is(:'b0_workspace_rows'::bigint, 0::bigint, 'a signed-in non-member reads no work of that workspace at all');
select extensions.is(:'b0_with_tenant'::jsonb, '{"works":0,"using":0,"affected":0,"review":0}', 'setting app.tenant_id does not entitle a signed-in non-member');
select extensions.is(:'no_jwt'::jsonb, '{"works":0,"using":0,"affected":0,"review":0}', 'role authenticated without a JWT is entitled to nothing');
select extensions.is(:'no_subject'::jsonb, '{"works":0,"using":0,"affected":0,"review":0}', 'role authenticated without a subject is entitled to nothing');
select extensions.is(:'bad_subject'::jsonb, '{"works":0,"using":0,"affected":0,"review":0}', 'role authenticated with a malformed subject is entitled to nothing');
select extensions.is(:'wrong_role_claim'::jsonb, '{"works":0,"using":0,"affected":0,"review":0}', 'role authenticated with another role claim is entitled to nothing');
select extensions.is(:'owner0'::jsonb, '{"works":1,"using":1,"affected":1,"review":0}', 'the database owner reads every work (unchanged)');
select extensions.is(:'reader0'::jsonb, '{"works":1,"using":1,"affected":1,"review":0}', 'app_reader reads every work (unchanged)');
select extensions.is(:'pipeline0'::jsonb, '{"works":1,"using":1,"affected":1,"review":0}', 'pipeline_agent reads every work (unchanged)');
select extensions.is(:'verifier0'::jsonb, '{"works":1,"using":1,"affected":1,"review":0}', 'verifier_agent reads every work (unchanged)');
select extensions.is(:'control0'::jsonb, '{"works":1,"using":1,"affected":1,"review":0}', 'control_plane reads every work (unchanged)');
select extensions.is(:'executor_works'::bigint + :'executor_using'::bigint, 2::bigint, 'executor_service reads every work in the readers it is granted (unchanged)');
select extensions.is(:'service0'::jsonb, '{"works":1,"using":1,"affected":1,"review":0}', 'service_role reads every work (unchanged)');

-- ------------------------------------------------------------------ 5. membership entitles
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select api.product_command(:'ws_a', 'grant_member', 'adc-a-grant-c', null, jsonb_build_object('principal_id', :'user_c', 'role', 'reader')) ->> 'granted' as granted_c \gset
set local request.jwt.claims = :'claims_c';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as c1 \gset
reset role;
select extensions.is(jsonb_build_object('granted', :'granted_c'::boolean) || :'c1'::jsonb, '{"granted":true,"works":1,"using":1,"affected":1,"review":0}', 'a member of the owning workspace reads its works');

-- ------------------------------------------------------------------ 6. a release, and a verdict that changes after it
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select api.product_read(:'ws_a', 'preview_exposure', jsonb_build_object('root_revision_id', :'rev1', 'ceiling', 'named'))::text as exposure \gset
select api.product_command(:'ws_a', 'review_revision', 'adc-a-review', null, jsonb_build_object('work_id', :'work', 'revision_id', :'rev1', 'review',
   jsonb_build_object('reviewType', 'release_review', 'decision', 'approve', 'closure_sha256', :'exposure'::jsonb ->> 'closure_sha256', 'ceiling', 'named', 'audience', 'named'))) ->> 'eventId' as review_event \gset
select api.product_command(:'ws_a', 'freeze_release', 'adc-a-freeze', null, jsonb_build_object('root_revision_id', :'rev1', 'ceiling', 'named', 'approval_event_id', :'review_event'))::text as frozen \gset
reset role;
select (:'frozen'::jsonb ->> 'releaseId') as release_1 \gset
set local app.tenant_id = :'tenant';
insert into verification.probe_verdict(tenant_id, claim_id, probe_id, verdict, rationale, decided_by, decided_at)
 values (:'tenant', :'claim', :'probe', 'contradicted', 'fixture: no longer holds after the release', 'adc-test', clock_timestamp() + interval '1 hour');
select (select count(*) from api.releases_needing_review() r where r.release_id = :'release_1') as owner_review \gset
set local role app_reader;
select (select count(*) from api.releases_needing_review() r where r.release_id = :'release_1') as reader_review \gset
reset role;
set local app.tenant_id = '';
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select (select count(*) from api.releases_needing_review() r where r.release_id = :'release_1') as a_review,
       (select string_agg(r.verdict_at_release || ' -> ' || r.verdict_now, ',') from api.releases_needing_review() r where r.release_id = :'release_1') as a_review_verdicts \gset
set local request.jwt.claims = :'claims_c';
select (select count(*) from api.releases_needing_review() r where r.release_id = :'release_1') as c_review \gset
set local request.jwt.claims = :'claims_b';
select (select count(*) from api.releases_needing_review() r where r.release_id = :'release_1') as b_review,
       (select coalesce(array_agg(distinct r.release_id), '{}')::text from api.releases_needing_review() r) as b_review_ids,
       (select coalesce(array_agg(distinct w.work_id), '{}')::text from api.works_authored w) as b_work_ids \gset
set local app.tenant_id = :'tenant';
select (select count(*) from api.releases_needing_review() r where r.release_id = :'release_1') as b_review_with_tenant \gset
set local app.tenant_id = '';
reset role;
-- on a populated database: whatever the non-member does read, the access model entitles them to it (asked as its owner)
set local role product_api_owner;
select (select count(*) from authoring.release x where x.id = any(:'b_review_ids'::uuid[]) and product.role_in(x.workspace_id, :'user_b') is null) as b_review_foreign,
       (select count(*) from authoring.work w where w.id = any(:'b_work_ids'::uuid[]) and not product.readable_revision(w.head_revision_id, :'user_b')) as b_works_unreadable,
       cardinality(:'b_work_ids'::uuid[]) as b_works_public \gset
reset role;

select extensions.is(:'owner_review'::bigint + :'reader_review'::bigint, 2::bigint, 'the release needs review: the database owner and app_reader both list it (unchanged)');
select extensions.is(:'a_review'::bigint, 1::bigint, 'a member of the owning workspace sees its release needing review');
select extensions.is(:'a_review_verdicts'::text, 'directly_supported -> contradicted', 'with the verdict at release and the verdict now');
select extensions.is(:'c_review'::bigint, 1::bigint, 'so does another member of that workspace');
select extensions.is(:'b_review'::bigint, 0::bigint, 'a signed-in non-member does not see another workspace''s release needing review');
select extensions.is(:'b_review_with_tenant'::bigint, 0::bigint, 'setting app.tenant_id does not show it either');
select extensions.is(:'b_review_foreign'::bigint, 0::bigint, 'a signed-in user sees no release of a workspace they are not a member of, whatever the database holds');
select extensions.is(:'b_works_unreadable'::bigint, 0::bigint,
  format('a signed-in user sees no work whose head revision the access model does not let them read (%s works on public or invited offers are readable here)', :'b_works_public'));

-- ------------------------------------------------------------------ 7. an offered release entitles to the released head revision, not to the review list
insert into storage.objects(bucket_id, name) values ('aieng-workspaces', :'frozen'::jsonb ->> 'objectPath');
set local role service_role;
set local request.jwt.claims = '{"role":"service_role"}';
select api.product_worker('complete_asset', jsonb_build_object('artifact_id', :'frozen'::jsonb ->> 'manifestArtifactId',
   'verified_sha256', (select a.sha256 from orchestration.artifact a where a.id = (:'frozen'::jsonb ->> 'manifestArtifactId')::uuid))) ->> 'state' as manifest_state \gset
reset role;
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select api.product_command(:'ws_a', 'open_distribution', 'adc-a-distribution', null, jsonb_build_object('root_work_id', :'work', 'channel', 'invited', 'title', 'ADC cohort')) ->> 'distributionId' as distribution \gset
select api.product_command(:'ws_a', 'offer_release', 'adc-a-offer', null, jsonb_build_object('distribution_id', :'distribution', 'release_id', :'release_1', 'approval_event_id', :'review_event',
   'terms', '{"study":true,"adapt":"private","redistribute":"none","derived_work":"none","attribution":"BellLabs","updates":"corrections_included","endorsement":"creator"}'::jsonb)) ->> 'offerId' as offer \gset
set local request.jwt.claims = :'claims_b';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as b_uninvited \gset
set local request.jwt.claims = :'claims_a';
select api.product_command(:'ws_a', 'grant_reader', 'adc-a-grant-b', null, jsonb_build_object('distribution_id', :'distribution', 'principal_id', :'user_b')) ->> 'granted' as granted_b \gset
set local request.jwt.claims = :'claims_b';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as b_invited \gset
select (select w.released from api.works_authored w where w.work_id = :'work') as b_sees_released \gset
-- the author moves the head past the release: the reader keeps release 1 through the product path, not the new draft
set local request.jwt.claims = :'claims_a';
select api.product_command(:'ws_a', 'revise_work', 'adc-a-revise', :'rev1', jsonb_build_object('work_id', :'work', 'revision', jsonb_build_object(
   'title', 'Thornwick retries, unreleased draft', 'body', '{"formatVersion":1,"blocks":[{"id":"adc00000-0000-4000-8000-0000000000c1","kind":"markdown","content":{"text":"Draft that is not released."}}],"metadata":{}}'::jsonb,
   'bindings', jsonb_build_array(jsonb_build_object('local_key', 'thornwick', 'relation', 'uses', 'target', jsonb_build_object('kind', 'entity', 'id', :'software')))))) ->> 'revisionId' as rev2 \gset
select pg_temp.adc_reads(:'work', :'software', :'release')::text as a_after_revise \gset
select (select w.title from api.works_authored w where w.work_id = :'work') as a_head_title \gset
set local request.jwt.claims = :'claims_b';
select pg_temp.adc_reads(:'work', :'software', :'release')::text as b_after_revise \gset
select api.product_read(null, 'get_revision', jsonb_build_object('revision_id', :'rev1')) ->> 'title' as b_reads_release_1,
       pg_temp.adc_state(format('select api.product_read(null, ''get_revision'', %L)', jsonb_build_object('revision_id', :'rev2'))) as b_reads_draft \gset
reset role;
set local request.jwt.claims = '';

select extensions.is(:'manifest_state' || ' ' || (:'offer' is not null)::text || ' ' || :'granted_b', 'available true true', 'release 1 is offered on an invited distribution and the non-member is granted as a reader');
select extensions.is(:'b_uninvited'::jsonb, '{"works":0,"using":0,"affected":0,"review":0}', 'an offer the user is not invited to entitles to nothing');
select extensions.is(:'b_invited'::jsonb, '{"works":1,"using":1,"affected":1,"review":0}', 'a release offered to the user entitles them to the work at its released head revision, and not to the review list');
select extensions.ok(:'b_sees_released', 'the row says the head revision is released');
select extensions.is(:'a_after_revise'::jsonb, '{"works":1,"using":1,"affected":1,"review":1}', 'the author still reads the work after revising it');
select extensions.is(:'a_head_title'::text, 'Thornwick retries, unreleased draft', 'at its new head revision');
select extensions.is(:'b_after_revise'::jsonb, '{"works":0,"using":0,"affected":0,"review":0}', 'the reader of release 1 does not read the unreleased head revision');
select extensions.is(:'b_reads_release_1' || ' ' || :'b_reads_draft', 'Thornwick retries P0001', 'the product path agrees: release 1 is readable, the draft is refused');

-- ------------------------------------------------------------------ 8. every read of the service still answers a signed-in user
set local role authenticated;
set local request.jwt.claims = :'claims_b';
select pg_temp.adc_state('select * from api.knowledge_head()') as s_head,
       pg_temp.adc_state(format('select * from api.what_changed(p_entity => %L, p_k1 => 0, p_k2 => 1)', :'software')) as s_changed,
       pg_temp.adc_state('select * from api.probe_matrix(p_probe => ''adc-thornwick-retries'')') as s_matrix,
       pg_temp.adc_state(format('select * from api.attention_due(p_as_of => %L)', :'as_of')) as s_attention,
       pg_temp.adc_state('select * from api.attention_due()') as s_attention_default,
       pg_temp.adc_state(format('select * from api.probe_revalidation_due(p_as_of => %L)', :'as_of')) as s_revalidation,
       pg_temp.adc_state('select * from api.releases_needing_review()') as s_review,
       pg_temp.adc_state('select * from api.changes_since(p_since => ''2026-11-01T00:00:00Z'')') as s_since,
       pg_temp.adc_state(format('select * from api.modules_affected_by_release(p_release => %L)', :'release')) as s_affected,
       pg_temp.adc_state('select api.library_dossier(p_library => ''adc-thornwick'')') as s_dossier,
       pg_temp.adc_state(format('select api.entity_card(p_entity => %L)', :'software')) as s_card,
       pg_temp.adc_state(format('select * from api.fact_locators(p_entity => %L, p_stream_kind => ''price'')', :'software')) as s_locators,
       pg_temp.adc_state(format('select * from api.summary_evidence(p_summary => %L)', :'software')) as s_summary,
       pg_temp.adc_state('select * from api.search_knowledge(p_query => ''thornwick retries'', p_lenses => array[''corpus'',''evidence''], p_limit => 5, p_collapse => true)') as s_search \gset
select pg_temp.adc_state(format('select claim_id, claim_type, statement, status, path, source_role, subjects, document_node_id, document_title from api.claim_candidates where claim_id = %L limit 1', :'claim')) as v_candidates,
       pg_temp.adc_state(format('select receipt_id, use_decision_id, verified_at, executor_version, verdicts from api.verified_claims where claim_id = %L limit 1', :'claim')) as v_verified,
       pg_temp.adc_state(format('select stated_at, quote, stated_by, channel, verdict, probe, review_state, decided_by, decided_at, rationale from api.claim_verdicts where claim_id = %L limit 1', :'claim')) as v_verdicts,
       pg_temp.adc_state(format('select claim_id, statement, status, qualified, dropped, probe, original_claim_id, original_statement, original_status from api.claim_restatements where claim_id = %L or original_claim_id = %L limit 20', :'claim', :'claim')) as v_restatements,
       pg_temp.adc_state(format('select conflict_id, conflict_kind, detected_by, detected_at, first_party_claim_id, first_party_statement, first_party_status, other_claim_id, other_statement, other_status, reconciliation from api.claim_conflicts where first_party_claim_id = %L or other_claim_id = %L limit 20', :'claim', :'claim')) as v_conflicts,
       pg_temp.adc_state('select source_entity_id, source_kind, source, platform, url, topic, as_of, source_role_code, conflict_of_interest, method_disclosure, claims_observed, claims_checked, confirmed, qualified, refuted, self_checked, median_lead_days, noise_ratio, authority_score, recommended_watch_level, current_watch_level, rationale from api.source_registry where source ilike ''thornwick'' order by as_of desc limit 20') as v_registry,
       pg_temp.adc_state('select source_entity_id, source, source_kind, claim_id, statement, status, stated_at, first_party_at, verdict, probe from api.source_track_record where source ilike ''thornwick'' limit 21') as v_track,
       pg_temp.adc_state('select api.product_scope(''read'')') as p_scope,
       pg_temp.adc_state('select api.product_read(null, ''search'', ''{"query":"thornwick"}'')') as p_search \gset
select (select count(*) from api.claim_candidates where claim_id = :'claim') as b_claim_rows,
       (select count(*) from api.claim_verdicts where claim_id = :'claim') as b_verdict_rows,
       (api.entity_card(:'software') -> 'entity' ->> 'display_name') as b_card_name \gset
reset role;
set local request.jwt.claims = '';

select extensions.is(concat_ws(' ', :'s_head', :'s_changed', :'s_matrix', :'s_attention', :'s_attention_default', :'s_revalidation', :'s_review', :'s_since', :'s_affected', :'s_dossier', :'s_card', :'s_locators', :'s_summary', :'s_search'),
  'ok ok ok ok ok ok ok ok ok ok ok ok ok ok', 'signed in: each of the 13 functions the service calls answers, with the arguments it passes');
select extensions.is(concat_ws(' ', :'v_candidates', :'v_verified', :'v_verdicts', :'v_restatements', :'v_conflicts', :'v_registry', :'v_track'),
  'ok ok ok ok ok ok ok', 'signed in: each of the 7 views the service reads answers, with the columns it selects');
select extensions.is(:'p_scope' || ' ' || :'p_search', 'ok ok', 'signed in: the client-grant check and the product search answer');
select extensions.is(:'b_claim_rows'::bigint + :'b_verdict_rows'::bigint, 2::bigint, 'signed in: the shared claim and its latest verdict are still readable by a non-member');
select extensions.is(:'b_card_name'::text, 'Thornwick Orchestrator', 'signed in: a shared entity card is still readable by a non-member');

select * from extensions.finish();
rollback;
