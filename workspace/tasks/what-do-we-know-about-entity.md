---
id: "task:what-do-we-know-about-entity"
kind: task
lens: corpus
domains: [identity, temporal-facts, relationships, evidence, guidance]
queries: [entity.resolve, entity.card, entity.attributes, entity.relationships, evidence.claims_for_entity, guidance.items, knowledge.head]
aliases: [baseline, prior knowledge]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# What do we already know about <name>?

Domains: [`identity`](../domains/identity.md), [`temporal-facts`](../domains/temporal-facts.md), [`relationships`](../domains/relationships.md), [`evidence`](../domains/evidence.md), [`guidance`](../domains/guidance.md). Queries: [`q:entity.resolve`](../queries/README.md), [`q:entity.card`](../queries/README.md), [`q:entity.attributes`](../queries/README.md), [`q:entity.relationships`](../queries/README.md), [`q:evidence.claims_for_entity`](../queries/README.md), [`q:guidance.items`](../queries/README.md), [`q:knowledge.head`](../queries/README.md).

## Navigation

`domains/identity.md` → `queries/README.md` (entity.*); for a whole kind use the L1 views (`tasks/compare-models.md`).

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "openai-baseline",
  "operations": [
    { "opId": "resolve", "kind": "named_query", "query": "entity.resolve", "params": { "text": "OpenAI" } },
    { "opId": "card", "kind": "named_query", "query": "entity.card", "params": { "entity_id": "$resolve.rows[0].entity_id" } },
    { "opId": "attrs", "kind": "named_query", "query": "entity.attributes", "params": { "entity_id": "$resolve.rows[0].entity_id" } },
    { "opId": "rels", "kind": "named_query", "query": "entity.relationships", "params": { "entity_id": "$resolve.rows[0].entity_id", "direction": "both" } },
    { "opId": "claims", "kind": "named_query", "query": "evidence.claims_for_entity", "params": { "entity_id": "$resolve.rows[0].entity_id", "limit": 100 } },
    { "opId": "guidance", "kind": "named_query", "query": "guidance.items", "params": { "entity_id": "$resolve.rows[0].entity_id", "limit": 50 } },
    { "opId": "head", "kind": "named_query", "query": "knowledge.head" }
  ]
}
```

## Expected shape

`resolve` rows: entity_id, kind, display_name, score (≤ 25, best first). `card` is one JSON object with entity, aliases, facts[], relationships[], events[], sources[]. `attrs` is the row with its kind-validated `attributes` and the kind's `attributes_schema`. The snapshot knowledge_seq is the value for `expectedKnowledgeHead`.

## Pitfalls

`q:entity.card` shows current facts only (valid_during contains now() via `api.entity_at` defaults). For a historical date use `q:entity.at`. Merged entities are excluded by `api.resolve_entity`; follow merged_into_id if you hold an old id. Attributes never hold numbers that change — look at facts for prices, context windows, headcount.
