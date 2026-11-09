-- Build 08 R2 draft, fixups applied after the first lab run: removal retires vector items; trigram channel threshold.
begin;
create or replace function product.dispatch_command(ws uuid, op text, head uuid, pl jsonb, p uuid, g access.client_grant) returns jsonb
language plpgsql set search_path = '' as $$
declare
  t uuid := product.tenant(); w authoring.work; rid uuid; res jsonb; ex jsonb; ev uuid; rel authoring.release; d authoring.distribution;
  o authoring.distribution_offer; e learning.enrollment; aid uuid; x jsonb; human boolean; surface text; k text; tok text;
  a learning.attempt; s learning.submission; r learning.assessment_result; ap learning.appeal; n int; srcws uuid; cnt int; rm library.removal;
begin
  human := g.id is null or g.client_kind = 'cli';          -- MCP/harness grants act as agents; web or interactive CLI = human
  surface := case when g.id is null then 'web' else 'harness' end;

  case op
  when 'ensure_personal_workspace' then
    return jsonb_build_object('workspaceId', product.personal_workspace(p));

  when 'create_workspace' then
    insert into authoring.workspace(tenant_id, owner_id, kind, name) values (t, p, 'shared', pl ->> 'name') returning id into rid;
    insert into authoring.workspace_member(tenant_id, workspace_id, principal_id, role, granted_by) values (t, rid, p, 'owner', p);
    return jsonb_build_object('workspaceId', rid);

  when 'grant_member' then
    perform product.require_role(ws, p, array['owner']);
    insert into authoring.workspace_member(tenant_id, workspace_id, principal_id, role, granted_by)
    values (t, ws, (pl ->> 'principal_id')::uuid, pl ->> 'role', p);
    return jsonb_build_object('granted', true);

  when 'revoke_member' then
    perform product.require_role(ws, p, array['owner']);
    if product.role_in(ws, (pl ->> 'principal_id')::uuid) = 'owner'
       and (select count(*) from authoring.workspace_member where workspace_id = ws and role = 'owner' and revoked_at is null) = 1 then
      perform product.fail('CONFLICT', 'cannot revoke the last owner');
    end if;
    update authoring.workspace_member set revoked_at = now() where workspace_id = ws and principal_id = (pl ->> 'principal_id')::uuid and revoked_at is null;
    return jsonb_build_object('revoked', true);

  when 'create_work' then
    perform product.require_role(ws, p, array['owner','editor']);
    if pl ->> 'kind' = 'dataset' then perform product.fail('VALIDATION', 'create datasets with create_dataset'); end if;
    insert into authoring.work(tenant_id, workspace_id, kind, slug, created_by) values (t, ws, pl ->> 'kind', pl ->> 'slug', p) returning * into w;
    rid := product.insert_revision(ws, w, p, null, pl -> 'revision');
    update authoring.work set head_revision_id = rid where id = w.id;
    return jsonb_build_object('workId', w.id, 'revisionId', rid);

  when 'revise_work' then
    perform product.require_role(ws, p, array['owner','editor']);
    select * into w from authoring.work where id = (pl ->> 'work_id')::uuid and workspace_id = ws for update;
    if w.id is null then perform product.fail('NOT_FOUND', 'work'); end if;
    if w.kind = 'dataset' then perform product.fail('VALIDATION', 'revise datasets with edit_dataset and commit_dataset_revision'); end if;
    if head is null or w.head_revision_id is distinct from head then perform product.fail('CONFLICT', 'stale expected head'); end if;
    rid := product.insert_revision(ws, w, p, w.head_revision_id, pl -> 'revision');
    update authoring.work set head_revision_id = rid where id = w.id;
    return jsonb_build_object('workId', w.id, 'revisionId', rid);

  when 'review_revision' then
    perform product.require_role(ws, p, array['owner','editor']);
    if (pl -> 'review' ->> 'reviewType') in ('release_review','official_publication','transition_review','runtime_review') and not human then
      perform product.fail('FORBIDDEN', 'agents may propose but not record human reviews');
    end if;
    if pl -> 'review' ->> 'reviewType' = 'official_publication' and not exists (select 1 from authoring.publisher_grant pg
         where pg.tenant_id = t and pg.principal_id = p and pg.revoked_at is null) then
      perform product.fail('FORBIDDEN', 'official publication requires a publisher grant');
    end if;
    ev := product.new_event(ws, p, (pl ->> 'work_id')::uuid, (pl ->> 'revision_id')::uuid, 'reviewed', pl -> 'review',
                            coalesce(pl ->> 'dedupe_key', 'review:' || util.uuidv7()), case when human then 'human' else 'agent' end, surface, 'maintainer');
    return jsonb_build_object('eventId', ev);

  when 'freeze_release' then
    perform product.require_role(ws, p, array['owner','editor']);
    select wk.* into w from authoring.work_revision rv join authoring.work wk on wk.id = rv.work_id
      where rv.id = (pl ->> 'root_revision_id')::uuid and rv.workspace_id = ws;
    if w.id is null then perform product.fail('NOT_FOUND', 'root revision'); end if;
    ex := product.exposure((pl ->> 'root_revision_id')::uuid, pl ->> 'ceiling');
    -- apply explicit author decisions to blockers
    for x in select * from jsonb_array_elements(coalesce(pl -> 'decisions', '[]')) loop
      ex := jsonb_set(ex, '{items}', (select jsonb_agg(case when i ->> 'item_key' = x ->> 'item_key'
              then i || jsonb_build_object('disposition', x ->> 'disposition', 'decided', true, 'rationale', x ->> 'rationale', 'substitute', x ->> 'substitute_artifact_id') else i end)
              from jsonb_array_elements(ex -> 'items') i));
    end loop;
    if exists (select 1 from jsonb_array_elements(ex -> 'items') i where i ->> 'disposition' = 'BLOCKER') then
      perform product.fail('EXPOSURE_BLOCKED', (select string_agg(i ->> 'item_key', ',') from jsonb_array_elements(ex -> 'items') i where i ->> 'disposition' = 'BLOCKER'));
    end if;
    if not exists (select 1 from authoring.event v where v.id = (pl ->> 'approval_event_id')::uuid and v.workspace_id = ws and v.kind = 'reviewed'
                    and v.actor_kind = 'human' and v.payload ->> 'reviewType' = 'release_review' and v.payload ->> 'decision' = 'approve'
                    and v.payload ->> 'closure_sha256' = ex ->> 'closure_sha256' and v.payload ->> 'ceiling' = pl ->> 'ceiling'
                    and product.role_in(ws, v.actor_id) in ('owner','editor')) then
      perform product.fail('FORBIDDEN', 'release requires a human review of this exact closure and ceiling');
    end if;
    aid := product.register_artifact(ws, p, 'course_release_manifest', product.sha256_text(ex::text), octet_length(ex::text), 'application/json',
                                     'private_copy', 'release manifest generated by the platform');
    select coalesce(max(release_no), 0) + 1 into n from authoring.release where root_work_id = w.id;
    insert into authoring.release(tenant_id, workspace_id, root_work_id, root_revision_id, release_no, audience_ceiling, manifest_artifact_id, closure_sha256, approved_event_id, created_by)
    values (t, ws, w.id, (pl ->> 'root_revision_id')::uuid, n, pl ->> 'ceiling', aid, ex ->> 'closure_sha256', (pl ->> 'approval_event_id')::uuid, p) returning * into rel;
    insert into authoring.release_item(tenant_id, workspace_id, release_id, item_key, revision_id, artifact_id, capture_id, locator_id, claim_id, record_id, entity_id,
                                       via_binding_id, disposition, substitute_artifact_id, decided_by, rationale)
    select t, ws, rel.id, i ->> 'item_key',
           case when i ->> 'kind' = 'revision' then (i ->> 'id')::uuid end, case when i ->> 'kind' = 'artifact' then (i ->> 'id')::uuid end,
           case when i ->> 'kind' = 'capture' then (i ->> 'id')::uuid end, case when i ->> 'kind' = 'locator' then (i ->> 'id')::uuid end,
           case when i ->> 'kind' = 'claim' then (i ->> 'id')::uuid end, case when i ->> 'kind' = 'record' then (i ->> 'id')::uuid end,
           case when i ->> 'kind' = 'entity' then (i ->> 'id')::uuid end, (i ->> 'binding_id')::uuid, i ->> 'disposition',
           (i ->> 'substitute')::uuid, case when (i ->> 'decided')::boolean then p end, case when (i ->> 'decided')::boolean then i ->> 'rationale' end
      from jsonb_array_elements(ex -> 'items') i;
    return jsonb_build_object('releaseId', rel.id, 'releaseNo', n, 'manifestArtifactId', aid, 'manifestText', ex::text,
                              'objectPath', (select object_path from orchestration.artifact where id = aid));

  when 'open_distribution' then
    perform product.require_role(ws, p, array['owner','editor']);
    if pl ->> 'channel' = 'public_library'
       and product.band_rank(product.band(p)) < product.band_rank(coalesce(product.policy() ->> 'public_publish_min_band', 'adult')) then
      perform product.fail('FORBIDDEN', 'account band may not publish publicly under the active policy');
    end if;
    insert into authoring.distribution(tenant_id, workspace_id, root_work_id, channel, title, created_by)
    values (t, ws, (pl ->> 'root_work_id')::uuid, pl ->> 'channel', pl ->> 'title', p) returning * into d;
    return jsonb_build_object('distributionId', d.id);

  when 'grant_reader' then
    perform product.require_role(ws, p, array['owner','editor']);
    insert into authoring.distribution_member(tenant_id, workspace_id, distribution_id, principal_id, grant_basis, granted_by)
    select t, ws, d2.id, (pl ->> 'principal_id')::uuid, 'invited', p from authoring.distribution d2
     where d2.id = (pl ->> 'distribution_id')::uuid and d2.workspace_id = ws and d2.channel = 'invited';
    get diagnostics cnt = row_count;
    if cnt = 0 then perform product.fail('NOT_FOUND', 'invited distribution'); end if;
    return jsonb_build_object('granted', true);

  when 'offer_release' then
    perform product.require_role(ws, p, array['owner','editor']);
    select * into d from authoring.distribution where id = (pl ->> 'distribution_id')::uuid and workspace_id = ws and closed_at is null;
    select * into rel from authoring.release where id = (pl ->> 'release_id')::uuid and workspace_id = ws;
    if d.id is null or rel.id is null or rel.root_work_id <> d.root_work_id then perform product.fail('NOT_FOUND', 'distribution/release'); end if;
    if not ((d.channel = 'workspace') or (d.channel = 'invited' and rel.audience_ceiling in ('named','public'))
         or (d.channel in ('public_library','official_catalog') and rel.audience_ceiling = 'public')) then
      perform product.fail('FORBIDDEN', format('release ceiling %s cannot be offered in %s', rel.audience_ceiling, d.channel));
    end if;
    if (select storage_state from orchestration.artifact where id = rel.manifest_artifact_id) <> 'available' then
      perform product.fail('CONFLICT', 'release manifest not yet stored and verified');
    end if;
    if not exists (select 1 from authoring.event v where v.id = (pl ->> 'approval_event_id')::uuid and v.workspace_id = ws and v.kind = 'reviewed' and v.actor_kind = 'human'
        and v.payload ->> 'closure_sha256' = rel.closure_sha256
        and ((d.channel = 'official_catalog' and v.payload ->> 'reviewType' = 'official_publication'
              and v.payload -> 'terms' = pl -> 'terms'
              and exists (select 1 from authoring.publisher_grant pg where pg.principal_id = v.actor_id and pg.revoked_at is null))
          or (d.channel <> 'official_catalog' and v.payload ->> 'reviewType' = 'release_review'))) then
      perform product.fail('FORBIDDEN', 'offer approval does not match this release/channel');
    end if;
    select coalesce(max(offer_no), 0) + 1 into n from authoring.distribution_offer where distribution_id = d.id;
    insert into authoring.distribution_offer(tenant_id, workspace_id, distribution_id, release_id, offer_no, terms_schema, terms, approval_event_id, offered_by)
    values (t, ws, d.id, rel.id, n, 'aieng.use-terms.v1', pl -> 'terms', (pl ->> 'approval_event_id')::uuid, p) returning * into o;
    return jsonb_build_object('offerId', o.id, 'offerNo', n);

  when 'end_offer' then
    perform product.require_role(ws, p, array['owner','editor']);
    ev := product.new_event(ws, p, null, null, 'withdrawn', jsonb_build_object('offer_id', pl ->> 'offer_id', 'reason', pl ->> 'reason'),
                            'end_offer:' || (pl ->> 'offer_id'), case when human then 'human' else 'agent' end, surface, 'maintainer');
    update authoring.distribution_offer set ended_at = now(), end_kind = pl ->> 'end_kind', end_event_id = ev
     where id = (pl ->> 'offer_id')::uuid and workspace_id = ws and ended_at is null;
    get diagnostics cnt = row_count;
    if cnt = 0 then perform product.fail('NOT_FOUND', 'open offer'); end if;
    return jsonb_build_object('ended', pl ->> 'end_kind');

  when 'enroll' then
    perform product.require_role(ws, p, array['owner']);
    if (select kind from authoring.workspace where id = ws) <> 'personal' then perform product.fail('VALIDATION', 'enroll in your personal workspace'); end if;
    select * into d from authoring.distribution where id = (pl ->> 'distribution_id')::uuid and closed_at is null;
    if d.id is null or (select kind from authoring.work where id = d.root_work_id) <> 'course'
       or not exists (select 1 from authoring.distribution_offer o2 where o2.distribution_id = d.id and o2.ended_at is null and product.can_read_offer(o2, p)) then
      perform product.fail('NOT_FOUND', 'distribution');
    end if;
    insert into learning.enrollment(tenant_id, workspace_id, learner_id, source_workspace_id, distribution_id, update_policy)
    values (t, ws, p, d.workspace_id, d.id, coalesce(pl ->> 'update_policy', 'manual')) returning * into e;
    return jsonb_build_object('enrollmentId', e.id);

  when 'adopt_release' then
    select * into e from learning.enrollment where id = (pl ->> 'enrollment_id')::uuid and workspace_id = ws and learner_id = p;
    select * into o from authoring.distribution_offer where id = (pl ->> 'offer_id')::uuid;
    if e.id is null or o.id is null or o.distribution_id <> e.distribution_id or not product.can_read_offer(o, p) or o.ended_at is not null then
      perform product.fail('NOT_FOUND', 'enrollment/offer');
    end if;
    select coalesce(max(sequence_no), 0) + 1 into n from learning.release_adoption where enrollment_id = e.id;
    insert into learning.release_adoption(tenant_id, workspace_id, enrollment_id, sequence_no, previous_adoption_id, source_workspace_id, offer_id, transition_id, actor_id, basis, reason)
    values (t, ws, e.id, n, (select id from learning.release_adoption where enrollment_id = e.id and sequence_no = n - 1), e.source_workspace_id, o.id,
            (pl ->> 'transition_id')::uuid, p, 'explicit', coalesce(pl ->> 'reason', 'learner choice')) returning id into rid;
    return jsonb_build_object('adoptionId', rid, 'sequenceNo', n);

  when 'register_asset' then
    perform product.require_role(ws, p, array['owner','editor']);
    if pl ->> 'artifact_type' not in ('authored_work_asset','uploaded_document','experience_bundle','project_bundle','course_source_capture') then
      perform product.fail('VALIDATION', 'artifact type');
    end if;
    if (pl ->> 'size_bytes')::bigint > 26214400 then perform product.fail('LIMIT_EXCEEDED', '25 MiB per object'); end if;
    aid := product.register_artifact(ws, p, pl ->> 'artifact_type', pl ->> 'sha256', (pl ->> 'size_bytes')::bigint, pl ->> 'media_type',
                                     pl ->> 'usage', pl ->> 'rights_basis', coalesce(pl ->> 'retention', 'durable'));
    return jsonb_build_object('artifactId', aid, 'objectPath', (select object_path from orchestration.artifact where id = aid));

  when 'revoke_asset' then
    perform product.require_role(ws, p, array['owner']);
    update authoring.asset_scope set revoked_at = now() where workspace_id = ws and artifact_id = (pl ->> 'artifact_id')::uuid and revoked_at is null;
    return jsonb_build_object('revoked', true);

  when 'set_control' then
    perform product.require_role(ws, p, array['owner','editor']);
    if coalesce((pl ->> 'semantic_index')::boolean, false)
       and not product.processing_allowed(p, 'embedding', coalesce(pl ->> 'embedding_processor', 'openai')) then
      perform product.fail('CONSENT_REQUIRED', 'embedding processing is not authorized for this account');
    end if;
    insert into library.resource_control(tenant_id, workspace_id, work_id, excluded_at, excluded_by, semantic_index, updated_by)
    values (t, ws, (pl ->> 'work_id')::uuid, case when (pl ->> 'exclude')::boolean then now() end, case when (pl ->> 'exclude')::boolean then p end,
            coalesce((pl ->> 'semantic_index')::boolean, false), p)
    on conflict (tenant_id, workspace_id, work_id) do update set
      excluded_at = case when (pl ->> 'exclude')::boolean then coalesce(library.resource_control.excluded_at, now()) end,
      excluded_by = case when (pl ->> 'exclude')::boolean then coalesce(library.resource_control.excluded_by, p) end,
      semantic_index = coalesce((pl ->> 'semantic_index')::boolean, library.resource_control.semantic_index), updated_by = p, updated_at = now();
    return jsonb_build_object('updated', true);

  when 'create_connection' then
    perform product.require_role(ws, p, array['owner','editor']);
    if product.band_rank(product.band(p)) < product.band_rank(coalesce(product.policy() ->> 'connector_min_band', 'teen'))
       or not product.processing_allowed(p, 'connector', pl ->> 'provider') then
      perform product.fail('CONSENT_REQUIRED', 'connector not permitted for this account');
    end if;
    insert into library.connection(tenant_id, workspace_id, provider, account_label, capabilities, credential_handle, status, connected_by)
    values (t, ws, pl ->> 'provider', pl ->> 'account_label', array(select jsonb_array_elements_text(pl -> 'capabilities')), pl ->> 'credential_handle', 'active', p)
    returning id into rid;
    return jsonb_build_object('connectionId', rid);

  when 'create_thread' then
    perform product.require_role(ws, p, array['owner','editor','reader']);
    insert into conversation.thread(tenant_id, workspace_id, owner_id, visibility, title, purpose, mode)
    values (t, ws, p, coalesce(pl ->> 'visibility', 'private'), pl ->> 'title', pl ->> 'purpose', coalesce(pl ->> 'mode', 'coach')) returning id into rid;
    return jsonb_build_object('threadId', rid);

  when 'append_message' then
    if not exists (select 1 from conversation.thread th where th.id = (pl ->> 'thread_id')::uuid and th.workspace_id = ws
                   and (th.owner_id = p or (th.visibility = 'workspace' and product.role_in(ws, p) is not null))) then
      perform product.fail('NOT_FOUND', 'thread');
    end if;
    perform 1 from conversation.thread where id = (pl ->> 'thread_id')::uuid for update;
    rid := null;
    if pl ? 'context' then
      k := product.sha256_text((pl -> 'context')::text);
      insert into conversation.context_snapshot(tenant_id, workspace_id, digest, body) values (t, ws, k, pl -> 'context')
      on conflict (tenant_id, workspace_id, digest) do nothing;
      select id into rid from conversation.context_snapshot where workspace_id = ws and digest = k;
      for x in select * from jsonb_array_elements(coalesce(pl -> 'context' -> 'items', '[]')) loop
        if x ? 'revision_id' and not product.readable_revision((x ->> 'revision_id')::uuid, p) then perform product.fail('NOT_FOUND', 'context item'); end if;
        -- released material from another workspace is referenced through its release item (lab finding F-08)
        aid := null;
        if x ? 'revision_id' and not exists (select 1 from authoring.work_revision rv where rv.id = (x ->> 'revision_id')::uuid and rv.workspace_id = ws) then
          select ri.id into aid from authoring.release_item ri join authoring.distribution_offer o2 on o2.release_id = ri.release_id
           where ri.revision_id = (x ->> 'revision_id')::uuid and ri.disposition in ('include','snapshot') and product.can_read_offer(o2, p)
           order by ri.created_at desc limit 1;
        end if;
        insert into conversation.context_item(tenant_id, workspace_id, snapshot_id, item_key, reason, revision_id, release_item_id, passage_id)
        values (t, ws, rid, x ->> 'item_key', x ->> 'reason', case when aid is null then (x ->> 'revision_id')::uuid end, aid, (x ->> 'passage_id')::uuid)
        on conflict (tenant_id, workspace_id, snapshot_id, item_key) do nothing;
      end loop;
    end if;
    select coalesce(max(seq), 0) + 1 into n from conversation.message where thread_id = (pl ->> 'thread_id')::uuid;
    insert into conversation.message(tenant_id, workspace_id, thread_id, seq, role, author_id, agent_identity, client_surface, content, content_sha256, context_snapshot_id, runtime_ref)
    values (t, ws, (pl ->> 'thread_id')::uuid, n, pl ->> 'role', case when pl ->> 'role' = 'user' then p end, pl ->> 'agent_identity',
            case when g.id is null then 'web' else 'harness' end, pl -> 'content', product.sha256_text((pl -> 'content')::text), rid, coalesce(pl -> 'runtime_ref', '{}'))
    returning id into aid;
    return jsonb_build_object('messageId', aid, 'seq', n, 'contextSnapshotId', rid);

  when 'start_attempt' then
    perform product.require_role(ws, p, array['owner']);
    if pl ->> 'purpose' = 'official' then
      select * into e from learning.enrollment where id = (pl ->> 'enrollment_id')::uuid and workspace_id = ws and learner_id = p;
      if e.id is null or not exists (
          select 1 from learning.release_adoption ad join authoring.distribution_offer o2 on o2.id = ad.offer_id
            join curriculum.requirement_option op on op.id = (pl ->> 'option_id')::uuid and op.approval_state = 'approved'
            join curriculum.requirement rq on rq.id = op.requirement_id and rq.requirement_key = (pl ->> 'requirement_key')::uuid
            join authoring.release_item ri on ri.release_id = o2.release_id and ri.revision_id = rq.revision_id
           where ad.id = (pl ->> 'adoption_id')::uuid and ad.enrollment_id = e.id) then
        perform product.fail('VALIDATION', 'official attempt needs an approved option of a requirement in the adopted release');
      end if;
      -- the task must be the one the route names (lab finding F-15)
      select route, activity_revision_id into k, aid from curriculum.requirement_option where id = (pl ->> 'option_id')::uuid;
      if k in ('standard','test_out') and not exists (select 1 from authoring.release_item ri where ri.id = (pl ->> 'task_release_item_id')::uuid and ri.revision_id = aid) then
        perform product.fail('VALIDATION', 'task does not match the option''s activity');
      end if;
      if k in ('learner_project','alternative') and not exists (select 1 from learning.equivalence_request q where q.id = (pl ->> 'equivalence_request_id')::uuid
            and q.learner_id = p and q.enrollment_id = e.id and q.state = 'approved' and q.work_revision_id = (pl ->> 'task_revision_id')::uuid
            and (pl ->> 'requirement_key')::uuid = any(q.requirement_keys)) then
        perform product.fail('VALIDATION', 'a learner project or challenge counts only under an approved equivalence request');
      end if;
    end if;
    if pl ? 'task_release_item_id' and not exists (select 1 from authoring.release_item ri join authoring.distribution_offer o2 on o2.release_id = ri.release_id
         where ri.id = (pl ->> 'task_release_item_id')::uuid and ri.disposition in ('include','snapshot') and product.can_read_offer(o2, p)) then
      perform product.fail('NOT_FOUND', 'task');
    end if;
    if pl ? 'environment_session_id' and not exists (select 1 from learning.environment_session es where es.id = (pl ->> 'environment_session_id')::uuid and es.learner_id = p) then
      perform product.fail('NOT_FOUND', 'environment session');
    end if;
    insert into learning.attempt(tenant_id, workspace_id, learner_id, task_revision_id, task_release_item_id, enrollment_id, adoption_id, requirement_key, option_id, purpose, conditions,
                                 equivalence_request_id, environment_session_id)
    values (t, ws, p, (pl ->> 'task_revision_id')::uuid, (pl ->> 'task_release_item_id')::uuid, (pl ->> 'enrollment_id')::uuid, (pl ->> 'adoption_id')::uuid,
            (pl ->> 'requirement_key')::uuid, (pl ->> 'option_id')::uuid, pl ->> 'purpose', pl -> 'conditions',
            (pl ->> 'equivalence_request_id')::uuid, (pl ->> 'environment_session_id')::uuid) returning * into a;
    return jsonb_build_object('attemptId', a.id);

  when 'submit_attempt' then
    select * into a from learning.attempt where id = (pl ->> 'attempt_id')::uuid and workspace_id = ws and learner_id = p for update;
    if a.id is null then perform product.fail('NOT_FOUND', 'attempt'); end if;
    if a.state <> 'started' then perform product.fail('CONFLICT', 'attempt already ' || a.state); end if;
    tok := jsonb_build_object('attempt', a.id, 'items', (select jsonb_agg(i order by i ->> 'item_key') from jsonb_array_elements(pl -> 'items') i))::text;
    k := product.sha256_text(tok);
    aid := product.register_artifact(ws, p, 'submission_manifest', k, octet_length(tok), 'application/json', 'private_copy', 'learner submission');
    insert into learning.submission(tenant_id, workspace_id, attempt_id, learner_id, manifest_artifact_id, closure_sha256, observed_conditions, submitted_via)
    values (t, ws, a.id, p, aid, k, coalesce(pl -> 'observed_conditions', '{}'), case when g.id is null then 'web' else 'harness' end) returning * into s;
    for x in select * from jsonb_array_elements(pl -> 'items') loop
      if x ? 'revision_id' and not exists (select 1 from authoring.work_revision rv where rv.id = (x ->> 'revision_id')::uuid and rv.workspace_id = ws) then
        perform product.fail('NOT_FOUND', 'evidence revision');
      end if;
      insert into learning.evidence_item(tenant_id, workspace_id, submission_id, item_key, kind, revision_id, artifact_id, message_id, file_set_id, deployment_id,
                                         external_ref, sha256, availability)
      values (t, ws, s.id, x ->> 'item_key', x ->> 'kind', (x ->> 'revision_id')::uuid, (x ->> 'artifact_id')::uuid, (x ->> 'message_id')::uuid,
              (x ->> 'file_set_id')::uuid, (x ->> 'deployment_id')::uuid, x -> 'external_ref', x ->> 'sha256', coalesce(x ->> 'availability', 'preserved'));
    end loop;
    update learning.attempt set state = 'submitted', ended_at = now() where id = a.id;
    return jsonb_build_object('submissionId', s.id, 'manifestArtifactId', aid, 'closureSha256', k, 'manifestText', tok, 'objectPath', (select object_path from orchestration.artifact where id = aid));

  when 'finalize_result' then
    -- the maintainer of the course an official submission was made to (review scope limited to that submission)
    select r2.* into r from learning.assessment_result r2 where r2.id = (pl ->> 'result_id')::uuid;
    select en.source_workspace_id into srcws from learning.submission sb join learning.attempt at on at.id = sb.attempt_id
      join learning.enrollment en on en.id = at.enrollment_id where sb.id = r.submission_id and at.purpose = 'official';
    if r.id is null or srcws is null or coalesce(product.role_in(srcws, p), '') not in ('owner','editor') then perform product.fail('NOT_FOUND', 'result'); end if;
    if r.status <> 'provisional' or not human then perform product.fail('CONFLICT', 'only provisional results are finalized by a human'); end if;
    perform product.finalize(r.id, 'human', null);
    return jsonb_build_object('finalized', true);

  when 'open_appeal' then
    select * into r from learning.assessment_result where id = (pl ->> 'result_id')::uuid and workspace_id = ws;
    if r.id is null or not exists (select 1 from learning.submission sb where sb.id = r.submission_id and sb.learner_id = p) then perform product.fail('NOT_FOUND', 'result'); end if;
    insert into learning.appeal(tenant_id, workspace_id, result_id, learner_id, grounds, new_evidence_submission_id, state)
    values (t, ws, r.id, p, pl ->> 'grounds', (pl ->> 'new_evidence_submission_id')::uuid, 'open') returning id into rid;
    return jsonb_build_object('appealId', rid);

  when 'resolve_appeal' then
    select * into ap from learning.appeal where id = (pl ->> 'appeal_id')::uuid for update;
    select * into r from learning.assessment_result where id = ap.result_id;
    select en.source_workspace_id into srcws from learning.submission sb join learning.attempt at on at.id = sb.attempt_id
      join learning.enrollment en on en.id = at.enrollment_id where sb.id = r.submission_id;
    if ap.id is null or srcws is null or coalesce(product.role_in(srcws, p), '') not in ('owner','editor') then perform product.fail('NOT_FOUND', 'appeal'); end if;
    if ap.state not in ('open','under_review') or not human then perform product.fail('CONFLICT', 'appeal not open'); end if;
    if pl ->> 'decision' = 'modified' then
      select coalesce(max(sequence_no), 0) + 1 into n from learning.assessment_result where submission_id = r.submission_id;
      insert into learning.assessment_result(tenant_id, workspace_id, submission_id, sequence_no, outcomes, status, supersedes_id, reason)
      values (t, ap.workspace_id, r.submission_id, n, pl -> 'outcomes', 'provisional', r.id, 'appeal: ' || (pl ->> 'resolution')) returning id into rid;
      perform product.finalize(rid, 'human', null);
      update learning.assessment_result set status = 'superseded' where id = r.id;
    end if;
    update learning.appeal set state = pl ->> 'decision', reviewer_id = p, resolution = pl ->> 'resolution', resolution_result_id = rid, resolved_at = now() where id = ap.id;
    return jsonb_build_object('state', pl ->> 'decision', 'newResultId', rid);

  when 'grant_evidence' then
    perform product.require_role(ws, p, array['owner']);
    if pl ? 'guardian_link_id' and not exists (select 1 from access.guardian_link gl where gl.id = (pl ->> 'guardian_link_id')::uuid and gl.youth_id = p
         and gl.guardian_id = (pl ->> 'grantee_id')::uuid and gl.state = 'consented'
         and array(select jsonb_array_elements_text(pl -> 'includes')) <@ (gl.help_scope || array['mastery','goals','submissions'])) then
      perform product.fail('FORBIDDEN', 'guardian grant exceeds the consented help scope');
    end if;
    insert into learning.evidence_grant(tenant_id, workspace_id, learner_id, grantee_id, scope_kind, enrollment_id, includes, guardian_link_id)
    values (t, ws, p, (pl ->> 'grantee_id')::uuid, pl ->> 'scope_kind', (pl ->> 'enrollment_id')::uuid, array(select jsonb_array_elements_text(pl -> 'includes')),
            (pl ->> 'guardian_link_id')::uuid) returning id into rid;
    return jsonb_build_object('grantId', rid);

  when 'preview_removal' then
    perform product.require_role(ws, p, array['owner']);
    select * into w from authoring.work where id = (pl ->> 'work_id')::uuid and workspace_id = ws;
    if w.id is null then perform product.fail('NOT_FOUND', 'work'); end if;
    ex := jsonb_build_object(
      'revisions', (select count(*) from authoring.work_revision where work_id = w.id),
      'linked_from', (select coalesce(jsonb_agg(distinct b.revision_id), '[]') from authoring.revision_binding b join authoring.work_revision rv on rv.id = b.target_revision_id
                       where rv.work_id = w.id or b.target_work_id = w.id),
      'released_in_active_offers', (select coalesce(jsonb_agg(distinct o2.id), '[]') from authoring.release_item ri join authoring.work_revision rv on rv.id = ri.revision_id
                       join authoring.distribution_offer o2 on o2.release_id = ri.release_id where rv.work_id = w.id and ri.disposition in ('include','snapshot')
                       and coalesce(o2.end_kind, '') <> 'revoke'),
      'conversation_contexts', (select count(*) from conversation.context_item ci join authoring.work_revision rv on rv.id = ci.revision_id where rv.work_id = w.id),
      'retained_submission_evidence', (select count(*) from learning.evidence_item ei join authoring.work_revision rv on rv.id = ei.revision_id where rv.work_id = w.id),
      'passages', (select count(*) from library.passage pa join authoring.work_revision rv on rv.id = pa.revision_id where rv.work_id = w.id),
      'legal_hold', false);
    insert into library.removal(tenant_id, workspace_id, requested_by, targets, impact, state)
    values (t, ws, p, jsonb_build_object('work_id', w.id), ex,
            case when jsonb_array_length(ex -> 'released_in_active_offers') > 0 then 'blocked' else 'previewed' end) returning id into rid;
    return jsonb_build_object('removalId', rid, 'impact', ex,
                              'state', case when jsonb_array_length(ex -> 'released_in_active_offers') > 0 then 'blocked' else 'previewed' end);

  when 'confirm_removal' then
    perform product.require_role(ws, p, array['owner']);
    select * into rm from library.removal where id = (pl ->> 'removal_id')::uuid and workspace_id = ws for update;
    if rm.id is null then perform product.fail('NOT_FOUND', 'removal'); end if;
    if rm.state <> 'previewed' then perform product.fail('CONFLICT', 'removal is ' || rm.state); end if;
    if exists (select 1 from learning.evidence_item ei join authoring.work_revision rv on rv.id = ei.revision_id
                where rv.work_id = (rm.targets ->> 'work_id')::uuid) and coalesce((pl ->> 'include_retained_evidence')::boolean, false) = false then
      null;   -- submissions keep their evidence (Build 03 A4): revisions they cite are purged of body only if the learner also withdraws them
    end if;
    ev := product.new_event(ws, p, (rm.targets ->> 'work_id')::uuid, null, 'removal_impact_acknowledged', jsonb_build_object('removal_id', rm.id),
                            'removal:' || rm.id, 'human', surface, 'learner');
    perform pg_catalog.set_config('product.purge', 'on', true);
    update authoring.work_revision set body = jsonb_build_object('formatVersion', 1, 'blocks', '[]'::jsonb, 'metadata', jsonb_build_object('purged', true)),
           purged_at = now(), purged_by_removal_id = rm.id
     where work_id = (rm.targets ->> 'work_id')::uuid and purged_at is null
       and id not in (select ei.revision_id from learning.evidence_item ei where ei.revision_id is not null);
    get diagnostics n = row_count;
    -- Build 08: the passages' vector items (one retrieval stack) are retired; embeddings stay bound to retired items and never match again
    perform retrieval.retire_items_for_passages(array(select pa.id from library.passage pa join authoring.work_revision rv on rv.id = pa.revision_id
     where rv.work_id = (rm.targets ->> 'work_id')::uuid and rv.purged_at is not null));
    delete from library.passage pa using authoring.work_revision rv where pa.revision_id = rv.id and rv.work_id = (rm.targets ->> 'work_id')::uuid and rv.purged_at is not null;
    get diagnostics cnt = row_count;
    update library.connected_item set suppressed_at = now(), updated_at = now() where work_id = (rm.targets ->> 'work_id')::uuid;
    perform pg_catalog.set_config('product.purge', 'off', true);
    update library.removal set impact_acknowledged_event_id = ev, state = 'completed', completed_at = now(),
           steps = jsonb_build_array(jsonb_build_object('step', 'purge_revisions', 'count', n), jsonb_build_object('step', 'delete_passages', 'count', cnt),
                                     jsonb_build_object('step', 'suppress_connected_items'))
     where id = rm.id;
    return jsonb_build_object('removalId', rm.id, 'purgedRevisions', n, 'deletedPassages', cnt);

  when 'register_file_set' then
    perform product.require_role(ws, p, array['owner','editor']);
    if exists (select 1 from jsonb_array_elements(pl -> 'files') f where not exists (
         select 1 from authoring.asset_scope sc join orchestration.artifact ar on ar.id = sc.artifact_id
          where sc.workspace_id = ws and sc.artifact_id = (f ->> 'artifact_id')::uuid and sc.revoked_at is null and ar.storage_state = 'available')) then
      perform product.fail('NOT_FOUND', 'every file must be an available artifact admitted to this workspace');
    end if;
    if not exists (select 1 from jsonb_array_elements(pl -> 'files') f where f ->> 'path' = pl ->> 'entrypoint') then
      perform product.fail('VALIDATION', 'entrypoint is not one of the files');
    end if;
    insert into authoring.file_set(tenant_id, workspace_id, entrypoint, tree_sha256, file_count, total_bytes, origin, created_by)
    select t, ws, pl ->> 'entrypoint',
           product.sha256_text(string_agg((f ->> 'path') || ':' || ar.sha256, E'\n' order by f ->> 'path')), count(*), sum(ar.size_bytes),
           case when g.id is null then 'web' else g.client_kind end, p
      from jsonb_array_elements(pl -> 'files') f join orchestration.artifact ar on ar.id = (f ->> 'artifact_id')::uuid
    returning id into rid;
    insert into authoring.file_set_entry(tenant_id, workspace_id, file_set_id, path, artifact_id, sha256, size_bytes, media_type)
    select t, ws, rid, f ->> 'path', ar.id, ar.sha256, ar.size_bytes, coalesce(ar.media_type, 'application/octet-stream')
      from jsonb_array_elements(pl -> 'files') f join orchestration.artifact ar on ar.id = (f ->> 'artifact_id')::uuid;
    return jsonb_build_object('fileSetId', rid, 'treeSha256', (select tree_sha256 from authoring.file_set where id = rid));

  when 'record_deployment' then
    perform product.require_role(ws, p, array['owner','editor']);
    aid := util.uuidv7();
    insert into authoring.deployment(id, tenant_id, workspace_id, revision_id, file_set_id, target, environment, url, external_ref, snapshot_file_set_id, status, origin, created_by)
    values (aid, t, ws, (pl ->> 'revision_id')::uuid, (pl ->> 'file_set_id')::uuid, pl ->> 'target', coalesce(pl ->> 'environment', 'preview'),
            case when pl ->> 'target' = 'platform_static' then format('https://%s.%s.workspaces.aieng.invalid/', aid, coalesce(pl ->> 'environment', 'preview')) else pl ->> 'url' end,
            pl -> 'external_ref', (pl ->> 'snapshot_file_set_id')::uuid,
            case when pl ->> 'target' = 'platform_static' then 'pending' else 'live' end, case when g.id is null then 'web' else g.client_kind end, p);
    return jsonb_build_object('deploymentId', aid, 'url', (select url from authoring.deployment where id = aid), 'status', (select status from authoring.deployment where id = aid));

  when 'propose_equivalence' then
    select * into e from learning.enrollment where id = (pl ->> 'enrollment_id')::uuid and workspace_id = ws and learner_id = p;
    if e.id is null or not exists (select 1 from authoring.work_revision rv where rv.id = (pl ->> 'work_revision_id')::uuid and rv.workspace_id = ws) then
      perform product.fail('NOT_FOUND', 'enrollment or own work');
    end if;
    insert into learning.equivalence_request(tenant_id, workspace_id, learner_id, enrollment_id, work_revision_id, requirement_keys, evidence_plan, state)
    values (t, ws, p, e.id, (pl ->> 'work_revision_id')::uuid, array(select (jsonb_array_elements_text(pl -> 'requirement_keys'))::uuid), pl ->> 'evidence_plan', 'proposed')
    returning id into rid;
    if product.role_in(e.source_workspace_id, p) = 'owner' then        -- the learner's own course: approval is automatic
      update learning.equivalence_request set state = 'approved', decided_by = p, decision = 'owner_course_auto', decided_at = now(),
             decision_reason = 'learner owns the course' where id = rid;
    end if;
    return jsonb_build_object('equivalenceRequestId', rid, 'state', (select state from learning.equivalence_request where id = rid));

  when 'decide_equivalence' then
    select en.source_workspace_id into srcws from learning.equivalence_request q join learning.enrollment en on en.id = q.enrollment_id where q.id = (pl ->> 'request_id')::uuid;
    if srcws is null or coalesce(product.role_in(srcws, p), '') not in ('owner','editor') then perform product.fail('NOT_FOUND', 'equivalence request'); end if;
    if not human then perform product.fail('FORBIDDEN', 'a person decides equivalence'); end if;
    update learning.equivalence_request set state = case when pl ->> 'decision' = 'approve' then 'approved' else 'rejected' end,
           decided_by = p, decision = 'maintainer', decision_reason = pl ->> 'reason', decided_at = now()
     where id = (pl ->> 'request_id')::uuid and state in ('proposed','checked');
    get diagnostics cnt = row_count;
    if cnt = 0 then perform product.fail('CONFLICT', 'request already decided'); end if;
    return jsonb_build_object('state', case when pl ->> 'decision' = 'approve' then 'approved' else 'rejected' end);

  when 'request_environment' then
    perform product.require_role(ws, p, array['owner']);
    if pl ? 'spec_revision_id' and not product.readable_revision((pl ->> 'spec_revision_id')::uuid, p) then perform product.fail('NOT_FOUND', 'environment spec'); end if;
    if exists (select 1 from jsonb_array_elements(coalesce(pl -> 'key_handles', '[]')) h where h ->> 'source' = 'platform' and not exists (
         select 1 from access.provided_credential c where c.id = (h ->> 'provided_credential_id')::uuid and c.principal_id = p and c.revoked_at is null and c.expires_at > now())) then
      perform product.fail('NOT_FOUND', 'platform-provided credential');
    end if;
    if exists (select 1 from jsonb_array_elements(coalesce(pl -> 'key_handles', '[]')) h where (h::text) ~ '(sk-|ghp_|xox[bp]-|AKIA|-----BEGIN)') then
      perform product.fail('VALIDATION', 'key handles must never contain secret values');
    end if;
    insert into learning.environment_session(tenant_id, workspace_id, learner_id, project_work_id, spec_revision_id, provider, adapter, status, key_handles, spend_limit_usd, expires_at)
    values (t, ws, p, (pl ->> 'project_work_id')::uuid, (pl ->> 'spec_revision_id')::uuid, pl ->> 'provider', pl ->> 'adapter',
            case when pl ->> 'provider' in ('local_harness','browser_runtime') then 'ready' else 'requested' end,
            coalesce(pl -> 'key_handles', '[]'), (pl ->> 'spend_limit_usd')::numeric, now() + interval '12 hours')
    returning id into rid;
    return jsonb_build_object('environmentSessionId', rid, 'status', (select status from learning.environment_session where id = rid));

  when 'create_client_grant' then
    tok := 'aiec_' || pg_catalog.encode(extensions.gen_random_bytes(24), 'hex');
    insert into access.client_grant(tenant_id, principal_id, client_kind, label, token_sha256, scopes, workspace_ids, expires_at)
    values (t, p, pl ->> 'client_kind', pl ->> 'label', product.sha256_text(tok), array(select jsonb_array_elements_text(pl -> 'scopes')),
            case when pl ? 'workspace_ids' then array(select (jsonb_array_elements_text(pl -> 'workspace_ids'))::uuid) end,
            now() + make_interval(hours => coalesce((pl ->> 'ttl_hours')::int, 720))) returning id into rid;
    return jsonb_build_object('grantId', rid, 'token', tok);

  when 'revoke_client_grant' then
    update access.client_grant set revoked_at = now() where id = (pl ->> 'grant_id')::uuid and principal_id = p and revoked_at is null;
    return jsonb_build_object('revoked', true);

  when 'invite_guardian' then
    insert into access.guardian_link(tenant_id, youth_id, guardian_id, state) values (t, p, (pl ->> 'guardian_id')::uuid, 'invited') returning id into rid;
    return jsonb_build_object('guardianLinkId', rid);

  when 'consent_guardian' then
    update access.guardian_link set state = 'consented', consented_at = now(), consent_method = pl ->> 'consent_method',
           help_scope = array(select jsonb_array_elements_text(coalesce(pl -> 'help_scope', '[]')))
     where id = (pl ->> 'guardian_link_id')::uuid and guardian_id = p and state = 'invited';
    get diagnostics cnt = row_count;
    if cnt = 0 then perform product.fail('NOT_FOUND', 'guardian invitation'); end if;
    return jsonb_build_object('consented', true);

  when 'authorize_processing' then
    -- self consent, or guardian consent for a youth with a consented link
    if (pl ->> 'principal_id')::uuid = p then
      if product.band(p) = 'child' or product.band_rank(product.band(p)) < product.band_rank(coalesce(product.policy() ->> 'self_consent_min_band', 'teen')) then
        perform product.fail('CONSENT_REQUIRED', 'guardian consent required for this account');
      end if;
      insert into access.processing_authorization(tenant_id, principal_id, processor_class, processor_key, purpose, basis, policy_version_id, granted_by)
      values (t, p, pl ->> 'processor_class', pl ->> 'processor_key', pl ->> 'purpose', 'self', (product.policy() ->> 'policy_version_id')::uuid, p) returning id into rid;
    else
      select gl.id into aid from access.guardian_link gl where gl.youth_id = (pl ->> 'principal_id')::uuid and gl.guardian_id = p and gl.state = 'consented';
      if aid is null then perform product.fail('NOT_FOUND', 'guardian link'); end if;
      insert into access.processing_authorization(tenant_id, principal_id, processor_class, processor_key, purpose, basis, guardian_link_id, policy_version_id, granted_by)
      values (t, (pl ->> 'principal_id')::uuid, pl ->> 'processor_class', pl ->> 'processor_key', pl ->> 'purpose', 'guardian', aid,
              (product.policy() ->> 'policy_version_id')::uuid, p) returning id into rid;
    end if;
    return jsonb_build_object('authorizationId', rid);

  else
    return product.dispatch_research_command(ws, op, head, pl, p, g, human, surface);
  end case;
