---
id: "task:check-knowledge-head"
kind: task
lens: corpus
domains: [temporal-facts]
queries: [knowledge.head, entity.what_changed]
aliases: [freshness, expected head]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# Check the knowledge head before writing

Domains: [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:knowledge.head`](../queries/README.md), [`q:entity.what_changed`](../queries/README.md).

## Navigation

`domains/temporal-facts.md` → `q:knowledge.head`

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "read-head",
  "operations": [
    { "opId": "head", "kind": "named_query", "query": "knowledge.head" }
  ]
}
```

Put the head knowledge_seq in the snapshot and in expectedKnowledgeHead. If apply fails rebase_required, re-run `q:entity.what_changed` for every subject.

## Expected shape

One row: `knowledge_seq` (0 when no batch has been sealed), `updated_at`.

## Pitfalls

Freshness is the integer head, not executed_at. Two open writers cannot share a batch; the second sees knowledge batch already open. Always pass expectedKnowledgeHead (rule write.expected_head_required). Product operations use a different head: `p_expected_head` is the work's head revision id.
