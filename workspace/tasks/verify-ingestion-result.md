---
id: "task:verify-ingestion-result"
kind: task
domains: [temporal-facts, orchestration-ledger]
queries: [receipts.for_intent, knowledge.head, entity.what_changed, facts.history_for_stream, artifacts.by_type]
aliases: [receipt, verify write, post-ingest check]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Verify what an ingestion actually changed

Domains: [`temporal-facts`](../domains/temporal-facts.md), [`orchestration-ledger`](../domains/orchestration-ledger.md). Queries: [`q:receipts.for_intent`](../queries/README.md), [`q:knowledge.head`](../queries/README.md), [`q:entity.what_changed`](../queries/README.md), [`q:facts.history_for_stream`](../queries/README.md), [`q:artifacts.by_type`](../queries/README.md).

## Navigation

`tasks/compose-ingestion-intent.md` → `q:receipts.for_intent` → `q:entity.what_changed`

## Operation

Take `knowledgeHead.before` and `knowledgeHead.after` from the receipt and diff every subject between them.

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "verify-codex-2026-09-11",
  "operations": [
    { "opId": "receipt", "kind": "named_query", "query": "receipts.for_intent", "params": { "intent_id": "0192c000-0000-7000-8000-000000000001" } },
    { "opId": "head", "kind": "named_query", "query": "knowledge.head" },
    { "opId": "changed", "kind": "named_query", "query": "entity.what_changed", "params": { "entity_id": "0192b000-0000-7000-8000-000000000011", "k_from": 4, "k_to": 5 } },
    { "opId": "price_history", "kind": "named_query", "query": "facts.history_for_stream", "params": { "entity_id": "0192b000-0000-7000-8000-000000000011", "stream_kind": "model_offering_price", "scope_key": "per_1m_input_tokens", "limit": 5, "offset": 0 } }
  ]
}
```

## Expected shape

`receipt`: one row with `receipt_id`, `outcome`, `knowledge_seq`. `changed`: one `opened` row per new segment/relationship/event and one `closed` row per superseded segment. A correction shows exactly one `closed` and one `opened` on the same `scope_key`; only `opened` rows mean you created a parallel fact instead of superseding.

## Pitfalls

The receipt is the record; the agent's own log is not. Zero `closed` rows after a "stale fix" is a failed fix. Do not re-apply the intent to "make sure": the same `intentId` is `duplicateOf`. Cite `receipt_id` and `knowledgeHead.after` in the report.
