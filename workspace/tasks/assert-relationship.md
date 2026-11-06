---
id: "task:assert-relationship"
kind: task
domains: [relationships]
queries: [vocab.relationship_kind, entity.relationships, relationships.current_by_kind]
aliases: [link, graph edge]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Assert a relationship

Domains: [`relationships`](../domains/relationships.md). Queries: [`q:vocab.relationship_kind`](../queries/README.md), [`q:entity.relationships`](../queries/README.md), [`q:relationships.current_by_kind`](../queries/README.md).

## Navigation

`domains/relationships.md` → `q:vocab.relationship_kind`

## Operation

```json
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "model-offered-as",
  "expectedKnowledgeHead": 41,
  "onStale": "rebase_if_disjoint",
  "subjects": [
    { "ref": "model", "mode": "resolved", "entityId": "0192b000-0000-7000-8000-000000000102", "kind": "ai_model_version" },
    { "ref": "offering", "mode": "resolved", "entityId": "0192b000-0000-7000-8000-000000000001", "kind": "model_offering" }
  ],
  "proposals": [
    {
      "proposalId": "p-rel",
      "kind": "relationship.assert",
      "relationshipKind": "offered_as",
      "fromRef": "model",
      "toRef": "offering",
      "temporalBasis": "observation_bounded",
      "belief": "accepted"
    }
  ]
}
```

## Expected shape

One `corpus.relationship` with k_to null. Temporal kinds also get a `temporal.stream_kind:relationship_active` segment. `q:entity.relationships` returns the row when direction includes the endpoint.

## Pitfalls

Endpoint kinds must match `taxonomy.relationship_kind.from_kinds` / `to_kinds` (`offered_as` is ai_model_version → model_offering, not ai_model). Temporal kinds need `worldInterval`. Properties must satisfy `property_schema`.
