-- Build 08 R2 draft. Part 3b: product.dispatch_read / product.dispatch_worker re-created on the unified retrieval stack (patched copies of 20261105010300_product_api.sql).

create or replace function product.dispatch_read(ws uuid, op text, pl jsonb, p uuid) returns jsonb language plpgsql stable set search_path = '' as $$
declare res jsonb; q tsquery; lim int := least(coalesce((pl ->> 'limit')::int, 20), 50); o authoring.distribution_offer; e learning.enrollment;
begin
  case op
  when 'get_revision' then
    if not product.readable_revision((pl ->> 'revision_id')::uuid, p) then perform product.fail('NOT_FOUND', 'revision'); end if;
    select jsonb_build_object('id', r.id, 'workId', r.work_id, 'revisionNo', r.revision_no, 'title', r.title, 'body', r.body,
                              'contentSha256', r.content_sha256, 'purged', r.purged_at is not null) into res
      from authoring.work_revision r where r.id = (pl ->> 'revision_id')::uuid;
    return res;

  when 'list_works' then
    perform product.require_role(ws, p, array['owner','editor','reader']);
    return coalesce((select jsonb_agg(jsonb_build_object('id', w.id, 'kind', w.kind, 'slug', w.slug, 'head', w.head_revision_id) order by w.created_at)
                       from authoring.work w where w.workspace_id = ws), '[]');

  when 'preview_exposure' then
    perform product.require_role(ws, p, array['owner','editor']);
    if not exists (select 1 from authoring.work_revision r where r.id = (pl ->> 'root_revision_id')::uuid and r.workspace_id = ws) then perform product.fail('NOT_FOUND', 'revision'); end if;
    return product.exposure((pl ->> 'root_revision_id')::uuid, pl ->> 'ceiling');

  when 'get_offer' then
    select * into o from authoring.distribution_offer where id = (pl ->> 'offer_id')::uuid;
    if o.id is null or not product.can_read_offer(o, p) then perform product.fail('NOT_FOUND', 'offer'); end if;
    return jsonb_build_object('offerId', o.id, 'terms', o.terms, 'items',
      (select jsonb_agg(jsonb_build_object('releaseItemId', i.id, 'itemKey', i.item_key, 'disposition', i.disposition, 'revisionId', case when i.disposition in ('include','snapshot') then i.revision_id end,
                                           'artifactId', case when i.disposition in ('include','snapshot') then coalesce(i.substitute_artifact_id, i.artifact_id) end) order by i.item_key)
         from authoring.release_item i where i.release_id = o.release_id and i.disposition <> 'withheld'));

  when 'list_library' then
    return coalesce((select jsonb_agg(jsonb_build_object('distributionId', d.id, 'title', d.title, 'channel', d.channel, 'offerId', o2.id))
                       from authoring.distribution d join authoring.distribution_offer o2 on o2.distribution_id = d.id and o2.ended_at is null
                      where d.channel = coalesce(pl ->> 'channel', 'public_library') and d.closed_at is null and product.can_read_offer(o2, p)), '[]');

  when 'search' then
    -- Build 08: one retrieval stack. Private notes (lens private) and released course material (lens ours) are vector items;
    -- the workspace list bounds private candidates, the per-passage predicates below keep the exact Build 02/04 readability rules.
    return coalesce((select jsonb_agg(x order by (x ->> 'rank')::double precision desc) from (
      select jsonb_build_object('label', case when pa.message_id is not null then 'conversation'
                                              when wk.kind = 'document' or pa.artifact_id is not null then 'uploaded_source'
                                              when product.role_in(pa.workspace_id, p) is not null then 'private_note' else 'course_material' end,
                                'passageId', pa.id, 'revisionId', pa.revision_id, 'workKind', wk.kind, 'locator', pa.locator,
                                'snippet', left(pa.text, 240), 'rank', h.fused_score, 'lens', h.lens, 'tier', h.source_tier, 'channels', h.channel_scores) as x
        from api.search_unified(pl ->> 'query', null, array['private','ours'], null, array['learner_notes','own_content'], null, null, null, null,
               (select array_agg(distinct w) from (
                  select m.workspace_id w from authoring.workspace_member m where m.tenant_id = product.tenant() and m.principal_id = p and m.revoked_at is null
                  union select rv2.workspace_id from authoring.release_item i2 join authoring.distribution_offer o2 on o2.release_id = i2.release_id
                        join authoring.work_revision rv2 on rv2.id = i2.revision_id where i2.disposition in ('include','snapshot') and product.can_read_offer(o2, p)) ws_list),
               null, null, least(lim * 10, 200), least(lim * 20, 2000), 60) h
        join library.passage pa on pa.id = h.target_id and h.target_kind = 'passage'
        left join authoring.work_revision rv on rv.id = pa.revision_id
        left join authoring.work wk on wk.id = rv.work_id
        left join conversation.message m on m.id = pa.message_id
        left join conversation.thread th on th.id = m.thread_id
       where (   (pa.revision_id is not null and (product.role_in(pa.workspace_id, p) is not null or product.readable_revision(pa.revision_id, p)))
              or (pa.message_id is not null and m.redacted_at is null and (th.owner_id = p or (th.visibility = 'workspace' and product.role_in(th.workspace_id, p) is not null)))
              or (pa.artifact_id is not null and exists (select 1 from authoring.asset_scope s where s.artifact_id = pa.artifact_id and s.revoked_at is null
                                                         and product.role_in(s.workspace_id, p) is not null)))
         and not exists (select 1 from library.resource_control c where c.work_id = wk.id and c.excluded_at is not null and product.role_in(c.workspace_id, p) is not null)
         and not (pa.artifact_id is not null and product.restricted(null, pa.artifact_id, array['deny_all']))
         and (rv.id is null or rv.purged_at is null)
       limit lim) s), '[]');

  when 'progress' then
    select * into e from learning.enrollment where id = (pl ->> 'enrollment_id')::uuid;
    if e.id is null or not (e.learner_id = p or exists (select 1 from learning.evidence_grant g where g.learner_id = e.learner_id and g.grantee_id = p
          and g.revoked_at is null and 'progress' = any(g.includes) and (g.scope_kind = 'all_learning' or g.enrollment_id = e.id))) then
      perform product.fail('NOT_FOUND', 'enrollment');
    end if;
    return (select jsonb_build_object('enrollmentId', e.id, 'adoptionId', ad.id, 'requirements',
             (select jsonb_agg(jsonb_build_object('requirementKey', rq.requirement_key, 'kind', rq.kind,
                     'met', exists (select 1 from learning.credit c where c.adoption_id = ad.id and c.requirement_id = rq.id and c.status = 'active'))
                     order by rq.requirement_key)
                from authoring.release_item ri join curriculum.requirement rq on rq.revision_id = ri.revision_id
               where ri.release_id = o2.release_id))
       from learning.release_adoption ad join authoring.distribution_offer o2 on o2.id = ad.offer_id
      where ad.enrollment_id = e.id order by ad.sequence_no desc limit 1);

  when 'get_result' then
    return (select jsonb_build_object('resultId', r.id, 'status', r.status, 'outcomes', r.outcomes, 'supersedes', r.supersedes_id,
              'criteria', (select jsonb_agg(jsonb_build_object('criterion', c.criterion_key, 'value', case when c.visibility = 'student_visible' then c.value end,
                                   'visibility', c.visibility, 'judgedBy', c.judged_by, 'explanation', c.explanation) order by c.criterion_key)
                             from learning.grading_run gr join learning.criterion_result c on c.grading_run_id = gr.id where gr.submission_id = r.submission_id))
       from learning.assessment_result r join learning.submission sb on sb.id = r.submission_id
      where r.id = (pl ->> 'result_id')::uuid
        and (sb.learner_id = p or exists (select 1 from learning.evidence_grant g where g.learner_id = sb.learner_id and g.grantee_id = p
               and g.revoked_at is null and 'results' = any(g.includes))));
    -- (NULL above means not found; callers map NULL to NOT_FOUND)

  when 'get_lesson_view' then
    if not product.readable_revision((pl ->> 'revision_id')::uuid, p) then perform product.fail('NOT_FOUND', 'revision'); end if;
    return (select jsonb_build_object('revisionId', r.id, 'title', r.title, 'body', r.body,
       'blocks', (select jsonb_agg(jsonb_build_object('key', b.block_key, 'type', b.block_type, 'parent', b.parent_key, 'position', b.position) order by b.parent_key nulls first, b.position)
                    from authoring.revision_block b where b.revision_id = r.id),
       'learnerLayer', coalesce((select jsonb_agg(jsonb_build_object('workId', w.id, 'kind', w.kind, 'revisionId', lr.id, 'title', lr.title, 'blockKey', x.block_key,
                                  'anchoredRevisionNo', tr.revision_no, 'carriedForward', tr.id <> r.id))
            from authoring.revision_binding x
            join authoring.work_revision lr on lr.id = x.revision_id
            join authoring.work w on w.id = lr.work_id and w.head_revision_id = lr.id
            join authoring.workspace ws2 on ws2.id = lr.workspace_id and ws2.kind = 'personal' and ws2.owner_id = p
            join authoring.work_revision tr on tr.id = coalesce((select ri.revision_id from authoring.release_item ri where ri.id = x.release_item_id), x.target_revision_id)
           where x.relation = 'anchored_to' and tr.work_id = r.work_id
             and (x.block_key is null or exists (select 1 from authoring.revision_block rb where rb.revision_id = r.id and rb.block_key = x.block_key))), '[]'))
      from authoring.work_revision r where r.id = (pl ->> 'revision_id')::uuid);

  when 'get_thread' then
    return (select jsonb_build_object('threadId', th.id, 'messages', (select jsonb_agg(jsonb_build_object('seq', m.seq, 'role', m.role,
               'content', case when m.redacted_at is null then m.content end, 'surface', m.client_surface) order by m.seq) from conversation.message m where m.thread_id = th.id))
      from conversation.thread th where th.id = (pl ->> 'thread_id')::uuid
        and (th.owner_id = p or (th.visibility = 'workspace' and product.role_in(th.workspace_id, p) is not null)));

  else
    return product.dispatch_research_read(ws, op, pl, p);
  end case;
  return null;
