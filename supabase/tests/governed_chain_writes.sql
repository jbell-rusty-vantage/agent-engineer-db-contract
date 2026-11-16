-- Build 08 (AIDB-2): the governed writes of the research verification chain, run as the bounded roles and never as the
-- database owner, the lines an agent does not cross, and the product owner's row policies
-- (migration 20261116130000_build08_governed_chain_writes.sql).
-- Fixtures are created here and rolled back; the suite passes on an empty installation and on a populated one.
-- A call made as another role is taken with \gset and asserted after `reset role`, because pgTAP's own tables belong to the
-- role that opened the plan. pg_temp.gcw_try returns 'ok' or '<SQLSTATE> <message>': the message of a governed function is
-- its stable error code.
begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(66);

\set tenant        '00000000-0000-7000-8000-000000000001'
\set other_tenant  '9c000000-0000-7000-8000-0000000000ff'
\set fx_intent     '9c000000-0000-7000-8000-000000000001'
\set fx_receipt    '9c000000-0000-7000-8000-000000000002'
\set adm_intent    '9c000000-0000-7000-8000-000000000003'
\set adm_receipt   '9c000000-0000-7000-8000-000000000004'
\set library       '9c000000-0000-7000-8000-000000000010'
\set channel       '9c000000-0000-7000-8000-000000000011'
\set poster        '9c000000-0000-7000-8000-000000000012'
\set fetch_a       '9c000000-0000-7000-8000-000000000020'
\set fetch_b       '9c000000-0000-7000-8000-000000000021'
\set artifact_a    '9c000000-0000-7000-8000-000000000022'
\set artifact_b    '9c000000-0000-7000-8000-000000000023'
\set source_a      '9c000000-0000-7000-8000-000000000024'
\set source_b      '9c000000-0000-7000-8000-000000000025'
\set capture_a     '9c000000-0000-7000-8000-000000000026'
\set capture_b     '9c000000-0000-7000-8000-000000000027'
\set document_a    '9c000000-0000-7000-8000-000000000030'
\set document_b    '9c000000-0000-7000-8000-000000000031'
\set version_a     '9c000000-0000-7000-8000-000000000032'
\set version_b     '9c000000-0000-7000-8000-000000000033'
\set repr_a        '9c000000-0000-7000-8000-000000000034'
\set repr_b        '9c000000-0000-7000-8000-000000000035'
\set node_a        '9c000000-0000-7000-8000-000000000036'
\set node_b        '9c000000-0000-7000-8000-000000000037'
\set policy_watch  '9c000000-0000-7000-8000-000000000040'
\set policy_w0     '9c000000-0000-7000-8000-000000000041'
\set mission_1     '9c000000-0000-7000-8000-000000000050'
\set mission_0     '9c000000-0000-7000-8000-000000000051'
\set verified      '9c000000-0000-7000-8000-000000000060'
\set foreign_claim '9c000000-0000-7000-8000-000000000061'
\set user_a        '9c000000-0000-4000-8000-00000000000a'
\set claims_a      '{"role":"authenticated","sub":"9c000000-0000-4000-8000-00000000000a"}'
\set actor_m1 '{"label":"gcw watch tool","mission_id":"9c000000-0000-7000-8000-000000000050","mc":{"mission_id":"mc-mission-gcw","run_id":"mc-run-gcw-1","operation_id":"op-7","operation_attempt":1,"execution_generation":0,"lane":"deep_agents"}}'
\set actor_m1_retry '{"label":"gcw watch tool","mission_id":"9c000000-0000-7000-8000-000000000050","mc":{"mission_id":"mc-mission-gcw","run_id":"mc-run-gcw-1","operation_id":"op-7","operation_attempt":2,"execution_generation":0,"lane":"deep_agents"}}'
\set actor_m0 '{"label":"gcw watch tool","mission_id":"9c000000-0000-7000-8000-000000000051","mc":{"mission_id":"mc-mission-gcw","run_id":"mc-run-gcw-0","operation_id":"op-1","operation_attempt":1,"execution_generation":0,"lane":"deep_agents"}}'
\set quote_a 'Quillfeather retries a failed route exactly once by default.'
\set statement_a 'The post states that Quillfeather retries a failed route exactly once by default.'
\set statement_r 'Quillfeather retries a failed route exactly once by default (quillfeather 2.0.0).'
\set statement_c 'Quillfeather drops the request body on a retry.'
\set statement_l 'A live model picks the Quillfeather fallback route in most runs.'

create function pg_temp.gcw_try(p_sql text) returns text language plpgsql as $f$
begin execute p_sql; return 'ok'; exception when others then return sqlstate || ' ' || sqlerrm; end $f$;
grant execute on function pg_temp.gcw_try(text) to public;

-- ------------------------------------------------------------------ 1. the surface: who may call what, and what the code can do
select extensions.is((select coalesce(string_agg(p.proname || case when not p.prosecdef then ' not definer' else '' end
        || case when p.proconfig is distinct from array['search_path=""'] then ' search_path' else '' end
        || case when r.rolsuper then ' superuser-owned' else '' end
        || case when p.proowner <> (select s.proowner from pg_proc s where s.oid = 'api.submit_intent(text,jsonb,text,uuid,uuid,jsonb)'::regprocedure) then ' other owner' else '' end, ', ' order by p.proname)
      filter (where not p.prosecdef or p.proconfig is distinct from array['search_path=""'] or r.rolsuper
              or p.proowner <> (select s.proowner from pg_proc s where s.oid = 'api.submit_intent(text,jsonb,text,uuid,uuid,jsonb)'::regprocedure)), '')
      || ' / ' || count(*)
   from pg_proc p join pg_roles r on r.oid = p.proowner
  where p.pronamespace = 'api'::regnamespace and p.proname in ('record_claim','restate_claim','register_probe','record_probe_run','propose_verdict','record_triage','record_source_assessment','raise_attention_sweep','settle_attention_sweep')),
  ' / 9', 'nine governed write functions: security definer, empty search_path, owned by the non-superuser owner of the knowledge api');
select extensions.is((select string_agg(x.fn || ':' || x.roles, ' ' order by x.fn) from (
    select p.proname fn, coalesce((select string_agg(g.rolname, ',' order by g.rolname) from aclexplode(p.proacl) a join pg_roles g on g.oid = a.grantee
                                    where a.privilege_type = 'EXECUTE' and a.grantee <> p.proowner), '-') roles
      from pg_proc p where p.pronamespace = 'api'::regnamespace
       and p.proname in ('record_claim','restate_claim','register_probe','record_probe_run','propose_verdict','record_triage','record_source_assessment','raise_attention_sweep','settle_attention_sweep')) x),
  'propose_verdict:control_plane,pipeline_agent,verifier_agent raise_attention_sweep:control_plane,pipeline_agent record_claim:executor_service,pipeline_agent '
  || 'record_probe_run:control_plane,pipeline_agent,verifier_agent record_source_assessment:control_plane,pipeline_agent,verifier_agent '
  || 'record_triage:control_plane,pipeline_agent,verifier_agent register_probe:control_plane,pipeline_agent,verifier_agent '
  || 'restate_claim:executor_service,pipeline_agent settle_attention_sweep:control_plane,pipeline_agent',
  'each function is granted by name to the bounded roles that hold the table write, and to nobody else (not PUBLIC, anon, authenticated, app_reader)');
select extensions.is((select coalesce(string_agg(p.oid::regprocedure::text || ' by ' || r.rolname, '; ' order by p.oid::regprocedure::text, r.rolname), '')
   from pg_proc p cross join pg_roles r
  where p.pronamespace = 'verification'::regnamespace and (p.proname like 'chain\_%' or p.proname = 'guard_human_judgment')
    and r.rolname in ('anon','authenticated','service_role','app_reader','pipeline_agent','verifier_agent','executor_service','control_plane','product_api_owner')
    and (has_function_privilege(r.oid, p.oid, 'execute')
         or exists (select 1 from aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a where a.grantee = 0))), '',
  'the helpers behind the functions are callable by no bounded role and not by PUBLIC');
-- What the code of the governed functions can do, read from their source: nothing is deleted; the only rows changed in place
-- are a sweep (settled once) and a claim's status, and the only status ever set is disputed; the immutable and admitted
-- tables are not named.
select extensions.is((select coalesce(string_agg(p.oid::regproc::text, ', ' order by p.oid::regproc::text), '') from pg_proc p
  where (p.pronamespace = 'api'::regnamespace and p.proname in ('record_claim','restate_claim','register_probe','record_probe_run','propose_verdict','record_triage','record_source_assessment','raise_attention_sweep','settle_attention_sweep')
         or p.pronamespace = 'verification'::regnamespace and p.proname like 'chain\_%')
    and (p.prosrc ~* '\mdelete\s+from\M' or p.prosrc ~* '\mtruncate\M'
         or p.prosrc ~* '(retrieval\.vector_item|verification\.use_admission|knowledge_verification\.|record_admitted_claim_verification)'
         or exists (select 1 from regexp_matches(p.prosrc, '\mupdate\s+([a-z_]+\.[a-z_]+)', 'gi') m where lower(m[1]) not in ('acquisition.attention_sweep', 'evidence.claim'))
         or exists (select 1 from regexp_matches(p.prosrc, '\mset\s+status\s*=\s*''([a-z_]+)''', 'gi') m where lower(m[1]) <> 'disputed')
         or exists (select 1 from regexp_matches(p.prosrc, 'insert\s+into\s+(verification\.probe_verdict|verification\.claim_triage)[^;]*', 'gi') m where m[1] is not null)
            and p.prosrc !~ '''agent_proposed''')), '',
  'no governed function deletes, sets a status other than disputed, or names the vector items, the admissions or the verification component');
select extensions.is((select count(*) from pg_trigger t
   where not t.tgisinternal and t.tgenabled = 'O'
     and (t.tgrelid::regclass::text, t.tgname) in (
       ('verification.probe_verdict', 'probe_verdict_human_judgment'), ('verification.claim_triage', 'claim_triage_human_judgment'), ('evidence.source_assessment', 'source_assessment_human_judgment'),
       ('verification.probe_verdict', 'probe_verdict_append_only'), ('verification.claim_triage', 'claim_triage_append_only'), ('evidence.source_assessment', 'source_assessment_append_only'),
       ('retrieval.vector_item', 'vector_item_immutable'), ('verification.use_admission', 'use_admission_immutable'), ('orchestration.operation_receipt', 'operation_receipt_immutable'),
       ('evidence.locator', 'locator_immutable'), ('evidence.claim_evidence_link', 'claim_evidence_link_immutable'), ('evidence.claim', 'claim_verified_gate'))),
  12::bigint, 'the guards on the tables are in place: human judgment, append-only, immutable rows, the verified gate');
