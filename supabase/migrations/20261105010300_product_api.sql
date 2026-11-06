-- Builds 01–04 product API: api.product_command / api.product_read (authenticated) and api.product_worker (service_role).
-- Lab implementation: the operations needed for the journey and denial tests. Remaining operations are listed in the
-- Build 04 record as not yet implemented. All functions are SECURITY DEFINER owned by product_api_owner (no BYPASSRLS).
begin;
set local lock_timeout = '15s';

-- ================================================================== context and errors
create or replace function product.fail(code text, detail text default null) returns void language plpgsql set search_path = '' as $$
begin raise exception '%', code using errcode = 'P0001', detail = coalesce(detail, ''); end $$;

create or replace function product.tenant() returns uuid language sql stable set search_path = '' as
$$ select util.default_tenant_id() $$;   -- trusted server configuration in this single-tenant cycle; never request input

-- Lab finding F-06: Supabase's postgres role cannot grant USAGE on schema auth, so the API owner reads the
-- PostgREST-verified JWT claims directly (exactly what auth.uid()/auth.role() do). FKs to auth.users still validate actors.
create or replace function product.claims() returns jsonb language sql stable set search_path = '' as
$$ select coalesce(nullif(pg_catalog.current_setting('request.jwt.claims', true), '')::jsonb, '{}'::jsonb) $$;

create or replace function product.actor() returns uuid language plpgsql stable set search_path = '' as $$
declare a uuid := (product.claims() ->> 'sub')::uuid;
begin
  if a is null or coalesce(product.claims() ->> 'role', '') <> 'authenticated' then perform product.fail('AUTH_REQUIRED'); end if;
  return a;
end $$;

create or replace function product.policy() returns jsonb language sql stable set search_path = '' as $$
  select coalesce((select p.body || jsonb_build_object('policy_version_id', p.id) from access.policy_version p
                    where p.tenant_id = product.tenant() and p.active_from <= now() order by p.version desc limit 1),
                  jsonb_build_object('default_band','unknown'))
$$;

create or replace function product.band(p uuid) returns text language sql stable set search_path = '' as $$
  select coalesce((select a.age_band from access.account_profile a where a.tenant_id = product.tenant() and a.principal_id = p order by a.seq desc limit 1),
                  product.policy() ->> 'default_band', 'unknown')
$$;

create or replace function product.band_rank(b text) returns int language sql immutable set search_path = '' as $$
  select case b when 'adult' then 3 when 'teen' then 2 when 'child' then 1 else 0 end
$$;

-- Processing consent required by policy for this principal/class/key?
create or replace function product.processing_allowed(p uuid, cls text, pkey text) returns boolean language sql stable set search_path = '' as $$
  select case
    when not (product.band(p) = any(array(select jsonb_array_elements_text(coalesce(product.policy() -> 'consent_required_bands' -> cls, '["child","teen","unknown"]')))))
      then true
    else exists (select 1 from access.processing_authorization a where a.tenant_id = product.tenant() and a.principal_id = p
                  and a.processor_class = cls and a.processor_key = pkey and a.withdrawn_at is null)
  end
$$;

create or replace function product.role_in(ws uuid, p uuid) returns text language sql stable set search_path = '' as $$
  select m.role from authoring.workspace_member m where m.tenant_id = product.tenant() and m.workspace_id = ws and m.principal_id = p and m.revoked_at is null
$$;

create or replace function product.require_role(ws uuid, p uuid, allowed text[]) returns text language plpgsql stable set search_path = '' as $$
declare r text := product.role_in(ws, p);
begin
  if r is null then perform product.fail('NOT_FOUND', 'workspace'); end if;
  if not (r = any(allowed)) then perform product.fail('FORBIDDEN', format('role %s', r)); end if;
  return r;
end $$;

create or replace function product.restricted(cap uuid, art uuid, effects text[]) returns boolean language sql stable set search_path = '' as $$
  select exists (select 1 from access.source_restriction s where s.tenant_id = product.tenant() and s.lifted_at is null and s.effect = any(effects)
                  and ((cap is not null and s.capture_id = cap) or (art is not null and s.artifact_id = art)
                       or (cap is not null and s.source_id = (select c.source_id from evidence.source_capture c where c.id = cap))))
$$;

-- Client grant from the request header; NULL means an interactive web session.
create or replace function product.client_grant(op_scope text, ws uuid) returns access.client_grant language plpgsql set search_path = '' as $$
declare tok text; g access.client_grant;
begin
  tok := nullif(pg_catalog.current_setting('request.headers', true), '')::jsonb ->> 'x-aieng-client-token';
  if tok is null then return null; end if;
  select * into g from access.client_grant c where c.token_sha256 = product.sha256_text(tok) and c.tenant_id = product.tenant();
  if g.id is null or g.revoked_at is not null or g.expires_at <= now() or g.principal_id <> product.actor() then
    perform product.fail('CLIENT_GRANT_INVALID');
  end if;
  if not (op_scope = any(g.scopes)) then perform product.fail('CLIENT_SCOPE_DENIED', op_scope); end if;
  if ws is not null and g.workspace_ids is not null and not (ws = any(g.workspace_ids)) then perform product.fail('NOT_FOUND', 'workspace'); end if;
  update access.client_grant set last_used_at = now() where id = g.id;
  return g;
end $$;

create or replace function product.personal_workspace(p uuid) returns uuid language plpgsql set search_path = '' as $$
declare w uuid;
begin
  select id into w from authoring.workspace where tenant_id = product.tenant() and owner_id = p and kind = 'personal';
  if w is null then
    insert into authoring.workspace(tenant_id, owner_id, kind, name) values (product.tenant(), p, 'personal', 'Personal') returning id into w;
    insert into authoring.workspace_member(tenant_id, workspace_id, principal_id, role, granted_by) values (product.tenant(), w, p, 'owner', p);
  end if;
  return w;
end $$;

-- ================================================================== body validation and sealing
create or replace function product.validate_body(kind text, body jsonb) returns void language plpgsql set search_path = '' as $$
declare b jsonb; ids text[] := '{}';
begin
  if coalesce(body ->> 'formatVersion', '') not in ('1','2') or coalesce(jsonb_typeof(body -> 'blocks'), '') <> 'array' then
    perform product.fail('VALIDATION', 'body must be aieng.work-body.v1/v2 {formatVersion, blocks:[]}');
  end if;
  if (select count(*) from jsonb_object_keys(body) k where k not in ('formatVersion','blocks','metadata','extensions')) > 0 then
    perform product.fail('VALIDATION', 'unknown body fields outside extensions');
  end if;
  if body ? 'extensions' and octet_length((body -> 'extensions')::text) > 16384 then perform product.fail('VALIDATION', 'extensions over 16 KiB'); end if;
  if body ->> 'formatVersion' = '2' then return; end if;      -- v2 blocks are validated while projecting (product.walk_blocks)
  for b in select * from jsonb_array_elements(body -> 'blocks') loop
    if (b ->> 'id') !~ '^[0-9a-f-]{36}$' or (b ->> 'kind') not in ('markdown','code','image','file','interaction') then
      perform product.fail('VALIDATION', 'block id/kind');
    end if;
    if (b ->> 'id') = any(ids) then perform product.fail('VALIDATION', 'duplicate block id'); end if;
    ids := ids || (b ->> 'id');
  end loop;
end $$;

-- v2: validate each block against the catalog and project it into authoring.revision_block (stable keys, nesting).
create or replace function product.walk_blocks(rid uuid, blocks jsonb, parent uuid, p uuid) returns void language plpgsql set search_path = '' as $$
declare b jsonb; i int := 0; bt authoring.block_type; k uuid; roles text[]; lk text; r text; comp uuid;
begin
  for b in select * from jsonb_array_elements(blocks) loop
    if coalesce(b ->> 'key', '') !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then perform product.fail('VALIDATION', 'block key must be a UUID'); end if;
    k := (b ->> 'key')::uuid;
    select * into bt from authoring.block_type where code = b ->> 'type';
    if bt.code is null then perform product.fail('VALIDATION', format('unknown block type %s', b ->> 'type')); end if;
    if bt.needs_fallback and not product.nonblank(b ->> 'fallback') then perform product.fail('VALIDATION', format('%s block needs a text fallback', bt.code)); end if;
    if b ? 'children' and bt.code <> 'section' then perform product.fail('VALIDATION', 'only sections have children'); end if;
    roles := '{}';
    for lk in select jsonb_array_elements_text(coalesce(b -> 'bindings', '[]')) loop
      select x.role into r from authoring.revision_binding x where x.revision_id = rid and x.local_key = lk;
      if not found then perform product.fail('VALIDATION', format('block %s references unknown binding %s', k, lk)); end if;
      if r is not null and not (r = any(bt.allowed_roles || bt.required_roles)) then perform product.fail('VALIDATION', format('role %s not allowed on %s', r, bt.code)); end if;
      roles := roles || coalesce(r, '');
    end loop;
    if not (bt.required_roles <@ roles) then perform product.fail('VALIDATION', format('%s block requires roles %s', bt.code, bt.required_roles)); end if;
    if bt.code = 'interactive' then
      comp := (b -> 'content' ->> 'component_revision_id')::uuid;
      if comp is null or not exists (select 1 from authoring.work_revision cr join authoring.work w on w.id = cr.work_id
                                       where cr.id = comp and w.kind = 'component' and product.readable_revision(cr.id, p)) then
        perform product.fail('VALIDATION', 'interactive block needs a readable component revision');
      end if;
    end if;
    -- lab finding F-16: every revision a block names in its content must also be a typed `uses` binding of that block,
    -- so the release closure carries it (renderer components, embedded challenges, project milestones).
    for lk in select v from jsonb_each_text(coalesce(b -> 'content', '{}')) e(k2, v) where e.k2 ~ '_revision_id$' loop
      if not exists (select 1 from authoring.revision_binding x where x.revision_id = rid and x.relation = 'uses' and x.target_revision_id = lk::uuid
                      and x.local_key in (select jsonb_array_elements_text(coalesce(b -> 'bindings', '[]')))) then
        perform product.fail('VALIDATION', format('block %s names revision %s without a uses binding', k, lk));
      end if;
    end loop;
    if bt.code = 'embedded_site' and not exists (select 1 from authoring.revision_binding x where x.revision_id = rid and x.file_set_id is not null and x.role = 'build'
                                                   and x.local_key in (select jsonb_array_elements_text(coalesce(b -> 'bindings', '[]'))))
       and not exists (select 1 from authoring.deployment d where d.id = (b -> 'content' ->> 'deployment_id')::uuid and d.target = 'external') then
      perform product.fail('VALIDATION', 'embedded_site needs a build file set or an external deployment');
    end if;
    if bt.code = 'snippet_ref' and not exists (select 1 from authoring.revision_binding x join authoring.work_revision sr on sr.id = x.target_revision_id
           join authoring.work w on w.id = sr.work_id where x.revision_id = rid and x.relation = 'uses' and w.kind = 'snippet'
           and x.local_key in (select jsonb_array_elements_text(coalesce(b -> 'bindings', '[]')))) then
      perform product.fail('VALIDATION', 'snippet_ref needs a uses binding to a snippet revision');
    end if;
    begin
      insert into authoring.revision_block(tenant_id, workspace_id, revision_id, block_key, block_type, parent_key, position, content_sha256)
      select r2.tenant_id, r2.workspace_id, rid, k, bt.code, parent, i, product.sha256_text((b - 'children')::text) from authoring.work_revision r2 where r2.id = rid;
    exception when unique_violation then perform product.fail('VALIDATION', format('duplicate block key %s', k));
    end;
    if bt.code = 'section' then perform product.walk_blocks(rid, coalesce(b -> 'children', '[]'), k, p); end if;
    i := i + 1;
  end loop;
end $$;

