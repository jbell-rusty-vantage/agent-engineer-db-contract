-- Build 08: the authoring reads and the author's hand-off inside the product API (migration
-- 20261116140000_build08_authoring_review_reads.sql): list_workspaces, get_revision_structure, mark_ready_for_review and
-- list_reviews, as signed-in members, a reader, a non-member and an agent client; and a statement that names the shared claim
-- it restates (accepted for this tenant's claim, refused for another tenant's).
-- Fixtures are created here and rolled back; the suite passes on an empty installation and on a populated one.
-- Calls made as another role are taken with \gset and asserted after `reset role`, because pgTAP's own tables belong to the
-- role that opened the plan.
begin;
create extension if not exists pgtap with schema extensions;
select extensions.plan(49);

\set tenant '00000000-0000-7000-8000-000000000001'
\set other_tenant 'a7b00000-0000-7000-8000-0000000000ff'
\set user_a 'a7b00000-0000-4000-8000-00000000000a'
\set user_b 'a7b00000-0000-4000-8000-00000000000b'
\set user_d 'a7b00000-0000-4000-8000-00000000000d'
\set user_c 'a7b00000-0000-4000-8000-00000000000c'
\set claims_a '{"role":"authenticated","sub":"a7b00000-0000-4000-8000-00000000000a"}'
\set claims_b '{"role":"authenticated","sub":"a7b00000-0000-4000-8000-00000000000b"}'
\set claims_d '{"role":"authenticated","sub":"a7b00000-0000-4000-8000-00000000000d"}'
\set claims_c '{"role":"authenticated","sub":"a7b00000-0000-4000-8000-00000000000c"}'
\set claim_ok 'a7b00000-0000-7000-8000-0000000000c1'
\set claim_other 'a7b00000-0000-7000-8000-0000000000c2'
\set blk 'a7b00000-0000-4000-8000-0000000000b1'
\set blk2 'a7b00000-0000-4000-8000-0000000000b2'
\set occ_lesson 'a7b00000-0000-4000-8000-0000000000e1'
\set occ_activity 'a7b00000-0000-4000-8000-0000000000e2'
\set outcome_key 'a7b00000-0000-4000-8000-0000000000e3'
\set requirement_key 'a7b00000-0000-4000-8000-0000000000e4'
\set rule '{"schema":"aieng.evidence-rule.v2","observables":["working retry wrapper","explanation"],"facet":"assisted"}'

-- The answer of one statement run as the current role: its text, or 'ERR <sqlstate> <message> <detail>'.
create function pg_temp.ar_try(p_sql text) returns text language plpgsql as $f$
declare r text; d text;
begin
  execute p_sql into r;
  return coalesce(r, 'null');
exception when others then
  get stacked diagnostics d = pg_exception_detail;
  return pg_catalog.btrim(format('ERR %s %s %s', sqlstate, sqlerrm, coalesce(d, '')));
end $f$;
grant execute on function pg_temp.ar_try(text) to public;
-- A v2 body with one text block.
create function pg_temp.ar_body(k uuid, md text) returns jsonb language sql immutable as $f$
  select jsonb_build_object('formatVersion', 2, 'blocks', jsonb_build_array(jsonb_build_object('key', k, 'type', 'text', 'content', jsonb_build_object('markdown', md))))
$f$;
grant execute on function pg_temp.ar_body(uuid, text) to public;

-- ------------------------------------------------------------------ 1. fixtures: one shared claim of this tenant, one of another
set local app.tenant_id = :'tenant';
insert into evidence.claim(id, tenant_id, claim_type, statement, producer_origin_digest)
 values (:'claim_ok', :'tenant', 'recommendation', 'ar fixture: wrapped retries are idempotent', 'sha256:' || repeat('b', 64));
set local app.tenant_id = :'other_tenant';
insert into evidence.claim(id, tenant_id, claim_type, statement, producer_origin_digest)
 values (:'claim_other', :'other_tenant', 'recommendation', 'ar fixture: a claim of another tenant', 'sha256:' || repeat('c', 64));