select extensions.is((select coalesce(string_agg(r.rolname || ' ' || c.oid::regclass, ', ' order by r.rolname, c.oid::regclass::text), '') from pg_class c cross join pg_roles r
  where c.oid in ('verification.probe_verdict'::regclass, 'verification.claim_triage'::regclass, 'evidence.source_assessment'::regclass, 'verification.use_admission'::regclass, 'orchestration.operation_receipt_target'::regclass)
    and r.rolname in ('pipeline_agent','verifier_agent','executor_service','control_plane','app_reader','authenticated','anon')
    and (has_table_privilege(r.oid, c.oid, 'update') or has_table_privilege(r.oid, c.oid, 'delete') or has_table_privilege(r.oid, c.oid, 'truncate'))), '',
  'no bounded role may update or delete a verdict, a triage row, an assessment, an admission or a receipt target');
-- A human release review is a product command of a signed-in person.
select extensions.is((select coalesce(string_agg(r.rolname || ' ' || x.what, ', ' order by r.rolname, x.what), '') from pg_roles r cross join lateral (
     select c.oid::regclass::text what from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where c.relkind in ('r','p') and n.nspname in ('authoring','curriculum','learning','library','conversation','access','inquiry','dataset')
        and (has_table_privilege(r.oid, c.oid, 'insert') or has_table_privilege(r.oid, c.oid, 'update') or has_table_privilege(r.oid, c.oid, 'delete'))
     union all
     select p.oid::regprocedure::text from pg_proc p where p.pronamespace = 'api'::regnamespace and p.proname in ('product_command','product_worker') and has_function_privilege(r.oid, p.oid, 'execute')) x
  where r.rolname in ('pipeline_agent','verifier_agent','executor_service','control_plane','app_reader')), '',
  'no agent role can write a product table or call the product commands (a release review is recorded by a signed-in person)');

-- ------------------------------------------------------------------ 2. fixtures, written as the database owner
set local app.tenant_id = :'tenant';
insert into orchestration.operation_intent(id, tenant_id, intent_type, schema_version, payload, preconditions, idempotency_key, approval_state, origin_digest, origin_kind)
 values (:'fx_intent', :'tenant', 'knowledge_ingestion', 1, '{"label":"governed chain fixture"}', '[]', 'gcw-fixture', 'approved', 'sha256:' || repeat('c', 64), 'standalone'),
        (:'adm_intent', :'tenant', 'claim_verification', 1, '{"label":"governed chain fixture: admitted"}', '[]', 'gcw-fixture-admitted', 'approved', 'sha256:' || repeat('d', 64), 'standalone');
insert into orchestration.operation_receipt(id, intent_id, executor_version, precondition_results, outcome, changes_summary, affected_refs, requires_admission, origin_digest)
 values (:'fx_receipt', :'fx_intent', 'gcw-test', '[]', 'applied', '{}', '[]', false, 'sha256:' || repeat('c', 64));
-- an admission-bound receipt: the verified gate accepts its claim; the deferred commit check never runs in a rolled-back suite
insert into orchestration.operation_receipt(id, intent_id, executor_version, outcome, requires_admission, use_decision_id, bound_effect_digest, origin_digest)
 values (:'adm_receipt', :'adm_intent', 'gcw-test', 'applied', true, 'ud-gcw-fixture', 'sha256:' || repeat('e', 64), 'sha256:' || repeat('d', 64));
insert into catalog.entity(id, tenant_id, kind, display_name, slug, attributes, created_by_receipt_id) values
 (:'library', :'tenant', 'library', 'Quillfeather Router', 'gcw-quillfeather', '{}', :'fx_receipt'),
 (:'channel', :'tenant', 'source_channel', 'Quillfeather forum', 'gcw-quillfeather-forum', '{"platform":"web","channel_kind":"forum","url":"https://forum.quillfeather.invalid"}', :'fx_receipt'),
 (:'poster', :'tenant', 'community_actor', 'gcw-poster', 'gcw-poster', '{"platform":"web","handle":"gcw-poster"}', :'fx_receipt');
insert into acquisition.fetch(id, tenant_id, origin_kind, origin_label, tool, request_url, outcome, content_sha256, media_type, completed_at) values
 (:'fetch_a', :'tenant', 'native_harness', 'gcw fixture', 'http', 'https://forum.quillfeather.invalid/t/1', 'captured', repeat('a', 64), 'text/markdown', now()),
 (:'fetch_b', :'tenant', 'native_harness', 'gcw fixture', 'other', 'urn:gcw:probe:retries', 'captured', repeat('b', 64), 'application/json', now());
insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at) values
 (:'artifact_a', :'tenant', 'source_capture', 1, repeat('a', 64), 'source_captures', 'gcw-sources', :'tenant' || '/sha256/' || repeat('a', 64), 'text/markdown', 100, 'available', now()),
 (:'artifact_b', :'tenant', 'source_capture', 1, repeat('b', 64), 'source_captures', 'gcw-sources', :'tenant' || '/sha256/' || repeat('b', 64), 'application/json', 100, 'available', now());
insert into evidence.source(id, tenant_id, source_class, canonical_url, publisher, channel_entity_id) values
 (:'source_a', :'tenant', 'web_page', 'https://forum.quillfeather.invalid/t/1', 'Quillfeather forum', :'channel'),
 (:'source_b', :'tenant', 'other', 'urn:gcw:probe:retries', 'gcw probes', null);
insert into evidence.source_capture(id, tenant_id, source_id, artifact_id, content_sha256, media_type, capture_method, capture_method_version, request_url, acquisition_fetch_id) values
 (:'capture_a', :'tenant', :'source_a', :'artifact_a', repeat('a', 64), 'text/markdown', 'native_harness_http', '0.4', 'https://forum.quillfeather.invalid/t/1', :'fetch_a'),
 (:'capture_b', :'tenant', :'source_b', :'artifact_b', repeat('b', 64), 'application/json', 'probe_execution', '0.4', 'urn:gcw:probe:retries', :'fetch_b');
insert into content.document(id, tenant_id, document_type_code, canonical_title, canonical_source_id) values
 (:'document_a', :'tenant', 'official_docs_page', 'GCW fixture: forum thread', :'source_a'),
 (:'document_b', :'tenant', 'official_docs_page', 'GCW fixture: probe report', :'source_b');
insert into content.document_version(id, tenant_id, document_id, version_label, manifest_sha256) values
 (:'version_a', :'tenant', :'document_a', 'gcw-1', repeat('a', 64)), (:'version_b', :'tenant', :'document_b', 'gcw-1', repeat('b', 64));
insert into content.document_representation(id, tenant_id, document_version_id, artifact_id, representation_kind, representation_class, media_type, content_sha256, acceptance_state) values
 (:'repr_a', :'tenant', :'version_a', :'artifact_a', 'markdown', 'structural_extraction', 'text/markdown', repeat('a', 64), 'accepted'),
 (:'repr_b', :'tenant', :'version_b', :'artifact_b', 'json', 'structural_extraction', 'application/json', repeat('b', 64), 'accepted');
insert into content.document_version_source_capture(tenant_id, document_version_id, source_capture_id, capture_role, identity_confidence) values
 (:'tenant', :'version_a', :'capture_a', 'primary', 1), (:'tenant', :'version_b', :'capture_b', 'primary', 1);
insert into content.document_node(id, tenant_id, representation_id, ordinal, stable_local_key, unit_kind, inline_text, normalized_content_sha256) values
 (:'node_a', :'tenant', :'repr_a', 0, 'post-1', 'paragraph', 'gcw-poster wrote: ' || :'quote_a' || '  It also' || chr(8217) || 's documented nowhere.', repeat('a', 64)),
 (:'node_b', :'tenant', :'repr_b', 0, 'run-D1', 'paragraph', 'Probe GCW in cell D1: quillfeather 2.0.0. Checks: {"retries_once": true}. Outcome pass.', repeat('b', 64));
insert into orchestration.mission(id, tenant_id, slug, goal, budget_cost_usd) values
 (:'mission_1', :'tenant', 'gcw-watch', 'governed chain suite: a watch with a budget', 1.00),
 (:'mission_0', :'tenant', 'gcw-watch-no-budget', 'governed chain suite: a watch whose budget is spent', 0);
insert into acquisition.attention_policy(id, tenant_id, slug, title, scope_kind, channel_entity_ids, subject_entity_ids, watch_level, cadence, budget_usd_per_run, rationale, decided_by, state) values
 (:'policy_watch', :'tenant', 'gcw-forum-weekly', 'GCW forum weekly', 'channel', array[:'channel'::uuid], array[:'library'::uuid], 'W2', 'P7D', 0.10, 'fixture', 'human:fixture owner', 'active'),
 (:'policy_w0', :'tenant', 'gcw-ignored', 'GCW ignored channel', 'channel', array[:'channel'::uuid], array[:'library'::uuid], 'W0', null, 0, 'fixture: registered, never swept', 'human:fixture owner', 'paused');
insert into evidence.claim(id, tenant_id, claim_type, statement, status, producer_origin_digest, created_by_receipt_id)
 values (:'verified', :'tenant', 'assertion', 'Quillfeather 2.0.0 logs every retry.', 'verified', 'sha256:' || repeat('d', 64), :'adm_receipt');
insert into evidence.claim(id, tenant_id, claim_type, statement, producer_origin_digest)
 values (:'foreign_claim', :'other_tenant', 'assertion', 'A claim of another tenant.', 'sha256:' || repeat('f', 64));
select (select count(*) from evidence.claim) as claims_before, (select count(*) from verification.probe_verdict) as verdicts_before \gset

-- ------------------------------------------------------------------ 3. the chain, end to end, as the bounded roles
-- 3.1 a claim with its evidence (pipeline_agent)
set local role pipeline_agent;
select api.record_claim('gcw-claim-1', 'assertion', :'statement_a',
   jsonb_build_array(jsonb_build_object('capture_id', :'capture_a', 'node_id', :'node_a', 'quote', :'quote_a')),
   jsonb_build_array(:'library'), jsonb_build_array(jsonb_build_object('entity_id', :'poster')),
   '{"path":"community_thread","source_role":"community","stated_at":"2026-11-10"}', '{"label":"gcw extractor"}')::text as r_claim \gset
select api.record_claim('gcw-claim-1', 'assertion', :'statement_a',
   jsonb_build_array(jsonb_build_object('capture_id', :'capture_a', 'node_id', :'node_a', 'quote', :'quote_a')),
   jsonb_build_array(:'library'), jsonb_build_array(jsonb_build_object('entity_id', :'poster')),
   '{"path":"community_thread","source_role":"community","stated_at":"2026-11-10"}', '{"label":"gcw extractor"}')::text as r_claim_again \gset
