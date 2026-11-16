---
id: "task:cheapest-qualified-model"
kind: task
lens: corpus
domains: [api-surface, ranking]
queries: [catalog.models, catalog.model_offerings, catalog.benchmark_scores, ranking.leaderboard]
aliases: [cheapest, cost effective, budget model, cheapest with tool use]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# Cheapest model that satisfies a capability or benchmark floor

Domains: [`api-surface`](../domains/api-surface.md), [`ranking`](../domains/ranking.md). Queries: [`q:catalog.models`](../queries/README.md), [`q:catalog.model_offerings`](../queries/README.md), [`q:catalog.benchmark_scores`](../queries/README.md), [`q:ranking.leaderboard`](../queries/README.md).

## Navigation

`tasks/compare-models.md` → `q:catalog.models` (filter capabilities) → `q:catalog.model_offerings` (price per offering) → `q:catalog.benchmark_scores` (floor).

## Operation

Filter first, then price, then verify the floor; a leaderboard edition can replace all three when one exists.

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "cheapest-with-tool-use",
  "operations": [
    { "opId": "models", "kind": "named_query", "query": "catalog.models", "params": { "text": null, "availability": "ga", "limit": 200 } },
    { "opId": "offers", "kind": "named_query", "query": "catalog.model_offerings", "params": { "model_version_id": null, "text": null, "limit": 200 } },
    { "opId": "scores", "kind": "named_query", "query": "catalog.benchmark_scores", "params": { "subject_id": null, "benchmark": "SWE-bench", "limit": 200 } },
    { "opId": "board", "kind": "named_query", "query": "ranking.leaderboard", "params": { "slug": "cheapest-frontier-input", "limit": 20 } }
  ]
}
```

Keep `models` rows where `tool_use = 'supported'` (or the status you need), join `offers` on `model_version_id` and take the lowest `input_usd_per_1m` whose subject has a `scores` row above the floor.

## Expected shape

A short list ordered by `input_usd_per_1m` with the offering, provider, region/tier, the capability status that qualified it and the benchmark row (`score`, `setting`, `claim_id`) that met the floor. Cite `price_locator_id` and `as_of_knowledge_seq`.

## Pitfalls

Cheapest input is not cheapest overall: weigh `output_usd_per_1m` and cached/batch meters by your traffic. Capability statuses are per model version; offerings of the same version share them. A missing benchmark row means unknown, not failed. Leaderboard editions are snapshots at a knowledge head; recompute from L1 when the head has moved.