create or replace function product.revision_digest(rid uuid) returns text language sql stable set search_path = '' as $$
  select product.sha256_text(jsonb_build_object(
    'title', r.title, 'body', r.body,
    'bindings', coalesce((select jsonb_agg(jsonb_build_object('k', b.local_key, 'rel', b.relation, 't', coalesce(b.target_revision_id, b.target_work_id, b.artifact_id, b.capture_id, b.locator_id, b.claim_id, b.entity_id, b.record_id, b.release_item_id, b.file_set_id, b.assertion_id), 'u', b.usage, 'r', b.role, 'bk', b.block_key) order by b.local_key) from authoring.revision_binding b where b.revision_id = r.id), '[]'),
    'parts', coalesce((select jsonb_agg(jsonb_build_object('o', p.occurrence_key, 'c', p.child_revision_id, 'n', p.ordinal, 'r', p.role) order by p.ordinal) from curriculum.part p where p.parent_revision_id = r.id), '[]'),
    'outcomes', coalesce((select jsonb_agg(jsonb_build_object('k', o.outcome_key, 's', o.statement, 'b', o.bloom_level, 'e', o.evidence_rule,
         'a', coalesce((select jsonb_agg(jsonb_build_object('c', a.competency_revision_id, 'f', a.facet, 'v', a.coverage) order by a.competency_revision_id, a.facet) from curriculum.outcome_alignment a where a.outcome_id = o.id), '[]')) order by o.outcome_key) from curriculum.outcome o where o.revision_id = r.id), '[]'),
    'requirements', coalesce((select jsonb_agg(jsonb_build_object('k', q.requirement_key, 'kind', q.kind,
         'o', (select o.outcome_key from curriculum.outcome o where o.id = q.outcome_id), 'p', (select p.occurrence_key from curriculum.part p where p.id = q.part_id),
         'opts', coalesce((select jsonb_agg(jsonb_build_object('r', x.route, 'a', x.activity_revision_id, 'e', x.evidence_rule, 's', x.approval_state) order by x.route, x.activity_revision_id) from curriculum.requirement_option x where x.requirement_id = q.id), '[]')) order by q.requirement_key) from curriculum.requirement q where q.revision_id = r.id), '[]'),
    'prerequisites', coalesce((select jsonb_agg(jsonb_build_object('r', x.required_revision_id, 's', x.strength) order by x.required_revision_id) from curriculum.prerequisite x where x.revision_id = r.id), '[]'),
    'runtime', coalesce((select jsonb_agg(jsonb_build_object('k', x.local_key, 'kind', x.kind, 'e', x.ecosystem, 'n', x.name, 'v', x.version_spec, 'rv', x.resolved_version) order by x.local_key) from authoring.runtime_requirement x where x.revision_id = r.id), '[]'),
    'assertions', coalesce((select jsonb_agg(jsonb_build_object('k', a.assertion_key, 'b', a.block_key, 'kind', a.kind, 's', a.statement, 'st', a.support_status, 'x', a.structured,
         'e', a.entity_ids, 'wf', a.world_from, 'wt', a.world_to, 'c', a.uses_claim_id) order by a.assertion_key) from inquiry.assertion a where a.revision_id = r.id), '[]')
  )::text) from authoring.work_revision r where r.id = rid
$$;

-- Can p read release item ri (released content they were offered)?
create or replace function product.can_read_offer(o authoring.distribution_offer, p uuid) returns boolean language plpgsql stable set search_path = '' as $$
declare d authoring.distribution; adopted boolean;
begin
  select * into d from authoring.distribution where id = o.distribution_id;
  adopted := exists (select 1 from learning.release_adoption a join learning.enrollment e on e.id = a.enrollment_id
                      where a.offer_id = o.id and e.learner_id = p);
  if o.end_kind = 'revoke' then return false; end if;
  if (o.end_kind = 'retire' or d.closed_at is not null) and not adopted then return false; end if;
  return case d.channel
    when 'workspace' then product.role_in(d.workspace_id, p) is not null
    when 'invited' then exists (select 1 from authoring.distribution_member m where m.distribution_id = d.id and m.principal_id = p and m.revoked_at is null)
                        or product.role_in(d.workspace_id, p) is not null
    when 'public_library' then product.band_rank(product.band(p)) >= product.band_rank(coalesce(product.policy() ->> 'public_read_min_band', 'adult'))
    when 'official_catalog' then product.band(p) <> 'unknown'
  end;
end $$;

create or replace function product.readable_revision(rid uuid, p uuid) returns boolean language sql stable set search_path = '' as $$
  select exists (select 1 from authoring.work_revision r where r.id = rid and product.role_in(r.workspace_id, p) is not null)
      or exists (select 1 from authoring.release_item i join authoring.distribution_offer o on o.release_id = i.release_id
                  where i.revision_id = rid and i.disposition in ('include','snapshot') and product.can_read_offer(o, p))
$$;

-- ================================================================== revisions
create or replace function product.insert_revision(ws uuid, w authoring.work, p uuid, parent uuid, spec jsonb) returns uuid language plpgsql set search_path = '' as $$
declare rid uuid; n int; x jsonb; oc jsonb; q jsonb; t jsonb; oid uuid; qid uuid; pid uuid; tkind text; tid uuid; ckind text; rkind text;
begin
  perform product.validate_body(w.kind, spec -> 'body');
  select coalesce(max(revision_no), 0) + 1 into n from authoring.work_revision where work_id = w.id;
  insert into authoring.work_revision(tenant_id, workspace_id, work_id, revision_no, parent_revision_id, title, body_schema, body, origin, origin_ref, created_by)
  values (product.tenant(), ws, w.id, n, parent, spec ->> 'title', 'aieng.work-body.v' || (spec -> 'body' ->> 'formatVersion'), spec -> 'body', coalesce(spec ->> 'origin', 'human'),
          coalesce(spec -> 'origin_ref', '{}'), p)
  returning id into rid;

  for x in select * from jsonb_array_elements(coalesce(spec -> 'bindings', '[]')) loop
    tkind := x -> 'target' ->> 'kind'; tid := (x -> 'target' ->> 'id')::uuid;
    if tkind = 'artifact' and not exists (select 1 from authoring.asset_scope s where s.workspace_id = ws and s.artifact_id = tid and s.revoked_at is null) then
      perform product.fail('NOT_FOUND', 'artifact not admitted to this workspace');
    end if;
    if tkind = 'release_item' and not exists (select 1 from authoring.release_item i join authoring.distribution_offer o on o.release_id = i.release_id
          where i.id = tid and i.disposition in ('include','snapshot') and product.can_read_offer(o, p)
            and (x ->> 'relation' <> 'adapted_from' or coalesce(o.terms ->> 'adapt', 'none') <> 'none')) then
      perform product.fail('FORBIDDEN', 'release item not readable or adaptation not permitted');
    end if;
    if x ->> 'relation' = 'anchored_to' then
      if (select kind from authoring.workspace where id = ws) <> 'personal' then perform product.fail('VALIDATION', 'learner-layer anchors live in a personal workspace'); end if;
      if x ? 'block_key' and not exists (select 1 from authoring.revision_block rb
            where rb.block_key = (x ->> 'block_key')::uuid
              and rb.revision_id = coalesce((select ri.revision_id from authoring.release_item ri where ri.id = tid and tkind = 'release_item'), case when tkind = 'revision' then tid end)) then
        perform product.fail('NOT_FOUND', 'anchor block');
      end if;
    end if;
    if tkind = 'file_set' and not exists (select 1 from authoring.file_set f where f.id = tid and f.workspace_id = ws) then
      perform product.fail('NOT_FOUND', 'file set not in this workspace');
    end if;
    -- Build 07: a `dataset` role must name an exact dataset revision; a cited statement must be readable
    if x ->> 'role' = 'dataset' and not (tkind = 'revision' and exists (select 1 from authoring.work_revision dr join authoring.work dw on dw.id = dr.work_id
          where dr.id = tid and dr.workspace_id = ws and dw.kind = 'dataset')) then
      perform product.fail('VALIDATION', 'a dataset binding must target an exact dataset revision');
    end if;
    if tkind = 'assertion' and not exists (select 1 from inquiry.assertion a where a.id = tid and product.readable_revision(a.revision_id, p)) then
      perform product.fail('NOT_FOUND', 'assertion');
    end if;
    insert into authoring.revision_binding(tenant_id, workspace_id, revision_id, local_key, relation, target_revision_id, target_work_id, artifact_id,
      capture_id, locator_id, claim_id, entity_id, record_id, release_item_id, file_set_id, assertion_id, role, block_key, usage, rights_basis)
    values (product.tenant(), ws, rid, x ->> 'local_key', x ->> 'relation',
      case when tkind = 'revision' then tid end, case when tkind = 'work' then tid end, case when tkind = 'artifact' then tid end,
      case when tkind = 'capture' then tid end, case when tkind = 'locator' then tid end, case when tkind = 'claim' then tid end,
      case when tkind = 'entity' then tid end, case when tkind = 'record' then tid end, case when tkind = 'release_item' then tid end,
      case when tkind = 'file_set' then tid end, case when tkind = 'assertion' then tid end, x ->> 'role', (x ->> 'block_key')::uuid,
      coalesce(x ->> 'usage', 'reference_only'), coalesce(x ->> 'rights_basis', 'author-declared'));
  end loop;

  for x in select * from jsonb_array_elements(coalesce(spec -> 'parts', '[]')) loop
    select wk.kind into ckind from authoring.work_revision cr join authoring.work wk on wk.id = cr.work_id where cr.id = (x ->> 'child_revision_id')::uuid and cr.workspace_id = ws;
    if ckind is null then perform product.fail('NOT_FOUND', 'child revision'); end if;
    if not ((w.kind = 'course' and ckind in ('track','module','lesson','activity','challenge','project_template'))
         or (w.kind = 'track' and ckind in ('module','lesson','activity','challenge','project_template'))
         or (w.kind = 'module' and ckind in ('lesson','activity','challenge','project_template')) or (w.kind = 'lesson' and ckind in ('activity','challenge'))
         or (w.kind = 'project_template' and ckind in ('challenge','activity','lesson'))
         or (w.kind in ('wiki','project') and ckind in ('note','document','experience','lesson','activity','challenge'))) then
      perform product.fail('VALIDATION', format('%s cannot contain %s', w.kind, ckind));
    end if;
    insert into curriculum.part(tenant_id, workspace_id, parent_revision_id, occurrence_key, child_revision_id, ordinal, role)
    values (product.tenant(), ws, rid, (x ->> 'occurrence_key')::uuid, (x ->> 'child_revision_id')::uuid, (x ->> 'ordinal')::int, coalesce(x ->> 'role', 'recommended'));
  end loop;

  for oc in select * from jsonb_array_elements(coalesce(spec -> 'outcomes', '[]')) loop
    insert into curriculum.outcome(tenant_id, workspace_id, revision_id, outcome_key, statement, bloom_level, evidence_rule)
    values (product.tenant(), ws, rid, (oc ->> 'outcome_key')::uuid, oc ->> 'statement', oc ->> 'bloom_level', oc -> 'evidence_rule') returning id into oid;
    for t in select * from jsonb_array_elements(coalesce(oc -> 'alignments', '[]')) loop
      select wk.kind into rkind from authoring.work_revision cr join authoring.work wk on wk.id = cr.work_id where cr.id = (t ->> 'competency_revision_id')::uuid;
      if rkind is distinct from 'competency' or not product.readable_revision((t ->> 'competency_revision_id')::uuid, p) then
        perform product.fail('VALIDATION', 'alignment target must be a readable competency revision');
      end if;
      insert into curriculum.outcome_alignment(tenant_id, workspace_id, outcome_id, competency_revision_id, facet, coverage, rationale)
      values (product.tenant(), ws, oid, (t ->> 'competency_revision_id')::uuid, t ->> 'facet', t ->> 'coverage', t ->> 'rationale');
    end loop;
  end loop;

  for q in select * from jsonb_array_elements(coalesce(spec -> 'requirements', '[]')) loop
    select id into oid from curriculum.outcome where revision_id = rid and outcome_key = (q ->> 'outcome_key')::uuid;
    select id into pid from curriculum.part where parent_revision_id = rid and occurrence_key = (q ->> 'occurrence_key')::uuid;
    insert into curriculum.requirement(tenant_id, workspace_id, revision_id, requirement_key, kind, outcome_id, part_id, rationale)
    values (product.tenant(), ws, rid, (q ->> 'requirement_key')::uuid, q ->> 'kind', case when q ->> 'kind' = 'outcome' then oid end,
            case when q ->> 'kind' = 'mandatory_activity' then pid end, q ->> 'rationale') returning id into qid;
    for t in select * from jsonb_array_elements(coalesce(q -> 'options', '[]')) loop
      if t ->> 'approval_state' = 'approved' and product.role_in(ws, p) not in ('owner','editor') then perform product.fail('FORBIDDEN', 'only maintainers approve options'); end if;
      insert into curriculum.requirement_option(tenant_id, workspace_id, requirement_id, route, activity_revision_id, evidence_rule, approval_state, approved_by)
      values (product.tenant(), ws, qid, t ->> 'route', (t ->> 'activity_revision_id')::uuid, t -> 'evidence_rule', t ->> 'approval_state',
              case when t ->> 'approval_state' = 'approved' then p end);
    end loop;
  end loop;

  for x in select * from jsonb_array_elements(coalesce(spec -> 'prerequisites', '[]')) loop
    insert into curriculum.prerequisite(tenant_id, workspace_id, revision_id, required_revision_id, strength, rationale)
    values (product.tenant(), ws, rid, (x ->> 'required_revision_id')::uuid, x ->> 'strength', x ->> 'rationale');
  end loop;

  for x in select * from jsonb_array_elements(coalesce(spec -> 'runtime', '[]')) loop
    insert into authoring.runtime_requirement(tenant_id, workspace_id, revision_id, local_key, kind, ecosystem, name, version_spec, resolved_version, phase, optional)
    values (product.tenant(), ws, rid, x ->> 'local_key', x ->> 'kind', x ->> 'ecosystem', x ->> 'name', x ->> 'version_spec', x ->> 'resolved_version',
            coalesce(x ->> 'phase', 'run'), coalesce((x ->> 'optional')::boolean, false));
  end loop;

  if spec -> 'body' ->> 'formatVersion' = '2' then perform product.walk_blocks(rid, spec -> 'body' -> 'blocks', null, p); end if;

  -- Build 07: statements made in this revision, anchored to its blocks; every finding block names one
  for x in select * from jsonb_array_elements(coalesce(spec -> 'assertions', '[]')) loop
    if x ? 'block_key' and not exists (select 1 from authoring.revision_block rb where rb.revision_id = rid and rb.block_key = (x ->> 'block_key')::uuid) then
      perform product.fail('VALIDATION', format('assertion anchored to unknown block %s', x ->> 'block_key'));
    end if;
    if x ? 'uses_claim_id' and not exists (select 1 from evidence.claim c where c.id = (x ->> 'uses_claim_id')::uuid and c.tenant_id = product.tenant()) then
      perform product.fail('NOT_FOUND', 'cited shared claim');
    end if;
    insert into inquiry.assertion(tenant_id, workspace_id, revision_id, assertion_key, block_key, kind, statement, structured, support_status, entity_ids,
                                  world_from, world_to, world_precision, uses_claim_id, created_by)
    values (product.tenant(), ws, rid, coalesce((x ->> 'assertion_key')::uuid, util.uuidv7()), (x ->> 'block_key')::uuid, x ->> 'kind', x ->> 'statement', x -> 'structured',
            x ->> 'support_status', array(select (jsonb_array_elements_text(coalesce(x -> 'entity_ids', '[]')))::uuid),
            (x -> 'world' ->> 'from')::timestamptz, (x -> 'world' ->> 'to')::timestamptz, coalesce(x -> 'world' ->> 'precision', 'unknown'), (x ->> 'uses_claim_id')::uuid, p);
  end loop;
  if exists (select 1 from authoring.revision_block rb where rb.revision_id = rid and rb.block_type = 'finding'
              and not exists (select 1 from inquiry.assertion a where a.revision_id = rid and a.block_key = rb.block_key)) then
    perform product.fail('VALIDATION', 'every finding block needs a statement anchored to it');
  end if;
  update authoring.work_revision set content_sha256 = product.revision_digest(rid) where id = rid;
  return rid;
