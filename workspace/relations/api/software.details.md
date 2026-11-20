---
id: "rel:api.software#details"
kind: details
schema: api
name: software
of: "rel:api.software"
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.software — details

Spill-over from [the main page](software.md).

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## View definition

```sql
SELECT e.id AS software_id,
    e.kind,
    e.display_name AS software,
    e.slug,
    e.attributes ->> 'ecosystem'::text AS ecosystem,
    e.attributes ->> 'package_name'::text AS package_name,
    e.attributes ->> 'category'::text AS category,
    e.attributes ->> 'docs_url'::text AS docs_url,
    COALESCE(e.attributes ->> 'repository_url'::text, ( SELECT (((('https://'::text || (x.attributes ->> 'host'::text)) || '/'::text) || (x.attributes ->> 'owner'::text)) || '/'::text) || (x.attributes ->> 'name'::text)
           FROM catalog.entity x
          WHERE (x.id IN ( SELECT api.related(e.id, 'backed_by_repository'::text, 'outgoing'::text) AS related))
         LIMIT 1)) AS repository_url,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'develops'::text, 'incoming'::text) x(x))) AS developers,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'maintains'::text, 'incoming'::text) x(x))) AS maintainers,
    lr.version_label AS latest_release,
    lr.released_on AS latest_release_on,
    COALESCE(api.fact_payload(e.id, 'library_license'::text) ->> 'spdx'::text, e.attributes ->> 'license'::text) AS license,
    api.fact_amount(COALESCE(( SELECT api.related(e.id, 'backed_by_repository'::text, 'outgoing'::text) AS related
         LIMIT 1), e.id), 'repository_stars'::text) AS stars,
    api.fact_amount(e.id, 'package_downloads'::text) AS downloads,
    e.attributes ->> 'hosting'::text AS mcp_hosting,
    e.attributes ->> 'auth'::text AS mcp_auth,
    (e.attributes ->> 'is_official'::text)::boolean AS mcp_is_official,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'implements_protocol'::text, 'outgoing'::text) x(x))) AS protocols,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'instance_of_concept'::text, 'outgoing'::text) x(x))) AS concepts,
    e.summary
   FROM catalog.entity e
     LEFT JOIN LATERAL ( SELECT r.attributes ->> 'version_label'::text AS version_label,
            (r.attributes ->> 'released_on'::text)::date AS released_on
           FROM catalog.entity r
          WHERE r.kind = 'library_release'::text AND (r.id IN ( SELECT api.related(e.id, 'version_of'::text, 'incoming'::text) AS related))
          ORDER BY (r.attributes ->> 'released_on'::text) DESC NULLS LAST
         LIMIT 1) lr ON true
  WHERE e.tenant_id = util.current_tenant_id() AND (e.kind = ANY (ARRAY['library'::text, 'repository'::text, 'mcp_server'::text, 'agent_skill'::text, 'product'::text, 'ai_protocol'::text])) AND e.lifecycle = 'active'::text;
```
