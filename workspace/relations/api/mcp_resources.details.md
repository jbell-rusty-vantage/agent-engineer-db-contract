---
id: "rel:api.mcp_resources#details"
kind: details
schema: api
name: mcp_resources
of: "rel:api.mcp_resources"
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.mcp_resources — details

Spill-over from [the main page](mcp_resources.md).

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
SELECT n.id AS node_id,
    d.id AS document_id,
    v.version_label,
    n.attributes ->> 'server'::text AS server,
    n.attributes ->> 'name'::text AS name,
    n.attributes ->> 'description'::text AS description,
    n.attributes ->> 'uri_template'::text AS uri_template,
    ( SELECT r_1.entity_id
           FROM content.unit_entity_role r_1
          WHERE r_1.node_id = n.id AND r_1.role = 'server'::text
         LIMIT 1) AS server_id
   FROM content.document d
     JOIN content.document_version v ON v.document_id = d.id
     JOIN content.document_representation r ON r.document_version_id = v.id
     JOIN content.document_node n ON n.representation_id = r.id
  WHERE d.tenant_id = util.current_tenant_id() AND n.unit_kind = 'mcp_resource'::text;
```