end $$;

-- ================================================================== release exposure
create or replace function product.exposure(root_rev uuid, ceiling text) returns jsonb language plpgsql stable set search_path = '' as $$
declare items jsonb := '[]'; r record; disp text; blockers jsonb := '[]';
begin
  for r in
    with recursive closure(rid) as (
      select root_rev
      union
      select x.child from closure c cross join lateral (
        select p.child_revision_id as child from curriculum.part p where p.parent_revision_id = c.rid
        union select b.target_revision_id from authoring.revision_binding b where b.revision_id = c.rid and b.target_revision_id is not null
             and b.relation in ('uses','derived_from','has_component','contains','evaluates_with')
        union select q.required_revision_id from curriculum.prerequisite q where q.revision_id = c.rid
        union select a.revision_id from authoring.revision_binding b join inquiry.assertion a on a.id = b.assertion_id where b.revision_id = c.rid
        union select s.source_revision_id from inquiry.assertion a join inquiry.support s on s.assertion_id = a.id where a.revision_id = c.rid and s.source_revision_id is not null
        union select s.source_revision_id from authoring.work_revision dr join inquiry.support s on s.dataset_work_id = dr.work_id
               where dr.id = c.rid and s.source_revision_id is not null
                 and (s.cell_id is null or exists (select 1 from dataset.cell cc where cc.id = s.cell_id and cc.from_revision_no <= dr.revision_no
                                                     and (cc.to_revision_no is null or cc.to_revision_no > dr.revision_no)))
        union select o.activity_revision_id from curriculum.requirement_option o join curriculum.requirement rq on rq.id = o.requirement_id
              where rq.revision_id = c.rid and o.activity_revision_id is not null and o.approval_state = 'approved'
      ) x
    )
    select 'rev:' || c.rid as key, 'revision' as kind, c.rid as id, null::uuid as binding_id, null::text as usage, null::text as relation,
           exists (select 1 from authoring.revision_binding b where b.target_revision_id = c.rid and b.relation = 'evaluates_with') as hidden
      from closure c
    union all
    select 'bind:' || b.id, case when b.artifact_id is not null then 'artifact' when b.capture_id is not null then 'capture' when b.locator_id is not null then 'locator'
                                 when b.claim_id is not null then 'claim' when b.record_id is not null then 'record' else 'entity' end,
           coalesce(b.artifact_id, b.capture_id, b.locator_id, b.claim_id, b.record_id, b.entity_id), b.id,
           coalesce((select s.usage from authoring.asset_scope s where s.artifact_id = b.artifact_id and s.revoked_at is null), b.usage), b.relation,
           b.relation = 'evaluates_with' or coalesce(b.role, '') in ('hidden_check','solution')
      from closure c join authoring.revision_binding b on b.revision_id = c.rid
     where b.target_revision_id is null and b.target_work_id is null and b.release_item_id is null and b.file_set_id is null and b.assertion_id is null
    union all
    select 'bind:' || b.id || ':' || e.path, 'artifact', e.artifact_id, b.id,
           coalesce((select s.usage from authoring.asset_scope s where s.artifact_id = e.artifact_id and s.revoked_at is null), b.usage), b.relation,
           b.relation = 'evaluates_with' or coalesce(b.role, '') in ('hidden_check','solution')
      from closure c join authoring.revision_binding b on b.revision_id = c.rid join authoring.file_set_entry e on e.file_set_id = b.file_set_id
  loop
    disp := case
      when r.hidden then 'withheld'
      when r.kind = 'revision' then 'include'
      when r.kind = 'artifact' and product.restricted(null, r.id, array['deny_all','deny_bytes']) then 'withheld'
      when r.kind = 'capture' and product.restricted(r.id, null, array['deny_all','deny_bytes']) then 'withheld'
      when r.kind in ('entity','record','claim') then 'include'
      when ceiling = 'workspace' then case when r.usage = 'reference_only' then 'reference' else 'include' end
      when r.usage = 'redistributable' then 'include'
      when r.usage = 'reference_only' then 'reference'
      else 'BLOCKER' end;
    if disp = 'BLOCKER' then blockers := blockers || jsonb_build_object('item_key', r.key, 'kind', r.kind, 'id', r.id, 'usage', r.usage); end if;
    items := items || jsonb_build_object('item_key', r.key, 'kind', r.kind, 'id', r.id, 'binding_id', r.binding_id, 'disposition', disp);
  end loop;
  return jsonb_build_object('root_revision_id', root_rev, 'ceiling', ceiling, 'items', items, 'blockers', blockers,
    'closure_sha256', product.sha256_text(jsonb_build_object('root', root_rev, 'ceiling', ceiling,
       'items', (select jsonb_agg(e order by e ->> 'item_key') from jsonb_array_elements(items) e))::text));
end $$;

create or replace function product.register_artifact(ws uuid, p uuid, atype text, sha text, size bigint, media text, usage text, rights text,
                                                     retention text default 'durable', ttl interval default null) returns uuid language plpgsql set search_path = '' as $$
declare aid uuid := util.uuidv7();
begin
  insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at)
  values (aid, product.tenant(), atype, 1, sha, 'workspace', 'aieng-workspaces', format('%s/%s/%s/%s', product.tenant(), ws, aid, sha), media, size, 'pending', null);
  insert into authoring.asset_scope(tenant_id, workspace_id, artifact_id, registered_by, rights_basis, usage, retention, expires_at)
  values (product.tenant(), ws, aid, p, rights, usage, retention, case when retention = 'temporary' then now() + coalesce(ttl, interval '7 days') end);
  return aid;
end $$;

create or replace function product.new_event(ws uuid, p uuid, work uuid, rev uuid, kind text, payload jsonb, dedupe text, actor_kind text, surface text, role text)
returns uuid language sql set search_path = '' as $$
  insert into authoring.event(tenant_id, workspace_id, work_id, revision_id, kind, actor_id, actor_kind, client_surface, author_role, payload_schema, payload, dedupe_key)
  values (product.tenant(), ws, work, rev, kind, p, actor_kind, surface, role, 'aieng.review.v1', payload, dedupe) returning id
$$;

-- ================================================================== commands
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
    delete from library.passage_embedding_1536 pe using library.passage pa, authoring.work_revision rv
     where pe.passage_id = pa.id and pa.revision_id = rv.id and rv.work_id = (rm.targets ->> 'work_id')::uuid and rv.purged_at is not null;
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
create or replace function product.finalize(result_id uuid, how text, policy uuid) returns void language plpgsql set search_path = '' as $$
declare r learning.assessment_result; a learning.attempt; q curriculum.requirement;
begin
  select * into r from learning.assessment_result where id = result_id for update;
  update learning.assessment_result set status = 'final', finalized_by = coalesce(finalized_by, how), finalized_at = coalesce(finalized_at, now()) where id = r.id;
  select at.* into a from learning.submission sb join learning.attempt at on at.id = sb.attempt_id where sb.id = r.submission_id;
  if a.purpose <> 'official' then return; end if;
  select rq.* into q from curriculum.requirement_option op join curriculum.requirement rq on rq.id = op.requirement_id where op.id = a.option_id;
  update learning.credit set status = 'superseded', ended_at = now(), status_reason = 'superseded by result ' || r.id
   where adoption_id = a.adoption_id and requirement_id = q.id and status = 'active';
  if r.outcomes ->> q.requirement_key::text = 'met' then
    insert into learning.credit(tenant_id, workspace_id, learner_id, enrollment_id, adoption_id, requirement_id, route, facet, result_id, status)
    values (r.tenant_id, r.workspace_id, a.learner_id, a.enrollment_id, a.adoption_id, q.id,
            (select route from curriculum.requirement_option where id = a.option_id), a.conditions ->> 'facet', r.id, 'active');
  end if;
end $$;

