---
id: "rel:api.entities#details"
kind: details
schema: api
name: entities
of: "rel:api.entities"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
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
