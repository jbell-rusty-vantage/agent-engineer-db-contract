-- Build 08 loop 3 draft, fixup 1 (2026-11-10, in-loop deltas):
-- D-43 a release surface can be parsed again by a newer grammar (deepagents 0.7.1 and 0.7.35 exist from loop 2 with one unit per overload
--      and from loop 3 with one unit per name). Documents are append-only, so api.api_symbols reads only the newest surface document that
--      has units for a (repository, release tag, package); api.symbol_history and api.symbol_changes read through the view.
begin;
create or replace view api.api_symbols as
SELECT n.id AS node_id,
    d.id AS document_id,
    d.attributes ->> 'repository'::text AS repository,
    d.attributes ->> 'release_tag'::text AS release_tag,
    d.attributes ->> 'package'::text AS package,
    n.attributes ->> 'qualified_name'::text AS qualified_name,
    n.attributes ->> 'kind'::text AS symbol_kind,
    n.attributes ->> 'signature'::text AS signature,
    n.attributes ->> 'module'::text AS module,
    (n.attributes ->> 'is_public'::text)::boolean AS is_public,
    (n.attributes ->> 'deprecated'::text)::boolean AS deprecated,
    n.attributes ->> 'docstring_head'::text AS docstring_head,
    n.attributes ->> 'path'::text AS path,
    (n.attributes ->> 'lineno'::text)::integer AS lineno,
    ( SELECT r_1.entity_id
           FROM content.unit_entity_role r_1
          WHERE r_1.node_id = n.id AND r_1.role = 'release'::text
         LIMIT 1) AS release_id,
    ( SELECT count(*) AS count
           FROM content.unit_link l
          WHERE l.to_node_id = n.id AND l.kind = 'documents'::text) AS docs_links,
    n.attributes -> 'overloads'::text AS overloads,
    n.attributes -> 'uses_external'::text AS uses_external,
    d.attributes ->> 'released_on'::text AS released_on
   FROM content.document d
     JOIN content.document_version v ON v.document_id = d.id
     JOIN content.document_representation r ON r.document_version_id = v.id
     JOIN content.document_node n ON n.representation_id = r.id
  WHERE d.tenant_id = util.current_tenant_id() AND d.document_type_code = 'api_surface'::text AND n.unit_kind = 'api_symbol'::text
    AND NOT (EXISTS ( SELECT 1 FROM content.document d2
          WHERE d2.tenant_id = d.tenant_id AND d2.document_type_code = 'api_surface'::text AND d2.id <> d.id AND d2.created_at > d.created_at
            AND (d2.attributes ->> 'repository'::text) = (d.attributes ->> 'repository'::text) AND (d2.attributes ->> 'release_tag'::text) = (d.attributes ->> 'release_tag'::text)
            AND COALESCE(d2.attributes ->> 'package'::text, ''::text) = COALESCE(d.attributes ->> 'package'::text, ''::text)
            AND (EXISTS ( SELECT 1 FROM content.document_version v2 JOIN content.document_representation r2 ON r2.document_version_id = v2.id JOIN content.document_node n2 ON n2.representation_id = r2.id WHERE v2.document_id = d2.id))));
comment on view api.api_symbols is 'L1: public API symbols per repository release (R3). When a release surface was parsed more than once, only the newest document with units is read.';

create or replace function api.symbol_history(p_repository text, p_package text default null)
returns table(qualified_name text, symbol_kind text, package text, first_tag text, first_released_on text, last_tag text, releases_present integer, releases_total integer, in_latest boolean, latest_node_id uuid)
language sql stable security definer set search_path = '' as $$
  with s as materialized (
    select a.package, a.release_tag as tag, a.released_on, a.node_id, a.qualified_name as qn, a.symbol_kind as kind
      from api.api_symbols a where a.repository = p_repository and (p_package is null or a.package = p_package)
  ), tags as (
    select package, tag, max(released_on) released_on, row_number() over (partition by package order by api.release_order(tag)) as ord, count(*) over (partition by package) as total
      from s group by package, tag
  ), per as (
    select s.package, s.qn, min(s.kind) kind, min(t.ord) first_ord, max(t.ord) last_ord, count(distinct s.tag)::integer present, max(t.total)::integer total
      from s join tags t on t.package = s.package and t.tag = s.tag group by s.package, s.qn
  )
  select p.qn, p.kind, p.package, f.tag, f.released_on, l.tag, p.present, p.total, p.last_ord = p.total,
         (select min(s2.node_id::text)::uuid from s s2 where s2.package = p.package and s2.qn = p.qn and s2.tag = l.tag)
    from per p join tags f on f.package = p.package and f.ord = p.first_ord join tags l on l.package = p.package and l.ord = p.last_ord
   order by p.package, p.qn
$$;
commit;
