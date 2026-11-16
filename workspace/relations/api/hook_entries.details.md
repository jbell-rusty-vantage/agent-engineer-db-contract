---
id: "rel:api.hook_entries#details"
kind: details
schema: api
name: hook_entries
of: "rel:api.hook_entries"
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.hook_entries — details

Spill-over from [the main page](hook_entries.md).

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
    ( SELECT r_1.entity_id
           FROM content.unit_entity_role r_1
          WHERE r_1.node_id = n.id AND r_1.role = 'capability'::text
         LIMIT 1) AS plugin_id,
    ( SELECT e.display_name
           FROM content.unit_entity_role r_1
             JOIN catalog.entity e ON e.id = r_1.entity_id
          WHERE r_1.node_id = n.id AND r_1.role = 'capability'::text
         LIMIT 1) AS plugin,
    n.attributes ->> 'event'::text AS event,
    n.attributes ->> 'matcher'::text AS matcher,
    n.attributes ->> 'hook_type'::text AS hook_type,
    n.attributes ->> 'command'::text AS command,
    n.attributes ->> 'config_path'::text AS config_path
   FROM content.document d
     JOIN content.document_version v ON v.document_id = d.id
     JOIN content.document_representation r ON r.document_version_id = v.id
     JOIN content.document_node n ON n.representation_id = r.id
  WHERE d.tenant_id = util.current_tenant_id() AND n.unit_kind = 'hook_entry'::text;
```
