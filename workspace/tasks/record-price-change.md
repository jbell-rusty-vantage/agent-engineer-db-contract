---
id: "task:record-price-change"
kind: task
domains: [temporal-facts]
queries: [vocab.stream_kind, facts.history_for_stream, entity.at, knowledge.head]
aliases: [price, pricing]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Record a price change with world-time

Domains: [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:vocab.stream_kind`](../queries/README.md), [`q:facts.history_for_stream`](../queries/README.md), [`q:entity.at`](../queries/README.md), [`q:knowledge.head`](../queries/README.md).

## Navigation

`domains/temporal-facts.md` → `vocabularies/temporal.stream_kind.md` → `q:facts.history_for_stream`

## Operation

```json
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "openai-terra-input-price",
  "expectedKnowledgeHead": 41,
  "onStale": "rebase_if_disjoint",
  "subjects": [{ "ref": "offering", "mode": "resolved", "entityId": "0192b000-0000-7000-8000-000000000001", "kind": "model_offering" }],
  "proposals": [
    {
      "proposalId": "p-price",
      "kind": "fact.assert_state",
      "subjectRef": "offering",
      "streamKind": "model_offering_price",
      "scopeKey": "per_1m_input_tokens",
      "worldInterval": { "from": "2026-08-20T00:00:00Z", "to": null, "bounds": "[)" },
      "amount": 2.5,
      "currency": "USD",
      "unit": "per_1m_input_tokens",
      "extent": { "sourceText": "August 20, 2026", "precision": "day", "earliest": "2026-08-20", "latest": "2026-08-20" },
      "temporalBasis": "explicit",
      "belief": "accepted"
    }
  ]
}
```

## Expected shape

One new `temporal.segment` on stream (model_offering_price, offering, per_1m_input_tokens). Re-query with `q:entity.at` at the world instant and `q:facts.history_for_stream` to see closed predecessors.

## Pitfalls

`scopeKey` names the series, and the database enforces no naming convention for it. Read `q:facts.current_by_stream` first: if the offering already has a current segment for this unit under any `scope_key` (older data uses keys such as `input_tokens`), reuse that key exactly, or the old price stays current beside the new one. Only a series that does not exist yet defaults `scopeKey` to the unit (rule price.scope_key_is_unit). unit must be in `temporal.stream_kind:model_offering_price` unit_values. Currency must be three ASCII letters. temporal_basis explicit requires an extent.
