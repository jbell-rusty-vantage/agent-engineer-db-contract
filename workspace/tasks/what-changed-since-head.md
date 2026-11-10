---
id: "task:what-changed-since-head"
kind: task
lens: corpus
domains: [temporal-facts]
queries: [knowledge.head, entity.what_changed, facts.changes_since]
aliases: [diff, rebase, delta]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# What changed since head K

Domains: [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:knowledge.head`](../queries/README.md), [`q:entity.what_changed`](../queries/README.md), [`q:facts.changes_since`](../queries/README.md).

## Navigation

`domains/temporal-facts.md` → `q:entity.what_changed` (per entity, by head) or `tasks/what-changed-since.md` (by date, whole tenant).

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

`what_changed` is entity-scoped (segments on the entity or its relationships, occurrences, relationship rows). Call it per subject when rebasing an intent. `k_from`/`k_to` here are knowledge heads, not world time; for a date-based, tenant-wide view use `q:facts.changes_since`.