select api.record_claim('gcw-claim-1-other-key', 'assertion', :'statement_a',
   jsonb_build_array(jsonb_build_object('capture_id', :'capture_a', 'node_id', :'node_a', 'quote', :'quote_a')))::text as r_claim_reused \gset
select pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-claim-1', 'assertion', 'Another statement under the same key.',
         jsonb_build_array(jsonb_build_object('capture_id', :'capture_a', 'node_id', :'node_a', 'quote', :'quote_a')))) as key_other_payload,
       pg_temp.gcw_try(format('select api.restate_claim(%L, %L, %L)', 'gcw-claim-1', (:'r_claim'::jsonb ->> 'claim_id'), 'Same key, another function.')) as key_other_function \gset
reset role;
select (:'r_claim'::jsonb ->> 'claim_id') as claim, (:'r_claim'::jsonb ->> 'receipt_id') as claim_receipt, (:'r_claim'::jsonb ->> 'intent_id') as claim_intent,
       (:'r_claim'::jsonb -> 'locator_ids' ->> 0) as claim_locator \gset

select extensions.is(:'r_claim'::jsonb - 'claim_id' - 'locator_ids' - 'receipt_id' - 'intent_id', '{"created":true,"reused":false,"status":"proposed","subjects":1,"attributions":1,"replayed":false}',
  'pipeline_agent records a claim: created, proposed');
select extensions.is((select jsonb_build_object('status', c.status, 'receipt', c.created_by_receipt_id, 'digest', c.producer_origin_digest ~ '^sha256:[0-9a-f]{64}$', 'path', c.structured ->> 'path',
      'quote', c.structured ->> 'quote', 'node', c.structured ->> 'node_id',
      'links', (select jsonb_agg(l.role) from evidence.claim_evidence_link l where l.claim_id = c.id),
      'subjects', (select count(*) from evidence.claim_subject s where s.claim_id = c.id and s.entity_id = :'library'),
      'stated_by', (select jsonb_agg(jsonb_build_array(a.role, a.source_id, a.locator_id)) from evidence.attribution a where a.claim_id = c.id and a.entity_id = :'poster'))
    from evidence.claim c where c.id = :'claim'),
  jsonb_build_object('status', 'proposed', 'receipt', :'claim_receipt', 'digest', true, 'path', 'community_thread', 'quote', :'quote_a', 'node', :'node_a', 'links', jsonb_build_array('context'), 'subjects', 1,
      'stated_by', jsonb_build_array(jsonb_build_array('stated_by', :'source_a', :'claim_locator'))),
  'the claim row: proposed, bound to its receipt, with its evidence link, subject and attribution to the source of the capture');
select extensions.is((select jsonb_build_object('capture', l.capture_id, 'kind', l.selector_kind, 'node', l.selector ->> 'node_id', 'value', l.normalized_value, 'extractor', l.extractor_name)
    from evidence.locator l where l.id = :'claim_locator'),
  jsonb_build_object('capture', :'capture_a', 'kind', 'text_quote', 'node', :'node_a', 'value', :'quote_a', 'extractor', 'governed-chain'),
  'the evidence anchor is a locator on the capture, naming the unit that holds the verbatim quote');
select extensions.is((select jsonb_build_object('type', i.intent_type, 'approval', i.approval_state, 'origin', i.origin_kind, 'function', i.payload ->> 'function',
      'role', i.payload -> 'actor' ->> 'session_role', 'label', i.payload -> 'actor' ->> 'label', 'executor', r.executor_version, 'acting', r.changes_summary ->> 'acting',
      'targets', (select jsonb_agg(t.target_table || ':' || t.action order by t.ordinal) from orchestration.operation_receipt_target t where t.receipt_id = r.id))
    from orchestration.operation_intent i join orchestration.operation_receipt r on r.intent_id = i.id where i.id = :'claim_intent'),
  '{"type":"governed_chain_write","approval":"approved","origin":"standalone","function":"api.record_claim","role":"pipeline_agent","label":"gcw extractor","executor":"api.record_claim/1","acting":"agent:gcw extractor (role pipeline_agent)","targets":["claim:created","locator:created"]}',
  'who acted is on the ledger: the intent names the function, the session role and the label; the receipt targets the rows written');
select extensions.is(:'r_claim_again'::jsonb, :'r_claim'::jsonb || '{"replayed":true}',
  'the same key with the same arguments returns the first result, marked replayed');
select extensions.is((select count(*) from evidence.claim where statement = :'statement_a') + (select count(*) from orchestration.operation_intent where idempotency_key = 'chain:gcw-claim-1'),
  2::bigint, 'a replay writes nothing: one claim, one intent');
select extensions.is(:'key_other_payload' || ' | ' || :'key_other_function', '23505 IDEMPOTENCY_KEY_REUSED | 23505 IDEMPOTENCY_KEY_REUSED',
  'the same key with other arguments, or with another function, is refused');
select extensions.is(:'r_claim_reused'::jsonb - 'receipt_id' - 'intent_id', jsonb_build_object('claim_id', :'claim', 'created', false, 'reused', true, 'status', 'proposed', 'locator_ids', '[]'::jsonb, 'replayed', false),
  'the same statement under a new key is the same claim (reused); nothing is added to it');

-- 3.2 a restatement (pipeline_agent)
set local role pipeline_agent;
select api.restate_claim('gcw-restate-1', :'claim', :'statement_r', true, 'attribution; the version is what the probe pins', '{"negative":false}')::text as r_restate \gset
select pg_temp.gcw_try(format('select api.restate_claim(%L, %L, %L)', 'gcw-restate-2', :'claim', 'A second, different restatement.')) as restate_twice,
       pg_temp.gcw_try(format('select api.restate_claim(%L, %L, %L)', 'gcw-restate-3', (:'r_restate'::jsonb ->> 'claim_id'), 'A restatement of a restatement.')) as restate_restatement,
       pg_temp.gcw_try(format('select api.restate_claim(%L, %L, %L)', 'gcw-restate-4', :'claim', :'statement_a')) as restate_unchanged \gset
reset role;
select (:'r_restate'::jsonb ->> 'claim_id') as restated \gset
select extensions.is((select jsonb_build_object('status', r.status, 'from', r.atomized_from_id, 'type', r.claim_type, 'path', r.structured ->> 'path', 'qualified', r.structured -> 'qualified',
      'role', r.structured ->> 'source_role', 'subjects', (select count(*) from evidence.claim_subject s where s.claim_id = r.id),
      'attributions', (select count(*) from evidence.attribution s where s.claim_id = r.id), 'links', (select count(*) from evidence.claim_evidence_link s where s.claim_id = r.id),
      'original', (select jsonb_build_array(o.status, o.statement) from evidence.claim o where o.id = :'claim'))
    from evidence.claim r where r.id = :'restated'),
  jsonb_build_object('status', 'proposed', 'from', :'claim', 'type', 'assertion', 'path', 'restatement', 'qualified', true, 'role', 'community', 'subjects', 1, 'attributions', 1, 'links', 1,
      'original', jsonb_build_array('proposed', :'statement_a')),
  'pipeline_agent restates the claim: a new proposed claim atomized from it, with its subjects, attributions and evidence; the original is unchanged');
select extensions.is(:'restate_twice' || ' | ' || :'restate_restatement' || ' | ' || :'restate_unchanged',
  '23505 RESTATEMENT_EXISTS | 23514 CLAIM_NOT_RESTATABLE | 22023 RESTATEMENT_UNCHANGED', 'one restatement per original; a restatement is not restated; the statement must change');

-- 3.3 a probe (verifier_agent), a sweep under a mission (pipeline_agent), a run in it (verifier_agent)
set local role verifier_agent;
select api.register_probe('gcw-probe-1', 'GCW1-retries', 'Quillfeather retries', 'a failed route is retried exactly once by default', 'executed',
   jsonb_build_array(jsonb_build_object('claim_id', :'claim', 'expectation', '{"expected":"retries_once true in every cell"}'::jsonb), :'verified'),
   array[:'library'::uuid], jsonb_build_object('path', 'probes/gcw_retries.py', 'sha256', repeat('1', 64)), '{"python":"3.12"}', '[{"label":"D1"}]', 'fake', 0, '{"label":"gcw verifier"}')::text as r_probe \gset
select pg_temp.gcw_try(format('select api.register_probe(%L, %L, %L, %L, %L, %L::jsonb)', 'gcw-probe-dup', 'GCW1-retries', 't', 'h', 'executed', jsonb_build_array(:'claim'))) as probe_slug_taken,
       pg_temp.gcw_try(format('select api.register_probe(%L, %L, %L, %L, %L, %L::jsonb, p_model_policy => %L)', 'gcw-probe-bad', 'GCW-bad', 't', 'h', 'executed', jsonb_build_array(:'claim'), 'live')) as probe_policy,
       pg_temp.gcw_try(format('select api.register_probe(%L, %L, %L, %L, %L, %L::jsonb)', 'gcw-probe-none', 'GCW-none', 't', 'h', 'executed', '[]')) as probe_no_claims \gset
reset role;
select (:'r_probe'::jsonb ->> 'probe_id') as probe \gset
set local role pipeline_agent;
select api.raise_attention_sweep('gcw-sweep-1', 'gcw-forum-weekly', 'schedule', '{"ref":"gcw tick"}', 'gcw: weekly tick', p_actor => :'actor_m1')::text as r_sweep \gset
select pg_temp.gcw_try(format('select api.raise_attention_sweep(%L, %L, %L)', 'gcw-sweep-w0', 'gcw-ignored', 'manual')) as sweep_w0,
       pg_temp.gcw_try(format('select api.raise_attention_sweep(%L, %L, %L, p_actor => %L::jsonb)', 'gcw-sweep-nomission', 'gcw-forum-weekly', 'schedule',
         '{"mc":{"mission_id":"m","run_id":"r","operation_id":"o","operation_attempt":1,"execution_generation":0,"lane":"deep_agents"}}')) as sweep_no_mission \gset
select api.raise_attention_sweep('gcw-sweep-0', 'gcw-forum-weekly', 'schedule', p_actor => :'actor_m0')::text as r_sweep_stopped \gset
reset role;
select (:'r_sweep'::jsonb ->> 'sweep_id') as sweep \gset
set local role verifier_agent;
select api.record_probe_run('gcw-run-1', :'probe', 'D1', 'pass', now() - interval '2 hours', '{"checks":{"retries_once":true}}',
   jsonb_build_object('capture_id', :'capture_b', 'node_id', :'node_b', 'selector_kind', 'json_pointer', 'pointer', '/runs/0'),
   '{"exclude_newer":"2026-11-01"}', '{"quillfeather":"2.0.0"}', jsonb_build_object('ended_at', now() - interval '119 minutes', 'exit_code', 0, 'python_version', '3.12.7'), :'sweep', :'actor_m1')::text as r_run \gset
