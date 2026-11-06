---
id: "task:find-stale-facts"
kind: task
domains: [temporal-facts, evidence]
queries: [entity.resolve, facts.current_by_stream, facts.history_for_stream, entity.card, knowledge.head]
aliases: [stale, outdated, contradicts, gap analysis]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Find facts the database still holds as current that a source contradicts

Domains: [`temporal-facts`](../domains/temporal-facts.md), [`evidence`](../domains/evidence.md). Queries: [`q:entity.resolve`](../queries/README.md), [`q:facts.current_by_stream`](../queries/README.md), [`q:facts.history_for_stream`](../queries/README.md), [`q:entity.card`](../queries/README.md), [`q:knowledge.head`](../queries/README.md).

## Navigation

`domains/temporal-facts.md` → `q:facts.current_by_stream` → `tasks/supersede-stale-fact.md`

## Operation

Read the current segments per stream and compare each `(stream_kind, scope_key)` slot with what the source states. A fact is stale when the slot exists, its segment is current (`valid_to` null), and the source gives a different value with a later world time.

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "stale-scan-codex",
  "operations": [
    { "opId": "resolve", "kind": "named_query", "query": "entity.resolve", "params": { "text": "Codex" } },
    { "opId": "prices", "kind": "named_query", "query": "facts.current_by_stream", "params": { "stream_kind": "model_offering_price", "entity_id": "$resolve.rows[0].entity_id", "limit": 100 } },
    { "opId": "history", "kind": "named_query", "query": "facts.history_for_stream", "params": { "entity_id": "$resolve.rows[0].entity_id", "stream_kind": "model_offering_price", "scope_key": "per_1m_input_tokens", "limit": 20, "offset": 0 } },
    { "opId": "head", "kind": "named_query", "query": "knowledge.head" }
  ]
}
```

## Expected shape

`prices` rows carry `scope_key`, the current value columns, `valid_from`, and `valid_to` null. Every stale slot you find becomes one `fact.assert_state` proposal on the **same** `streamKind` and `scopeKey` (see `tasks/supersede-stale-fact.md`); the snapshot head is your `expectedKnowledgeHead`.

## Pitfalls

Writing the new value under a new `scopeKey` does not fix anything: the old segment stays current and the entity now has two contradicting current facts. Reuse the existing slot's `scope_key` exactly. Facts without a world time in the source are not corrections; record them with `temporalBasis: unresolved` or stage them.