-- ================================================================== reads
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
    q := websearch_to_tsquery('english', pl ->> 'query');
    return coalesce((select jsonb_agg(x order by (x ->> 'rank')::real desc) from (
      select jsonb_build_object('label', case when pa.message_id is not null then 'conversation'
                                              when wk.kind = 'document' or pa.artifact_id is not null then 'uploaded_source'
                                              when product.role_in(pa.workspace_id, p) is not null then 'private_note' else 'course_material' end,
                                'passageId', pa.id, 'revisionId', pa.revision_id, 'workKind', wk.kind, 'locator', pa.locator,
                                'snippet', left(pa.text, 240), 'rank', ts_rank(pa.tsv, q)) as x
        from library.passage pa
        left join authoring.work_revision rv on rv.id = pa.revision_id
        left join authoring.work wk on wk.id = rv.work_id
        left join conversation.message m on m.id = pa.message_id
        left join conversation.thread th on th.id = m.thread_id
       where pa.tsv @@ q
         and (   (pa.revision_id is not null and (product.role_in(pa.workspace_id, p) is not null or product.readable_revision(pa.revision_id, p)))
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

create or replace function product.dataset_snapshot(dw uuid, n integer) returns jsonb language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'fields', coalesce((select jsonb_agg(jsonb_build_object('fieldKey', f.field_key, 'name', f.name, 'valueType', f.value_type, 'unit', f.unit,
                 'currency', f.currency, 'meaning', f.meaning, 'required', f.required) order by f.position, f.field_key)
               from dataset.field f where f.dataset_work_id = dw and f.from_revision_no <= n and (f.to_revision_no is null or f.to_revision_no > n)), '[]'),
    'rows', coalesce((select jsonb_agg(jsonb_build_object('rowKey', r.row_key, 'label', r.label, 'entityId', r.entity_id,
                 'cells', coalesce((select jsonb_object_agg(c.field_key::text, jsonb_build_object('cellId', c.id, 'value', c.value, 'status', c.value_status, 'observedAt', c.observed_at))
                                      from dataset.cell c where c.dataset_work_id = dw and c.row_key = r.row_key and c.from_revision_no <= n
                                       and (c.to_revision_no is null or c.to_revision_no > n)), '{}')) order by r.position, r.row_key)
               from dataset.row r where r.dataset_work_id = dw and r.from_revision_no <= n and (r.to_revision_no is null or r.to_revision_no > n)), '[]'))
$$;

-- Content digest of revision n: field definitions, rows and cell values/statuses (not cell ids or edit attribution).
create or replace function product.dataset_content_sha256(dw uuid, n integer) returns text language sql stable set search_path = '' as $$
  select product.sha256_text(jsonb_build_object(
    'f', (select jsonb_agg(f - 'name' || jsonb_build_object('n', f ->> 'name') order by f ->> 'fieldKey') from jsonb_array_elements(s -> 'fields') f),
    'r', (select jsonb_agg(jsonb_build_object('k', r ->> 'rowKey', 'l', r ->> 'label', 'e', r ->> 'entityId',
               'c', (select jsonb_object_agg(c.key, (c.value - 'cellId')) from jsonb_each(r -> 'cells') c)) order by r ->> 'rowKey') from jsonb_array_elements(s -> 'rows') r))::text)
  from (select product.dataset_snapshot(dw, n) s) x
$$;

create or replace function product.dataset_work(ws uuid, dw uuid) returns authoring.work language plpgsql set search_path = '' as $$
declare w authoring.work;
begin
  select * into w from authoring.work where id = dw and workspace_id = ws and kind = 'dataset' for update;
  if w.id is null then perform product.fail('NOT_FOUND', 'dataset'); end if;
  return w;
end $$;

-- Close a version at draft n (inside the same draft this makes it an empty range: kept as history, never visible).
create or replace function product.dataset_close_cell(dw uuid, rk uuid, fk uuid, n integer) returns void language sql set search_path = '' as $$
  update dataset.cell set to_revision_no = n where dataset_work_id = dw and row_key = rk and field_key = fk and from_revision_no is not null and to_revision_no is null
$$;

-- Apply direct draft edits. Returns the number of changed versions.
create or replace function product.dataset_edit(ws uuid, dw uuid, pl jsonb, p uuid, human boolean) returns integer language plpgsql set search_path = '' as $$
declare n integer := product.dataset_draft_no(dw); x jsonb; cur dataset.cell; ch integer := 0; fk uuid; ft text;
begin
  for x in select * from jsonb_array_elements(coalesce(pl -> 'fields_add', '[]')) loop
    insert into dataset.field(tenant_id, workspace_id, dataset_work_id, field_key, name, value_type, unit, currency, meaning, required, position, entered_by, from_revision_no)
    values (product.tenant(), ws, dw, coalesce((x ->> 'field_key')::uuid, util.uuidv7()), x ->> 'name', x ->> 'value_type', x ->> 'unit', x ->> 'currency', x ->> 'meaning',
            coalesce((x ->> 'required')::boolean, false), coalesce((x ->> 'position')::int, 0), p, n);
    ch := ch + 1;
  end loop;
  for x in select * from jsonb_array_elements(coalesce(pl -> 'fields_change', '[]')) loop
    update dataset.field set to_revision_no = n where dataset_work_id = dw and field_key = (x ->> 'field_key')::uuid and to_revision_no is null;
    if not found then perform product.fail('NOT_FOUND', 'field ' || (x ->> 'field_key')); end if;
    insert into dataset.field(tenant_id, workspace_id, dataset_work_id, field_key, name, value_type, unit, currency, meaning, required, position, entered_by, from_revision_no)
    select product.tenant(), ws, dw, f.field_key, coalesce(x ->> 'name', f.name), coalesce(x ->> 'value_type', f.value_type),
           case when x ? 'unit' then x ->> 'unit' else f.unit end, case when x ? 'currency' then x ->> 'currency' else f.currency end,
           coalesce(x ->> 'meaning', f.meaning), coalesce((x ->> 'required')::boolean, f.required), coalesce((x ->> 'position')::int, f.position), p, n
      from dataset.field f where f.dataset_work_id = dw and f.field_key = (x ->> 'field_key')::uuid and f.to_revision_no = n
     order by f.created_at desc limit 1;
    ch := ch + 1;
  end loop;
  for x in select * from jsonb_array_elements(coalesce(pl -> 'fields_remove', '[]')) loop
    update dataset.field set to_revision_no = n where dataset_work_id = dw and field_key = (x #>> '{}')::uuid and to_revision_no is null;
    update dataset.cell set to_revision_no = n where dataset_work_id = dw and field_key = (x #>> '{}')::uuid and from_revision_no is not null and to_revision_no is null;
    ch := ch + 1;
  end loop;
  for x in select * from jsonb_array_elements(coalesce(pl -> 'rows_add', '[]')) loop
    insert into dataset.row(tenant_id, workspace_id, dataset_work_id, row_key, entity_id, label, position, entered_by, from_revision_no)
    values (product.tenant(), ws, dw, coalesce((x ->> 'row_key')::uuid, util.uuidv7()), (x ->> 'entity_id')::uuid, x ->> 'label', coalesce((x ->> 'position')::int, 0), p, n);
    ch := ch + 1;
  end loop;
  for x in select * from jsonb_array_elements(coalesce(pl -> 'rows_remove', '[]')) loop
    update dataset.row set to_revision_no = n where dataset_work_id = dw and row_key = (x #>> '{}')::uuid and from_revision_no is not null and to_revision_no is null;
    if not found then perform product.fail('NOT_FOUND', 'row ' || (x #>> '{}')); end if;
    update dataset.cell set to_revision_no = n where dataset_work_id = dw and row_key = (x #>> '{}')::uuid and from_revision_no is not null and to_revision_no is null;
    ch := ch + 1;
  end loop;
  for x in select * from jsonb_array_elements(coalesce(pl -> 'cells', '[]')) loop
    if not exists (select 1 from dataset.row r where r.dataset_work_id = dw and r.row_key = (x ->> 'row_key')::uuid and r.from_revision_no is not null and r.to_revision_no is null) then
      perform product.fail('NOT_FOUND', 'row ' || (x ->> 'row_key'));
    end if;
    select f.value_type into ft from dataset.field f where f.dataset_work_id = dw and f.field_key = (x ->> 'field_key')::uuid and f.to_revision_no is null;
    if ft is null then perform product.fail('NOT_FOUND', 'field ' || (x ->> 'field_key')); end if;
    perform product.check_cell_value(ft, x);
    select * into cur from dataset.cell c where c.dataset_work_id = dw and c.row_key = (x ->> 'row_key')::uuid and c.field_key = (x ->> 'field_key')::uuid
       and c.from_revision_no is not null and c.to_revision_no is null;
    if cur.id is not null and cur.value is not distinct from (nullif(x -> 'value', 'null'::jsonb)) and cur.value_status = (x ->> 'value_status')
       and cur.observed_at is not distinct from (x ->> 'observed_at')::timestamptz then
      continue;   -- unchanged: no new version
    end if;
    perform product.dataset_close_cell(dw, (x ->> 'row_key')::uuid, (x ->> 'field_key')::uuid, n);
    insert into dataset.cell(tenant_id, workspace_id, dataset_work_id, row_key, field_key, value, value_status, observed_at, entered_by, entered_kind, entered_origin_ref, from_revision_no)
    values (product.tenant(), ws, dw, (x ->> 'row_key')::uuid, (x ->> 'field_key')::uuid, nullif(x -> 'value', 'null'::jsonb), x ->> 'value_status', (x ->> 'observed_at')::timestamptz,
            p, case when human then 'human' else 'agent' end, coalesce(pl -> 'origin_ref', '{}'), n);
    ch := ch + 1;
  end loop;
  return ch;
end $$;

-- Values must match the field type when present (statuses without a value carry none).
create or replace function product.check_cell_value(ft text, x jsonb) returns void language plpgsql set search_path = '' as $$
declare v jsonb := nullif(x -> 'value', 'null'::jsonb); t text := jsonb_typeof(nullif(x -> 'value', 'null'::jsonb));
begin
  if v is null or t = 'null' then return; end if;
  if (ft in ('number','integer','percent') and t <> 'number') or (ft = 'integer' and (v #>> '{}')::numeric <> trunc((v #>> '{}')::numeric))
     or (ft = 'boolean' and t <> 'boolean') or (ft in ('text','url','date','datetime','entity') and t <> 'string')
     or (ft = 'money' and (t <> 'object' or jsonb_typeof(v -> 'amount') <> 'number'))
     or (ft = 'url' and (v #>> '{}') !~ '^https?://') or (ft = 'date' and (v #>> '{}') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') then
    perform product.fail('VALIDATION', format('value %s does not match field type %s', v, ft));
  end if;
end $$;

-- Freeze draft n as revision n of the dataset work.
create or replace function product.dataset_commit(ws uuid, w authoring.work, p uuid, title text, note text, origin text) returns uuid language plpgsql set search_path = '' as $$
declare n integer := product.dataset_draft_no(w.id); rid uuid; s jsonb; head_title text;
begin
  if not exists (select 1 from dataset.field where dataset_work_id = w.id and (from_revision_no = n or to_revision_no = n))
     and not exists (select 1 from dataset.row where dataset_work_id = w.id and (from_revision_no = n or to_revision_no = n))
     and not exists (select 1 from dataset.cell where dataset_work_id = w.id and (from_revision_no = n or to_revision_no = n)) then
    perform product.fail('NO_CHANGES', 'the dataset draft has no changes to commit');
  end if;
  s := product.dataset_snapshot(w.id, n);
  select r.title into head_title from authoring.work_revision r where r.id = w.head_revision_id;
  rid := product.insert_revision(ws, w, p, w.head_revision_id, jsonb_build_object(
    'title', coalesce(title, head_title), 'origin', origin,
    'body', jsonb_build_object('formatVersion', '2', 'blocks', '[]'::jsonb, 'metadata', jsonb_build_object('dataset', jsonb_build_object(
       'schema', 'aieng.dataset-revision.v1', 'revisionNo', n, 'note', note,
       'fieldOrder', (select coalesce(jsonb_agg(f -> 'fieldKey'), '[]') from jsonb_array_elements(s -> 'fields') f),
       'counts', jsonb_build_object('fields', jsonb_array_length(s -> 'fields'), 'rows', jsonb_array_length(s -> 'rows'),
                                    'cells', (select count(*) from jsonb_array_elements(s -> 'rows') r, jsonb_each(r -> 'cells'))),
       'cellsSha256', product.dataset_content_sha256(w.id, n))))));
  update authoring.work set head_revision_id = rid where id = w.id;
  return rid;
end $$;

-- Research brief metadata (body.metadata.research, aieng.research-brief.v1) as a proposal: returns problems, empty when valid.
create or replace function product.proposal_problems(m jsonb) returns jsonb language plpgsql stable set search_path = '' as $$
declare probs jsonb := '[]'; o jsonb; keys text[] := '{}';
begin
  if m is null or m ->> 'schema' is distinct from 'aieng.research-brief.v1' then return '["metadata.research must be aieng.research-brief.v1"]'; end if;
  if not product.nonblank(m ->> 'question') then probs := probs || '"question is required"'; end if;
  if jsonb_typeof(m -> 'plan') is distinct from 'array' or jsonb_array_length(m -> 'plan') = 0 then probs := probs || '"plan needs at least one step"'; end if;
  if jsonb_typeof(m -> 'budget_limit_usd') is distinct from 'number' or (m ->> 'budget_limit_usd')::numeric < 0 then probs := probs || '"budget_limit_usd must be a non-negative number"'; end if;
  if coalesce(m ->> 'knowledge_policy', 'latest_at_run') not in ('sealed','latest_at_run') then probs := probs || '"knowledge_policy must be sealed or latest_at_run"'; end if;
  if jsonb_typeof(m -> 'obligations') is distinct from 'array' or jsonb_array_length(m -> 'obligations') = 0 then
    probs := probs || '"at least one output obligation is required"';
  else
    for o in select * from jsonb_array_elements(m -> 'obligations') loop
      if coalesce(o ->> 'key', '') !~ '^[a-z0-9][a-z0-9._:-]{0,99}$' then probs := probs || to_jsonb(format('obligation key %s is invalid', o ->> 'key')); end if;
      if (o ->> 'key') = any(keys) then probs := probs || to_jsonb(format('duplicate obligation key %s', o ->> 'key')); end if;
      keys := keys || (o ->> 'key');
      if coalesce(o ->> 'form', '') not in ('dataset','report','experience','finding_set','file','course_content') then probs := probs || to_jsonb(format('obligation %s form is invalid', o ->> 'key')); end if;
      if coalesce(o ->> 'enforcement', 'required') not in ('required','expected','optional') then probs := probs || to_jsonb(format('obligation %s enforcement is invalid', o ->> 'key')); end if;
    end loop;
  end if;
  if m ? 'world' and not (coalesce(m -> 'world' ->> 'precision', '') in ('day','instant') and (m -> 'world' ->> 'from') is not null and (m -> 'world' ->> 'to') is not null) then
    probs := probs || '"world needs precision day|instant with from and to"';
  end if;
  return probs;
end $$;

create or replace function product.dispatch_research_command(ws uuid, op text, head uuid, pl jsonb, p uuid, g access.client_grant, human boolean, surface text)
returns jsonb language plpgsql set search_path = '' as $$
declare
  t uuid := product.tenant(); w authoring.work; rid uuid; ev uuid; m jsonb; probs jsonb; acc inquiry.acceptance; prev inquiry.acceptance; ob inquiry.obligation;
  dl inquiry.delivery; pr dataset.proposal; n integer; x jsonb; changes jsonb; cnt integer; summary jsonb; rk uuid; fk uuid; cur dataset.cell; ekind text; tkind text; tid uuid; aid uuid;
  subj_ws uuid;
begin
  case op
  -- ---------------------------------------------------------------- requests and missions
  when 'propose_research' then
    perform product.require_role(ws, p, array['owner','editor']);
    select r.body -> 'metadata' -> 'research', r.work_id into m, rid from authoring.work_revision r join authoring.work wk on wk.id = r.work_id
     where r.id = (pl ->> 'revision_id')::uuid and r.workspace_id = ws and wk.kind = 'brief';
    if rid is null then perform product.fail('NOT_FOUND', 'brief revision'); end if;
    probs := product.proposal_problems(m);
    if jsonb_array_length(probs) > 0 then return jsonb_build_object('valid', false, 'problems', probs); end if;
    select id into ev from authoring.event where workspace_id = ws and dedupe_key = 'proposal:' || (pl ->> 'revision_id');
    if ev is null then
      ev := product.new_event(ws, p, rid, (pl ->> 'revision_id')::uuid, 'proposal_submitted', jsonb_build_object('obligations', jsonb_array_length(m -> 'obligations')),
                              'proposal:' || (pl ->> 'revision_id'), case when human then 'human' else 'agent' end, surface, 'maintainer');
    end if;
    return jsonb_build_object('valid', true, 'problems', '[]'::jsonb, 'eventId', ev);

  when 'accept_research' then
    perform product.require_role(ws, p, array['owner','editor']);
    if not human then perform product.fail('FORBIDDEN', 'a person accepts research scope and budget; agents may only propose'); end if;
    select r.body -> 'metadata' -> 'research', r.work_id into m, rid from authoring.work_revision r
     where r.id = (pl ->> 'revision_id')::uuid and r.workspace_id = ws;
    if rid is null or not exists (select 1 from authoring.event e where e.workspace_id = ws and e.kind = 'proposal_submitted' and e.revision_id = (pl ->> 'revision_id')::uuid) then
      perform product.fail('NOT_FOUND', 'submitted proposal');
    end if;
    if pl ? 'revises_acceptance_id' then
      select * into prev from inquiry.acceptance where id = (pl ->> 'revises_acceptance_id')::uuid and workspace_id = ws and brief_work_id = rid for update;
      if prev.id is null then perform product.fail('NOT_FOUND', 'acceptance to revise'); end if;
      if prev.state in ('closed','cancelled','superseded','failed') then perform product.fail('CONFLICT', format('acceptance is %s', prev.state)); end if;
      update inquiry.acceptance set state = 'superseded', state_changed_at = now() where id = prev.id;
    end if;
    ev := product.new_event(ws, p, rid, (pl ->> 'revision_id')::uuid, 'accepted', jsonb_build_object('budgetLimitUsd', coalesce(pl -> 'budget_limit_usd', m -> 'budget_limit_usd')),
                            'accept:' || util.uuidv7(), 'human', surface, 'maintainer');
    insert into inquiry.acceptance(tenant_id, workspace_id, brief_work_id, brief_revision_id, acceptance_no, revises_acceptance_id, accepted_by, accepted_event_id,
       budget_limit_usd, budget_policy, world_from, world_to, world_precision, knowledge_policy, execution_origin,
       mc_installation_id, mc_application_id, mc_mission_id, mc_revision_id)
    values (t, ws, rid, (pl ->> 'revision_id')::uuid,
            (select coalesce(max(acceptance_no), 0) + 1 from inquiry.acceptance where workspace_id = ws and brief_work_id = rid),
            prev.id, p, ev, coalesce((pl ->> 'budget_limit_usd')::numeric, (m ->> 'budget_limit_usd')::numeric),
            jsonb_build_object('trigger', coalesce(pl ->> 'trigger', 'manual'), 'review', 'human') || coalesce(pl -> 'budget_policy', '{}'),
            (m -> 'world' ->> 'from')::timestamptz, (m -> 'world' ->> 'to')::timestamptz, coalesce(m -> 'world' ->> 'precision', 'unknown'),
            coalesce(m ->> 'knowledge_policy', 'latest_at_run'), pl ->> 'execution_origin',
            (pl -> 'mc' ->> 'installation_id')::uuid, pl -> 'mc' ->> 'application_id', (pl -> 'mc' ->> 'mission_id')::uuid, (pl -> 'mc' ->> 'revision_id')::uuid)
    returning * into acc;
    insert into inquiry.obligation(tenant_id, workspace_id, acceptance_id, obligation_key, form, enforcement, expected_work_kind, criteria, mc_obligation_key, position)
    select t, ws, acc.id, o ->> 'key', o ->> 'form', coalesce(o ->> 'enforcement', 'required'), o ->> 'expected_work_kind', coalesce(o -> 'criteria', '{}'),
           o ->> 'mc_obligation_key', (ord - 1)::int
      from jsonb_array_elements(m -> 'obligations') with ordinality e(o, ord);
    return jsonb_build_object('acceptanceId', acc.id, 'acceptanceNo', acc.acceptance_no, 'supersededAcceptanceId', prev.id,
      'obligations', (select jsonb_object_agg(obligation_key, id) from inquiry.obligation where acceptance_id = acc.id));

  when 'set_acceptance_state' then
    perform product.require_role(ws, p, array['owner','editor']);
    select * into acc from inquiry.acceptance where id = (pl ->> 'acceptance_id')::uuid and workspace_id = ws for update;
    if acc.id is null then perform product.fail('NOT_FOUND', 'acceptance'); end if;
    if not ((acc.state = 'accepted' and pl ->> 'state' in ('running','failed')) or (acc.state = 'running' and pl ->> 'state' in ('running','delivered','failed'))
            or (acc.state = 'delivered' and pl ->> 'state' in ('running','closed'))) then
      perform product.fail('CONFLICT', format('cannot move acceptance from %s to %s', acc.state, pl ->> 'state'));
    end if;
    if pl ->> 'state' = 'closed' then
      if not human then perform product.fail('FORBIDDEN', 'a person closes accepted research'); end if;
      if exists (select 1 from inquiry.obligation o where o.acceptance_id = acc.id and o.enforcement = 'required'
                  and not exists (select 1 from inquiry.delivery d where d.obligation_id = o.id and d.state = 'accepted')) then
        perform product.fail('CONFLICT', 'required obligations are not fulfilled');
      end if;
    end if;
    if pl ? 'spent_usd' then
      if (pl ->> 'spent_usd')::numeric < acc.spent_usd then perform product.fail('VALIDATION', 'recorded spend cannot decrease'); end if;
      if (pl ->> 'spent_usd')::numeric > acc.budget_limit_usd then perform product.fail('BUDGET_EXCEEDED', format('spend %s over limit %s', pl ->> 'spent_usd', acc.budget_limit_usd)); end if;
    end if;
    if pl ? 'mc_run_id' and acc.execution_origin <> 'mc' then perform product.fail('VALIDATION', 'only MC acceptances carry an MC run'); end if;
    update inquiry.acceptance set state = pl ->> 'state', state_changed_at = now(), spent_usd = coalesce((pl ->> 'spent_usd')::numeric, spent_usd),
           mc_run_id = coalesce((pl ->> 'mc_run_id')::uuid, mc_run_id) where id = acc.id;
    return jsonb_build_object('state', pl ->> 'state');

  when 'withdraw_acceptance' then
    perform product.require_role(ws, p, array['owner','editor']);
    if not human then perform product.fail('FORBIDDEN', 'a person withdraws accepted research'); end if;
    select * into acc from inquiry.acceptance where id = (pl ->> 'acceptance_id')::uuid and workspace_id = ws for update;
    if acc.id is null then perform product.fail('NOT_FOUND', 'acceptance'); end if;
    if acc.state in ('closed','cancelled','superseded','failed') then perform product.fail('CONFLICT', format('acceptance is %s', acc.state)); end if;
    ev := product.new_event(ws, p, acc.brief_work_id, acc.brief_revision_id, 'acceptance_withdrawn', jsonb_build_object('reason', pl ->> 'reason'),
                            'withdraw:' || acc.id, 'human', surface, 'maintainer');
    update inquiry.acceptance set state = 'cancelled', state_changed_at = now() where id = acc.id;
    return jsonb_build_object('state', 'cancelled', 'eventId', ev);

  when 'deliver_output' then
    perform product.require_role(ws, p, array['owner','editor']);
    select * into ob from inquiry.obligation where id = (pl ->> 'obligation_id')::uuid and workspace_id = ws;
    if ob.id is null then perform product.fail('NOT_FOUND', 'obligation'); end if;
    select * into acc from inquiry.acceptance where id = ob.acceptance_id for update;
    if acc.state not in ('accepted','running','delivered') then perform product.fail('CONFLICT', format('acceptance is %s', acc.state)); end if;
    if pl ? 'revision_id' then
      select wk.kind into ekind from authoring.work_revision r join authoring.work wk on wk.id = r.work_id where r.id = (pl ->> 'revision_id')::uuid and r.workspace_id = ws;
      if ekind is null then perform product.fail('NOT_FOUND', 'output revision'); end if;
      if ob.expected_work_kind is not null and ekind <> ob.expected_work_kind then
        perform product.fail('VALIDATION', format('obligation %s expects a %s, got a %s', ob.obligation_key, ob.expected_work_kind, ekind));
      end if;
    elsif pl ? 'artifact_id' and not exists (select 1 from authoring.asset_scope s where s.workspace_id = ws and s.artifact_id = (pl ->> 'artifact_id')::uuid and s.revoked_at is null) then
      perform product.fail('NOT_FOUND', 'artifact not admitted to this workspace');
    elsif pl ? 'file_set_id' and not exists (select 1 from authoring.file_set f where f.id = (pl ->> 'file_set_id')::uuid and f.workspace_id = ws) then
      perform product.fail('NOT_FOUND', 'file set');
    end if;
    ev := product.new_event(ws, p, acc.brief_work_id, null, 'delivered', jsonb_build_object('obligation', ob.obligation_key, 'revisionId', pl ->> 'revision_id'),
                            'deliver:' || util.uuidv7(), case when human then 'human' else 'agent' end, surface, 'maintainer');
    insert into inquiry.delivery(tenant_id, workspace_id, obligation_id, revision_id, artifact_id, file_set_id, mc_output_revision_id,
                                 delivered_by, delivered_kind, origin, delivered_event_id)
    values (t, ws, ob.id, (pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, (pl ->> 'file_set_id')::uuid, (pl ->> 'mc_output_revision_id')::uuid,
            p, case when human then 'human' else 'agent' end, acc.execution_origin, ev)
    returning id into rid;
    if acc.state = 'accepted' then update inquiry.acceptance set state = 'running', state_changed_at = now() where id = acc.id; end if;
    return jsonb_build_object('deliveryId', rid);

  when 'decide_delivery' then
    perform product.require_role(ws, p, array['owner','editor']);
    if not human then perform product.fail('FORBIDDEN', 'a person accepts or rejects delivered outputs; the producing agent cannot accept its own work'); end if;
    select * into dl from inquiry.delivery where id = (pl ->> 'delivery_id')::uuid and workspace_id = ws for update;
    if dl.id is null then perform product.fail('NOT_FOUND', 'delivery'); end if;
    if dl.state <> 'submitted' then perform product.fail('CONFLICT', format('delivery is %s', dl.state)); end if;
    select * into ob from inquiry.obligation where id = dl.obligation_id;
    select * into acc from inquiry.acceptance where id = ob.acceptance_id;
    ev := product.new_event(ws, p, acc.brief_work_id, null, case when pl ->> 'decision' = 'accept' then 'delivery_accepted' else 'delivery_rejected' end,
                            jsonb_build_object('deliveryId', dl.id, 'assessment', coalesce(pl -> 'assessment', '{}')), 'decide:' || dl.id, 'human', surface, 'maintainer');
    update inquiry.delivery set state = case when pl ->> 'decision' = 'accept' then 'accepted' else 'rejected' end, assessment = coalesce(pl -> 'assessment', '{}'),
           decided_by = p, decided_event_id = ev, decided_at = now() where id = dl.id;
    return jsonb_build_object('state', case when pl ->> 'decision' = 'accept' then 'accepted' else 'rejected' end,
      'fulfilled', not exists (select 1 from inquiry.obligation o where o.acceptance_id = acc.id and o.enforcement = 'required'
                                and not exists (select 1 from inquiry.delivery d where d.obligation_id = o.id and d.state = 'accepted')));

  when 'create_watch' then
    perform product.require_role(ws, p, array['owner','editor']);
    if not human then perform product.fail('FORBIDDEN', 'watches are opt-in by a person'); end if;
    if not exists (select 1 from authoring.work where id = (pl ->> 'brief_work_id')::uuid and workspace_id = ws and kind = 'brief') then perform product.fail('NOT_FOUND', 'brief'); end if;
    if exists (select 1 from unnest(array(select (jsonb_array_elements_text(coalesce(pl -> 'target_work_ids', '[]')))::uuid)) tw
                where not exists (select 1 from authoring.work where id = tw and workspace_id = ws and kind = 'dataset')) then
      perform product.fail('NOT_FOUND', 'watch targets must be datasets in this workspace');
    end if;
    insert into inquiry.watch(tenant_id, workspace_id, brief_work_id, subjects, sources, cadence, budget_per_run_usd, budget_total_usd, stop_condition, target_work_ids, created_by)
    values (t, ws, (pl ->> 'brief_work_id')::uuid, pl -> 'subjects', coalesce(pl -> 'sources', '[]'), pl ->> 'cadence', (pl ->> 'budget_per_run_usd')::numeric,
            (pl ->> 'budget_total_usd')::numeric, coalesce(pl -> 'stop_condition', '{}'), array(select (jsonb_array_elements_text(coalesce(pl -> 'target_work_ids', '[]')))::uuid), p)
    returning id into rid;
    return jsonb_build_object('watchId', rid, 'state', 'active');

  when 'set_watch_state' then
    perform product.require_role(ws, p, array['owner','editor']);
    if not human and pl ->> 'state' = 'active' then perform product.fail('FORBIDDEN', 'only a person resumes a watch'); end if;
    update inquiry.watch set state = pl ->> 'state', state_changed_at = now() where id = (pl ->> 'watch_id')::uuid and workspace_id = ws and state <> 'stopped';
    get diagnostics cnt = row_count;
    if cnt = 0 then perform product.fail('NOT_FOUND', 'active or paused watch'); end if;
    return jsonb_build_object('state', pl ->> 'state');

  -- ---------------------------------------------------------------- datasets
  when 'create_dataset' then
    perform product.require_role(ws, p, array['owner','editor']);
    insert into authoring.work(tenant_id, workspace_id, kind, slug, created_by) values (t, ws, 'dataset', pl ->> 'slug', p) returning * into w;
    perform product.dataset_edit(ws, w.id, pl, p, human);
    rid := product.dataset_commit(ws, w, p, pl ->> 'title', pl ->> 'note', coalesce(pl ->> 'origin', case when human then 'human' else 'agent' end));
    return jsonb_build_object('workId', w.id, 'revisionId', rid, 'revisionNo', 1);

  when 'edit_dataset' then
    perform product.require_role(ws, p, array['owner','editor']);
    w := product.dataset_work(ws, (pl ->> 'dataset_work_id')::uuid);
    cnt := product.dataset_edit(ws, w.id, pl, p, human);
    return jsonb_build_object('draftRevisionNo', product.dataset_draft_no(w.id), 'changedVersions', cnt);

  when 'commit_dataset_revision' then
    perform product.require_role(ws, p, array['owner','editor']);
    w := product.dataset_work(ws, (pl ->> 'dataset_work_id')::uuid);
    if head is null or w.head_revision_id is distinct from head then perform product.fail('CONFLICT', 'stale expected head'); end if;
    if exists (select 1 from dataset.proposal pp where pp.dataset_work_id = w.id and pp.state = 'open') then
      update dataset.proposal set state = 'stale' where dataset_work_id = w.id and state = 'open';   -- their base is no longer the head
    end if;
    n := product.dataset_draft_no(w.id);
    rid := product.dataset_commit(ws, w, p, pl ->> 'title', pl ->> 'note', coalesce(pl ->> 'origin', case when human then 'human' else 'agent' end));
    return jsonb_build_object('workId', w.id, 'revisionId', rid, 'revisionNo', n);

  when 'propose_dataset_change' then
    perform product.require_role(ws, p, array['owner','editor']);
    w := product.dataset_work(ws, (pl ->> 'dataset_work_id')::uuid);
    n := product.dataset_draft_no(w.id) - 1;     -- head revision number
    if (pl ->> 'base_revision_no')::int is distinct from n then perform product.fail('CONFLICT', format('proposal base %s is not the head revision %s', pl ->> 'base_revision_no', n)); end if;
    select * into pr from dataset.proposal where dataset_work_id = w.id and dedupe_key = pl ->> 'dedupe_key';
    if pr.id is not null then return jsonb_build_object('proposalId', pr.id, 'state', pr.state, 'duplicate', true, 'unchanged', false); end if;
    -- effective changes against the head revision
    select coalesce(jsonb_agg(c), '[]') into changes from jsonb_array_elements(coalesce(pl -> 'cells', '[]')) c
     where not exists (select 1 from dataset.cell h where h.dataset_work_id = w.id and h.row_key = (c ->> 'row_key')::uuid and h.field_key = (c ->> 'field_key')::uuid
                        and h.from_revision_no <= n and (h.to_revision_no is null or h.to_revision_no > n)
                        and h.value is not distinct from (nullif(c -> 'value', 'null'::jsonb)) and h.value_status = (c ->> 'value_status')
                        and h.observed_at is not distinct from (c ->> 'observed_at')::timestamptz);
    if jsonb_array_length(changes) = 0 and jsonb_array_length(coalesce(pl -> 'rows_add', '[]')) = 0 and jsonb_array_length(coalesce(pl -> 'rows_remove', '[]')) = 0 then
      return jsonb_build_object('proposalId', null, 'unchanged', true, 'duplicate', false);    -- nothing to review, no notice
    end if;
    summary := jsonb_build_object('cellsChanged', jsonb_array_length(changes), 'rowsAdded', jsonb_array_length(coalesce(pl -> 'rows_add', '[]')),
       'rowsRemoved', coalesce(pl -> 'rows_remove', '[]'),
       'byField', coalesce((select jsonb_object_agg(k, cnt2) from (select c ->> 'field_key' k, count(*) cnt2 from jsonb_array_elements(changes) c group by 1) z), '{}'),
       'explanation', pl ->> 'explanation');
    insert into dataset.proposal(tenant_id, workspace_id, dataset_work_id, base_revision_no, reason, acceptance_id, summary, dedupe_key, created_by, created_kind)
    values (t, ws, w.id, n, pl ->> 'reason', (pl ->> 'acceptance_id')::uuid, summary, pl ->> 'dedupe_key', p, case when human then 'human' else 'agent' end)
    returning * into pr;
    insert into dataset.row(tenant_id, workspace_id, dataset_work_id, row_key, entity_id, label, position, entered_by, proposal_id)
    select t, ws, w.id, coalesce((r ->> 'row_key')::uuid, util.uuidv7()), (r ->> 'entity_id')::uuid, r ->> 'label', coalesce((r ->> 'position')::int, 0), p, pr.id
      from jsonb_array_elements(coalesce(pl -> 'rows_add', '[]')) r;
    for x in select * from jsonb_array_elements(changes) loop
      if not exists (select 1 from dataset.field f where f.dataset_work_id = w.id and f.field_key = (x ->> 'field_key')::uuid and f.to_revision_no is null) then
        perform product.fail('NOT_FOUND', 'field ' || (x ->> 'field_key'));
      end if;
      perform product.check_cell_value((select f.value_type from dataset.field f where f.dataset_work_id = w.id and f.field_key = (x ->> 'field_key')::uuid and f.to_revision_no is null), x);
      insert into dataset.cell(tenant_id, workspace_id, dataset_work_id, row_key, field_key, value, value_status, observed_at, entered_by, entered_kind, entered_origin_ref, proposal_id)
      values (t, ws, w.id, (x ->> 'row_key')::uuid, (x ->> 'field_key')::uuid, nullif(x -> 'value', 'null'::jsonb), x ->> 'value_status', (x ->> 'observed_at')::timestamptz,
              p, case when human then 'human' else 'agent' end, coalesce(pl -> 'origin_ref', '{}'), pr.id);
    end loop;
    ev := product.new_event(ws, p, w.id, w.head_revision_id, 'change_proposed', jsonb_build_object('proposalId', pr.id, 'summary', summary),
                            'change:' || pr.id, case when human then 'human' else 'agent' end, surface, 'maintainer');
    return jsonb_build_object('proposalId', pr.id, 'state', 'open', 'duplicate', false, 'unchanged', false, 'summary', summary,
      'stagedCells', (select coalesce(jsonb_agg(jsonb_build_object('cellId', c.id, 'rowKey', c.row_key, 'fieldKey', c.field_key)), '[]') from dataset.cell c where c.proposal_id = pr.id));

  when 'decide_dataset_change' then
    perform product.require_role(ws, p, array['owner','editor']);
    if not human then perform product.fail('FORBIDDEN', 'a person reviews dataset changes'); end if;
    select * into pr from dataset.proposal where id = (pl ->> 'proposal_id')::uuid and workspace_id = ws for update;
    if pr.id is null then perform product.fail('NOT_FOUND', 'proposal'); end if;
    if pr.state <> 'open' then perform product.fail('CONFLICT', format('proposal is %s', pr.state)); end if;
    w := product.dataset_work(ws, pr.dataset_work_id);
    n := product.dataset_draft_no(w.id);
    if pr.base_revision_no <> n - 1 then
      update dataset.proposal set state = 'stale' where id = pr.id;
      return jsonb_build_object('state', 'stale');
    end if;
    if pl ->> 'decision' <> 'apply' then
      update dataset.proposal set state = 'rejected', decided_by = p, decided_at = now() where id = pr.id;
      ev := product.new_event(ws, p, w.id, w.head_revision_id, 'change_rejected', jsonb_build_object('proposalId', pr.id, 'reason', pl ->> 'reason'), 'change-decided:' || pr.id, 'human', surface, 'maintainer');
      return jsonb_build_object('state', 'rejected');
    end if;
    if exists (select 1 from dataset.cell where dataset_work_id = w.id and (from_revision_no = n or to_revision_no = n))
       or exists (select 1 from dataset.row where dataset_work_id = w.id and (from_revision_no = n or to_revision_no = n)) then
      perform product.fail('CONFLICT', 'the dataset draft has uncommitted edits; commit or discard them before applying a proposal');
    end if;
    update dataset.row set from_revision_no = n where proposal_id = pr.id;
    for x in select to_jsonb(r) from jsonb_array_elements_text(pr.summary -> 'rowsRemoved') r loop
      update dataset.row set to_revision_no = n where dataset_work_id = w.id and row_key = (x #>> '{}')::uuid and from_revision_no is not null and to_revision_no is null;
      update dataset.cell set to_revision_no = n where dataset_work_id = w.id and row_key = (x #>> '{}')::uuid and from_revision_no is not null and to_revision_no is null;
    end loop;
    for cur in select * from dataset.cell where proposal_id = pr.id loop
      perform product.dataset_close_cell(w.id, cur.row_key, cur.field_key, n);
      update dataset.cell set from_revision_no = n where id = cur.id;
    end loop;
    rid := product.dataset_commit(ws, w, p, null, coalesce(pl ->> 'note', 'applied proposal ' || pr.id), 'human');
    update dataset.proposal set state = 'applied', decided_by = p, decided_at = now(), applied_revision_id = rid where id = pr.id;
    ev := product.new_event(ws, p, w.id, rid, 'change_applied', jsonb_build_object('proposalId', pr.id, 'summary', pr.summary), 'change-decided:' || pr.id, 'human', surface, 'maintainer');
    return jsonb_build_object('state', 'applied', 'revisionId', rid, 'revisionNo', n);

  -- ---------------------------------------------------------------- support
  when 'add_support' then
    perform product.require_role(ws, p, array['owner','editor']);
    if pl -> 'subject' ? 'assertion_id' then
      if not exists (select 1 from inquiry.assertion a where a.id = (pl -> 'subject' ->> 'assertion_id')::uuid and a.workspace_id = ws) then perform product.fail('NOT_FOUND', 'assertion'); end if;
    else
      perform product.dataset_work(ws, (pl -> 'subject' ->> 'dataset_work_id')::uuid);
      if pl -> 'subject' ? 'cell_id' and not exists (select 1 from dataset.cell c where c.id = (pl -> 'subject' ->> 'cell_id')::uuid
            and c.dataset_work_id = (pl -> 'subject' ->> 'dataset_work_id')::uuid and c.row_key = (pl -> 'subject' ->> 'row_key')::uuid and c.field_key = (pl -> 'subject' ->> 'field_key')::uuid) then
        perform product.fail('NOT_FOUND', 'cell');
      end if;
    end if;
    tkind := pl -> 'target' ->> 'kind'; tid := (pl -> 'target' ->> 'id')::uuid;
    if tkind = 'source_revision' and not exists (select 1 from authoring.work_revision r join authoring.work wk on wk.id = r.work_id
          where r.id = tid and r.workspace_id = ws and wk.kind = 'document' and r.purged_at is null) then
      perform product.fail('NOT_FOUND', 'source document revision in this workspace');
    end if;
    if tkind = 'decision' and not exists (select 1 from authoring.work_revision r join authoring.work wk on wk.id = r.work_id
          where r.id = tid and r.workspace_id = ws and wk.kind = 'decision_attempt' and r.body -> 'metadata' -> 'answers' ? (pl -> 'target' ->> 'answer_key')) then
      perform product.fail('NOT_FOUND', 'decision attempt answer');
    end if;
    if pl ->> 'role' = 'calculated_from' and exists (select 1 from jsonb_array_elements_text(coalesce(pl -> 'method' -> 'inputs', '[]')) i
          where not exists (select 1 from dataset.cell c where c.id = i::uuid and c.workspace_id = ws)) then
      perform product.fail('NOT_FOUND', 'calculation input cell');
    end if;
    insert into inquiry.support(tenant_id, workspace_id, assertion_id, dataset_work_id, row_key, field_key, cell_id, role,
       source_revision_id, locator_id, capture_id, claim_id, record_id, target_assertion_id, target_cell_id, decision_revision_id, answer_key,
       selector, excerpt, method, assessed_by, assessed_kind, verification_ref)
    values (t, ws, (pl -> 'subject' ->> 'assertion_id')::uuid, (pl -> 'subject' ->> 'dataset_work_id')::uuid, (pl -> 'subject' ->> 'row_key')::uuid,
            (pl -> 'subject' ->> 'field_key')::uuid, (pl -> 'subject' ->> 'cell_id')::uuid, pl ->> 'role',
            case when tkind = 'source_revision' then tid end, case when tkind = 'locator' then tid end, case when tkind = 'capture' then tid end,
            case when tkind = 'claim' then tid end, case when tkind = 'record' then tid end, case when tkind = 'assertion' then tid end,
            case when tkind = 'cell' then tid end, case when tkind = 'decision' then tid end, pl -> 'target' ->> 'answer_key',
            pl -> 'selector', pl ->> 'excerpt', pl -> 'method', p,
            case when pl ? 'verification_ref' then 'verification' when human then 'human' else 'agent' end, pl ->> 'verification_ref')
    returning id into rid;
    return jsonb_build_object('supportId', rid);

  else
    perform product.fail('UNKNOWN_OPERATION', op);
  end case;
  return null;
end $$;

-- Support summary for one statement or cell: counts per role.
create or replace function product.support_counts(aid uuid, cid uuid) returns jsonb language sql stable set search_path = '' as $$
  select coalesce(jsonb_object_agg(role, n), '{}') from (select s.role, count(*) n from inquiry.support s
    where (aid is not null and s.assertion_id = aid) or (cid is not null and s.cell_id = cid) group by s.role) z
$$;

create or replace function product.support_detail(s inquiry.support, p uuid) returns jsonb language plpgsql stable set search_path = '' as $$
declare r authoring.work_revision; d jsonb;
begin
  if s.source_revision_id is not null then
    select * into r from authoring.work_revision where id = s.source_revision_id;
    if not product.readable_revision(r.id, p) then
      d := jsonb_build_object('kind', 'source_revision', 'withheld', true);
    else
      d := jsonb_build_object('kind', 'source_revision', 'revisionId', r.id, 'title', r.title, 'source', r.body -> 'metadata' -> 'source',
             'artifacts', (select coalesce(jsonb_agg(jsonb_build_object('artifactId', a.id, 'sha256', a.sha256, 'mediaType', a.media_type, 'role', b.role, 'usage', b.usage)), '[]')
                             from authoring.revision_binding b join orchestration.artifact a on a.id = b.artifact_id where b.revision_id = r.id and b.relation = 'representation'));
    end if;
  elsif s.target_cell_id is not null then
    d := (select jsonb_build_object('kind', 'cell', 'cellId', c.id, 'datasetWorkId', c.dataset_work_id, 'rowKey', c.row_key, 'fieldKey', c.field_key,
                 'value', c.value, 'status', c.value_status, 'fromRevisionNo', c.from_revision_no) from dataset.cell c where c.id = s.target_cell_id);
  elsif s.decision_revision_id is not null then
    d := (select jsonb_build_object('kind', 'decision', 'revisionId', r2.id, 'answerKey', s.answer_key, 'answer', r2.body -> 'metadata' -> 'answers' -> s.answer_key,
                 'definition', r2.body -> 'metadata' -> 'definition') from authoring.work_revision r2 where r2.id = s.decision_revision_id);
  elsif s.claim_id is not null then
    d := (select jsonb_build_object('kind', 'claim', 'claimId', c.id, 'statement', c.statement, 'status', c.status) from evidence.claim c where c.id = s.claim_id);
  elsif s.target_assertion_id is not null then
    d := (select jsonb_build_object('kind', 'assertion', 'assertionId', a.id, 'statement', a.statement, 'revisionId', a.revision_id) from inquiry.assertion a where a.id = s.target_assertion_id);
  elsif s.locator_id is not null then d := jsonb_build_object('kind', 'locator', 'locatorId', s.locator_id);
  elsif s.capture_id is not null then d := jsonb_build_object('kind', 'capture', 'captureId', s.capture_id);
  elsif s.record_id is not null then d := jsonb_build_object('kind', 'record', 'recordId', s.record_id);
  else d := jsonb_build_object('kind', 'method_only');
  end if;
  return jsonb_build_object('supportId', s.id, 'role', s.role, 'selector', s.selector, 'excerpt', s.excerpt, 'method', s.method,
    'assessedKind', s.assessed_kind, 'assessedAt', s.assessed_at, 'verificationRef', s.verification_ref, 'target', d);
end $$;

create or replace function product.dispatch_research_read(ws uuid, op text, pl jsonb, p uuid) returns jsonb language plpgsql stable set search_path = '' as $$
declare acc inquiry.acceptance; w authoring.work; n integer; a inquiry.assertion; res jsonb; srcs uuid[]; cells uuid[]; revs uuid[]; dsrevs uuid[];
  lim int := least(coalesce((pl ->> 'limit')::int, 200), 1000); off int := greatest(coalesce((pl ->> 'offset')::int, 0), 0);
begin
  case op
  when 'get_acceptance' then
    perform product.require_role(ws, p, array['owner','editor','reader']);
    select * into acc from inquiry.acceptance where id = (pl ->> 'acceptance_id')::uuid and workspace_id = ws;
    if acc.id is null then perform product.fail('NOT_FOUND', 'acceptance'); end if;
    return jsonb_build_object('acceptanceId', acc.id, 'acceptanceNo', acc.acceptance_no, 'briefRevisionId', acc.brief_revision_id, 'state', acc.state,
      'revisesAcceptanceId', acc.revises_acceptance_id, 'budgetLimitUsd', acc.budget_limit_usd, 'spentUsd', acc.spent_usd, 'budgetPolicy', acc.budget_policy,
      'world', jsonb_build_object('from', acc.world_from, 'to', acc.world_to, 'precision', acc.world_precision), 'knowledgePolicy', acc.knowledge_policy,
      'executionOrigin', acc.execution_origin,
      'missionControl', case when acc.execution_origin = 'mc' then jsonb_build_object('installationId', acc.mc_installation_id, 'applicationId', acc.mc_application_id,
                          'missionId', acc.mc_mission_id, 'revisionId', acc.mc_revision_id, 'runId', acc.mc_run_id) end,
      'obligations', (select coalesce(jsonb_agg(jsonb_build_object('obligationId', o.id, 'key', o.obligation_key, 'form', o.form, 'enforcement', o.enforcement,
           'expectedWorkKind', o.expected_work_kind, 'criteria', o.criteria, 'mcObligationKey', o.mc_obligation_key,
           'fulfilled', exists (select 1 from inquiry.delivery d where d.obligation_id = o.id and d.state = 'accepted'),
           'deliveries', (select coalesce(jsonb_agg(jsonb_build_object('deliveryId', d.id, 'revisionId', d.revision_id, 'artifactId', d.artifact_id, 'fileSetId', d.file_set_id,
                 'state', d.state, 'deliveredKind', d.delivered_kind, 'origin', d.origin, 'assessment', d.assessment) order by d.created_at), '[]')
                 from inquiry.delivery d where d.obligation_id = o.id)) order by o.position), '[]') from inquiry.obligation o where o.acceptance_id = acc.id),
      'fulfilled', not exists (select 1 from inquiry.obligation o where o.acceptance_id = acc.id and o.enforcement = 'required'
                                and not exists (select 1 from inquiry.delivery d where d.obligation_id = o.id and d.state = 'accepted')));

  when 'get_dataset' then
    select * into w from authoring.work where id = (pl ->> 'dataset_work_id')::uuid and kind = 'dataset';
    if w.id is null then perform product.fail('NOT_FOUND', 'dataset'); end if;
    if coalesce((pl ->> 'draft')::boolean, false) then
      perform product.require_role(w.workspace_id, p, array['owner','editor','reader']);
      n := product.dataset_draft_no(w.id);
    else
      n := coalesce((pl ->> 'revision_no')::int, product.dataset_draft_no(w.id) - 1);
      if not product.readable_revision((select r.id from authoring.work_revision r where r.work_id = w.id and r.revision_no = n), p) then
        perform product.fail('NOT_FOUND', 'dataset revision');
      end if;
    end if;
    res := product.dataset_snapshot(w.id, n);
    return jsonb_build_object('datasetWorkId', w.id, 'revisionNo', n, 'draft', coalesce((pl ->> 'draft')::boolean, false),
      'revisionId', (select r.id from authoring.work_revision r where r.work_id = w.id and r.revision_no = n),
      'cellsSha256', product.dataset_content_sha256(w.id, n), 'fields', res -> 'fields',
      'rowCount', jsonb_array_length(res -> 'rows'),
      'rows', (select coalesce(jsonb_agg(r || jsonb_build_object('cells', (select coalesce(jsonb_object_agg(c.key, c.value || jsonb_build_object('support',
                   product.support_counts(null, (c.value ->> 'cellId')::uuid))), '{}') from jsonb_each(r -> 'cells') c)) order by ord), '[]')
               from jsonb_array_elements(res -> 'rows') with ordinality e(r, ord) where ord > off and ord <= off + lim),
      'rowSupport', (select coalesce(jsonb_agg(jsonb_build_object('rowKey', s.row_key, 'fieldKey', s.field_key, 'role', s.role, 'supportId', s.id)), '[]')
                       from inquiry.support s where s.dataset_work_id = w.id and s.cell_id is null));

  when 'get_dataset_diff' then
    if pl ? 'proposal_id' then
      perform product.require_role(ws, p, array['owner','editor','reader']);
      return (select jsonb_build_object('proposalId', pr.id, 'state', pr.state, 'baseRevisionNo', pr.base_revision_no, 'reason', pr.reason, 'summary', pr.summary,
        'changes', (select coalesce(jsonb_agg(jsonb_build_object('rowKey', c.row_key, 'fieldKey', c.field_key, 'cellId', c.id,
              'from', (select jsonb_build_object('value', h.value, 'status', h.value_status) from dataset.cell h where h.dataset_work_id = c.dataset_work_id and h.row_key = c.row_key
                         and h.field_key = c.field_key and h.from_revision_no <= pr.base_revision_no and (h.to_revision_no is null or h.to_revision_no > pr.base_revision_no)),
              'to', jsonb_build_object('value', c.value, 'status', c.value_status), 'support', product.support_counts(null, c.id))), '[]')
            from dataset.cell c where c.proposal_id = pr.id),
        'addedRows', (select coalesce(jsonb_agg(jsonb_build_object('rowKey', r.row_key, 'label', r.label)), '[]') from dataset.row r where r.proposal_id = pr.id))
        from dataset.proposal pr where pr.id = (pl ->> 'proposal_id')::uuid and pr.workspace_id = ws);
    end if;
    select * into w from authoring.work where id = (pl ->> 'dataset_work_id')::uuid and kind = 'dataset';
    if w.id is null or not product.readable_revision((select r.id from authoring.work_revision r where r.work_id = w.id and r.revision_no = (pl ->> 'to_revision_no')::int), p)
       or not product.readable_revision((select r.id from authoring.work_revision r where r.work_id = w.id and r.revision_no = (pl ->> 'from_revision_no')::int), p) then
      perform product.fail('NOT_FOUND', 'dataset revisions');
    end if;
    return jsonb_build_object('datasetWorkId', w.id, 'fromRevisionNo', (pl ->> 'from_revision_no')::int, 'toRevisionNo', (pl ->> 'to_revision_no')::int,
      'changes', (with f as (select r ->> 'rowKey' rk, c.key fk, c.value v from jsonb_array_elements(product.dataset_snapshot(w.id, (pl ->> 'from_revision_no')::int) -> 'rows') r, jsonb_each(r -> 'cells') c),
                       t2 as (select r ->> 'rowKey' rk, c.key fk, c.value v from jsonb_array_elements(product.dataset_snapshot(w.id, (pl ->> 'to_revision_no')::int) -> 'rows') r, jsonb_each(r -> 'cells') c)
                  select coalesce(jsonb_agg(jsonb_build_object('rowKey', coalesce(t2.rk, f.rk), 'fieldKey', coalesce(t2.fk, f.fk),
                           'from', f.v - 'cellId', 'to', t2.v - 'cellId')), '[]')
                    from f full join t2 on t2.rk = f.rk and t2.fk = f.fk where (f.v - 'cellId') is distinct from (t2.v - 'cellId')));

  when 'get_support' then
    if pl ? 'assertion_id' then
      select * into a from inquiry.assertion where id = (pl ->> 'assertion_id')::uuid;
      if a.id is null or not product.readable_revision(a.revision_id, p) then perform product.fail('NOT_FOUND', 'assertion'); end if;
      return (select coalesce(jsonb_agg(product.support_detail(s, p) order by s.assessed_at), '[]') from inquiry.support s where s.assertion_id = a.id);
    end if;
    perform product.require_role((select c.workspace_id from dataset.cell c where c.id = (pl ->> 'cell_id')::uuid), p, array['owner','editor','reader']);
    return (select coalesce(jsonb_agg(product.support_detail(s, p) order by s.assessed_at), '[]') from inquiry.support s
             where s.cell_id = (pl ->> 'cell_id')::uuid
                or (s.cell_id is null and s.dataset_work_id = (select c.dataset_work_id from dataset.cell c where c.id = (pl ->> 'cell_id')::uuid)
                    and s.row_key = (select c.row_key from dataset.cell c where c.id = (pl ->> 'cell_id')::uuid)
                    and (s.field_key is null or s.field_key = (select c.field_key from dataset.cell c where c.id = (pl ->> 'cell_id')::uuid))));

  when 'get_report' then
    if not product.readable_revision((pl ->> 'revision_id')::uuid, p) then perform product.fail('NOT_FOUND', 'revision'); end if;
    return (select jsonb_build_object('revisionId', r.id, 'workId', r.work_id, 'revisionNo', r.revision_no, 'title', r.title, 'body', r.body,
      'blocks', (select coalesce(jsonb_agg(jsonb_build_object('key', b.block_key, 'type', b.block_type, 'parent', b.parent_key, 'position', b.position)
                   order by b.parent_key nulls first, b.position), '[]') from authoring.revision_block b where b.revision_id = r.id),
      'assertions', (select coalesce(jsonb_agg(jsonb_build_object('assertionId', a2.id, 'assertionKey', a2.assertion_key, 'blockKey', a2.block_key, 'kind', a2.kind,
                       'statement', a2.statement, 'supportStatus', a2.support_status, 'support', product.support_counts(a2.id, null),
                       'world', jsonb_build_object('from', a2.world_from, 'to', a2.world_to, 'precision', a2.world_precision)) order by a2.created_at), '[]')
                     from inquiry.assertion a2 where a2.revision_id = r.id),
      'datasets', (select coalesce(jsonb_agg(jsonb_build_object('localKey', b.local_key, 'revisionId', dr.id, 'workId', dr.work_id, 'revisionNo', dr.revision_no)), '[]')
                     from authoring.revision_binding b join authoring.work_revision dr on dr.id = b.target_revision_id join authoring.work dw on dw.id = dr.work_id
                    where b.revision_id = r.id and dw.kind = 'dataset'))
      from authoring.work_revision r where r.id = (pl ->> 'revision_id')::uuid);

  when 'trace_assertion' then
    select * into a from inquiry.assertion where id = (pl ->> 'assertion_id')::uuid;
    if a.id is null or not product.readable_revision(a.revision_id, p) then perform product.fail('NOT_FOUND', 'assertion'); end if;
    return jsonb_build_object('assertionId', a.id, 'statement', a.statement, 'supportStatus', a.support_status, 'revisionId', a.revision_id,
      'supports', (select coalesce(jsonb_agg(product.support_detail(s, p) order by s.assessed_at), '[]') from inquiry.support s where s.assertion_id = a.id),
      'unsupported', not exists (select 1 from inquiry.support s where s.assertion_id = a.id and s.role in ('supports','calculated_from','inferred_by')),
      'otherRevisions', (select coalesce(jsonb_agg(jsonb_build_object('revisionId', a3.revision_id, 'assertionId', a3.id) order by a3.created_at), '[]')
                           from inquiry.assertion a3 where a3.assertion_key = a.assertion_key and a3.id <> a.id and a3.workspace_id = a.workspace_id));

  when 'trace_reverse' then
    perform product.require_role(ws, p, array['owner','editor','reader']);
    srcs := array(select x::uuid from jsonb_array_elements_text(coalesce(pl -> 'source_revision_ids', '[]')) x);
    cells := array(select x::uuid from jsonb_array_elements_text(coalesce(pl -> 'cell_ids', '[]')) x);
    -- cells and statements supported by the sources (or claims/captures), then dataset revisions containing those cells
    cells := cells || array(select s.cell_id from inquiry.support s where s.workspace_id = ws and s.cell_id is not null
              and (s.source_revision_id = any(srcs) or s.claim_id = (pl ->> 'claim_id')::uuid or s.capture_id = (pl ->> 'capture_id')::uuid));
    dsrevs := array(select distinct r.id from dataset.cell c join authoring.work_revision r on r.work_id = c.dataset_work_id
                     where c.id = any(cells) and c.from_revision_no <= r.revision_no and (c.to_revision_no is null or c.to_revision_no > r.revision_no))
           || array(select distinct r.id from inquiry.support s join dataset.row rw on rw.dataset_work_id = s.dataset_work_id and rw.row_key = s.row_key
                     join authoring.work_revision r on r.work_id = s.dataset_work_id
                     where s.workspace_id = ws and s.cell_id is null and s.row_key is not null and s.source_revision_id = any(srcs)
                       and rw.from_revision_no <= r.revision_no and (rw.to_revision_no is null or rw.to_revision_no > r.revision_no));
    revs := array(select distinct a4.revision_id from inquiry.support s join inquiry.assertion a4 on a4.id = s.assertion_id where s.workspace_id = ws
              and (s.source_revision_id = any(srcs) or s.claim_id = (pl ->> 'claim_id')::uuid or s.capture_id = (pl ->> 'capture_id')::uuid or s.target_cell_id = any(cells)))
            || array(select distinct b.revision_id from authoring.revision_binding b where b.workspace_id = ws and b.target_revision_id = any(dsrevs || srcs));
    return jsonb_build_object(
      'assertions', (select coalesce(jsonb_agg(distinct jsonb_build_object('assertionId', a5.id, 'revisionId', a5.revision_id, 'statement', a5.statement, 'role', s.role)), '[]')
                       from inquiry.support s join inquiry.assertion a5 on a5.id = s.assertion_id where s.workspace_id = ws
                        and (s.source_revision_id = any(srcs) or s.claim_id = (pl ->> 'claim_id')::uuid or s.capture_id = (pl ->> 'capture_id')::uuid or s.target_cell_id = any(cells))),
      'cells', (select coalesce(jsonb_agg(jsonb_build_object('cellId', c.id, 'datasetWorkId', c.dataset_work_id, 'rowKey', c.row_key, 'fieldKey', c.field_key,
                   'value', c.value, 'fromRevisionNo', c.from_revision_no, 'toRevisionNo', c.to_revision_no)), '[]') from dataset.cell c where c.id = any(cells)),
      'datasetRevisions', (select coalesce(jsonb_agg(jsonb_build_object('revisionId', r.id, 'workId', r.work_id, 'revisionNo', r.revision_no) order by r.revision_no), '[]')
                             from authoring.work_revision r where r.id in (select distinct unnest(dsrevs))),
      'dependentRevisions', (select coalesce(jsonb_agg(distinct jsonb_build_object('revisionId', r.id, 'workId', r.work_id, 'kind', wk.kind, 'revisionNo', r.revision_no)), '[]')
                               from authoring.work_revision r join authoring.work wk on wk.id = r.work_id where r.id = any(revs)),
      'acceptances', (select coalesce(jsonb_agg(distinct jsonb_build_object('acceptanceId', o.acceptance_id, 'obligation', o.obligation_key, 'deliveryId', d.id, 'state', d.state)), '[]')
                        from inquiry.delivery d join inquiry.obligation o on o.id = d.obligation_id where d.revision_id = any(revs || dsrevs)));

  when 'list_watches' then
    perform product.require_role(ws, p, array['owner','editor','reader']);
    return (select coalesce(jsonb_agg(jsonb_build_object('watchId', x.id, 'briefWorkId', x.brief_work_id, 'subjects', x.subjects, 'cadence', x.cadence, 'state', x.state,
              'budgetPerRunUsd', x.budget_per_run_usd, 'budgetTotalUsd', x.budget_total_usd, 'targets', x.target_work_ids,
              'runs', (select count(*) from inquiry.acceptance ac where ac.brief_work_id = x.brief_work_id and ac.budget_policy ->> 'trigger' = 'watch'))
              order by x.created_at), '[]') from inquiry.watch x where x.workspace_id = ws);

  else
    perform product.fail('UNKNOWN_OPERATION', op);
  end case;
  return null;
end $$;

-- ================================================================== worker (service_role only)
create or replace function product.dispatch_worker(op text, pl jsonb) returns jsonb language plpgsql set search_path = '' as $$
declare t uuid := product.tenant(); aid uuid; rid uuid; x jsonb; n int; s learning.submission; pol jsonb; auto boolean; ws uuid; cnt int;
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
    perform pg_catalog.set_config('product.purge', 'on', true);
    delete from library.passage where workspace_id = ws and coalesce(revision_id, artifact_id, message_id) = coalesce((pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, (pl ->> 'message_id')::uuid)
       and procedure_version = pl ->> 'procedure_version';
    perform pg_catalog.set_config('product.purge', 'off', true);
    n := 0;
    for x in select * from jsonb_array_elements(pl -> 'passages') loop
      insert into library.passage(tenant_id, workspace_id, revision_id, artifact_id, message_id, passage_no, locator, text, content_sha256, procedure_version)
      values (t, ws, (pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, (pl ->> 'message_id')::uuid, n,
              x -> 'locator', x ->> 'text', product.sha256_text(x ->> 'text'), pl ->> 'procedure_version');
      n := n + 1;
    end loop;
    insert into library.preparation(tenant_id, workspace_id, revision_id, artifact_id, stage, procedure_version, status, attempt_count, output_ref)
    values (t, ws, (pl ->> 'revision_id')::uuid, (pl ->> 'artifact_id')::uuid, 'index_lexical', pl ->> 'procedure_version', 'succeeded', 1, jsonb_build_object('passages', n))
    on conflict do nothing;
    return jsonb_build_object('passages', n);

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
      insert into library.passage_embedding_1536(tenant_id, workspace_id, passage_id, space_version_id, embedding, embedding_sha256, processor_authorization_id)
      values (t, ws, (x ->> 'passage_id')::uuid, (pl ->> 'space_version_id')::uuid, (x ->> 'embedding')::extensions.halfvec(1536),
              product.sha256_text(x ->> 'embedding'),
              (select a.id from access.processing_authorization a where a.principal_id = (pl ->> 'principal_id')::uuid and a.processor_class = 'embedding'
                and a.processor_key = pl ->> 'processor_key' and a.withdrawn_at is null limit 1));
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

-- Lab findings F-04/F-05: credit and result rows need explicit status transitions.
drop trigger immutable_guard on learning.credit;
create trigger mutable_guard before update or delete on learning.credit for each row execute function product.guard_mutable('status','status_reason','ended_at');
drop trigger mutable_guard on learning.assessment_result;
create trigger mutable_guard before update or delete on learning.assessment_result for each row execute function product.guard_mutable('status','finalized_by','finalized_at');

-- ================================================================== public entrypoints
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
  res := product.dispatch_command(p_workspace_id, p_operation, p_expected_head, coalesce(p_payload, '{}'), p, g);
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
  return product.dispatch_read(p_workspace_id, p_operation, coalesce(p_payload, '{}'), p);
end $$;

create or replace function api.product_worker(p_operation text, p_payload jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
begin
  if coalesce(product.claims() ->> 'role', '') <> 'service_role' then perform product.fail('FORBIDDEN', 'worker credential required'); end if;
  return product.dispatch_worker(p_operation, coalesce(p_payload, '{}'));
end $$;

grant create on schema product, api to product_api_owner;   -- needed only to transfer ownership; revoked below
do $$
declare f regprocedure;
begin
  for f in select p.oid::regprocedure from pg_proc p where p.pronamespace = 'product'::regnamespace loop
    execute format('alter function %s owner to product_api_owner', f);
  end loop;
end $$;
alter function api.product_command(uuid, text, text, uuid, jsonb) owner to product_api_owner;
alter function api.product_read(uuid, text, jsonb) owner to product_api_owner;
alter function api.product_worker(text, jsonb) owner to product_api_owner;
grant usage on schema api to product_api_owner;
revoke create on schema product, api from product_api_owner;
grant execute on function util.uuidv7(), util.default_tenant_id() to product_api_owner;
grant execute on function extensions.gen_random_bytes(integer) to product_api_owner;
grant usage on schema storage to product_api_owner;
grant select on storage.objects to product_api_owner;
grant select on curriculum.part, curriculum.outcome to product_api_owner;
grant select on evidence.claim to product_api_owner;
revoke all on function api.product_command(uuid, text, text, uuid, jsonb), api.product_read(uuid, text, jsonb), api.product_worker(text, jsonb) from public, anon;
grant execute on function api.product_command(uuid, text, text, uuid, jsonb), api.product_read(uuid, text, jsonb) to authenticated;
grant execute on function api.product_worker(text, jsonb) to service_role;
revoke all on all functions in schema product from public, anon, authenticated, service_role;

-- Storage: no direct client access to the private product bucket; only the API owner may read object metadata.
create policy product_api_reads_workspace_objects on storage.objects for select to product_api_owner using (bucket_id = 'aieng-workspaces');

commit;