select api.record_probe_run('gcw-run-1', :'probe', 'D1', 'pass', now() - interval '2 hours', '{"checks":{"retries_once":true}}',
   jsonb_build_object('capture_id', :'capture_b', 'node_id', :'node_b', 'selector_kind', 'json_pointer', 'pointer', '/runs/0'),
   '{"exclude_newer":"2026-11-01"}', '{"quillfeather":"2.0.0"}', jsonb_build_object('ended_at', now() - interval '119 minutes', 'exit_code', 0, 'python_version', '3.12.7'), :'sweep', :'actor_m1_retry')::text as r_run_retry \gset
select pg_temp.gcw_try(format('select api.record_probe_run(%L, %L, %L, %L, %L)', 'gcw-run-noout', :'probe', 'D2', 'pass', now() - interval '1 hour')) as run_no_output,
       pg_temp.gcw_try(format('select api.record_probe_run(%L, %L, %L, %L, %L, p_run => %L::jsonb)', 'gcw-run-spend', :'probe', 'D2', 'error', now() - interval '1 hour', '{"cost_usd":0.01}')) as run_spend,
       pg_temp.gcw_try(format('select api.record_probe_run(%L, %L, %L, %L, %L, p_sweep_id => %L)', 'gcw-run-sweep', :'probe', 'D2', 'skipped', now() - interval '1 hour', :'sweep')) as run_sweep_mission,
       pg_temp.gcw_try(format('select api.record_probe_run(%L, %L, %L, %L, %L, p_output => %L::jsonb)', 'gcw-run-dup', :'probe', 'D1', 'pass', now() - interval '2 hours',
         jsonb_build_object('locator_id', :'r_run'::jsonb ->> 'output_locator_id'))) as run_duplicate \gset
reset role;
select (:'r_run'::jsonb ->> 'probe_run_id') as run, (:'r_run'::jsonb ->> 'output_locator_id') as run_locator \gset

select extensions.is((select jsonb_build_object('state', p.state, 'kind', p.kind, 'policy', p.model_policy, 'by', p.designed_by, 'script', p.script_sha256 = repeat('1', 64),
      'claims', (select jsonb_agg(pc.expectation order by (pc.claim_id = :'claim') desc) from verification.probe_claim pc where pc.probe_id = p.id))
    from verification.probe p where p.id = :'probe'),
  '{"state":"active","kind":"executed","policy":"fake","by":"agent:gcw verifier (role verifier_agent)","script":true,"claims":[{"expected":"retries_once true in every cell"},{}]}',
  'verifier_agent registers a probe with the claims it tests and what is expected of each');
select extensions.is(:'probe_slug_taken' || ' | ' || :'probe_policy' || ' | ' || :'probe_no_claims',
  '23505 PROBE_SLUG_TAKEN | 22023 PROBE_MODEL_POLICY_MISMATCH | 22023 PROBE_CLAIMS_REQUIRED', 'a taken slug, a live policy on a deterministic probe, and a probe without claims are refused');
select extensions.is((select jsonb_build_object('open', s.ended_at is null, 'origin', s.origin_kind, 'mission', s.mission_id, 'trigger', s.trigger_kind, 'run', s.trigger_ref ->> 'mc_run_id',
      'receipt', s.receipt_id = (:'r_sweep'::jsonb ->> 'receipt_id')::uuid, 'result', :'r_sweep'::jsonb - 'sweep_id' - 'policy_id' - 'receipt_id' - 'intent_id')
    from acquisition.attention_sweep s where s.id = :'sweep'),
  jsonb_build_object('open', true, 'origin', 'mission', 'mission', :'mission_1', 'trigger', 'schedule', 'run', 'mc-run-gcw-1', 'receipt', true,
    'result', '{"policy":"gcw-forum-weekly","origin_kind":"mission","open":true,"budget_stopped":false,"mission_spent_usd":0,"mission_budget_usd":1.0000,"budget_usd_per_run":0.1000,"budget_credits_per_run":0,"replayed":false}'::jsonb),
  'pipeline_agent raises an attention sweep under a mission: open, tied to the mission and the Mission Control run');
select extensions.is(:'sweep_w0' || ' | ' || :'sweep_no_mission', '23514 ATTENTION_POLICY_NOT_SWEEPABLE | 22023 MISSION_REQUIRED',
  'a W0 policy is never swept; a Mission Control invocation names its mission');
select extensions.is((select jsonb_build_object('stopped', :'r_sweep_stopped'::jsonb -> 'budget_stopped', 'open', :'r_sweep_stopped'::jsonb -> 'open', 'outcome', s.outcome, 'ended', s.ended_at is not null, 'why', s.rejected ? 'budget')
    from acquisition.attention_sweep s where s.id = (:'r_sweep_stopped'::jsonb ->> 'sweep_id')::uuid),
  '{"stopped":true,"open":false,"outcome":"budget_stopped","ended":true,"why":true}', 'the budget gate: a mission whose budget is spent gets a settled budget_stopped sweep and no work');
select extensions.is((select jsonb_build_object('outcome', r.outcome, 'cell', r.cell_label, 'capture', r.output_capture_id, 'locator_kind', l.selector_kind, 'origin', r.origin_kind, 'mission', r.mission_id,
      'sweep', r.sweep_id, 'receipt', r.receipt_id = (:'r_run'::jsonb ->> 'receipt_id')::uuid, 'resolved', r.resolved, 'exit', r.exit_code)
    from verification.probe_run r join evidence.locator l on l.id = r.output_locator_id where r.id = :'run'),
  jsonb_build_object('outcome', 'pass', 'cell', 'D1', 'capture', :'capture_b', 'locator_kind', 'json_pointer', 'origin', 'mission', 'mission', :'mission_1', 'sweep', :'sweep', 'receipt', true,
    'resolved', '{"quillfeather":"2.0.0"}'::jsonb, 'exit', 0),
  'verifier_agent records a probe run in the sweep: outcome, resolved versions, and its captured output as a locator');
select extensions.is(:'r_run_retry'::jsonb, :'r_run'::jsonb || '{"replayed":true}', 'a retry by a later Mission Control attempt replays: the actor is not part of the request');
select extensions.is(:'run_no_output' || ' | ' || :'run_spend' || ' | ' || :'run_sweep_mission' || ' | ' || :'run_duplicate',
  '22023 PROBE_RUN_OUTPUT_REQUIRED | 23514 PROBE_RUN_SPEND_NOT_ALLOWED | 23514 SWEEP_MISSION_MISMATCH | 23505 PROBE_RUN_DUPLICATE',
  'a passed run needs its output; a probe that is not live reports no spend; a run joins a sweep of its own mission; a run is recorded once');

-- 3.4 verdicts (verifier_agent): always proposed by the agent; a supportive verdict does not verify
set local role verifier_agent;
select api.propose_verdict('gcw-verdict-1', :'claim', :'probe', 'directly_supported', '{"D1":{"retries_once":true}}', 'retries exactly once in D1 (quillfeather 2.0.0)', '{"label":"gcw verifier"}')::text as r_verdict \gset
select api.propose_verdict('gcw-verdict-1b', :'claim', :'probe', 'directly_supported', '{"D1":{"retries_once":true}}', 'the same verdict, proposed again')::text as r_verdict_same \gset
select api.propose_verdict('gcw-verdict-r1', :'restated', :'probe', 'directly_supported', '{"D1":{"retries_once":true}}', 'the restated statement is what D1 showed')::text as r_verdict_restated \gset
select api.propose_verdict('gcw-verdict-2', :'claim', :'probe', 'supported_with_qualification', '{"D1":{"retries_once":true}}', 'holds for 2.0.0 only; the post names no version')::text as r_verdict_changed \gset
select pg_temp.gcw_try(format('select api.propose_verdict(%L, %L, %L, %L, %L::jsonb, %L)', 'gcw-verdict-cell', :'claim', :'probe', 'contradicted', '{"D9":{}}', 'a cell that never ran')) as verdict_cell,
       pg_temp.gcw_try(format('select api.propose_verdict(%L, %L, %L, %L, %L::jsonb, %L)', 'gcw-verdict-foreign', :'foreign_claim', :'probe', 'contradicted', '{"D1":{}}', 'another tenant''s claim')) as verdict_foreign,
       pg_temp.gcw_try(format('select api.propose_verdict(%L, %L, %L, %L, %L::jsonb, %L)', 'gcw-verdict-bad', :'claim', :'probe', 'verified', '{"D1":{}}', 'not a verdict')) as verdict_invalid,
       pg_temp.gcw_try(format('select api.propose_verdict(%L, %L, %L, %L, %L::jsonb, %L)', 'gcw-verdict-norun', :'claim', :'probe', 'contradicted', '{}', 'no cells')) as verdict_no_runs \gset
reset role;
select (:'r_verdict'::jsonb ->> 'verdict_id') as verdict, (:'r_verdict_changed'::jsonb ->> 'verdict_id') as verdict_2 \gset

select extensions.is(:'r_verdict'::jsonb - 'verdict_id' - 'receipt_id' - 'intent_id',
  jsonb_build_object('written', true, 'unchanged', false, 'verdict', 'directly_supported', 'review_state', 'agent_proposed', 'claim_status', 'proposed', 'claim_status_changed', false,
     'evidence_locator_id', :'run_locator', 'needs_review', true, 'restatements_to_review', jsonb_build_array(:'restated'), 'replayed', false),
  'verifier_agent proposes a verdict: agent_proposed, the claim stays proposed, and its restatement is flagged for review');
select extensions.is((select jsonb_build_object('state', v.review_state, 'by', v.decided_by, 'verdict', v.verdict, 'claim', (select c.status from evidence.claim c where c.id = v.claim_id),
      'link', (select jsonb_build_array(l.role, l.support_verdict) from evidence.claim_evidence_link l where l.claim_id = v.claim_id and l.locator_id = :'run_locator'))
    from verification.probe_verdict v where v.id = :'verdict'),
  '{"state":"agent_proposed","by":"agent:gcw verifier (role verifier_agent)","verdict":"directly_supported","claim":"proposed","link":["supports","directly_supported"]}',
  'the verdict row names the agent and its role; the claim is not verified by a supportive verdict; the run output is linked as support');
select extensions.is(:'r_verdict_same'::jsonb - 'receipt_id' - 'intent_id',
  jsonb_build_object('verdict_id', :'verdict', 'written', false, 'unchanged', true, 'verdict', 'directly_supported', 'review_state', 'agent_proposed', 'claim_status', 'proposed',
     'claim_status_changed', false, 'needs_review', false, 'restatements_to_review', '[]'::jsonb, 'replayed', false),
  'the same verdict again writes no row');
select extensions.is((select jsonb_build_object('written', :'r_verdict_restated'::jsonb -> 'written', 'linked', (select pc.expectation ->> 'linked_by' from verification.probe_claim pc where pc.probe_id = :'probe' and pc.claim_id = :'restated'))),
  '{"written":true,"linked":"api.propose_verdict"}', 'a restatement is judged by the probe of the claim it restates, and is linked to it');