set local app.tenant_id = '';
insert into auth.users(id, instance_id, aud, role, email) values
 (:'user_a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'arsuite-a@lab.invalid'),
 (:'user_b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'arsuite-b@lab.invalid'),
 (:'user_d', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'arsuite-d@lab.invalid'),
 (:'user_c', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'arsuite-c@lab.invalid');

-- ------------------------------------------------------------------ 2. A: a shared workspace with an editor and a reader, and a module
set local role authenticated;
set local request.jwt.claims = :'claims_a';
select api.product_command(null, 'create_workspace', 'arsuite-ws', null, '{"name":"AR authoring"}') ->> 'workspaceId' as ws \gset
select api.product_command(null, 'ensure_personal_workspace', 'arsuite-a-personal', null, '{}') ->> 'workspaceId' as pws_a \gset
select api.product_command(:'ws', 'grant_member', 'arsuite-grant-b', null, jsonb_build_object('principal_id', :'user_b', 'role', 'editor')) is not null as granted_b \gset
select api.product_command(:'ws', 'grant_member', 'arsuite-grant-d', null, jsonb_build_object('principal_id', :'user_d', 'role', 'reader')) is not null as granted_d \gset
select api.product_command(:'ws', 'create_work', 'arsuite-lesson', null, jsonb_build_object('kind', 'lesson', 'slug', 'arsuite-retries', 'revision', jsonb_build_object(
   'title', 'Retries', 'body', pg_temp.ar_body(:'blk', 'Wrapped retries are idempotent.'),
   'bindings', jsonb_build_array(jsonb_build_object('local_key', 'claim-1', 'relation', 'supports', 'target', jsonb_build_object('kind', 'claim', 'id', :'claim_ok'), 'block_key', :'blk')),
   'runtime', jsonb_build_array(jsonb_build_object('local_key', 'py', 'kind', 'language_runtime', 'name', 'python', 'version_spec', '>=3.12', 'resolved_version', '3.12.7')),
   'assertions', jsonb_build_array(jsonb_build_object('kind', 'claim', 'statement', 'Wrapped retries are idempotent.', 'support_status', 'supported',
                                                      'block_key', :'blk', 'uses_claim_id', :'claim_ok'))))) as lesson \gset
select pg_temp.ar_try(format($q$select api.product_command(%L, 'create_work', 'arsuite-other-tenant', null, %L)::text$q$, :'ws',
   jsonb_build_object('kind', 'lesson', 'slug', 'arsuite-other-tenant', 'revision', jsonb_build_object('title', 'Other tenant', 'body', pg_temp.ar_body(:'blk2', 'x'),
     'assertions', jsonb_build_array(jsonb_build_object('kind', 'claim', 'statement', 'x', 'support_status', 'supported', 'block_key', :'blk2', 'uses_claim_id', :'claim_other')))))) as other_tenant_cite \gset
select api.product_command(:'ws', 'create_work', 'arsuite-activity', null, jsonb_build_object('kind', 'activity', 'slug', 'arsuite-activity', 'revision', jsonb_build_object(
   'title', 'Wrap a call', 'body', pg_temp.ar_body(:'blk2', 'Wrap one call and run it twice.')))) as activity \gset
select api.product_command(:'ws', 'create_work', 'arsuite-prereq', null, jsonb_build_object('kind', 'lesson', 'slug', 'arsuite-tools', 'revision', jsonb_build_object(
   'title', 'Tool calls', 'body', pg_temp.ar_body(:'blk2', 'One tool call.')))) as prereq \gset
select :'lesson'::jsonb ->> 'revisionId' as lesson_rev, :'activity'::jsonb ->> 'revisionId' as activity_rev, :'prereq'::jsonb ->> 'revisionId' as prereq_rev \gset
select api.product_command(:'ws', 'create_work', 'arsuite-module', null, jsonb_build_object('kind', 'module', 'slug', 'arsuite-module', 'revision', jsonb_build_object(
   'title', 'Retries module', 'body', pg_temp.ar_body(:'blk2', 'A lesson and the activity that proves it.'),
   'parts', jsonb_build_array(jsonb_build_object('occurrence_key', :'occ_lesson', 'child_revision_id', :'lesson_rev', 'ordinal', 0),
                              jsonb_build_object('occurrence_key', :'occ_activity', 'child_revision_id', :'activity_rev', 'ordinal', 1, 'role', 'optional')),
   'outcomes', jsonb_build_array(jsonb_build_object('outcome_key', :'outcome_key', 'statement', 'Wraps a call so a retry is safe', 'bloom_level', 'apply', 'evidence_rule', :'rule'::jsonb)),
   'requirements', jsonb_build_array(jsonb_build_object('requirement_key', :'requirement_key', 'kind', 'mandatory_activity', 'occurrence_key', :'occ_activity',
      'rationale', 'The activity proves the outcome', 'options', jsonb_build_array(jsonb_build_object('route', 'standard', 'activity_revision_id', :'activity_rev',
      'evidence_rule', :'rule'::jsonb, 'approval_state', 'proposed')))),
   'prerequisites', jsonb_build_array(jsonb_build_object('required_revision_id', :'prereq_rev', 'strength', 'required', 'rationale', 'Needs one tool call first')),
   'runtime', jsonb_build_array(jsonb_build_object('local_key', 'py', 'kind', 'language_runtime', 'name', 'python', 'version_spec', '>=3.12'))))) as module \gset
select :'module'::jsonb ->> 'revisionId' as module_rev, :'module'::jsonb ->> 'workId' as module_work, :'lesson'::jsonb ->> 'workId' as lesson_work \gset
select api.product_read(:'ws', 'get_revision_structure', jsonb_build_object('revision_id', :'module_rev')) as structure_a,
       api.product_read(null, 'get_revision_structure', jsonb_build_object('revision_id', :'lesson_rev')) as lesson_structure_a,
       api.product_read(null, 'list_workspaces', '{}') as workspaces_a,
       api.product_read(:'ws', 'preview_exposure', jsonb_build_object('root_revision_id', :'module_rev', 'ceiling', 'workspace')) ->> 'closure_sha256' as closure_a \gset
-- a private hand-over conversation of A, which nobody else may attach or read
select api.product_command(:'ws', 'create_thread', 'arsuite-a-private-thread', null, '{"title":"A private","purpose":"authoring","visibility":"private"}') ->> 'threadId' as private_thread \gset

-- ------------------------------------------------------------------ 3. C: a non-member with a private draft of its own
set local request.jwt.claims = :'claims_c';
select api.product_command(null, 'ensure_personal_workspace', 'arsuite-c-personal', null, '{}') ->> 'workspaceId' as pws_c \gset
select api.product_command(:'pws_c', 'create_work', 'arsuite-c-draft', null, jsonb_build_object('kind', 'lesson', 'slug', 'arsuite-c-draft', 'revision', jsonb_build_object(
   'title', 'C private draft', 'body', pg_temp.ar_body(:'blk2', 'Private.')))) ->> 'revisionId' as c_draft \gset
select api.product_read(null, 'list_workspaces', '{}') as workspaces_c,
       pg_temp.ar_try(format($q$select api.product_read(null, 'get_revision_structure', %L)::text$q$, jsonb_build_object('revision_id', :'module_rev'))) as c_structure,
       pg_temp.ar_try(format($q$select api.product_read(%L, 'get_revision_structure', %L)::text$q$, :'ws', jsonb_build_object('revision_id', :'module_rev'))) as c_structure_ws,
       pg_temp.ar_try(format($q$select api.product_read(%L, 'list_reviews', '{}')::text$q$, :'ws')) as c_reviews,
       pg_temp.ar_try(format($q$select api.product_command(%L, 'mark_ready_for_review', 'arsuite-c-ready', null, %L)::text$q$, :'ws',
                             jsonb_build_object('revision_id', :'module_rev', 'note', 'not mine'))) as c_ready \gset

-- A reads C's private draft: refused
set local request.jwt.claims = :'claims_a';
select pg_temp.ar_try(format($q$select api.product_read(null, 'get_revision_structure', %L)::text$q$, jsonb_build_object('revision_id', :'c_draft'))) as a_reads_c_draft,
       pg_temp.ar_try(format($q$select api.product_command(%L, 'mark_ready_for_review', 'arsuite-a-ready-foreign', null, %L)::text$q$, :'ws',
                             jsonb_build_object('revision_id', :'c_draft', 'note', 'not in this workspace'))) as a_ready_foreign \gset

-- ------------------------------------------------------------------ 4. D: a reader sees, and cannot mark ready
set local request.jwt.claims = :'claims_d';
select api.product_read(null, 'list_workspaces', '{}') as workspaces_d,
       api.product_read(null, 'list_workspaces', '{"writable_only":true}') as writable_d,
       pg_temp.ar_try(format($q$select (api.product_read(%L, 'get_revision_structure', %L) ->> 'revisionId')$q$, :'ws', jsonb_build_object('revision_id', :'module_rev'))) as d_structure,
       pg_temp.ar_try(format($q$select api.product_command(%L, 'mark_ready_for_review', 'arsuite-d-ready', null, %L)::text$q$, :'ws',
                             jsonb_build_object('revision_id', :'module_rev', 'note', 'a reader'))) as d_ready \gset

-- ------------------------------------------------------------------ 5. B: the editor hands the module over through an MCP client grant (an agent)
set local request.jwt.claims = :'claims_b';
select api.product_command(null, 'create_client_grant', 'arsuite-b-grant', null,
   jsonb_build_object('client_kind', 'mcp', 'label', 'ar agent', 'scopes', jsonb_build_array('author', 'read', 'library'))) ->> 'token' as b_token \gset
select api.product_command(null, 'create_client_grant', 'arsuite-b-grant-narrow', null,
   jsonb_build_object('client_kind', 'mcp', 'label', 'ar agent narrow', 'scopes', jsonb_build_array('read'), 'workspace_ids', jsonb_build_array(:'ws'))) ->> 'token' as b_narrow \gset
select jsonb_build_object('x-aieng-client-token', :'b_token')::text as b_header, jsonb_build_object('x-aieng-client-token', :'b_narrow')::text as b_narrow_header \gset
set local request.headers = :'b_narrow_header';
select api.product_read(null, 'list_workspaces', '{}') as workspaces_b_narrow \gset
set local request.headers = :'b_header';
select api.product_command(:'ws', 'create_thread', 'arsuite-b-thread', null, '{"title":"Review request: Retries module","purpose":"authoring","visibility":"workspace"}') ->> 'threadId' as thread \gset
select api.product_command(:'ws', 'append_message', 'arsuite-b-note', null, jsonb_build_object('thread_id', :'thread', 'role', 'assistant',
   'content', jsonb_build_object('schema', 'aieng.message.v1', 'parts', jsonb_build_array(jsonb_build_object('text', 'Hand-over: ready for your review.'))))) is not null as noted \gset
select pg_temp.ar_try(format($q$select api.product_command(%L, 'mark_ready_for_review', 'arsuite-b-ready-private', null, %L)::text$q$, :'ws',
   jsonb_build_object('revision_id', :'module_rev', 'note', 'n', 'thread_id', :'private_thread'))) as b_private_thread,
       pg_temp.ar_try(format($q$select api.product_command(%L, 'mark_ready_for_review', 'arsuite-b-ready-blank', null, %L)::text$q$, :'ws',
   jsonb_build_object('revision_id', :'module_rev', 'note', '  '))) as b_blank_note \gset
select api.product_command(:'ws', 'mark_ready_for_review', 'arsuite-b-ready', null, jsonb_build_object('revision_id', :'module_rev', 'ceiling', 'workspace',
   'note', 'Retries module: one lesson, one activity; the lesson restates a verified claim.', 'thread_id', :'thread')) as ready \gset
select api.product_command(:'ws', 'mark_ready_for_review', 'arsuite-b-ready-again', null, jsonb_build_object('revision_id', :'module_rev', 'ceiling', 'workspace',
   'note', 'again', 'thread_id', :'thread')) as ready_again \gset
select pg_temp.ar_try(format($q$select api.product_command(%L, 'review_revision', 'arsuite-b-review', null, %L)::text$q$, :'ws',
   jsonb_build_object('work_id', :'module_work', 'revision_id', :'module_rev', 'review', jsonb_build_object('reviewType', 'release_review', 'decision', 'approve',
                      'closure_sha256', :'closure_a', 'ceiling', 'workspace')))) as b_agent_review \gset
-- an agent's own peer note is recorded, labelled as an agent's, and does not count as a person's review
select api.product_command(:'ws', 'review_revision', 'arsuite-b-peer', null, jsonb_build_object('work_id', :'module_work', 'revision_id', :'module_rev',
   'review', jsonb_build_object('reviewType', 'peer_check', 'decision', 'looks_complete'))) ->> 'eventId' as agent_peer_event \gset
select api.product_read(:'ws', 'list_reviews', jsonb_build_object('revision_id', :'module_rev')) as reviews_before \gset
set local request.headers = '';

-- ------------------------------------------------------------------ 6. A, a person (no client grant), replies and records the review
set local request.jwt.claims = :'claims_a';
select api.product_command(:'ws', 'append_message', 'arsuite-a-reply', null, jsonb_build_object('thread_id', :'thread', 'role', 'user',
   'content', jsonb_build_object('schema', 'aieng.message.v1', 'parts', jsonb_build_array(jsonb_build_object('text', 'Tighten the activity rubric.'))))) is not null as replied \gset
select api.product_command(:'ws', 'review_revision', 'arsuite-a-review', null, jsonb_build_object('work_id', :'module_work', 'revision_id', :'module_rev',
   'review', jsonb_build_object('reviewType', 'release_review', 'decision', 'approve', 'closure_sha256', :'closure_a', 'ceiling', 'workspace'))) ->> 'eventId' as human_review \gset
select api.product_command(:'ws', 'review_revision', 'arsuite-a-lesson-review', null, jsonb_build_object('work_id', :'lesson_work', 'revision_id', :'lesson_rev',
   'review', jsonb_build_object('reviewType', 'release_review', 'decision', 'changes_requested'))) ->> 'eventId' as unrequested_review \gset

-- ------------------------------------------------------------------ 7. B reads the outcome; D reads it too; filters
set local request.jwt.claims = :'claims_b';
select api.product_read(:'ws', 'list_reviews', jsonb_build_object('revision_id', :'module_rev')) as reviews_after,
       api.product_read(:'ws', 'list_reviews', '{}') as reviews_all,
       api.product_read(:'ws', 'list_reviews', '{"status":"awaiting_review"}') as reviews_awaiting,
       pg_temp.ar_try(format($q$select api.product_read(%L, 'list_reviews', '{"status":"done"}')::text$q$, :'ws')) as bad_status \gset
set local request.jwt.claims = :'claims_d';
select api.product_read(:'ws', 'list_reviews', '{}') ->> 'requests' as reviews_d \gset
-- a newer head supersedes an unreviewed request
set local request.jwt.claims = :'claims_a';
select api.product_command(:'ws', 'mark_ready_for_review', 'arsuite-a-ready-activity', null, jsonb_build_object('revision_id', :'activity_rev', 'note', 'The activity alone')) ->> 'eventId' as activity_request \gset
select api.product_command(:'ws', 'revise_work', 'arsuite-a-revise-activity', :'activity_rev', jsonb_build_object('work_id', :'activity'::jsonb ->> 'workId', 'revision', jsonb_build_object(
   'title', 'Wrap a call, revised', 'body', pg_temp.ar_body(:'blk2', 'Wrap one call, run it twice, paste both outputs.')))) is not null as revised \gset
select api.product_read(:'ws', 'list_reviews', jsonb_build_object('revision_id', :'activity_rev')) -> 'requests' -> 0 ->> 'status' as activity_status,
       api.product_read(:'ws', 'get_revision_structure', jsonb_build_object('revision_id', :'module_rev')) -> 'parts' as parts_after_revise \gset

-- anon: the entrypoints are not callable
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select pg_temp.ar_try($q$select api.product_read(null, 'list_workspaces', '{}')::text$q$) as anon_list \gset
reset role;
set local request.jwt.claims = '';

-- ------------------------------------------------------------------ assertions: a statement that names the shared claim it restates
select extensions.is(:'lesson_structure_a'::jsonb -> 'statements' -> 0 ->> 'usesClaimId', :'claim_ok',
  'a statement naming the shared claim it restates is saved, and the structure read returns the claim it names');
select extensions.ok(:'other_tenant_cite' like 'ERR P0001 NOT_FOUND%cited shared claim%', 'a statement naming another tenant''s claim is refused NOT_FOUND (cited shared claim): ' || :'other_tenant_cite');

-- ------------------------------------------------------------------ list_workspaces
select extensions.is((select string_agg(x ->> 'kind' || ':' || (x ->> 'role') || ':' || (x ->> 'canWrite'), ',' order by n) from jsonb_array_elements(:'workspaces_a'::jsonb) with ordinality t(x, n)
                       where x ->> 'workspaceId' in (:'ws', :'pws_a')), 'personal:owner:true,shared:owner:true',
  'A lists its personal workspace first and the shared one it owns, both writable');
select extensions.ok(not exists (select 1 from jsonb_array_elements(:'workspaces_c'::jsonb) x where x ->> 'workspaceId' = :'ws')
  and exists (select 1 from jsonb_array_elements(:'workspaces_c'::jsonb) x where x ->> 'workspaceId' = :'pws_c'),
  'a non-member does not see the shared workspace; it sees its own');
select extensions.ok(not exists (select 1 from jsonb_array_elements(:'workspaces_a'::jsonb) x where x ->> 'workspaceId' = :'pws_c'), 'nobody lists another member''s personal workspace');
select extensions.is((select x ->> 'role' || ':' || (x ->> 'canWrite') || ':' || (x ->> 'ownedByYou') from jsonb_array_elements(:'workspaces_d'::jsonb) x where x ->> 'workspaceId' = :'ws'),
  'reader:false:false', 'a reader lists the workspace as a reader that cannot write and does not own it');
select extensions.is(jsonb_array_length(:'writable_d'::jsonb), 0, 'writable_only leaves out the workspaces a reader cannot write');
select extensions.is((select string_agg(x ->> 'workspaceId', ',') from jsonb_array_elements(:'workspaces_b_narrow'::jsonb) x), :'ws',
  'a client grant that names workspaces lists only those');

-- ------------------------------------------------------------------ get_revision_structure
select extensions.is((select string_agg(x ->> 'childRevisionId' || '@' || (x ->> 'ordinal') || ':' || (x ->> 'role') || ':' || (x ->> 'childKind'), ',' order by (x ->> 'ordinal')::int)
                       from jsonb_array_elements(:'structure_a'::jsonb -> 'parts') x),
  :'lesson_rev' || '@0:recommended:lesson,' || :'activity_rev' || '@1:optional:activity', 'parts: each exact child revision with its ordinal, role and kind');
select extensions.is(:'structure_a'::jsonb -> 'outcomes' -> 0 ->> 'outcomeKey', :'outcome_key', 'outcomes: the outcome key');
select extensions.is(:'structure_a'::jsonb -> 'outcomes' -> 0 -> 'evidenceRule', :'rule'::jsonb, 'outcomes: the evidence rule as saved');
select extensions.is((select x ->> 'kind' || ':' || (x ->> 'occurrenceKey') || ':' || (x -> 'options' -> 0 ->> 'route') || ':' || (x -> 'options' -> 0 ->> 'approvalState') || ':' || (x -> 'options' -> 0 ->> 'activityRevisionId')
                       from jsonb_array_elements(:'structure_a'::jsonb -> 'requirements') x),
  'mandatory_activity:' || :'occ_activity' || ':standard:proposed:' || :'activity_rev', 'requirements: kind, the placed part and the proposed route');
select extensions.is((select x ->> 'requiredRevisionId' || ':' || (x ->> 'strength') from jsonb_array_elements(:'structure_a'::jsonb -> 'prerequisites') x),
  :'prereq_rev' || ':required', 'prerequisites: the exact required revision and its strength');
select extensions.is((select x ->> 'name' || ' ' || (x ->> 'versionSpec') from jsonb_array_elements(:'structure_a'::jsonb -> 'runtime') x), 'python >=3.12', 'runtime: the version range claimed');
select extensions.is((select x ->> 'resolvedVersion' from jsonb_array_elements(:'lesson_structure_a'::jsonb -> 'runtime') x), '3.12.7', 'runtime: the version that ran');
select extensions.is((select x ->> 'localKey' || ':' || (x ->> 'relation') || ':' || (x -> 'target' ->> 'kind') || ':' || (x -> 'target' ->> 'id') || ':' || (x ->> 'blockKey')
                       from jsonb_array_elements(:'lesson_structure_a'::jsonb -> 'bindings') x),
  'claim-1:supports:claim:' || :'claim_ok' || ':' || :'blk', 'bindings: local key, relation, typed target and the block it anchors to');
select extensions.ok((:'structure_a'::jsonb ->> 'isHead')::boolean and :'structure_a'::jsonb ->> 'workKind' = 'module' and :'structure_a'::jsonb ->> 'contentSha256' ~ '^[0-9a-f]{64}$',
  'the structure says the work kind, whether it is the head and the content digest');
select extensions.is(:'d_structure'::text, :'module_rev', 'a reader of the workspace reads the structure');
select extensions.ok(:'c_structure' like 'ERR P0001 NOT_FOUND%revision%' and :'c_structure_ws' like 'ERR P0001 NOT_FOUND%', 'a non-member gets NOT_FOUND for the structure, with or without the workspace');
select extensions.ok(:'a_reads_c_draft' like 'ERR P0001 NOT_FOUND%revision%', 'another member''s private draft is NOT_FOUND');
select extensions.is((select string_agg(x ->> 'childIsHead', ',' order by (x ->> 'ordinal')::int) from jsonb_array_elements(:'parts_after_revise'::jsonb) x), 'true,false',
  'parts report whether each placed child is still its work''s head: the revised activity is not');

-- ------------------------------------------------------------------ mark_ready_for_review
select extensions.ok(:'ready'::jsonb ->> 'eventId' is not null and (:'ready'::jsonb ->> 'alreadyRequested')::boolean = false, 'an editor marks the module ready for review');
select extensions.is(:'ready'::jsonb ->> 'closureSha256', :'closure_a', 'the request carries the closure the database computes, equal to the exposure preview');
select extensions.is(:'ready'::jsonb ->> 'threadId', :'thread', 'the request names its hand-over conversation');
select extensions.ok(:'ready_again'::jsonb ->> 'eventId' = :'ready'::jsonb ->> 'eventId' and (:'ready_again'::jsonb ->> 'alreadyRequested')::boolean,
  'marking the same revision ready again at the same ceiling returns the first request');
select extensions.is((select e.kind || ':' || e.actor_kind || ':' || e.client_surface || ':' || e.actor_id from authoring.event e where e.id = (:'ready'::jsonb ->> 'eventId')::uuid),
  'revision_proposed:agent:harness:' || :'user_b', 'it is stored as a revision_proposed event of the author, labelled an agent''s through an MCP grant');
select extensions.ok(:'d_ready' like 'ERR P0001 FORBIDDEN%', 'a reader cannot mark a revision ready: ' || :'d_ready');
select extensions.ok(:'c_ready' like 'ERR P0001 NOT_FOUND%workspace%', 'a non-member cannot: ' || :'c_ready');
select extensions.ok(:'a_ready_foreign' like 'ERR P0001 NOT_FOUND%revision%', 'a revision of another workspace cannot be marked: ' || :'a_ready_foreign');
select extensions.ok(:'b_private_thread' like 'ERR P0001 NOT_FOUND%thread%', 'another member''s private conversation cannot be attached: ' || :'b_private_thread');
select extensions.ok(:'b_blank_note' like 'ERR P0001 VALIDATION%note%', 'a blank note is refused');
select extensions.ok(:'b_agent_review' like 'ERR P0001 FORBIDDEN%', 'the agent still cannot record the release review itself');

-- ------------------------------------------------------------------ list_reviews
select extensions.is(:'reviews_before'::jsonb -> 'requests' -> 0 ->> 'status', 'awaiting_review', 'before a person reviews, the request is awaiting review');
select extensions.is(jsonb_array_length(:'reviews_before'::jsonb -> 'requests' -> 0 -> 'reviews'), 1, 'the agent''s own peer note is listed with the request');
select extensions.is(:'reviews_before'::jsonb -> 'requests' -> 0 -> 'reviews' -> 0 ->> 'actorKind', 'agent', 'and labelled an agent''s, so it is not read as a person''s review');
select extensions.is(:'reviews_after'::jsonb -> 'requests' -> 0 ->> 'status', 'reviewed', 'after the person''s release review the request is reviewed');
select extensions.is((select x ->> 'decision' || ':' || (x ->> 'actorKind') from jsonb_array_elements(:'reviews_after'::jsonb -> 'requests' -> 0 -> 'reviews') x where x ->> 'eventId' = :'human_review'),
  'approve:human', 'the person''s review is listed with its decision');
select extensions.is((select string_agg(x ->> 'role' || ':' || (x ->> 'fromPerson'), ',' order by (x ->> 'seq')::int) from jsonb_array_elements(:'reviews_after'::jsonb -> 'requests' -> 0 -> 'replies') x),
  'user:true', 'replies are the messages after the hand-over note: the person''s reply, not the note itself');
select extensions.is(:'reviews_after'::jsonb -> 'requests' -> 0 -> 'replies' -> 0 -> 'content' -> 'parts' -> 0 ->> 'text', 'Tighten the activity rubric.', 'the reply text is returned');
select extensions.is(:'reviews_after'::jsonb -> 'requests' -> 0 ->> 'note', 'Retries module: one lesson, one activity; the lesson restates a verified claim.', 'the request keeps the author''s note');
select extensions.ok(exists (select 1 from jsonb_array_elements(:'reviews_all'::jsonb -> 'reviews') x where x ->> 'eventId' = :'unrequested_review' and x ->> 'decision' = 'changes_requested'),
  'a review recorded without a request is listed under reviews');
select extensions.ok(not exists (select 1 from jsonb_array_elements(:'reviews_awaiting'::jsonb -> 'requests') x where x ->> 'requestId' = :'ready'::jsonb ->> 'eventId'),
  'the status filter leaves out the reviewed request');
select extensions.ok(:'bad_status' like 'ERR P0001 VALIDATION%status%', 'an unknown status filter is refused');
select extensions.is(:'activity_status'::text, 'superseded', 'a request whose revision is no longer the head and was not reviewed is superseded');
select extensions.ok(:'c_reviews' like 'ERR P0001 NOT_FOUND%workspace%', 'a non-member cannot list a workspace''s reviews: ' || :'c_reviews');
select extensions.ok(:'reviews_d' like '%' || (:'ready'::jsonb ->> 'eventId') || '%', 'a reader of the workspace lists its review requests');

-- ------------------------------------------------------------------ grants
select extensions.ok(:'anon_list' like 'ERR 42501%', 'anon cannot call the product read entrypoint');
select extensions.is((select count(*) from pg_proc p where p.oid in ('product.dispatch_authoring_read(uuid, text, jsonb, uuid, access.client_grant)'::regprocedure,
                                                                     'product.dispatch_authoring_command(uuid, text, uuid, jsonb, uuid, access.client_grant)'::regprocedure)
                       and p.proowner = 'product_api_owner'::regrole and not p.prosecdef and p.proconfig @> array['search_path=""']
                       and not has_function_privilege('authenticated', p.oid, 'execute') and not has_function_privilege('anon', p.oid, 'execute')
                       and not has_function_privilege('service_role', p.oid, 'execute')
                       and not exists (select 1 from aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a where a.grantee = 0)),
  2::bigint, 'the two dispatchers are owned by product_api_owner, security invoker, with an empty search path, and executable by nobody else');
select extensions.ok((select bool_and(p.prosecdef and p.proowner = 'product_api_owner'::regrole and has_function_privilege('authenticated', p.oid, 'execute')
                                      and not has_function_privilege('anon', p.oid, 'execute'))
                        from pg_proc p where p.oid in ('api.product_read(uuid, text, jsonb)'::regprocedure, 'api.product_command(uuid, text, text, uuid, jsonb)'::regprocedure)),
  'the re-created entrypoints keep their owner, SECURITY DEFINER and grants');

select * from extensions.finish();
rollback;
