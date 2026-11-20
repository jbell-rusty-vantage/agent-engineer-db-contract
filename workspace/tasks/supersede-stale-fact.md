---
id: "task:supersede-stale-fact"
kind: task
lens: corpus
domains: [temporal-facts]
queries: [facts.price_history, facts.history_for_stream, entity.at, entity.what_changed, knowledge.head]
aliases: [correct, replace, stale]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# Supersede a stale fact

Domains: [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:facts.price_history`](../queries/README.md), [`q:facts.history_for_stream`](../queries/README.md), [`q:entity.at`](../queries/README.md), [`q:entity.what_changed`](../queries/README.md), [`q:knowledge.head`](../queries/README.md).

## Navigation

`domains/temporal-facts.md` → `q:facts.price_history`

## Operation

Supersession is not a separate proposal kind. Assert the newer fact on the same stream slot; `temporal.assert_state` closes and splits the old current segment.

```json
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "correct-input-price",
  "expectedKnowledgeHead": 41,
  "onStale": "fail",
  "subjects": [{ "ref": "offering", "mode": "resolved", "entityId": "0192b000-0000-7000-8000-000000000001", "kind": "model_offering" }],
  "proposals": [
    {
      "proposalId": "p-new",
      "kind": "fact.assert_state",
      "subjectRef": "offering",
      "streamKind": "offering_price",
      "scopeKey": "input_tokens||",
      "worldInterval": { "from": "2026-09-01T00:00:00Z", "to": null, "bounds": "[)" },
      "amount": 1.25,
      "currency": "USD",
      "unit": "usd_per_1m_tokens",
      "payload": { "meter": "input_tokens" },
      "extent": { "sourceText": "September 1, 2026", "precision": "day", "earliest": "2026-09-01", "latest": "2026-09-01" },
      "temporalBasis": "explicit",
      "belief": "accepted"
    }
  ]
}
```

## Expected shape

Plan lists supersedes old segment ids. `q:facts.price_history` shows the old row with k_to set and `replaces_segment_id` on fragments. `q:entity.what_changed` between the snapshot head and the new head reports opened/closed segments.

## Pitfalls

Overlapping assertions in one batch raise. Identical current values are a no-op. Do not call `temporal.close_segment` yourself. Reuse the existing `scope_key` exactly (see `q:facts.price_history` rows).
