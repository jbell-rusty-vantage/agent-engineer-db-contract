---
id: "task:find-entity-by-identifier"
kind: task
domains: [identity]
queries: [entity.by_identifier, entity.resolve, entity.typed_row]
aliases: [scheme, external id]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Find an entity by external identifier

Domains: [`identity`](../domains/identity.md). Queries: [`q:entity.by_identifier`](../queries/README.md), [`q:entity.resolve`](../queries/README.md), [`q:entity.typed_row`](../queries/README.md).

## Navigation

`domains/identity.md` → `q:entity.by_identifier`

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "lookup-github",
  "operations": [
    { "opId": "id", "kind": "named_query", "query": "entity.by_identifier", "params": { "scheme": "github", "value": "openai/openai-python" } },
    { "opId": "typed", "kind": "named_query", "query": "entity.typed_row", "params": { "entity_id": "$id.rows[0].entity_id" } }
  ]
}
```

## Expected shape

Zero or one row: entity_id, kind, display_name, lifecycle, scheme, value. `(scheme, value)` is unique per tenant.

## Pitfalls

Scheme must be in `entity_identifier_scheme_check`. There is no `openai_model_id` scheme; use `other` or a listed namespace. Prefer identifier lookup over name resolve when the source prints a stable id.
