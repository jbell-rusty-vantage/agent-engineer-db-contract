---
id: "task:record-price-change"
kind: task
lens: corpus
domains: [temporal-facts]
queries: [vocab.stream_kind, facts.price_history, facts.history_for_stream, entity.at, knowledge.head]
aliases: [price, pricing]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# Record a price change with world-time

Domains: [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:vocab.stream_kind`](../queries/README.md), [`q:facts.price_history`](../queries/README.md), [`q:facts.history_for_stream`](../queries/README.md), [`q:entity.at`](../queries/README.md), [`q:knowledge.head`](../queries/README.md).

## Navigation

`domains/temporal-facts.md` → `vocabularies/temporal.stream_kind.md` → `q:facts.price_history`

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
      "streamKind": "offering_price",
      "scopeKey": "input_tokens||",
      "worldInterval": { "from": "2026-08-20T00:00:00Z", "to": null, "bounds": "[)" },
      "amount": 2.5,
      "currency": "USD",
      "unit": "usd_per_1m_tokens",
      "payload": { "meter": "input_tokens" },
      "extent": { "sourceText": "August 20, 2026", "precision": "day", "earliest": "2026-08-20", "latest": "2026-08-20" },
      "temporalBasis": "explicit",
      "belief": "accepted"
    }
  ]
}
```

## Expected shape

One new `temporal.segment` on stream (offering_price, offering, `input_tokens||`). Re-query with `q:facts.price_history` (`meter: input_tokens`) to see closed predecessors, or `q:entity.at` at the world instant.

## Pitfalls

`payload.meter` is required by `temporal.stream_kind:offering_price`; `scopeKey` is `meter|tier|region` and the database enforces no naming convention for it. Read `q:facts.price_history` first: if the offering already has a current segment for this meter under another `scope_key`, reuse that key exactly, or the old price stays current beside the new one (rule price.scope_key_is_meter). `unit` must be in the stream kind's `unit_values` (check `q:vocab.stream_kind`). Currency must be three ASCII letters. temporal_basis explicit requires an extent.
