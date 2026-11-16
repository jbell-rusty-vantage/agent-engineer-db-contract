-- Build 08 (batch AIDB-3): the reads and the hand-off an authoring agent lacked, inside the product API.
--
-- An agent that authors through api.product_command / api.product_read could not (a) learn the ids of the shared workspaces
-- it belongs to, (b) read back what a saved revision binds, contains, promises and requires, (c) mark a revision ready for a
-- person's review outside an accepted research brief, or (d) list the reviews and replies people left. The event kinds for
-- (c) and (d) existed in authoring.event ('revision_proposed', 'reviewed', 'feedback') and only 'reviewed' was written.
--
--   read    list_workspaces          the caller's own active memberships (role, whether it can write); a client grant that
--                                    names workspaces narrows the list to them
--   read    get_revision_structure   one revision's bindings, parts (with the child's head state), outcomes with alignments,
--                                    requirements with their routes, prerequisites, runtime requirements and statements; for
--                                    members of the revision's workspace only (a release reader has get_lesson_view)
--   command mark_ready_for_review    the author's own act: a 'revision_proposed' event on an exact revision with the exposure
--                                    closure the database computes, the ceiling, the hand-over note and, optionally, the
--                                    workspace conversation it lives in; owner or editor; idempotent per revision and ceiling
--   read    list_reviews             a workspace's review requests with a derived status (awaiting_review, reviewed by a
--                                    person, superseded by a newer head), the reviews recorded on the revision since the
--                                    request, the replies in its hand-over conversation, and reviews made without a request
--
-- Nothing here records a person's decision: a review is still review_revision, refused to agent clients for the human review
-- types, and freezing and offering still need a person's matching review. Status 'reviewed' counts human reviews only.
-- Access follows the product model of 20261105010300: api.product_read / api.product_command (SECURITY DEFINER, owned by
-- product_api_owner) resolve the caller from the verified JWT (product.actor) and the client grant, and the product
-- functions decide visibility by membership (product.role_in). The two entrypoints keep their signatures, owner and grants;
-- they only route the four new operation names to two new dispatchers, which no other role may execute.
-- Lab draft for disposable-aieng-build04; suite supabase/tests/authoring_review_reads.sql; supabase/tests/api_default_closed.sql
-- covers the entrypoints and the dispatchers' grants.
begin;
set local lock_timeout = '15s';

-- ------------------------------------------------------------------ 1. reads
create or replace function product.dispatch_authoring_read(ws uuid, op text, pl jsonb, p uuid, g access.client_grant) returns jsonb
language plpgsql stable set search_path = '' as $function$
declare
  rv authoring.work_revision; wk authoring.work; lim int; rid uuid; wid uuid; st text;