select extensions.is((select jsonb_build_object('supersedes', v.supersedes_id, 'state', v.review_state, 'previous', (select jsonb_build_array(o.verdict, o.review_state, o.rationale) from verification.probe_verdict o where o.id = :'verdict'),
      'current', (select count(*) from verification.probe_verdict w where w.claim_id = :'claim' and not exists (select 1 from verification.probe_verdict x where x.supersedes_id = w.id)))
    from verification.probe_verdict v where v.id = :'verdict_2'),
  jsonb_build_object('supersedes', :'verdict', 'state', 'agent_proposed', 'previous', jsonb_build_array('directly_supported', 'agent_proposed', 'retries exactly once in D1 (quillfeather 2.0.0)'), 'current', 1),
  'a changed verdict is a new row that supersedes; the earlier row is kept as written');
select extensions.is(:'verdict_cell' || ' | ' || :'verdict_foreign' || ' | ' || :'verdict_invalid' || ' | ' || :'verdict_no_runs',
  '23514 VERDICT_CELL_NOT_RUN | P0002 CLAIM_NOT_FOUND | 22023 VERDICT_INVALID | 22023 VERDICT_REQUIRES_RUNS',
  'a verdict rests on recorded runs, on a claim of this tenant, with a value of the verdict vocabulary');

-- 3.5 a deterministic contradiction disputes a proposed claim; a live arm does not; a verified claim is never changed
set local role pipeline_agent;
select api.record_claim('gcw-claim-c', 'assertion', :'statement_c', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator', 'role', 'context')))::text as r_claim_c \gset
select api.record_claim('gcw-claim-l', 'assertion', :'statement_l', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')))::text as r_claim_l \gset
reset role;
select (:'r_claim_c'::jsonb ->> 'claim_id') as claim_c, (:'r_claim_l'::jsonb ->> 'claim_id') as claim_l \gset
set local role control_plane;
select api.register_probe('gcw-probe-2', 'GCW2-body', 'Quillfeather retry body', 'the request body survives a retry', 'static_docs', jsonb_build_array(:'claim_c'))::text as r_probe_2 \gset
select api.register_probe('gcw-probe-3', 'GCW3-live', 'Quillfeather fallback under a live model', 'a live model picks the fallback route', 'live_model', jsonb_build_array(:'claim_l'),
   p_model_policy => 'live', p_budget_usd => 0.05)::text as r_probe_3 \gset
select api.record_probe_run('gcw-run-2', (:'r_probe_2'::jsonb ->> 'probe_id')::uuid, 'docs', 'pass', now() - interval '50 minutes', '{"checks":{"body_kept":true}}', jsonb_build_object('locator_id', :'run_locator'))::text as r_run_2 \gset
select api.record_probe_run('gcw-run-3', (:'r_probe_3'::jsonb ->> 'probe_id')::uuid, 'live-1', 'pass', now() - interval '40 minutes', '{"checks":{"fallback":false}}', jsonb_build_object('locator_id', :'run_locator'),
   p_run => '{"tokens_in":900,"tokens_out":40,"cost_usd":0.06}')::text as r_run_3 \gset
select api.propose_verdict('gcw-verdict-c', :'claim_c', (:'r_probe_2'::jsonb ->> 'probe_id')::uuid, 'contradicted', '{"docs":{"body_kept":true}}', 'the docs say the body is replayed')::text as r_verdict_c \gset
select api.propose_verdict('gcw-verdict-l', :'claim_l', (:'r_probe_3'::jsonb ->> 'probe_id')::uuid, 'contradicted', '{"live-1":{"fallback":false}}', 'one live run did not pick the fallback')::text as r_verdict_l \gset
reset role;
set local role verifier_agent;
select api.propose_verdict('gcw-verdict-v', :'verified', :'probe', 'contradicted', '{"D1":{"retries_once":true}}', 'D1 shows no retry log line')::text as r_verdict_v \gset
select pg_temp.gcw_try(format('select api.propose_verdict(%L, %L, %L, %L, %L::jsonb, %L)', 'gcw-verdict-unlinked', :'claim_c', :'probe', 'contradicted', '{"D1":{}}', 'a claim the probe does not test')) as verdict_unlinked \gset
reset role;

select extensions.is(jsonb_build_object('result', :'r_verdict_c'::jsonb -> 'claim_status', 'changed', :'r_verdict_c'::jsonb -> 'claim_status_changed', 'row', (select c.status from evidence.claim c where c.id = :'claim_c'),
    'link', (select l.role from evidence.claim_evidence_link l where l.claim_id = :'claim_c' and l.support_verdict = 'contradicted'),
    'target', (select t.action from orchestration.operation_receipt_target t where t.receipt_id = (:'r_verdict_c'::jsonb ->> 'receipt_id')::uuid and t.target_table = 'claim')),
  '{"result":"disputed","changed":true,"row":"disputed","link":"contradicts","target":"updated"}',
  'control_plane proposes a contradiction from a deterministic probe: the proposed claim becomes disputed, and the receipt says so');
select extensions.is(jsonb_build_object('result', :'r_verdict_l'::jsonb -> 'claim_status', 'row', (select c.status from evidence.claim c where c.id = :'claim_l'), 'over_budget', :'r_run_3'::jsonb -> 'over_budget'),
  '{"result":"proposed","row":"proposed","over_budget":true}', 'a live arm never disputes a claim alone; its spend is recorded as reported and flagged over the probe budget');
select extensions.is(jsonb_build_object('written', :'r_verdict_v'::jsonb -> 'written', 'result', :'r_verdict_v'::jsonb -> 'claim_status', 'changed', :'r_verdict_v'::jsonb -> 'claim_status_changed',
    'needs_review', :'r_verdict_v'::jsonb -> 'needs_review', 'row', (select c.status from evidence.claim c where c.id = :'verified'),
    'links', (select count(*) from evidence.claim_evidence_link l where l.claim_id = :'verified')),
  '{"written":true,"result":"verified","changed":false,"needs_review":true,"row":"verified","links":0}',
  'a contradiction of a verified claim is recorded as a proposal for review; the verified claim and its evidence are not touched');
select extensions.is(:'verdict_unlinked'::text, '23514 CLAIM_NOT_PROBED', 'a probe judges only the claims it was registered to test');

-- 3.6 triage (pipeline_agent)
set local role pipeline_agent;
select api.record_triage('gcw-triage-1', :'claim', 'docs_check', 'deterministic_local', 'a docs page states the default', 40, '{"module_subject":true}')::text as r_triage \gset
select api.record_triage('gcw-triage-1b', :'claim', 'docs_check', 'deterministic_local', 'the same triage again')::text as r_triage_same \gset
select api.record_triage('gcw-triage-2', :'claim', 'probe', 'deterministic_local', 'selected for GCW1', 55, '{"selected_for":"GCW1"}', null, :'probe')::text as r_triage_2 \gset
select pg_temp.gcw_try(format('select api.record_triage(%L, %L, %L, %L, %L)', 'gcw-triage-dup', :'claim', 'duplicate', 'not_applicable', 'a duplicate of nothing')) as triage_duplicate,
       pg_temp.gcw_try(format('select api.record_triage(%L, %L, %L, %L, %L)', 'gcw-triage-verified', :'verified', 'not_checkable', 'not_applicable', 'a verified claim')) as triage_verified \gset
reset role;
select extensions.is(jsonb_build_object('first', :'r_triage'::jsonb -> 'written', 'same', :'r_triage_same'::jsonb -> 'unchanged', 'same_id', (:'r_triage_same'::jsonb ->> 'triage_id') = (:'r_triage'::jsonb ->> 'triage_id'),
    'second_supersedes', (:'r_triage_2'::jsonb ->> 'supersedes_id') = (:'r_triage'::jsonb ->> 'triage_id'),
    'rows', (select jsonb_agg(jsonb_build_array(t.disposition, t.review_state, t.decided_by) order by t.decided_at) from verification.claim_triage t where t.claim_id = :'claim')),
  '{"first":true,"same":true,"same_id":true,"second_supersedes":true,"rows":[["docs_check","agent_proposed","agent:pipeline_agent (role pipeline_agent)"],["probe","agent_proposed","agent:pipeline_agent (role pipeline_agent)"]]}',
  'pipeline_agent records a triage; a changed triage supersedes it; the same triage again writes nothing');
select extensions.is(:'triage_duplicate' || ' | ' || :'triage_verified', '22023 TRIAGE_DUPLICATE_INVALID | 23514 CLAIM_NOT_TRIAGEABLE', 'a duplicate names the claim it duplicates; a verified claim is not a candidate');

-- 3.7 a source assessment (verifier_agent): a prior, then the assessment derived from the verdicts
set local role verifier_agent;
select pg_temp.gcw_try(format('select api.record_source_assessment(%L, %L, %L)', 'gcw-assess-nobase', :'channel', 'derived')) as assess_no_base \gset
select api.record_source_assessment('gcw-assess-prior', :'channel', 'prior', null, 'community', 'none', 'not_applicable', 'a community forum')::text as r_prior \gset
select api.record_source_assessment('gcw-assess-prior-b', :'channel', 'prior', null, 'community', 'none', 'not_applicable', 'the same prior again')::text as r_prior_same \gset
select api.record_source_assessment('gcw-assess-derived', :'channel', 'derived')::text as r_derived \gset
select pg_temp.gcw_try(format('select api.record_source_assessment(%L, %L, %L)', 'gcw-assess-reviewed', :'channel', 'reviewed')) as assess_reviewed,
       pg_temp.gcw_try(format('select api.record_source_assessment(%L, %L, %L, null, %L)', 'gcw-assess-library', :'library', 'prior', 'community')) as assess_not_a_source \gset
reset role;
select extensions.is(jsonb_build_object('prior_score', :'r_prior'::jsonb -> 'authority_score', 'rank', (select to_jsonb(authority_rank) from content.source_role where code = 'community'),
    'same', :'r_prior_same'::jsonb -> 'unchanged', 'derived_method', :'r_derived'::jsonb ->> 'method', 'observed', :'r_derived'::jsonb -> 'claims_observed', 'checked', :'r_derived'::jsonb -> 'claims_checked',
    'supersedes_prior', (:'r_derived'::jsonb ->> 'supersedes_id') = (:'r_prior'::jsonb ->> 'assessment_id'),
    'rows', (select jsonb_agg(jsonb_build_array(a.method, a.assessed_by like 'agent:%(role verifier_agent)', a.receipt_id is not null) order by a.created_at, a.method desc) from evidence.source_assessment a where a.subject_entity_id = :'channel')),
  jsonb_build_object('prior_score', (select to_jsonb(authority_rank) from content.source_role where code = 'community'), 'rank', (select to_jsonb(authority_rank) from content.source_role where code = 'community'),
    'same', true, 'derived_method', 'derived', 'observed', 2, 'checked', 2, 'supersedes_prior', true, 'rows', '[["prior",true,true],["derived",true,false]]'::jsonb),
  'verifier_agent records a role prior (scored by the role, not by the caller) and the assessment derived from the verdicts on the claims the source stated');
select extensions.is(:'assess_no_base' || ' | ' || :'assess_reviewed' || ' | ' || :'assess_not_a_source',
  '23514 ASSESSMENT_BASE_REQUIRED | 42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE | 22023 ASSESSMENT_SUBJECT_INVALID',
  'a derived assessment needs a prior; a reviewed assessment is a person''s; a library is not a source');

-- 3.8 the sweep is settled once (control_plane), and the run's effects read as one list
set local role control_plane;
select api.settle_attention_sweep('gcw-settle-1', :'sweep', 'completed', 12, 3, 2, '{"off_topic":9}', 0.25, 0, :'actor_m1')::text as r_settle \gset
select pg_temp.gcw_try(format('select api.settle_attention_sweep(%L, %L, %L, 1, 1, 1, p_actor => %L::jsonb)', 'gcw-settle-2', :'sweep', 'completed', :'actor_m1')) as settle_twice,
       pg_temp.gcw_try(format('select api.settle_attention_sweep(%L, %L, %L, 1, 2, 1)', 'gcw-settle-3', (:'r_sweep_stopped'::jsonb ->> 'sweep_id'), 'completed')) as settle_stopped \gset
select (select jsonb_agg(e.target_table || ':' || e.action order by e.target_table || ':' || e.action) from orchestration.mission_run_effects e where e.mc_run_id = 'mc-run-gcw-1')::text as run_effects \gset
reset role;
select extensions.is((select jsonb_build_object('outcome', s.outcome, 'ended', s.ended_at is not null, 'seen', s.items_seen, 'selected', s.items_selected, 'captured', s.items_captured, 'spend', s.spend_usd,
      'result', :'r_settle'::jsonb - 'receipt_id' - 'intent_id' - 'sweep_id')
    from acquisition.attention_sweep s where s.id = :'sweep'),
  '{"outcome":"completed","ended":true,"seen":12,"selected":3,"captured":2,"spend":0.2500,"result":{"policy":"gcw-forum-weekly","outcome":"completed","settled":true,"over_budget_usd":true,"over_budget_credits":false,"mission_spent_usd":0.25,"mission_budget_usd":1.0000,"mission_budget_exhausted":false,"replayed":false}}',
  'control_plane settles the sweep: counts, rejections and spend as reported, flagged over the policy''s per-run budget');
select extensions.is(:'settle_twice' || ' | ' || :'settle_stopped', '23514 SWEEP_ALREADY_SETTLED | 23514 SWEEP_ALREADY_SETTLED', 'a sweep is settled once; a budget-stopped sweep is already settled');
select extensions.is(:'run_effects'::jsonb, '["attention_sweep:created","attention_sweep:updated","locator:created","probe_run:created"]',
  'everything the Mission Control run caused reads as one list (orchestration.mission_run_effects, read as control_plane)');

-- ------------------------------------------------------------------ 4. lines an agent does not cross
-- 4.1 verified only through a Knowledge Services admission
set local role pipeline_agent;
select left(pg_temp.gcw_try(format('update evidence.claim set status = %L where id = %L', 'verified', :'claim')), 5) as verify_pipeline,
       left(pg_temp.gcw_try(format('select verification.record_admitted_claim_verification(%L, %L, %L, 1, null, %L, %L, %L)', :'claim', 'ud-made-up', 'sha256:' || repeat('9', 64), 'sha256:' || repeat('9', 64), '{}', 'gcw')), 5) as admit_pipeline \gset
reset role;
set local role executor_service;
select pg_temp.gcw_try(format('update evidence.claim set status = %L where id = %L', 'verified', :'claim')) as verify_executor,
       pg_temp.gcw_try(format('insert into evidence.claim(tenant_id, claim_type, statement, status, producer_origin_digest) values (%L, %L, %L, %L, %L)', :'tenant', 'assertion', 'born verified', 'verified', 'sha256:' || repeat('9', 64))) as insert_verified \gset
reset role;
set local role verifier_agent;
select pg_temp.gcw_try(format('select verification.record_admitted_claim_verification(%L, %L, %L, 1, null, %L, %L, %L)', :'claim', 'ud-made-up', 'sha256:' || repeat('9', 64), 'sha256:' || repeat('9', 64),
         jsonb_build_object('claim_id', :'claim')::text, 'gcw')) as admit_unbound \gset
reset role;
select extensions.is(:'verify_pipeline' || ' | ' || :'admit_pipeline' || ' | ' || :'verify_executor' || ' | ' || :'insert_verified' || ' | ' || :'admit_unbound',
  '42501 | 42501 | 23514 VERIFIED_CLAIM_REQUIRES_ADMITTED_USE | 23514 VERIFIED_CLAIM_REQUIRES_ADMITTED_USE | 23514 EFFECT_PAYLOAD_NOT_BOUND',
  'no agent role verifies a claim: the status is gated, and the admission write refuses a decision the verification component did not issue');
select extensions.is((select count(*) from evidence.claim c join orchestration.operation_receipt r on r.id = c.created_by_receipt_id where r.executor_version like 'api.%' and c.status::text not in ('proposed', 'disputed')),
  0::bigint, 'every claim written by a governed function is proposed, or disputed by a deterministic contradiction');

-- 4.2 a person's judgment is not written by an agent role
set local role pipeline_agent;
select pg_temp.gcw_try(format('insert into verification.probe_verdict(claim_id, probe_id, verdict, rationale, decided_by, review_state) values (%L, %L, %L, %L, %L, %L)', :'claim', :'probe', 'directly_supported', 'x', 'human:someone', 'human_confirmed')) as human_pipeline,
       pg_temp.gcw_try(format('insert into verification.probe_verdict(claim_id, probe_id, verdict, rationale, decided_by, review_state) values (%L, %L, %L, %L, %L, %L)', :'claim', :'probe', 'directly_supported', 'x', 'human:someone', 'human_rejected')) as human_rejected_pipeline,
       pg_temp.gcw_try(format('insert into verification.claim_triage(claim_id, disposition, checkability, rationale, decided_by, review_state) values (%L, %L, %L, %L, %L, %L)', :'claim', 'probe', 'deterministic_local', 'x', 'human:someone', 'human_confirmed')) as human_triage_pipeline,
       pg_temp.gcw_try(format('insert into evidence.source_assessment(subject_entity_id, method, rationale, assessed_by) values (%L, %L, %L, %L)', :'channel', 'reviewed', 'x', 'human:someone')) as human_assessment_pipeline,
       left(pg_temp.gcw_try(format('update verification.probe_verdict set review_state = %L where id = %L', 'human_confirmed', :'verdict')), 5) as human_update_pipeline,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb, p_actor => %L::jsonb)', 'gcw-claim-human', 'assertion', 'labelled as a person', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')), '{"label":"human:john"}')) as human_label,
       left(pg_temp.gcw_try('select api.product_command(null, ''create_workspace'', ''gcw-agent-workspace'', null, ''{"name":"x"}'')'), 5) as product_pipeline \gset
