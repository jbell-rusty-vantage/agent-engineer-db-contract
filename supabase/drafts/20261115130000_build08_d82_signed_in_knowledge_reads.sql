-- Build 08 D-82 (lab draft): a signed-in PostgREST session reads the deployment's shared knowledge; the scope-taking search is for trusted callers only.
begin;

-- 1. Tenant resolution, one definition point. Unchanged for every session that sets app.tenant_id (pipeline, executor, verifier,
--    the lab scripts) and for every role without it except one: a PostgREST request of role authenticated. PostgREST cannot set
--    app.tenant_id, so the tenant-filtered api readers (verified_claims, claim_candidates, claim_conflicts, entity_card,
--    changes_since, releases_needing_review, probe_revalidation_due, ...) returned nothing to a signed-in user. Such a session now
--    resolves to the single deployment tenant, the same tenant the product path already uses (product.tenant() =
--    util.default_tenant_id()), under the same identity test as product.actor(): the active role is authenticated and the verified
--    JWT carries role authenticated and a subject. anon, service_role and every database role still resolve to NULL (fail closed,
--    20260903010200). authenticated holds SELECT on the api views and EXECUTE on api functions only, so this opens reads; no table
--    is writable by that role and the product write path (api.product_command) never consults this function.
create or replace function util.current_tenant_id() returns uuid
language plpgsql stable parallel safe
set search_path = ''
as $function$
declare v text; parsed uuid; claims jsonb;
begin
 v := current_setting('app.tenant_id', true);
 if v is null or btrim(v) = '' then
  if current_setting('role', true) = 'authenticated' then
   claims := nullif(current_setting('request.jwt.claims', true), '')::jsonb;
   if claims ->> 'role' = 'authenticated' and nullif(btrim(claims ->> 'sub'), '') is not null then
    return util.default_tenant_id();
   end if;
  end if;
  return null;
 end if;
 begin parsed := v::uuid; exception when invalid_text_representation then return null; end;
 if parsed = '00000000-0000-0000-0000-000000000000'::uuid then return null; end if;
 return parsed;
end $function$;
comment on function util.current_tenant_id() is
 'Active tenant: the app.tenant_id setting when set; a malformed or nil value resolves to NULL. Without the setting it resolves to NULL (tenant predicates match no rows), except for a PostgREST session of role authenticated whose verified JWT carries role authenticated and a subject: that session reads the single deployment tenant, util.default_tenant_id() (Build 08 D-82).';

-- 2. api.search_unified takes the private scope from its caller (p_workspace_ids) and serves the ours lens without a scope. That is
--    right for its trusted callers: product.dispatch_read derives the list from the caller's memberships and readable offers and then
--    applies the per-passage readability rules; the pipeline roles and the lab pass what they need. It was also executable by PUBLIC,
--    so any signed-in user, and anon, could pass another workspace's id and read its private passages. API roles lose it; the
--    product path (product_api_owner) and the bounded roles keep their own grants, and the function body is unchanged.
revoke execute on function api.search_unified(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, uuid[], text[], text[], integer, integer, integer, double precision, boolean) from public, anon, authenticated;
do $do$
declare f regprocedure := 'api.search_unified(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, uuid[], text[], text[], integer, integer, integer, double precision, boolean)'::regprocedure;
        note text := ' Trusted callers only (D-82): it takes the private scope from p_workspace_ids, so it is not executable by anon or authenticated; signed-in sessions use api.search_knowledge, and private or released course material is read through api.product_read(''search'').';
begin
 if position('Trusted callers only (D-82)' in coalesce(obj_description(f, 'pg_proc'), '')) = 0 then
  execute format('comment on function %s is %L', f, coalesce(obj_description(f, 'pg_proc'), '') || note);
 end if;
end $do$;

--    The signed-in entry of the same stack: shared lenses only, no workspace parameter.
create or replace function api.search_knowledge(p_query text, p_query_embedding halfvec default null, p_lenses text[] default array['corpus','evidence'], p_tiers smallint[] default null, p_space_slugs text[] default null, p_document_types text[] default null, p_unit_kinds text[] default null, p_entity_ids uuid[] default null, p_as_of timestamp with time zone default null, p_source_roles text[] default null, p_content_kinds text[] default null, p_limit integer default 20, p_candidate_limit integer default 100, p_rrf_k integer default 60, p_evidence_weight double precision default 0.15, p_collapse boolean default true)
 returns table(vector_item_id uuid, lens text, source_tier smallint, content_kind text, document_type_code text, unit_kind text, entity_id uuid, document_id uuid, document_version_id uuid, target_kind text, target_id uuid, workspace_id uuid, snippet text, start_ms integer, end_ms integer, observed_at timestamp with time zone, valid_during tstzrange, space_slug text, fused_score double precision, channel_scores jsonb)
 language plpgsql stable security definer set search_path to ''
as $function$
begin
  if p_lenses is null or cardinality(p_lenses) = 0 or not (p_lenses <@ array['corpus','evidence']::text[]) then
    raise exception 'search_knowledge reads the corpus and evidence lenses only' using errcode = 'invalid_parameter_value';
  end if;
  return query select * from api.search_unified(p_query, p_query_embedding, p_lenses, p_tiers, p_space_slugs, p_document_types, p_unit_kinds, p_entity_ids, p_as_of,
                                                 null::uuid[], p_source_roles, p_content_kinds, p_limit, p_candidate_limit, p_rrf_k, p_evidence_weight, p_collapse);
end $function$;
comment on function api.search_knowledge(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, text[], text[], integer, integer, integer, double precision, boolean) is
 'Search of the shared industry knowledge for a signed-in session (D-82): api.search_unified restricted to the corpus and evidence lenses, with no workspace parameter; any other lens is refused. Private notes and released course material are read through api.product_read(''search''), which derives the scope from the caller''s identity.';
revoke all on function api.search_knowledge(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, text[], text[], integer, integer, integer, double precision, boolean) from public, anon;
grant execute on function api.search_knowledge(text, halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamp with time zone, text[], text[], integer, integer, integer, double precision, boolean) to authenticated, app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, service_role;

-- 3. The per-space-version searches read every item of a space version whatever its lens. For authenticated they could only raise
--    ("valid app.tenant_id context is required"); with the tenant resolved they would read any published space, a private one
--    included. They stay with the roles that set app.tenant_id.
revoke execute on function api.search_knowledge_1536(uuid, halfvec, integer) from authenticated;
revoke execute on function api.hybrid_knowledge_search_1536(uuid, text, halfvec, jsonb, integer, integer, integer, text[], uuid[], text[], text[], timestamp with time zone, bigint, smallint, uuid) from authenticated;
revoke execute on function api.hybrid_knowledge_search_history_1536(uuid, text, halfvec, jsonb, integer, integer, integer, bigint, uuid[], timestamp with time zone, timestamp with time zone, timestamp with time zone, uuid) from authenticated;

commit;
