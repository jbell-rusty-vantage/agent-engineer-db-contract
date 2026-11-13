---
id: "rel:api.capabilities#details"
kind: details
schema: api
name: capabilities
of: "rel:api.capabilities"
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.capabilities — details

Spill-over from [the main page](capabilities.md).

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
SELECT e.id AS capability_id,
    e.kind,
    e.display_name AS capability,
    e.slug,
    ( SELECT jsonb_agg(jsonb_build_object('scheme', i.scheme, 'value', i.value) ORDER BY i.scheme) AS jsonb_agg
           FROM catalog.entity_identifier i
          WHERE i.entity_id = e.id) AS identifiers,
    COALESCE(m.custody_level, 'C0'::text) AS custody_level,
    m.document_id AS manifest_document_id,
    m.commit,
    m.version_label,
    e.attributes ->> 'description'::text AS description,
    ( SELECT count(*) AS count
           FROM api.bundle_files f
          WHERE f.capability_id = e.id AND f.document_id = m.document_id) AS files,
    ( SELECT count(*) AS count
           FROM api.bundle_files f
          WHERE f.capability_id = e.id AND f.document_id = m.document_id AND f.executable) AS executable_files,
    ( SELECT count(*) AS count
           FROM api.mcp_tools t
          WHERE t.server_id = e.id AND t.document_version_id = m.document_version_id) AS tools,
    ( SELECT count(*) AS count
           FROM api.hook_entries h
          WHERE h.plugin_id = e.id) AS hooks,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'bundles'::text, 'outgoing'::text) x(x))) AS bundles,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'bundles'::text, 'incoming'::text) x(x))) AS bundled_in,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'compatible_with'::text, 'outgoing'::text) x(x))) AS compatible_with,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'listed_in'::text, 'outgoing'::text) x(x))) AS listed_in,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(e.id, 'backed_by_repository'::text, 'outgoing'::text) x(x))) AS repositories
   FROM catalog.entity e
     LEFT JOIN LATERAL ( SELECT d.id AS document_id,
            d.attributes ->> 'custody_level'::text AS custody_level,
            d.attributes ->> 'commit'::text AS commit,
            v.id AS document_version_id,
            v.version_label
           FROM content.document_about_entity a
             JOIN content.document d ON d.id = a.document_id
             JOIN content.document_version v ON v.document_id = d.id
          WHERE a.entity_id = e.id AND a.role = 'primary'::text AND (d.document_type_code = ANY (ARRAY['agent_skill_manifest'::text, 'mcp_server_manifest'::text, 'agent_plugin_manifest'::text]))
          ORDER BY v.created_at DESC
         LIMIT 1) m ON true
  WHERE e.tenant_id = util.current_tenant_id() AND (e.kind = ANY (ARRAY['agent_skill'::text, 'mcp_server'::text, 'agent_plugin'::text])) AND e.lifecycle = 'active'::text;
```