reset role;
set local role verifier_agent;
select pg_temp.gcw_try(format('insert into verification.probe_verdict(claim_id, probe_id, verdict, rationale, decided_by, review_state) values (%L, %L, %L, %L, %L, %L)', :'claim', :'probe', 'directly_supported', 'x', 'human:someone', 'human_confirmed')) as human_verifier,
       pg_temp.gcw_try(format('insert into verification.claim_triage(claim_id, disposition, checkability, rationale, decided_by, review_state) values (%L, %L, %L, %L, %L, %L)', :'claim', 'probe', 'deterministic_local', 'x', 'human:someone', 'human_rejected')) as human_triage_verifier,
       pg_temp.gcw_try(format('insert into evidence.source_assessment(subject_entity_id, method, rationale, assessed_by) values (%L, %L, %L, %L)', :'channel', 'reviewed', 'x', 'human:someone')) as human_assessment_verifier,
       left(pg_temp.gcw_try('select api.product_command(null, ''create_workspace'', ''gcw-agent-workspace'', null, ''{"name":"x"}'')'), 5) as product_verifier \gset
reset role;
set local role control_plane;
select pg_temp.gcw_try(format('insert into verification.probe_verdict(claim_id, probe_id, verdict, rationale, decided_by, review_state) values (%L, %L, %L, %L, %L, %L)', :'claim', :'probe', 'directly_supported', 'x', 'human:someone', 'human_confirmed')) as human_control,
       pg_temp.gcw_try(format('insert into evidence.source_assessment(subject_entity_id, method, rationale, assessed_by) values (%L, %L, %L, %L)', :'channel', 'reviewed', 'x', 'human:someone')) as human_assessment_control,
       left(pg_temp.gcw_try('select api.product_command(null, ''create_workspace'', ''gcw-agent-workspace'', null, ''{"name":"x"}'')'), 5) as product_control \gset
reset role;
set local role executor_service;
select left(pg_temp.gcw_try(format('insert into verification.probe_verdict(claim_id, probe_id, verdict, rationale, decided_by, review_state) values (%L, %L, %L, %L, %L, %L)', :'claim', :'probe', 'directly_supported', 'x', 'human:someone', 'human_confirmed')), 5) as human_executor,
       left(pg_temp.gcw_try('select api.product_command(null, ''create_workspace'', ''gcw-agent-workspace'', null, ''{"name":"x"}'')'), 5) as product_executor \gset
reset role;
set local role service_role;
select pg_temp.gcw_try(format('insert into verification.probe_verdict(tenant_id, claim_id, probe_id, verdict, rationale, decided_by, review_state) values (%L, %L, %L, %L, %L, %L, %L)', :'tenant', :'claim', :'probe', 'directly_supported', 'x', 'human:someone', 'human_confirmed')) as human_service \gset
reset role;
select extensions.is(:'human_pipeline' || ' | ' || :'human_verifier' || ' | ' || :'human_control' || ' | ' || :'human_service' || ' | ' || :'human_rejected_pipeline',
  '42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE | 42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE | 42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE | 42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE | 42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE',
  'a human-confirmed or human-rejected verdict is not writable by pipeline_agent, verifier_agent, control_plane or service_role, even by direct insert');
select extensions.is(:'human_executor' || ' | ' || :'human_update_pipeline', '42501 | 42501', 'executor_service cannot write a verdict at all; no agent role can update one');
select extensions.is(:'human_triage_pipeline' || ' | ' || :'human_triage_verifier', '42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE | 42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE',
  'a human-reviewed triage is not writable by an agent role');
