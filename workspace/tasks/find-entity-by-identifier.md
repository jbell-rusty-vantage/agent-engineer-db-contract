---
id: "task:find-entity-by-identifier"
kind: task
lens: corpus
domains: [identity]
queries: [entity.by_identifier, entity.resolve, entity.attributes]
aliases: [scheme, external id]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# Find an entity by external identifier

Domains: [`identity`](../domains/identity.md). Queries: [`q:entity.by_identifier`](../queries/README.md), [`q:entity.resolve`](../queries/README.md), [`q:entity.attributes`](../queries/README.md).

## Navigation

`domains/identity.md` → `q:entity.by_identifier`

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "lookup-github",
  "operations": [
    { "opId": "id", "kind": "named_query", "query": "entity.by_identifier", "params": { "scheme": "github", "value": "openai/openai-python" } },
    { "opId": "attrs", "kind": "named_query", "query": "entity.attributes", "params": { "entity_id": "$id.rows[0].entity_id" } }
  ]
}
```

## Expected shape

Zero or one row: entity_id, kind, display_name, lifecycle, scheme, value. `(scheme, value)` is unique per tenant. `attrs` adds the kind-validated attributes.

## Pitfalls

Scheme must be in the closed scheme check. There is no `openai_model_id` scheme; use `other` or a listed namespace. Prefer identifier lookup over name resolve when the source prints a stable id.
