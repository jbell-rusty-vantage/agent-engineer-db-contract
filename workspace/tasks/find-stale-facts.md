---
id: "task:find-stale-facts"
kind: task
lens: corpus
domains: [temporal-facts, evidence, content]
queries: [entity.resolve, facts.current_by_stream, facts.price_history, content.unit_changes, knowledge.head]
aliases: [stale, outdated, contradicts, gap analysis]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# Find facts the database still holds as current that a source contradicts

Domains: [`temporal-facts`](../domains/temporal-facts.md), [`evidence`](../domains/evidence.md), [`content`](../domains/content.md). Queries: [`q:entity.resolve`](../queries/README.md), [`q:facts.current_by_stream`](../queries/README.md), [`q:facts.price_history`](../queries/README.md), [`q:content.unit_changes`](../queries/README.md), [`q:knowledge.head`](../queries/README.md).

## Navigation

`domains/temporal-facts.md` → `q:facts.current_by_stream` → `tasks/supersede-stale-fact.md`; refreshed documents already list candidate contradictions in `q:content.unit_changes`.

## Operation

Read the current segments per stream and compare each `(stream_kind, scope_key)` slot with what the source states. A fact is stale when the slot exists, its segment is current (`k_to` null), and the source gives a different value with a later world time.

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "stale-scan-codex",
  "operations": [
    { "opId": "resolve", "kind": "named_query", "query": "entity.resolve", "params": { "text": "Codex" } },
    { "opId": "prices", "kind": "named_query", "query": "facts.current_by_stream", "params": { "stream_kind": "offering_price", "entity_id": "$resolve.rows[0].entity_id", "limit": 100 } },
    { "opId": "history", "kind": "named_query", "query": "facts.price_history", "params": { "offering_id": "$resolve.rows[0].entity_id", "meter": "input_tokens" } },
    { "opId": "diffs", "kind": "named_query", "query": "content.unit_changes", "params": { "document_id": null, "since": "2026-10-01T00:00:00Z", "limit": 100 } },
    { "opId": "head", "kind": "named_query", "query": "knowledge.head" }
  ]
}
```

## Expected shape

`prices` rows carry `scope_key`, the current value columns, `valid_during`. Every stale slot you find becomes one `fact.assert_state` proposal on the **same** `streamKind` and `scopeKey` (see `tasks/supersede-stale-fact.md`); the snapshot head is your `expectedKnowledgeHead`. `diffs` rows with `change_kind = attribute_changed` on a `price_row` are the refresh pipeline's own stale candidates (`update_proposal_state`).

## Pitfalls

Writing the new value under a new `scopeKey` does not fix anything: the old segment stays current and the entity now has two contradicting current facts. Reuse the existing slot's `scope_key` exactly. Facts without a world time in the source are not corrections; record them with `temporalBasis: unresolved` or stage them.