select extensions.is(:'human_assessment_pipeline' || ' | ' || :'human_assessment_verifier' || ' | ' || :'human_assessment_control',
  '42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE | 42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE | 42501 HUMAN_REVIEW_NOT_AGENT_WRITABLE', 'a reviewed source assessment is not writable by an agent role');
select extensions.is(:'human_label'::text, '22023 ACTOR_INVALID', 'a governed write is never labelled as a person');
select extensions.is(:'product_pipeline' || ' | ' || :'product_verifier' || ' | ' || :'product_control' || ' | ' || :'product_executor', '42501 | 42501 | 42501 | 42501',
  'no agent role can call the product command that records a human release review');
select extensions.is((select jsonb_build_object(
    'verdicts', (select count(*) from verification.probe_verdict v where v.decided_at >= now() and (v.review_state <> 'agent_proposed' or v.decided_by not like 'agent:%')),
    'triage', (select count(*) from verification.claim_triage t where t.decided_at >= now() and (t.review_state <> 'agent_proposed' or t.decided_by not like 'agent:%')),
    'assessments', (select count(*) from evidence.source_assessment a where a.created_at >= now() and (a.method = 'reviewed' or a.assessed_by not like 'agent:%')),
    'written', (select count(*) from verification.probe_verdict v where v.decided_at >= now()))),
  '{"verdicts":0,"triage":0,"assessments":0,"written":6}', 'every verdict, triage row and assessment written in this suite so far is agent-proposed and names an agent');
-- What exists for a person today: the owner of the table records the confirmation (the lab scripts did). An agent's later
-- proposal supersedes it as a new row without rewriting it; the same verdict a person rejected is not proposed again.
insert into verification.probe_verdict(tenant_id, claim_id, probe_id, verdict, cells, rationale, decided_by, review_state, supersedes_id, decided_at)
 values (:'tenant', :'claim', :'probe', 'supported_with_qualification', '{"D1":{"retries_once":true}}', 'fixture: a person confirmed', 'human:fixture reviewer', 'human_confirmed', :'verdict_2', clock_timestamp());
insert into verification.probe_verdict(tenant_id, claim_id, probe_id, verdict, cells, rationale, decided_by, review_state, supersedes_id, decided_at)
 select :'tenant', :'restated', :'probe', 'directly_supported', '{"D1":{"retries_once":true}}', 'fixture: a person rejected', 'human:fixture reviewer', 'human_rejected', v.id, clock_timestamp()
   from verification.probe_verdict v where v.claim_id = :'restated' and v.probe_id = :'probe';
insert into verification.claim_triage(tenant_id, claim_id, disposition, checkability, rationale, decided_by, review_state, supersedes_id, decided_at)
 select :'tenant', :'claim', 'probe', 'deterministic_local', 'fixture: a person confirmed the selection', 'human:fixture reviewer', 'human_confirmed', (:'r_triage_2'::jsonb ->> 'triage_id')::uuid, clock_timestamp();
insert into evidence.source_assessment(tenant_id, subject_entity_id, topic_entity_id, method, source_role_code, rationale, assessed_by)
 values (:'tenant', :'channel', :'library', 'reviewed', 'first_party', 'fixture: a person reviewed this source on this topic', 'human:fixture reviewer');
set local role pipeline_agent;
select pg_temp.gcw_try(format('select api.record_triage(%L, %L, %L, %L, %L)', 'gcw-triage-3', :'claim_l', 'out_of_scope', 'not_applicable', 'unrelated')) as triage_other_claim,
       pg_temp.gcw_try(format('select api.record_triage(%L, %L, %L, %L, %L)', 'gcw-triage-4', :'claim', 'out_of_scope', 'not_applicable', 'over a person''s review')) as triage_over_review \gset
reset role;
set local role verifier_agent;
select api.propose_verdict('gcw-verdict-3', :'claim', :'probe', 'contradicted', '{"D1":{"retries_once":true}}', 'a later reading of D1')::text as r_verdict_over_human \gset
select pg_temp.gcw_try(format('select api.propose_verdict(%L, %L, %L, %L, %L::jsonb, %L)', 'gcw-verdict-r2', :'restated', :'probe', 'directly_supported', '{"D1":{"retries_once":true}}', 'proposed again after a rejection')) as verdict_after_rejection,
       pg_temp.gcw_try(format('select api.record_source_assessment(%L, %L, %L, %L, %L)', 'gcw-assess-over-review', :'channel', 'prior', :'library', 'community')) as prior_over_review \gset
reset role;
select extensions.is((select jsonb_build_object('needs_review', :'r_verdict_over_human'::jsonb -> 'needs_review', 'new_state', :'r_verdict_over_human'::jsonb ->> 'review_state',
      'human_row', (select jsonb_build_array(h.verdict, h.review_state, h.decided_by, h.rationale) from verification.probe_verdict h where h.claim_id = :'claim' and h.review_state = 'human_confirmed'),
      'claim', (select c.status from evidence.claim c where c.id = :'claim'))),
  '{"needs_review":true,"new_state":"agent_proposed","human_row":["supported_with_qualification","human_confirmed","human:fixture reviewer","fixture: a person confirmed"],"claim":"disputed"}',
  'an agent''s changed verdict is appended as a proposal for review; the row a person confirmed is not rewritten');
select extensions.is(:'verdict_after_rejection' || ' | ' || :'triage_over_review' || ' | ' || :'prior_over_review' || ' | ' || :'triage_other_claim',
  '23514 VERDICT_REJECTED_BY_PERSON | 23514 TRIAGE_REVIEWED_BY_PERSON | 23514 ASSESSMENT_REVIEWED_BY_PERSON | ok',
  'an agent does not re-propose a verdict a person rejected, nor supersede a person''s review of a triage or of a source; its other writes go on');

-- 4.3 nothing verified, admitted or immutable is deleted or rewritten
set local role executor_service;
select left(pg_temp.gcw_try(format('delete from evidence.claim where id = %L', :'verified')), 5) as delete_verified_executor,
       left(pg_temp.gcw_try(format('update evidence.claim set statement = %L where id = %L', 'rewritten', :'verified')), 5) as rewrite_verified_executor,
       left(pg_temp.gcw_try(format('update evidence.locator set normalized_value = %L where id = %L', 'rewritten', :'claim_locator')), 5) as rewrite_locator_executor \gset
reset role;
set local role pipeline_agent;
select pg_temp.gcw_try(format('select api.restate_claim(%L, %L, %L)', 'gcw-restate-verified', :'verified', 'A verified claim, restated.')) as restate_verified \gset
reset role;
select left(pg_temp.gcw_try(format('delete from evidence.claim where id = %L', :'verified')), 5) as delete_verified_owner,
       left(pg_temp.gcw_try(format('update verification.probe_verdict set verdict = %L where id = %L', 'contradicted', :'verdict')), 5) as rewrite_verdict_owner,
       left(pg_temp.gcw_try(format('delete from verification.probe_verdict where id = %L', :'verdict')), 5) as delete_verdict_owner,
       left(pg_temp.gcw_try(format('update verification.claim_triage set disposition = %L where id = %L', 'out_of_scope', (:'r_triage'::jsonb ->> 'triage_id'))), 5) as rewrite_triage_owner,
       left(pg_temp.gcw_try(format('delete from evidence.source_assessment where id = %L', (:'r_prior'::jsonb ->> 'assessment_id'))), 5) as delete_assessment_owner,
       left(pg_temp.gcw_try(format('delete from orchestration.operation_receipt where id = %L', :'claim_receipt')), 5) as delete_receipt_owner,
       left(pg_temp.gcw_try(format('update orchestration.operation_receipt_target set action = %L where receipt_id = %L', 'reused', :'claim_receipt')), 5) as rewrite_target_owner \gset
select extensions.is(:'delete_verified_executor' || ' | ' || :'rewrite_verified_executor' || ' | ' || :'rewrite_locator_executor' || ' | ' || :'restate_verified' || ' | ' || :'delete_verified_owner',
  '42501 | 23001 | 23001 | 23514 CLAIM_NOT_RESTATABLE | 23001',
  'a verified claim is not deleted, rewritten or restated, and an evidence locator is not rewritten, by an agent role or by the owner');
select extensions.is(:'rewrite_verdict_owner' || ' | ' || :'delete_verdict_owner' || ' | ' || :'rewrite_triage_owner' || ' | ' || :'delete_assessment_owner' || ' | ' || :'delete_receipt_owner' || ' | ' || :'rewrite_target_owner',
  '23001 | 23001 | 23001 | 23001 | 23001 | 23001', 'verdicts, triage rows, assessments, receipts and receipt targets are append-only for every role');
select extensions.is((select jsonb_build_object('claims', (select count(*) from evidence.claim) - :'claims_before'::bigint, 'verified', (select c.statement from evidence.claim c where c.id = :'verified'))),
  '{"claims":4,"verified":"Quillfeather 2.0.0 logs every retry."}', 'four claims were added by the chain (one restated) and none removed; the verified claim reads as before');

