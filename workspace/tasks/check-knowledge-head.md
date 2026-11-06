---
id: "task:check-knowledge-head"
kind: task
domains: [temporal-facts]
queries: [knowledge.head, entity.what_changed]
aliases: [freshness, expected head]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
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

Freshness is the integer head, not executed_at. Two open writers cannot share a batch; the second sees knowledge batch already open. Always pass expectedKnowledgeHead (rule write.expected_head_required).