end $$;

-- Final a result, grant credit for met official requirements (shared by worker auto-finalization and human paths).

-- the trigram channel at 0.05 surfaced unrelated passages (takedown check); pg_trgm's default 0.3 keeps it a spelling-tolerant exact channel
create or replace function api.search_unified(
  p_query text, p_query_embedding extensions.halfvec default null, p_lenses text[] default array['corpus','ours'], p_tiers smallint[] default null,
  p_space_slugs text[] default null, p_document_types text[] default null, p_unit_kinds text[] default null, p_entity_ids uuid[] default null,
  p_as_of timestamptz default null, p_workspace_ids uuid[] default null, p_source_roles text[] default null, p_content_kinds text[] default null,
  p_limit integer default 20, p_candidate_limit integer default 100, p_rrf_k integer default 60)
returns table(vector_item_id uuid, lens text, source_tier smallint, content_kind text, document_type_code text, unit_kind text, entity_id uuid, document_id uuid, document_version_id uuid,
              target_kind text, target_id uuid, workspace_id uuid, snippet text, start_ms integer, end_ms integer, observed_at timestamptz, valid_during tstzrange, space_slug text,
              fused_score double precision, channel_scores jsonb)
language plpgsql stable security definer set search_path = '' as $$
declare t uuid := util.default_tenant_id(); q tsquery := websearch_to_tsquery('english', p_query);
begin
  if coalesce(length(btrim(p_query)),0) < 1 or length(p_query) > 4096 then raise exception 'query text length must be between 1 and 4096' using errcode='invalid_parameter_value'; end if;
  if p_limit not between 1 and 200 or p_candidate_limit not between p_limit and 2000 then raise exception 'result/candidate bounds are invalid' using errcode='invalid_parameter_value'; end if;
  perform set_config('hnsw.iterative_scan','relaxed_order',true);
  return query
  with eligible as materialized (
    select vi.*, s.slug as space_slug_
    from retrieval.vector_item vi join retrieval.vector_space_version v on v.id = vi.space_version_id join retrieval.vector_space s on s.id = v.vector_space_id
    where vi.tenant_id = t and vi.lifecycle = 'active'
      and vi.lens = any(p_lenses)
      and (vi.lens <> 'private' or (p_workspace_ids is not null and vi.workspace_id = any(p_workspace_ids)))
      and (p_tiers is null or vi.source_tier = any(p_tiers))
      and (p_space_slugs is null or s.slug = any(p_space_slugs))
      and (p_document_types is null or vi.document_type_code = any(p_document_types))
      and (p_unit_kinds is null or vi.unit_kind = any(p_unit_kinds))
      and (p_content_kinds is null or vi.content_kind = any(p_content_kinds))
      and (p_source_roles is null or vi.source_role_code = any(p_source_roles))
      and (p_entity_ids is null or vi.entity_id = any(p_entity_ids) or vi.secondary_entity_ids && p_entity_ids)
      and (p_as_of is null or vi.valid_during is null or vi.valid_during @> p_as_of)
  ), fts as (
    select e.id, ts_rank_cd(e.search_tsv_en, q)::double precision raw, row_number() over (order by ts_rank_cd(e.search_tsv_en, q) desc, e.id)::bigint rk
    from eligible e where e.search_tsv_en @@ q limit p_candidate_limit
  ), trigram as (
    select e.id, extensions.similarity(e.search_text, p_query)::double precision raw, row_number() over (order by extensions.similarity(e.search_text, p_query) desc, e.id)::bigint rk
    from eligible e where length(p_query) >= 3 and extensions.similarity(e.search_text, p_query) > 0.3 limit p_candidate_limit
  ), ann as (
    select e.id, (1 - (emb.embedding operator(extensions.<=>) p_query_embedding))::double precision raw, row_number() over (order by emb.embedding operator(extensions.<=>) p_query_embedding, e.id)::bigint rk
    from eligible e join retrieval.vector_item_embedding_1536 emb on emb.vector_item_id = e.id and emb.vector_space_key = e.space_slug_
    where p_query_embedding is not null
    order by emb.embedding operator(extensions.<=>) p_query_embedding, e.id limit p_candidate_limit
  ), channels as (
    select id, 'fts' ch, raw, rk from fts union all select id, 'trigram', raw, rk from trigram union all select id, 'ann', raw, rk from ann
  ), fused as (
    select id, sum(1.0/(p_rrf_k + rk))::double precision score, jsonb_object_agg(ch, jsonb_build_object('score', raw, 'rank', rk) order by ch) details from channels group by id
  )
  select e.id, e.lens, e.source_tier, e.content_kind, e.document_type_code, e.unit_kind, e.entity_id, e.document_id, e.document_version_id,
         pt.target_kind, coalesce(pt.entity_id, pt.record_id, pt.chunk_id, pt.claim_id, pt.summary_id, pt.document_node_id, pt.digest_id, pt.authored_revision_id, pt.passage_id),
         e.workspace_id, left(e.search_text, 320), e.start_ms, e.end_ms, e.observed_at, e.valid_during, e.space_slug_, f.score * (1 + coalesce(0.1 * (3 - e.source_tier), 0)), f.details
  from fused f join eligible e on e.id = f.id left join retrieval.projection_target pt on pt.id = e.projection_target_id
  order by f.score * (1 + coalesce(0.1 * (3 - e.source_tier), 0)) desc, e.id limit p_limit;
end $$;
commit;