begin
  case op
  when 'list_workspaces' then
    return coalesce((select jsonb_agg(jsonb_build_object(
               'workspaceId', s.id, 'name', s.name, 'kind', s.kind, 'role', m.role, 'canWrite', m.role in ('owner','editor'),
               'ownedByYou', s.owner_id = p, 'memberSince', m.created_at)
             order by (s.kind = 'personal') desc, s.created_at, s.id)
        from authoring.workspace_member m join authoring.workspace s on s.id = m.workspace_id
       where m.tenant_id = product.tenant() and m.principal_id = p and m.revoked_at is null
         and (g.id is null or g.workspace_ids is null or s.id = any(g.workspace_ids))
         and (not coalesce((pl ->> 'writable_only')::boolean, false) or m.role in ('owner','editor'))), '[]');

  when 'get_revision_structure' then
    rid := (pl ->> 'revision_id')::uuid;
    if rid is null then perform product.fail('VALIDATION', 'revision_id is required'); end if;
    select * into rv from authoring.work_revision x where x.id = rid and x.tenant_id = product.tenant();
    if rv.id is null or product.role_in(rv.workspace_id, p) is null
       or (ws is not null and rv.workspace_id <> ws)
       or (g.id is not null and g.workspace_ids is not null and not (rv.workspace_id = any(g.workspace_ids))) then
      perform product.fail('NOT_FOUND', 'revision');
    end if;
    select * into wk from authoring.work x where x.id = rv.work_id;
    return jsonb_build_object(
      'revisionId', rv.id, 'workId', wk.id, 'workKind', wk.kind, 'workSlug', wk.slug, 'workspaceId', rv.workspace_id,
      'revisionNo', rv.revision_no, 'title', rv.title, 'origin', rv.origin, 'contentSha256', rv.content_sha256,
      'isHead', wk.head_revision_id = rv.id, 'headRevisionId', wk.head_revision_id, 'createdAt', rv.created_at, 'purged', rv.purged_at is not null,
      'bindings', coalesce((select jsonb_agg(jsonb_build_object(
          'localKey', b.local_key, 'relation', b.relation, 'role', b.role, 'blockKey', b.block_key, 'usage', b.usage, 'rightsBasis', b.rights_basis,
          'target', jsonb_build_object(
            'kind', case when b.target_revision_id is not null then 'revision' when b.target_work_id is not null then 'work'
                         when b.artifact_id is not null then 'artifact' when b.capture_id is not null then 'capture'
                         when b.locator_id is not null then 'locator' when b.claim_id is not null then 'claim'
                         when b.entity_id is not null then 'entity' when b.record_id is not null then 'record'
                         when b.release_item_id is not null then 'release_item' when b.file_set_id is not null then 'file_set'
                         when b.assertion_id is not null then 'assertion' end,
            'id', coalesce(b.target_revision_id, b.target_work_id, b.artifact_id, b.capture_id, b.locator_id, b.claim_id, b.entity_id,
                           b.record_id, b.release_item_id, b.file_set_id, b.assertion_id)))
          order by b.local_key) from authoring.revision_binding b where b.revision_id = rv.id), '[]'),
      'parts', coalesce((select jsonb_agg(jsonb_build_object(
          'occurrenceKey', pt.occurrence_key, 'ordinal', pt.ordinal, 'role', pt.role, 'childRevisionId', pt.child_revision_id,
          'childWorkId', cw.id, 'childKind', cw.kind, 'childSlug', cw.slug, 'childTitle', cr.title, 'childRevisionNo', cr.revision_no,
          'childIsHead', cw.head_revision_id = cr.id)
          order by pt.ordinal, pt.occurrence_key)
        from curriculum.part pt join authoring.work_revision cr on cr.id = pt.child_revision_id join authoring.work cw on cw.id = cr.work_id
       where pt.parent_revision_id = rv.id), '[]'),
      'outcomes', coalesce((select jsonb_agg(jsonb_build_object(
          'outcomeKey', o.outcome_key, 'statement', o.statement, 'bloomLevel', o.bloom_level, 'evidenceRule', o.evidence_rule,
          'alignments', coalesce((select jsonb_agg(jsonb_build_object('competencyRevisionId', a.competency_revision_id, 'facet', a.facet,
                                     'coverage', a.coverage, 'rationale', a.rationale) order by a.competency_revision_id, a.facet)
                                    from curriculum.outcome_alignment a where a.outcome_id = o.id), '[]'))
          order by o.outcome_key) from curriculum.outcome o where o.revision_id = rv.id), '[]'),
      'requirements', coalesce((select jsonb_agg(jsonb_build_object(
          'requirementKey', q.requirement_key, 'kind', q.kind, 'rationale', q.rationale,
          'outcomeKey', (select o.outcome_key from curriculum.outcome o where o.id = q.outcome_id),
          'occurrenceKey', (select pt.occurrence_key from curriculum.part pt where pt.id = q.part_id),
          'options', coalesce((select jsonb_agg(jsonb_build_object('route', ro.route, 'activityRevisionId', ro.activity_revision_id,
                                  'evidenceRule', ro.evidence_rule, 'approvalState', ro.approval_state) order by ro.route, ro.created_at, ro.id)
                                 from curriculum.requirement_option ro where ro.requirement_id = q.id), '[]'))
          order by q.requirement_key) from curriculum.requirement q where q.revision_id = rv.id), '[]'),
      'prerequisites', coalesce((select jsonb_agg(jsonb_build_object('requiredRevisionId', x.required_revision_id, 'strength', x.strength,
          'rationale', x.rationale) order by x.required_revision_id) from curriculum.prerequisite x where x.revision_id = rv.id), '[]'),
      'runtime', coalesce((select jsonb_agg(jsonb_build_object('localKey', x.local_key, 'kind', x.kind, 'ecosystem', x.ecosystem, 'name', x.name,
          'versionSpec', x.version_spec, 'resolvedVersion', x.resolved_version, 'entityId', x.entity_id, 'phase', x.phase, 'optional', x.optional)
          order by x.local_key) from authoring.runtime_requirement x where x.revision_id = rv.id), '[]'),
      'statements', coalesce((select jsonb_agg(jsonb_build_object('assertionKey', x.assertion_key, 'blockKey', x.block_key, 'kind', x.kind,
          'statement', x.statement, 'supportStatus', x.support_status, 'usesClaimId', x.uses_claim_id, 'entityIds', to_jsonb(x.entity_ids))
          order by x.created_at, x.assertion_key) from inquiry.assertion x where x.revision_id = rv.id), '[]'));

  when 'list_reviews' then
    perform product.require_role(ws, p, array['owner','editor','reader']);
    lim := least(greatest(coalesce((pl ->> 'limit')::int, 20), 1), 100);
    rid := (pl ->> 'revision_id')::uuid;
    wid := (pl ->> 'work_id')::uuid;
    st := pl ->> 'status';
    if st is not null and st not in ('awaiting_review','reviewed','superseded') then
      perform product.fail('VALIDATION', 'status is awaiting_review, reviewed or superseded');
    end if;
    return jsonb_build_object('workspaceId', ws,
      'requests', coalesce((select jsonb_agg(y.j order by y.created_at desc, y.id desc) from (
          select e.id, e.created_at, jsonb_build_object(
              'requestId', e.id, 'workId', e.work_id, 'workKind', w2.kind, 'workSlug', w2.slug, 'revisionId', e.revision_id,
              'revisionNo', r2.revision_no, 'title', r2.title, 'isHead', w2.head_revision_id = e.revision_id, 'status', s.status,
              'requestedAt', e.created_at, 'requestedBy', e.actor_id, 'requestedByYou', e.actor_id = p, 'actorKind', e.actor_kind,
              'ceiling', e.payload ->> 'ceiling', 'closureSha256', e.payload ->> 'closure_sha256', 'items', e.payload -> 'items',
              'blockers', e.payload -> 'blockers', 'note', e.payload ->> 'note', 'threadId', e.payload ->> 'thread_id',
              'reviews', coalesce(rl.reviews, '[]'), 'replies', coalesce(rp.replies, '[]')) j
            from authoring.event e
            join authoring.work w2 on w2.id = e.work_id
            join authoring.work_revision r2 on r2.id = e.revision_id
            cross join lateral (
              select jsonb_agg(jsonb_build_object('eventId', v.id, 'kind', v.kind, 'reviewType', v.payload ->> 'reviewType',
                       'decision', v.payload ->> 'decision', 'actorKind', v.actor_kind, 'actorId', v.actor_id, 'byYou', v.actor_id = p,
                       'at', v.created_at, 'payload', v.payload) order by v.created_at, v.id) reviews,
                     coalesce(bool_or(v.kind = 'reviewed' and v.actor_kind = 'human'), false) human_reviewed
                from authoring.event v
               where v.workspace_id = ws and v.revision_id = e.revision_id and v.kind in ('reviewed','feedback') and v.created_at >= e.created_at) rl
            cross join lateral (
              select case when rl.human_reviewed then 'reviewed' when w2.head_revision_id is distinct from e.revision_id then 'superseded'
                          else 'awaiting_review' end status) s
            left join lateral (
              select jsonb_agg(jsonb_build_object('seq', m.seq, 'role', m.role, 'fromPerson', m.role = 'user', 'authorId', m.author_id,
                       'byYou', m.author_id is not distinct from p, 'content', case when m.redacted_at is null then m.content end, 'at', m.created_at)
                     order by m.seq) replies
                from conversation.thread th join conversation.message m on m.thread_id = th.id
               where th.id = (e.payload ->> 'thread_id')::uuid and th.workspace_id = ws and (th.owner_id = p or th.visibility = 'workspace')
                 and m.seq > coalesce((e.payload ->> 'handover_seq')::int, 0)) rp on true
           where e.workspace_id = ws and e.kind = 'revision_proposed'
             and (rid is null or e.revision_id = rid) and (wid is null or e.work_id = wid) and (st is null or s.status = st)
           order by e.created_at desc, e.id desc limit lim) y), '[]'),
      'reviews', coalesce((select jsonb_agg(y.j order by y.created_at desc, y.id desc) from (
          select v.id, v.created_at, jsonb_build_object('eventId', v.id, 'kind', v.kind, 'workId', v.work_id, 'revisionId', v.revision_id,
              'reviewType', v.payload ->> 'reviewType', 'decision', v.payload ->> 'decision', 'actorKind', v.actor_kind, 'actorId', v.actor_id,
              'byYou', v.actor_id = p, 'at', v.created_at, 'payload', v.payload) j
            from authoring.event v
           where v.workspace_id = ws and v.kind in ('reviewed','feedback')
             and (rid is null or v.revision_id = rid) and (wid is null or v.work_id = wid)
             and not exists (select 1 from authoring.event e where e.workspace_id = ws and e.kind = 'revision_proposed'
                              and e.revision_id = v.revision_id and e.created_at <= v.created_at)
           order by v.created_at desc, v.id desc limit lim) y), '[]'));

  else
    perform product.fail('UNKNOWN_OPERATION', op);
  end case;
  return null;
