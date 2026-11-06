---
id: "dom:retrieval"
kind: domain
schemas: [retrieval]
aliases: [search, embeddings, packets, publication]
relations: [retrieval.vector_space, retrieval.vector_space_version, retrieval.vector_store_space, retrieval.vector_item, retrieval.search_projection, retrieval.retrieval_chunk, retrieval.chunk_span, retrieval.evidence_packet, retrieval.packet_member, retrieval.space_publication, retrieval.projection_target, retrieval.retrieval_run]
functions: [api.evidence_packet, api.hybrid_knowledge_search_1536]
tasks: [build-evidence-packet, run-hybrid-search]
summary: "Published 1536-d spaces, hybrid search, and evidence packets."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Vector retrieval

Published 1536-d spaces, hybrid search, and evidence packets.

> curated (model_assisted, unreviewed) — Spaces (`retrieval.vector_space` slugs such as engineering_claims, entity_profiles,
> market_intelligence) have versions and store attachments
> (`retrieval.vector_store_space.active_space_version_id`). `retrieval.vector_item`
> rows are what hybrid search ranks; child halfvec partitions are not a direct read
> path for bounded roles. Publication (`retrieval.space_publication`, status published)
> is the gate: `api.hybrid_knowledge_search_1536` refuses unpublished versions.
> 
> `q:retrieval.hybrid_search` fuses exact, full-text, trigram, and ANN channels with
> RRF. The catalog entry needs a query embedding (`paramOrder` starts with `$embedding`,
> `execute: false`). Agents pass `query_text` and a `vector_space_version_id`; the
> executor embeds. Optional filters include entity ids, document types, content kinds,
> as-of time, knowledge_seq, min assurance, and publication id.
> 
> Chunks, spans, and search projections are the derived text. `q:retrieval.evidence_packet`
> returns one packet plus members, joining `content.document_node` timecodes when
> present. Projection rebuilds emit a projection.rebuilt event on the knowledge-service
> outbox. Agents never write embeddings.
> 
> Invariant: unpublished versions are invisible to `app_reader`. Trap: passing a
> `vector_space` id where a `retrieval.vector_space_version` id is required, or
> expecting `q:retrieval.hybrid_search` to embed the query in-database. Use
> `run-hybrid-search` for ranking and `build-evidence-packet` when you already have
> a packet id. Filters for entity ids, document types, as-of time, knowledge_seq,
> and min assurance live in the jsonb argument, not as extra SQL.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`retrieval.vector_space`](../relations/retrieval/vector_space.md) | Named embedding space (engineering_claims, entity_profiles, …). | PK (id); unique (tenant_id, slug), (tenant_id, id); RLS | `executor_service` |
| [`retrieval.vector_space_version`](../relations/retrieval/vector_space_version.md) | Immutable version of a vector space, including dims and publication lifecycle. | PK (id); unique (tenant_id, id), (vector_space_id, version); RLS | `executor_service` |
| [`retrieval.vector_store_space`](../relations/retrieval/vector_store_space.md) | Attaches a vector store to a space and names the active published version. | PK (id); unique (tenant_id, id), (tenant_id, vector_store_id, vector_space_id); RLS | helpers only |
| [`retrieval.vector_item`](../relations/retrieval/vector_item.md) | Searchable item in a space version; child halfvec partitions are not a direct read path. | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`retrieval.search_projection`](../relations/retrieval/search_projection.md) | Derived text projection that a vector item may point at. | PK (id); unique (tenant_id, id), (tenant_id, projection_target_id, projection_procedure_id, purpose, embedding_text_sha256); RLS | helpers only |
| [`retrieval.retrieval_chunk`](../relations/retrieval/retrieval_chunk.md) | Chunk produced by a chunking procedure; spans point into document nodes. | PK (id); unique (tenant_id, chunk_set_id, ordinal), (tenant_id, id); RLS | helpers only |
| [`retrieval.chunk_span`](../relations/retrieval/chunk_span.md) | Character offsets of a chunk inside a document node, optionally with a locator. | PK (tenant_id, chunk_id, ordinal); RLS | helpers only |
| [`retrieval.evidence_packet`](../relations/retrieval/evidence_packet.md) | Assembled evidence bundle for one question. | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`retrieval.packet_member`](../relations/retrieval/packet_member.md) | One member of an evidence packet, optionally tied to a document node. | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`retrieval.space_publication`](../relations/retrieval/space_publication.md) | Published vector-space version that hybrid search may read. | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`retrieval.projection_target`](../relations/retrieval/projection_target.md) | Five-way target a search projection may point at (entity, record, chunk, claim, summary). | PK (id); unique (tenant_id, id), (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id); RLS | `executor_service`, `pipeline_agent` |
| [`retrieval.retrieval_run`](../relations/retrieval/retrieval_run.md) | One executed retrieval plan; packets may record the run that built them. | PK (id); unique (tenant_id, id); RLS | `executor_service` |

## Functions

[`api.evidence_packet`](../functions/api/evidence_packet.md), [`api.hybrid_knowledge_search_1536`](../functions/api/hybrid_knowledge_search_1536.md)

## Named queries

[`q:retrieval.evidence_packet`](../queries/README.md), [`q:retrieval.hybrid_search`](../queries/README.md)

## Tasks

[`build-evidence-packet`](../tasks/build-evidence-packet.md), [`run-hybrid-search`](../tasks/run-hybrid-search.md)

Schemas: [`retrieval`](../schemas/retrieval/README.md).
