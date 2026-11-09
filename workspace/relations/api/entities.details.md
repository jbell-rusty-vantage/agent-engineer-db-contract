---
id: "rel:api.entities#details"
kind: details
schema: api
name: entities
of: "rel:api.entities"
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
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
