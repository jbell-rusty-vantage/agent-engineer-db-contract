---
id: "task:record-availability-change"
kind: task
domains: [temporal-facts]
queries: [vocab.stream_kind, facts.current_by_stream, entity.at]
aliases: [ga, deprecated, availability]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Record an availability change

Domains: [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:vocab.stream_kind`](../queries/README.md), [`q:facts.current_by_stream`](../queries/README.md), [`q:entity.at`](../queries/README.md).

## Navigation

`domains/temporal-facts.md` → `q:facts.current_by_stream`

## Operation

```json
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "offering-ga",
  "expectedKnowledgeHead": 41,
  "onStale": "rebase_if_disjoint",
  "subjects": [{ "ref": "offering", "mode": "resolved", "entityId": "0192b000-0000-7000-8000-000000000001", "kind": "model_offering" }],
  "proposals": [
    {
      "proposalId": "p-avail",
      "kind": "fact.assert_state",
      "subjectRef": "offering",
      "streamKind": "model_offering_availability",
      "worldInterval": { "from": "2026-08-20T00:00:00Z", "to": null, "bounds": "[)" },
      "status": "ga",
      "extent": { "sourceText": "August 20, 2026", "precision": "day", "earliest": "2026-08-20", "latest": "2026-08-20" },
      "temporalBasis": "explicit",
      "belief": "accepted"
    }
  ]
}
```

## Expected shape

Current row in `api.current_facts` with `stream_kind='model_offering_availability'` and `status='ga'` when `now()` is inside `valid_during`.

## Pitfalls

Status must be announced, preview, ga, deprecated, or retired. Do not move backward along that sequence without an explicit correction (rule availability.transitions_are_ordered). Product features use `temporal.stream_kind:product_feature_availability` and removed instead of retired.
