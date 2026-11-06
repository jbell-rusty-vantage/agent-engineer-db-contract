---
id: "task:what-changed-since-head"
kind: task
domains: [temporal-facts]
queries: [knowledge.head, entity.what_changed]
aliases: [diff, rebase, delta]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# What changed since head K

Domains: [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:knowledge.head`](../queries/README.md), [`q:entity.what_changed`](../queries/README.md).

## Navigation

`domains/temporal-facts.md` → `q:entity.what_changed`

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "diff-since-41",
  "operations": [
    { "opId": "head", "kind": "named_query", "query": "knowledge.head" },
    { "opId": "changed", "kind": "named_query", "query": "entity.what_changed", "params": { "entity_id": "0192b000-0000-7000-8000-000000000001", "k_from": 41, "k_to": 42 } }
  ]
}
```

## Expected shape

Rows with `change_kind` opened or closed, `item_kind` segment, event, or relationship, `knowledge_seq`, and `details` jsonb of the row.

## Pitfalls

`what_changed` is entity-scoped (segments on the entity or its relationships, occurrences, relationship rows). Call it per subject when rebasing an intent. `k_from`/`k_to` here are knowledge heads, not world time.