end $function$;
comment on function product.dispatch_authoring_read(uuid, text, jsonb, uuid, access.client_grant) is
 'Product reads list_workspaces, get_revision_structure and list_reviews, routed by api.product_read. The principal comes from product.actor() and the client grant from product.client_grant; membership (product.role_in) decides what is visible: a caller sees only its own memberships, the structure of revisions in workspaces it belongs to, and the review requests, reviews and workspace-visible hand-over replies of a workspace it belongs to.';

-- ------------------------------------------------------------------ 2. the author's hand-off
create or replace function product.dispatch_authoring_command(ws uuid, op text, head uuid, pl jsonb, p uuid, g access.client_grant) returns jsonb
language plpgsql set search_path = '' as $function$
declare
  rv authoring.work_revision; ceiling text := coalesce(pl ->> 'ceiling', 'workspace'); note text := pl ->> 'note'; x jsonb; ev uuid;
  th uuid; hseq int; dk text; prior authoring.event; human boolean; surface text;
begin
  human := g.id is null or g.client_kind = 'cli';          -- the same rule as product.dispatch_command
  surface := case when g.id is null then 'web' else 'harness' end;
  case op
  when 'mark_ready_for_review' then
    perform product.require_role(ws, p, array['owner','editor']);
    if ceiling not in ('workspace','named','public') then perform product.fail('VALIDATION', 'ceiling is workspace, named or public'); end if;
    if note is null or not product.nonblank(note) or char_length(note) > 8000 then perform product.fail('VALIDATION', 'note: 1 to 8000 characters'); end if;
    select * into rv from authoring.work_revision r where r.id = (pl ->> 'revision_id')::uuid and r.workspace_id = ws;
    if rv.id is null then perform product.fail('NOT_FOUND', 'revision'); end if;
    if rv.purged_at is not null then perform product.fail('CONFLICT', 'revision purged'); end if;
    if pl ->> 'thread_id' is not null then
      th := (pl ->> 'thread_id')::uuid;
      if not exists (select 1 from conversation.thread t2 where t2.id = th and t2.workspace_id = ws and (t2.owner_id = p or t2.visibility = 'workspace')) then
        perform product.fail('NOT_FOUND', 'thread');
      end if;
      select coalesce(max(m.seq), 0) into hseq from conversation.message m where m.thread_id = th;
    end if;
    dk := 'review_request:' || rv.id || ':' || ceiling;
    select * into prior from authoring.event e where e.workspace_id = ws and e.dedupe_key = dk;
    if prior.id is not null then
      return jsonb_build_object('eventId', prior.id, 'workId', rv.work_id, 'revisionId', rv.id, 'ceiling', ceiling,
        'closureSha256', prior.payload ->> 'closure_sha256', 'items', prior.payload -> 'items', 'blockers', prior.payload -> 'blockers',
        'threadId', prior.payload ->> 'thread_id', 'alreadyRequested', true);
    end if;
    x := product.exposure(rv.id, ceiling);
    ev := product.new_event(ws, p, rv.work_id, rv.id, 'revision_proposed',
            jsonb_build_object('ceiling', ceiling, 'closure_sha256', x ->> 'closure_sha256', 'items', jsonb_array_length(x -> 'items'),
                               'blockers', jsonb_array_length(x -> 'blockers'), 'note', note, 'thread_id', th, 'handover_seq', hseq),
            dk, case when human then 'human' else 'agent' end, surface, 'maintainer');
    return jsonb_build_object('eventId', ev, 'workId', rv.work_id, 'revisionId', rv.id, 'ceiling', ceiling,
      'closureSha256', x ->> 'closure_sha256', 'items', jsonb_array_length(x -> 'items'), 'blockers', jsonb_array_length(x -> 'blockers'),
      'threadId', th, 'alreadyRequested', false);
  else
    perform product.fail('UNKNOWN_OPERATION', op);
  end case;
  return null;
