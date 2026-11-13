---
id: "task:run-hybrid-search"
kind: task
lens: corpus
domains: [retrieval]
queries: [retrieval.search_unified, retrieval.hybrid_search]
aliases: [search, rrf, vector, semantic search]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# Run a scoped search over the one retrieval stack

Domains: [`retrieval`](../domains/retrieval.md). Queries: [`q:retrieval.search_unified`](../queries/README.md), [`q:retrieval.hybrid_search`](../queries/README.md).

## Navigation

`domains/retrieval.md` → `q:retrieval.search_unified`

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "search-pricing",
  "operations": [
    { "opId": "kb", "kind": "named_query", "query": "retrieval.search_unified", "params": { "query": "OpenAI API pricing 2026", "lenses": ["corpus"], "tiers": [0, 1, 2], "document_types": ["pricing_page", "official_docs_page"], "limit": 20 } }
  ]
}
```

`q:retrieval.hybrid_search` is the older per-space-version entry; it needs an executor-computed embedding (`execute: false`).

## Expected shape

Up to `limit` rows fused by RRF from full-text, trigram and (with an embedding) ANN channels, each with `lens`, `source_tier`, facets and `channel_scores`.

## Pitfalls

Resolve the scope first: lens, tier, space, document type, unit kind, entity, as-of, workspace. Tier is a mild boost, never a truth claim. Query text must be 1–4096 characters. Private items need `workspace_ids`.
