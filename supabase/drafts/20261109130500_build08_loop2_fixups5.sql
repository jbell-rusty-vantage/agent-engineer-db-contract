-- Build 08 loop 2 draft, fixup 5 (2026-11-10): D-39 a qualified symbol name can appear more than once in one release (typing overloads,
-- property getter/setter pairs), so api.symbol_changes compares one aggregated signature set per name instead of cross-joining duplicates.
begin;
create or replace function api.symbol_changes(p_repository text, p_from_tag text, p_to_tag text) returns table(
  change text, qualified_name text, symbol_kind text, signature_from text, signature_to text, module text, from_node_id uuid, to_node_id uuid)
language sql stable security definer set search_path = '' as $$
  with a as (select qualified_name, min(symbol_kind) symbol_kind, string_agg(distinct coalesce(signature, ''), ' || ' order by coalesce(signature, '')) signature, bool_or(coalesce(deprecated, false)) deprecated, min(module) module, min(node_id::text)::uuid node_id
             from api.api_symbols where repository = p_repository and release_tag = p_from_tag group by qualified_name),
       b as (select qualified_name, min(symbol_kind) symbol_kind, string_agg(distinct coalesce(signature, ''), ' || ' order by coalesce(signature, '')) signature, bool_or(coalesce(deprecated, false)) deprecated, min(module) module, min(node_id::text)::uuid node_id
             from api.api_symbols where repository = p_repository and release_tag = p_to_tag group by qualified_name)
  select case when a.node_id is null then 'added' when b.node_id is null then 'removed' when a.signature <> b.signature then 'signature_changed' when a.deprecated <> b.deprecated then 'deprecation_changed' else 'unchanged' end,
         coalesce(b.qualified_name, a.qualified_name), coalesce(b.symbol_kind, a.symbol_kind), a.signature, b.signature, coalesce(b.module, a.module), a.node_id, b.node_id
  from a full outer join b on a.qualified_name = b.qualified_name
  where a.node_id is null or b.node_id is null or a.signature <> b.signature or a.deprecated <> b.deprecated
  order by 1, 2
$$;
comment on function api.symbol_changes is 'L2: public symbols added, removed, re-signed or (un)deprecated between two releases of a repository; overloaded names are compared as one signature set (D-39).';
grant execute on function api.symbol_changes(text, text, text) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
commit;