end $function$;
comment on function product.dispatch_authoring_command(uuid, text, uuid, jsonb, uuid, access.client_grant) is
 'Product command mark_ready_for_review, routed by api.product_command: an owner or editor of the workspace marks an exact revision ready for a person''s review (authoring.event kind revision_proposed) with the exposure closure the database computes at the ceiling, the note and optionally the workspace conversation that holds the hand-over. It records no review and no decision; actor_kind is agent for an MCP, harness or API client grant, as in product.dispatch_command.';

-- ------------------------------------------------------------------ 3. the two entrypoints route the new names (same signatures, owner and grants)
create or replace function api.product_command(p_workspace_id uuid, p_operation text, p_idempotency_key text, p_expected_head uuid, p_payload jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare p uuid := product.actor(); g access.client_grant; dig text; prior authoring.command; res jsonb; ws uuid; scope text;
begin
  if octet_length(coalesce(p_payload, '{}')::text) > 1048576 then perform product.fail('LIMIT_EXCEEDED', '1 MiB request'); end if;
  scope := case when p_operation in ('start_attempt','submit_attempt','open_appeal','enroll','adopt_release','grant_evidence','propose_equivalence','request_environment') then 'learn'
                when p_operation in ('set_control','create_connection','create_thread','append_message','preview_removal','confirm_removal') then 'library'
                when p_operation in ('finalize_result','resolve_appeal','decide_equivalence') then 'assess' else 'author' end;
  g := product.client_grant(scope, p_workspace_id);
  if p_operation in ('create_client_grant','revoke_client_grant') and g.id is not null then perform product.fail('FORBIDDEN', 'clients cannot mint grants'); end if;
  dig := product.sha256_text(jsonb_build_object('op', p_operation, 'ws', p_workspace_id, 'head', p_expected_head, 'payload', p_payload)::text);
  ws := coalesce(p_workspace_id, product.personal_workspace(p));
  select * into prior from authoring.command c where c.tenant_id = product.tenant() and c.workspace_id = ws and c.actor_id = p and c.idempotency_key = p_idempotency_key;
  if prior.id is not null then
    if prior.input_sha256 <> dig then perform product.fail('CONFLICT', 'idempotency key reused with different input'); end if;
    if p_workspace_id is not null and product.role_in(p_workspace_id, p) is null then perform product.fail('NOT_FOUND', 'workspace'); end if;
    return prior.result || jsonb_build_object('replayed', true);
  end if;
  if p_operation = 'mark_ready_for_review' then
    res := product.dispatch_authoring_command(p_workspace_id, p_operation, p_expected_head, coalesce(p_payload, '{}'), p, g);
  else
    res := product.dispatch_command(p_workspace_id, p_operation, p_expected_head, coalesce(p_payload, '{}'), p, g);
  end if;
  insert into authoring.command(tenant_id, workspace_id, actor_id, operation, idempotency_key, input_sha256, result, origin, client_grant_id)
  values (product.tenant(), ws, p, p_operation, p_idempotency_key, dig, res - 'token',
          coalesce(g.client_kind, 'web'), g.id);
  return res || jsonb_build_object('replayed', false);
end $$;

create or replace function api.product_read(p_workspace_id uuid, p_operation text, p_payload jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare p uuid := product.actor(); g access.client_grant;
begin
  g := product.client_grant('read', p_workspace_id);
  if p_operation in ('list_workspaces','get_revision_structure','list_reviews') then
    return product.dispatch_authoring_read(p_workspace_id, p_operation, coalesce(p_payload, '{}'), p, g);
  end if;
  return product.dispatch_read(p_workspace_id, p_operation, coalesce(p_payload, '{}'), p);
end $$;

-- ------------------------------------------------------------------ 4. ownership and grants
-- CREATE OR REPLACE keeps the owner (product_api_owner) and the grants of the two entrypoints: EXECUTE for authenticated,
-- none for PUBLIC or anon (20261105010300, 20261116120000). The dispatchers run as product_api_owner inside them, like every
-- other product function, and nobody else may execute them.
grant create on schema product to product_api_owner;   -- needed only to transfer ownership; revoked below
alter function product.dispatch_authoring_read(uuid, text, jsonb, uuid, access.client_grant) owner to product_api_owner;
alter function product.dispatch_authoring_command(uuid, text, uuid, jsonb, uuid, access.client_grant) owner to product_api_owner;
revoke create on schema product from product_api_owner;
revoke all on function product.dispatch_authoring_read(uuid, text, jsonb, uuid, access.client_grant),
                       product.dispatch_authoring_command(uuid, text, uuid, jsonb, uuid, access.client_grant)
  from public, anon, authenticated, service_role;
revoke execute on function api.product_command(uuid, text, text, uuid, jsonb), api.product_read(uuid, text, jsonb) from public, anon;
grant execute on function api.product_command(uuid, text, text, uuid, jsonb), api.product_read(uuid, text, jsonb) to authenticated;

commit;
