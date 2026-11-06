---
id: "task:run-hybrid-search"
kind: task
domains: [retrieval]
queries: [retrieval.hybrid_search]
aliases: [search, rrf, vector]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Run a hybrid search

Domains: [`retrieval`](../domains/retrieval.md). Queries: [`q:retrieval.hybrid_search`](../queries/README.md).

## Navigation

`domains/retrieval.md` → `q:retrieval.hybrid_search`

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "search-pricing",
  "operations": [
    {
      "opId": "kb",
      "kind": "retrieval",
      "query": "retrieval.hybrid_search",
      "params": {
        "query_text": "OpenAI API pricing 2026",
        "vector_space_version_id": "0192b100-0000-7000-8000-000000000001",
        "filters": {}
      },
      "limit": 20
    }
  ]
}
```

## Expected shape

Up to `limit` rows fused by RRF from exact, fts, trigram, and ann channels. `channel_scores` shows per-channel rank and score.

## Pitfalls

The catalog entry is `execute: false` because it needs a halfvec embedding. Query text must be 1–4096 characters. Hard filters may only use language, visibility, classification, source_kind, authority_level, freshness_after.
