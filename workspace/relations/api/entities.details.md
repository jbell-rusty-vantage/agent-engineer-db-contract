---
id: "rel:api.entities#details"
kind: details
schema: api
name: entities
of: "rel:api.entities"
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.entities — details

Spill-over from [the main page](entities.md).

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
SELECT id,
    tenant_id,
    kind,
    display_name,
    slug,
    summary,
    lifecycle,
    merged_into_id,
    projection_knowledge_seq,
    created_by_receipt_id,
    created_at,
    updated_at,
    api.entity_aliases(id) AS aliases
   FROM api.entity_rows() e(id, tenant_id, kind, display_name, slug, summary, lifecycle, merged_into_id, projection_knowledge_seq, created_by_receipt_id, created_at, updated_at);
```
