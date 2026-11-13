---
id: "task:build-evidence-packet"
kind: task
lens: corpus
domains: [retrieval, evidence, content]
queries: [retrieval.search_unified, retrieval.evidence_packet, evidence.sources_by_domain, content.document_units]
aliases: [packet, citations]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# Build an evidence packet for a question

Domains: [`retrieval`](../domains/retrieval.md), [`evidence`](../domains/evidence.md), [`content`](../domains/content.md). Queries: [`q:retrieval.search_unified`](../queries/README.md), [`q:retrieval.evidence_packet`](../queries/README.md), [`q:evidence.sources_by_domain`](../queries/README.md), [`q:content.document_units`](../queries/README.md).

## Navigation

`domains/retrieval.md` → `q:retrieval.search_unified` → `q:retrieval.evidence_packet`

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "packet-openai-pricing",
  "operations": [
    { "opId": "search", "kind": "named_query", "query": "retrieval.search_unified", "params": { "query": "OpenAI API pricing 2026", "lenses": ["corpus", "evidence"], "document_types": ["pricing_page"], "limit": 20 } },
    { "opId": "units", "kind": "named_query", "query": "content.document_units", "params": { "document_id": "$search.rows[0].document_id", "unit_kinds": ["price_row"] } },
    { "opId": "packet", "kind": "named_query", "query": "retrieval.evidence_packet", "params": { "packet_id": "0192c000-0000-7000-8000-000000000001" } }
  ]
}
```

## Expected shape

Search rows: `vector_item_id`, `lens`, `source_tier`, `unit_kind`, `document_id`, `target_kind`, `snippet`, `fused_score`, `channel_scores`. Units: the typed rows (`logical_key`, `attributes`) you can cite as locators. Packet JSON: packet plus members (verified claims, guidance items, source-faithful representations) with optional start_ms/end_ms from `content.document_node`.

## Pitfalls

Without an embedding `search_unified` is lexical; the executor adds the ANN channel when it embeds. Packets are built by retrieval runs, not by this read; pass an existing `packet_id`. A snippet is not a citation — cite the unit (`node_id`) or a locator.
