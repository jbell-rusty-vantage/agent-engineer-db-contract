---
id: "task:compare-models"
kind: task
lens: corpus
domains: [api-surface, ranking, temporal-facts]
queries: [catalog.models, catalog.benchmark_scores, catalog.model_offerings, ranking.leaderboard, catalog.models_at]
aliases: [compare models, which model, model comparison, best model for]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# Compare models on capabilities, context, price and benchmarks

Domains: [`api-surface`](../domains/api-surface.md), [`ranking`](../domains/ranking.md), [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:catalog.models`](../queries/README.md), [`q:catalog.benchmark_scores`](../queries/README.md), [`q:catalog.model_offerings`](../queries/README.md), [`q:ranking.leaderboard`](../queries/README.md), [`q:catalog.models_at`](../queries/README.md).

## Navigation

`START_HERE.md` (L1) → `relations/api/models.md` → `q:catalog.models`; numbers you quote go back to `q:catalog.benchmark_scores` / `q:facts.locators`.

## Operation

One L1 read answers most comparisons; add benchmarks and a leaderboard when ranking matters.

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "compare-frontier-models",
  "operations": [
    { "opId": "models", "kind": "named_query", "query": "catalog.models", "params": { "text": null, "availability": "ga", "limit": 100 } },
    { "opId": "scores", "kind": "named_query", "query": "catalog.benchmark_scores", "params": { "subject_id": null, "benchmark": "SWE-bench", "limit": 100 } },
    { "opId": "board", "kind": "named_query", "query": "ranking.leaderboard", "params": { "slug": "cheapest-frontier-input", "limit": 20 } }
  ]
}
```

For "as of last June" replace `catalog.models` with `q:catalog.models_at` (`at`).

## Expected shape

`models` rows: one per model version with `developer`, `released_on`, `context_tokens`, `max_output_tokens`, `modalities`, capability statuses (`tool_use`, `structured_output`, `reasoning`, `vision`), `knowledge_cutoff`, `availability`, `min_input_usd_per_1m`, `min_output_usd_per_1m`, `offering_count`, `as_of_knowledge_seq`. `scores` rows carry `score`, `unit`, `setting`, `claim_id`. A leaderboard row carries `source_segment_ids` in `explanation`.

## Pitfalls

`api.models` shows the minimum current price across offerings; the offering that has it is in `q:catalog.model_offerings` (`model_version_id`). Capability columns are statuses of fact streams, not booleans from a spec sheet; `null` means no fact, not "no". Cite `as_of_knowledge_seq` with every table you paste. Do not rank by benchmark without the `setting` column — two scores with different settings are not comparable.