end $$;

-- ================================================================== Build 07: research requests, datasets, statements and support
-- Dataset revision arithmetic: a version is visible in revision n when from <= n < coalesce(to, infinity).
create or replace function product.dataset_draft_no(dw uuid) returns integer language sql stable set search_path = '' as $$
  select coalesce((select r.revision_no from authoring.work w join authoring.work_revision r on r.id = w.head_revision_id where w.id = dw), 0) + 1
$$;

create or replace function product.dispatch_worker(op text, pl jsonb) returns jsonb language plpgsql set search_path = '' as $$
declare t uuid := product.tenant(); aid uuid; rid uuid; x jsonb; n int; s learning.submission; pol jsonb; auto boolean; ws uuid; cnt int; lens_ text;
begin
  case op
  when 'complete_asset' then
    select a.id into aid from orchestration.artifact a where a.id = (pl ->> 'artifact_id')::uuid and a.storage_bucket = 'aieng-workspaces' and a.storage_state = 'pending';
    if aid is null then perform product.fail('NOT_FOUND', 'pending artifact'); end if;
    if not exists (select 1 from storage.objects so where so.bucket_id = 'aieng-workspaces' and so.name = (select object_path from orchestration.artifact where id = aid)) then
      perform product.fail('STORAGE_OBJECT_MISSING', 'object not present in storage');
    end if;
    if (pl ->> 'verified_sha256') is distinct from (select sha256 from orchestration.artifact where id = aid) then
      -- stays pending: the worker removes the bad object and re-uploads the registered bytes (artifacts are append-only)
      return jsonb_build_object('state', 'pending', 'reason', 'digest_mismatch');
    end if;
    update orchestration.artifact set storage_state = 'available', available_at = now() where id = aid;
    return jsonb_build_object('state', 'available');

  when 'add_policy_version' then
    insert into access.policy_version(tenant_id, version, body, body_sha256, active_from)
    values (t, (select coalesce(max(version), 0) + 1 from access.policy_version where tenant_id = t), pl -> 'body', product.sha256_text((pl -> 'body')::text), now())
    returning id into rid;
    return jsonb_build_object('policyVersionId', rid);

  when 'set_account_profile' then
    insert into access.account_profile(tenant_id, principal_id, seq, age_band, jurisdiction, established_by, eligibility, policy_version_id)
    values (t, (pl ->> 'principal_id')::uuid,
            (select coalesce(max(seq), 0) + 1 from access.account_profile where tenant_id = t and principal_id = (pl ->> 'principal_id')::uuid),
            pl ->> 'age_band', pl ->> 'jurisdiction', pl ->> 'established_by', pl ->> 'eligibility', (product.policy() ->> 'policy_version_id')::uuid);
    return jsonb_build_object('ok', true);

  when 'grant_publisher' then
    insert into authoring.publisher_grant(tenant_id, principal_id, channel) values (t, (pl ->> 'principal_id')::uuid, 'official_catalog');
    return jsonb_build_object('ok', true);

  when 'record_equivalence_check' then
    update learning.equivalence_request set assistant_check = pl -> 'check', state = case when state = 'proposed' then 'checked' else state end
     where id = (pl ->> 'request_id')::uuid;
    return jsonb_build_object('ok', true);

  when 'issue_provided_credential' then
    insert into access.provided_credential(tenant_id, principal_id, provider_key, secret_handle, spend_limit_usd, period, expires_at)
    values (t, (pl ->> 'principal_id')::uuid, pl ->> 'provider_key', pl ->> 'secret_handle', (pl ->> 'spend_limit_usd')::numeric, pl ->> 'period',
            now() + make_interval(hours => coalesce((pl ->> 'ttl_hours')::int, 168))) returning id into rid;
    return jsonb_build_object('providedCredentialId', rid);

  when 'set_deployment_status' then
    update authoring.deployment set status = pl ->> 'status', retired_at = case when pl ->> 'status' = 'retired' then now() end where id = (pl ->> 'deployment_id')::uuid;
    return jsonb_build_object('ok', true);

  when 'restrict_source' then
    insert into access.source_restriction(tenant_id, artifact_id, capture_id, kind, effect, reason)
    values (t, (pl ->> 'artifact_id')::uuid, (pl ->> 'capture_id')::uuid, pl ->> 'kind', pl ->> 'effect', pl ->> 'reason') returning id into rid;
    return jsonb_build_object('restrictionId', rid);

  when 'index_passages' then
    ws := (pl ->> 'workspace_id')::uuid;
    perform retrieval.retire_items_for_passages((select coalesce(array_agg(id), '{}') from library.passage
       where workspace_id = ws and coalesce(revision_id, artifact_id, message_id) = coalesce((pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, (pl ->> 'message_id')::uuid)
         and procedure_version = pl ->> 'procedure_version'));
    perform pg_catalog.set_config('product.purge', 'on', true);
    delete from library.passage where workspace_id = ws and coalesce(revision_id, artifact_id, message_id) = coalesce((pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, (pl ->> 'message_id')::uuid)
       and procedure_version = pl ->> 'procedure_version';
    perform pg_catalog.set_config('product.purge', 'off', true);
    -- Build 08 lens rule: released course material is ours (tier 1, space own_content); everything else is private to its workspace (space learner_notes)
    select case when (pl ->> 'revision_id') is not null and exists (select 1 from authoring.release_item i where i.revision_id = (pl ->> 'revision_id')::uuid and i.disposition in ('include','snapshot'))
                then 'ours' else 'private' end into lens_;
    n := 0;
    for x in select * from jsonb_array_elements(pl -> 'passages') loop
      insert into library.passage(tenant_id, workspace_id, revision_id, artifact_id, message_id, passage_no, locator, text, content_sha256, procedure_version)
      values (t, ws, (pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, (pl ->> 'message_id')::uuid, n,
              x -> 'locator', x ->> 'text', product.sha256_text(x ->> 'text'), pl ->> 'procedure_version')
      returning id into rid;
      perform retrieval.index_text_item(case lens_ when 'ours' then 'own_content' else 'learner_notes' end, 'passage', rid, x ->> 'text', lens_,
                                        case lens_ when 'ours' then 1::smallint else null end, 'passage',
                                        p_workspace_id => ws, p_document_type_code => case lens_ when 'ours' then 'course_module' end, p_observed_at => now());
      n := n + 1;
    end loop;
    insert into library.preparation(tenant_id, workspace_id, revision_id, artifact_id, stage, procedure_version, status, attempt_count, output_ref)
    values (t, ws, (pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, 'index_lexical', pl ->> 'procedure_version', 'succeeded', 1, jsonb_build_object('passages', n, 'lens', lens_))
    on conflict do nothing;
    return jsonb_build_object('passages', n, 'lens', lens_);

  when 'record_embeddings' then
    ws := (pl ->> 'workspace_id')::uuid;
    if not product.processing_allowed((pl ->> 'principal_id')::uuid, 'embedding', pl ->> 'processor_key') then
      perform product.fail('CONSENT_REQUIRED', 'embedding processing is not authorized for the content owner');
    end if;
    n := 0;
    for x in select * from jsonb_array_elements(pl -> 'items') loop
      if not exists (select 1 from library.passage pa join authoring.work_revision rv on rv.id = pa.revision_id join library.resource_control c on c.work_id = rv.work_id
                      where pa.id = (x ->> 'passage_id')::uuid and pa.workspace_id = ws and c.semantic_index and c.excluded_at is null) then
        perform product.fail('FORBIDDEN', 'semantic indexing not enabled for this passage');
      end if;
      -- Build 08: the embedding lands in the one stack (partition of the passage's own space); the payload space_version_id is ignored
      select vi.id into rid from retrieval.vector_item vi join retrieval.projection_target pt on pt.id = vi.projection_target_id
       where pt.passage_id = (x ->> 'passage_id')::uuid and vi.lifecycle = 'active' and vi.workspace_id = ws limit 1;
      if rid is null then perform product.fail('NOT_FOUND', 'passage is not indexed'); end if;
      perform retrieval.store_embedding(rid, (x ->> 'embedding')::extensions.halfvec(1536), product.sha256_text(x ->> 'embedding'));
      n := n + 1;
    end loop;
    return jsonb_build_object('embeddings', n);

  when 'record_grading' then
    select * into s from learning.submission where id = (pl ->> 'submission_id')::uuid;
    if s.id is null then perform product.fail('NOT_FOUND', 'submission'); end if;
    if (select storage_state from orchestration.artifact where id = s.manifest_artifact_id) <> 'available' then
      perform product.fail('CONFLICT', 'submission manifest not yet stored and verified');
    end if;
    insert into learning.grading_run(tenant_id, workspace_id, submission_id, pipeline_revision_id, kind, runner, check_bundle_sha256, status, failure_class, reason,
                                     runtime_ref, requested_by, started_at, finished_at)
    values (t, s.workspace_id, s.id, (pl ->> 'pipeline_revision_id')::uuid, pl ->> 'kind', coalesce(pl -> 'runner', '{}'), pl ->> 'check_bundle_sha256',
            pl ->> 'status', pl ->> 'failure_class', pl ->> 'reason', coalesce(pl -> 'runtime_ref', '{}'), coalesce(pl ->> 'requested_by', 'initial'), now(), now())
    returning id into rid;
    if pl ->> 'status' <> 'completed' then
      return jsonb_build_object('gradingRunId', rid, 'result', null, 'note', 'infrastructure/abstention outcome recorded; no result, no learner failure');
    end if;
    for x in select * from jsonb_array_elements(pl -> 'criteria') loop
      insert into learning.criterion_result(tenant_id, workspace_id, grading_run_id, criterion_key, value, visibility, judged_by, judgment, explanation, evidence_refs)
      values (t, s.workspace_id, rid, x ->> 'criterion_key', x -> 'value', coalesce(x ->> 'visibility', 'student_visible'), x ->> 'judged_by', x -> 'judgment',
              x ->> 'explanation', coalesce(x -> 'evidence_refs', '[]'));
    end loop;
    select body -> 'metadata' -> 'finalization' into pol from authoring.work_revision where id = (pl ->> 'finalization_policy_revision_id')::uuid;
    auto := coalesce((pol ->> 'auto')::boolean, false)
        and not exists (select 1 from jsonb_array_elements(pl -> 'criteria') c where c ->> 'judged_by' = 'model'
                          and ((c -> 'judgment' ->> 'status') <> 'answered' or coalesce((c -> 'judgment' ->> 'confidence')::numeric, 0) < coalesce((pol ->> 'min_confidence')::numeric, 1)))
        and not exists (select 1 from jsonb_each_text(pl -> 'outcomes') o where o.value = 'insufficient_evidence');
    select coalesce(max(sequence_no), 0) + 1 into n from learning.assessment_result where submission_id = s.id;
    insert into learning.assessment_result(tenant_id, workspace_id, submission_id, sequence_no, outcomes, status, finalized_by, finalization_policy_revision_id, finalized_at, reason)
    values (t, s.workspace_id, s.id, n, pl -> 'outcomes', 'provisional', case when auto then 'auto' end,
            case when auto then (pl ->> 'finalization_policy_revision_id')::uuid end, case when auto then now() end,
            case when auto then 'auto-finalized under policy' else 'awaiting human review: policy conditions not met' end)
    returning id into aid;
    if auto then perform product.finalize(aid, 'auto', (pl ->> 'finalization_policy_revision_id')::uuid); end if;
    return jsonb_build_object('gradingRunId', rid, 'resultId', aid, 'status', case when auto then 'final' else 'provisional' end);

  else
    perform product.fail('UNKNOWN_OPERATION', op);
  end case;
end $$;