-- 4.4 tenant and caller
set local role pipeline_agent;
set local app.tenant_id = '';
select pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-no-tenant', 'assertion', 'no tenant', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')))) as no_tenant \gset
set local app.tenant_id = :'other_tenant';
select pg_temp.gcw_try(format('select api.restate_claim(%L, %L, %L)', 'gcw-other-tenant', :'claim', 'restated from another tenant')) as other_tenant_restate,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-claim-1', 'assertion', 'the key of another tenant', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')))) as other_tenant_key,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-other-tenant-claim', 'assertion', 'evidence of another tenant', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')))) as other_tenant_evidence \gset
set local app.tenant_id = :'tenant';
reset role;
set local role verifier_agent;
select left(pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-x2', 'assertion', 'x', '[]')), 5) as verifier_claim,
       left(pg_temp.gcw_try(format('select api.raise_attention_sweep(%L, %L, %L)', 'gcw-x3', 'gcw-forum-weekly', 'manual')), 5) as verifier_sweep \gset
reset role;
set local role executor_service;
select left(pg_temp.gcw_try(format('select api.propose_verdict(%L, %L, %L, %L, %L::jsonb, %L)', 'gcw-x4', :'claim', :'probe', 'contradicted', '{"D1":{}}', 'x')), 5) as executor_verdict \gset
reset role;
set local role app_reader;
select left(pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-x5', 'assertion', 'x', '[]')), 5) as reader_claim,
       left(pg_temp.gcw_try(format('select api.settle_attention_sweep(%L, %L, %L, 0, 0, 0)', 'gcw-x6', :'sweep', 'completed')), 5) as reader_settle \gset
reset role;
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select left(pg_temp.gcw_try(format('select api.propose_verdict(%L, %L, %L, %L, %L::jsonb, %L)', 'gcw-x7', :'claim', :'probe', 'directly_supported', '{"D1":{}}', 'x')), 5) as signed_in_verdict,
       left(pg_temp.gcw_try(format('select api.record_triage(%L, %L, %L, %L, %L)', 'gcw-x8', :'claim_l', 'probe', 'deterministic_local', 'x')), 5) as signed_in_triage \gset
reset role;
set local request.jwt.claims = '';
set local role anon;
select left(pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-x9', 'assertion', 'x', '[]')), 5) as anon_claim \gset
reset role;
select extensions.is(:'no_tenant' || ' | ' || :'other_tenant_restate' || ' | ' || :'other_tenant_key' || ' | ' || :'other_tenant_evidence',
  '42501 TENANT_CONTEXT_REQUIRED | P0002 CLAIM_NOT_FOUND | 23505 IDEMPOTENCY_KEY_FOREIGN_TENANT | P0002 EVIDENCE_NOT_FOUND',
  'the tenant comes from the session: none is refused, and another tenant reaches no claim, key or evidence of this one');
select extensions.is(:'verifier_claim' || ' | ' || :'verifier_sweep' || ' | ' || :'executor_verdict' || ' | ' || :'reader_claim' || ' | ' || :'reader_settle' || ' | ' || :'signed_in_verdict' || ' | ' || :'signed_in_triage' || ' | ' || :'anon_claim',
  '42501 | 42501 | 42501 | 42501 | 42501 | 42501 | 42501 | 42501',
  'a role without the grant is denied: verifier_agent writes no claim or sweep, executor_service no verdict, and app_reader, a signed-in user and anon nothing');

-- 4.5 what a malformed call returns
set local role pipeline_agent;
select pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-v1', 'assertion', 'a quote that is not in the unit', jsonb_build_array(jsonb_build_object('capture_id', :'capture_a', 'node_id', :'node_a', 'quote', 'Quillfeather retries twice.')))) as v_quote,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-v2', 'assertion', 'a unit of another capture', jsonb_build_array(jsonb_build_object('capture_id', :'capture_a', 'node_id', :'node_b', 'quote', 'Probe GCW')))) as v_unit,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-v3', 'assertion', 'no evidence', '[]')) as v_evidence,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-v4', 'no_such_type', 'an unknown type', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')))) as v_type,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb, p_structured => %L::jsonb)', 'gcw-v5', 'assertion', 'a restatement by the back door', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')), '{"path":"restatement"}')) as v_reserved,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb, %L::jsonb)', 'gcw-v6', 'assertion', 'an unknown subject', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')), jsonb_build_array(:'other_tenant'))) as v_subject,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb, p_actor => %L::jsonb)', 'gcw-v7', 'assertion', 'a mission that does not exist', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')), jsonb_build_object('mission_id', :'other_tenant'))) as v_mission,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', '', 'assertion', 'no key', jsonb_build_array(jsonb_build_object('locator_id', :'claim_locator')))) as v_key,
       pg_temp.gcw_try(format('select api.record_claim(%L, %L, %L, %L::jsonb)', 'gcw-v9', 'assertion', 'a curly quote in the unit', jsonb_build_array(jsonb_build_object('capture_id', :'capture_a', 'node_id', :'node_a', 'quote', 'It also''s   documented nowhere.')))) as v_normalised \gset
reset role;
select extensions.is(:'v_quote' || ' | ' || :'v_unit' || ' | ' || :'v_evidence' || ' | ' || :'v_type' || ' | ' || :'v_reserved' || ' | ' || :'v_subject' || ' | ' || :'v_mission' || ' | ' || :'v_key' || ' | ' || :'v_normalised',
  '23514 QUOTE_NOT_IN_UNIT | P0002 EVIDENCE_UNIT_NOT_IN_CAPTURE | 22023 EVIDENCE_REQUIRED | 22023 CLAIM_TYPE_UNKNOWN | 22023 STRUCTURED_RESERVED | P0002 SUBJECT_NOT_FOUND | P0002 MISSION_NOT_FOUND | 22023 IDEMPOTENCY_KEY_REQUIRED | ok',
  'a claim is stored only with a quote that is verbatim in a unit of its capture (whitespace and typographic quotes aside), a known type, known subjects and a key');

-- ------------------------------------------------------------------ 5. the product owner reads what its functions read
select extensions.is((select coalesce(string_agg(c.oid::regclass::text, ', ' order by c.oid::regclass::text), '') from pg_class c
   where c.relkind in ('r','p') and c.relrowsecurity
     and exists (select 1 from aclexplode(c.relacl) a where a.grantee = 'product_api_owner'::regrole)
     and not exists (select 1 from pg_policy p where p.polrelid = c.oid and (p.polroles = '{0}' or 'product_api_owner'::regrole = any(p.polroles)))), '',
  'no row-secured table grants product_api_owner a privilege that no policy lets it use');
select extensions.is((select string_agg(p.polrelid::regclass::text || ':' || p.polcmd::text || ':' || pg_get_expr(p.polqual, p.polrelid), ' ' order by p.polrelid::regclass::text) from pg_policy p
   where p.polname = 'product_api_owner_read' and p.polroles = array['product_api_owner'::regrole::oid]),
  'evidence.claim:r:(tenant_id = product.tenant()) evidence.source_capture:r:(tenant_id = product.tenant())',
  'product_api_owner reads evidence.claim and evidence.source_capture through a SELECT-only policy scoped to the product''s tenant');
select extensions.is((select coalesce(string_agg(t, ', ' order by t), '') from unnest(array['evidence.locator','catalog.entity','guidance.item','acquisition.fetch','ranking.leaderboard','ranking.leaderboard_edition',
     'retrieval.projection_procedure','retrieval.vector_space','retrieval.vector_space_version','content.document_kind_assignment','content.structure_census','content.refresh_check','content.unit_change',
     'content.unit_entity_role','content.document_digest','content.digest_item']) t
   where has_table_privilege('product_api_owner', t, 'select'))
   || ' / ' || (has_table_privilege('product_api_owner', 'evidence.claim', 'insert') or has_table_privilege('product_api_owner', 'evidence.claim', 'update') or has_table_privilege('product_api_owner', 'evidence.claim', 'delete')
                or has_table_privilege('product_api_owner', 'evidence.source_capture', 'insert') or has_table_privilege('product_api_owner', 'evidence.source_capture', 'update'))::text,
  ' / false', 'the 16 tables no product function reads are no longer granted; the two it reads stay read-only');
set local role product_api_owner;
select (select count(*) from evidence.claim c where c.id = :'claim') as owner_sees_shared, (select count(*) from evidence.claim c where c.id = :'foreign_claim') as owner_sees_foreign,
       (select count(*) from evidence.source_capture c where c.id = :'capture_a') as owner_sees_capture \gset
reset role;
select extensions.is(:'owner_sees_shared'::bigint * 100 + :'owner_sees_foreign'::bigint * 10 + :'owner_sees_capture'::bigint, 101::bigint,
  'as product_api_owner: the shared claim and the capture are visible, a claim of another tenant is not');
insert into access.source_restriction(tenant_id, source_id, kind, effect, reason) values (:'tenant', :'source_a', 'takedown', 'deny_all', 'fixture: the source asked for removal');
set local role product_api_owner;
select product.restricted(:'capture_a', null, array['deny_all']) as capture_restricted, product.restricted(:'capture_b', null, array['deny_all']) as other_capture_restricted \gset
reset role;
select extensions.ok(:'capture_restricted' and not :'other_capture_restricted', 'a restriction placed on a source reaches its captures (product.restricted reads the capture''s source)');
insert into auth.users(id, instance_id, aud, role, email) values (:'user_a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'gcw-a@lab.invalid');
set local app.tenant_id = '';
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select api.product_command(null, 'create_workspace', 'gcw-a-workspace', null, '{"name":"GCW authoring"}') ->> 'workspaceId' as ws_a \gset
select pg_temp.gcw_try(format('select api.product_command(%L, %L, %L, null, %L::jsonb)', :'ws_a', 'create_work', 'gcw-a-lesson-shared', jsonb_build_object('kind', 'lesson', 'slug', 'gcw-cites-shared', 'revision', jsonb_build_object(
          'title', 'Cites a shared claim', 'body', '{"formatVersion":1,"blocks":[{"id":"9c000000-0000-4000-8000-0000000000c1","kind":"markdown","content":{"text":"Quillfeather retries."}}],"metadata":{}}'::jsonb,
          'assertions', jsonb_build_array(jsonb_build_object('kind', 'claim', 'statement', 'Quillfeather retries once.', 'support_status', 'supported', 'uses_claim_id', :'claim')))))) as cite_shared,
       pg_temp.gcw_try(format('select api.product_command(%L, %L, %L, null, %L::jsonb)', :'ws_a', 'create_work', 'gcw-a-lesson-foreign', jsonb_build_object('kind', 'lesson', 'slug', 'gcw-cites-foreign', 'revision', jsonb_build_object(
          'title', 'Cites a claim of another tenant', 'body', '{"formatVersion":1,"blocks":[{"id":"9c000000-0000-4000-8000-0000000000c2","kind":"markdown","content":{"text":"x"}}],"metadata":{}}'::jsonb,
          'assertions', jsonb_build_array(jsonb_build_object('kind', 'claim', 'statement', 'A statement citing another tenant.', 'support_status', 'supported', 'uses_claim_id', :'foreign_claim')))))) as cite_foreign,
       pg_temp.gcw_try(format('select api.product_command(%L, %L, %L, null, %L::jsonb)', :'ws_a', 'create_work', 'gcw-a-lesson-missing', jsonb_build_object('kind', 'lesson', 'slug', 'gcw-cites-missing', 'revision', jsonb_build_object(
          'title', 'Cites a claim that does not exist', 'body', '{"formatVersion":1,"blocks":[{"id":"9c000000-0000-4000-8000-0000000000c3","kind":"markdown","content":{"text":"x"}}],"metadata":{}}'::jsonb,
          'assertions', jsonb_build_array(jsonb_build_object('kind', 'claim', 'statement', 'A statement citing nothing.', 'support_status', 'supported', 'uses_claim_id', :'other_tenant')))))) as cite_missing \gset
reset role;
set local request.jwt.claims = '';
set local app.tenant_id = :'tenant';
select extensions.is(:'cite_shared' || ' | ' || :'cite_foreign' || ' | ' || :'cite_missing', 'ok | P0001 NOT_FOUND | P0001 NOT_FOUND',
  'a statement that cites a shared claim is accepted; one that cites a claim of another tenant, or no claim, is refused');
select extensions.is((select count(*) from inquiry.assertion a where a.uses_claim_id = :'claim'), 1::bigint, 'the accepted statement is stored with the shared claim it cites');

select * from extensions.finish();
rollback;
