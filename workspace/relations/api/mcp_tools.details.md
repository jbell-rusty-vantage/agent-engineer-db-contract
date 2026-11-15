---
id: "rel:api.mcp_tools#details"
kind: details
schema: api
name: mcp_tools
of: "rel:api.mcp_tools"
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# api.mcp_tools — details

Spill-over from [the main page](mcp_tools.md).

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
    v.id AS document_version_id,
    v.version_label,
    n.attributes ->> 'server'::text AS server,
    n.attributes ->> 'name'::text AS name,
    n.attributes ->> 'description'::text AS description,
    n.attributes ->> 'toolset'::text AS toolset,
    n.attributes -> 'input_schema'::text AS input_schema,
    n.attributes -> 'required'::text AS required,
    n.attributes -> 'scopes'::text AS scopes,
    n.attributes ->> 'availability'::text AS availability,
    ( SELECT r_1.entity_id
           FROM content.unit_entity_role r_1
          WHERE r_1.node_id = n.id AND r_1.role = 'server'::text
         LIMIT 1) AS server_id,
    d.attributes ->> 'custody_level'::text AS custody_level,
    n.logical_key
   FROM content.document d
     JOIN content.document_version v ON v.document_id = d.id
     JOIN content.document_representation r ON r.document_version_id = v.id
     JOIN content.document_node n ON n.representation_id = r.id
  WHERE d.tenant_id = util.current_tenant_id() AND n.unit_kind = 'mcp_tool'::text;
```
