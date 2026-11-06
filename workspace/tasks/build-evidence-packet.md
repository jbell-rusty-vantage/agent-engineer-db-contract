---
id: "task:build-evidence-packet"
kind: task
domains: [retrieval, evidence]
queries: [retrieval.hybrid_search, retrieval.evidence_packet, evidence.sources_by_domain]
aliases: [packet, citations]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Build an evidence packet for a question

Domains: [`retrieval`](../domains/retrieval.md), [`evidence`](../domains/evidence.md). Queries: [`q:retrieval.hybrid_search`](../queries/README.md), [`q:retrieval.evidence_packet`](../queries/README.md), [`q:evidence.sources_by_domain`](../queries/README.md).

## Navigation

`domains/retrieval.md` → `q:retrieval.hybrid_search` → `q:retrieval.evidence_packet`

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "packet-openai-pricing",
  "operations": [
    {
      "opId": "search",
      "kind": "retrieval",
      "query": "retrieval.hybrid_search",
      "params": { "query_text": "OpenAI API pricing 2026", "vector_space_version_id": "0192b100-0000-7000-8000-000000000001" },
      "limit": 20
    },
    { "opId": "packet", "kind": "named_query", "query": "retrieval.evidence_packet", "params": { "packet_id": "0192c000-0000-7000-8000-000000000001" } }
  ]
}
```

## Expected shape

Hybrid search rows: vector_item_id, search_projection_id, search_text, source_kind, fused_score, channel_scores. Packet JSON: packet plus members with optional start_ms/end_ms from `content.document_node`.

## Pitfalls

Hybrid search needs a published space version and an executor-computed embedding (`execute: false` in the catalog). Agents pass text only. Unpublished spaces raise insufficient_privilege.
