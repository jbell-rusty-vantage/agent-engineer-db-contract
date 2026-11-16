---
id: "dom:retrieval"
kind: domain
lens: corpus
schemas: [retrieval]
aliases: [search, embeddings, packets, publication, lens, tier, spaces]
relations: [retrieval.vector_item, retrieval.projection_target, retrieval.search_projection, retrieval.vector_space, retrieval.vector_space_version, retrieval.space_publication, retrieval.vector_store_space, retrieval.retrieval_chunk, retrieval.chunk_span, retrieval.evidence_packet, retrieval.packet_member, retrieval.retrieval_run]
functions: [api.evidence_packet, api.hybrid_knowledge_search_1536, api.search_knowledge, api.search_unified, retrieval.index_text_item, retrieval.retire_items_for_passages]
tasks: [build-evidence-packet, modules-covering-concept, run-hybrid-search, search-my-notes, talks-on-topic]
summary: "One retrieval stack: every searchable text is a vector item with lens, source tier and facets; api.search_unified scopes then fuses."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# Retrieval (one stack, lens and tier)

One retrieval stack: every searchable text is a vector item with lens, source tier and facets; api.search_unified scopes then fuses.

> curated (model_assisted, unreviewed) — Build 08 collapsed retrieval into one stack. `retrieval.vector_item` is the searchable
> item: `search_text`, `lens` (corpus | ours | private | evidence), `source_tier` (T0 verified
> assertions, T1 our content, T2 primary corpus, T3 third-party, T4 live web — a filter and a
> mild boost, never a truth claim), and facets `document_type_code`, `unit_kind`,
> `entity_id`, `document_id`, `source_role_code`, `valid_during`, `knowledge_seq`,
> `assurance_rank`, `start_ms`/`end_ms`, `workspace_id` for private items. Embeddings live in
> `retrieval.vector_item_embedding_1536` partitions.
> 
> `retrieval.projection_target` says what an item is about — exactly one of entity card,
> guidance item (`record_id`), chunk, claim, summary, typed unit (`document_node_id`), digest,
> one of our authored revisions, or a private passage. `retrieval.index_text_item` is the one
> way a text becomes searchable (idempotent on identical text). Spaces (`retrieval.vector_space`
> slugs units, digests, entity_cards, assertions, own_content, learner_notes, knowledge_text, …)
> are facets, not separate engines; publication (`retrieval.space_publication`) still gates
> what `app_reader` may read.
> 
> `q:retrieval.search_unified` (`api.search_unified`) is L3: resolve the scope first (lenses,
> tiers, space slugs, document types, unit kinds, entity ids, as-of, workspace ids for
> private), then fuse english full-text, trigram and ANN (when the executor supplies an
> embedding) with RRF. Private items are returned only for the workspaces passed in; the
> product `search` operation passes the caller's workspaces. Because the scope comes from the
> caller, `api.search_unified` is executable by trusted roles only (D-82): not `anon`, not
> `authenticated`. A signed-in session searches with `api.search_knowledge`, the same stack
> restricted to the corpus and evidence lenses with no workspace parameter.
> `q:retrieval.hybrid_search` is the older per-space-version entry (needs an embedding,
> `execute: false`; not executable by `authenticated`).
> 
> Packets (`retrieval.evidence_packet`, `retrieval.packet_member`) assemble verified claims,
> guidance items and source-faithful representations with scores and locators for one
> question; `q:retrieval.evidence_packet` returns one with node timecodes. Agents never write
> embeddings; projection rebuilds are governed runtime operations. Trap: expecting
> `search_unified` to embed the query in-database — without an embedding it is lexical only.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`retrieval.vector_item`](../relations/retrieval/vector_item.md) | One searchable item in one space version with lens, source tier and facets; the one thing api.search_unified … | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`retrieval.projection_target`](../relations/retrieval/projection_target.md) | What a search projection is about — exactly one of entity, guidance item, chunk, claim, summary, typed unit, … | PK (id); unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id), (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`retrieval.search_projection`](../relations/retrieval/search_projection.md) | Derived text projection that a vector item points at. | PK (id); unique (tenant_id, id), (tenant_id, projection_target_id, projection_procedure_id, purpose, embedding_text_sha256); RLS | helpers only |
| [`retrieval.vector_space`](../relations/retrieval/vector_space.md) | Named embedding space (units, digests, entity_cards, assertions, own_content, learner_notes, knowledge_text, … | PK (id); unique (tenant_id, slug), (tenant_id, id); RLS | `executor_service` |
| [`retrieval.vector_space_version`](../relations/retrieval/vector_space_version.md) | Immutable version of a vector space, including dims and publication lifecycle. | PK (id); unique (tenant_id, id), (vector_space_id, version); RLS | `executor_service` |
| [`retrieval.space_publication`](../relations/retrieval/space_publication.md) | Published vector-space version that search may read. | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`retrieval.vector_store_space`](../relations/retrieval/vector_store_space.md) | table | PK (id); unique (tenant_id, id), (tenant_id, vector_store_id, vector_space_id); RLS | helpers only |
| [`retrieval.retrieval_chunk`](../relations/retrieval/retrieval_chunk.md) | table | PK (id); unique (tenant_id, chunk_set_id, ordinal), (tenant_id, id); RLS | helpers only |
| [`retrieval.chunk_span`](../relations/retrieval/chunk_span.md) | table | PK (tenant_id, chunk_id, ordinal); RLS | helpers only |
| [`retrieval.evidence_packet`](../relations/retrieval/evidence_packet.md) | Assembled evidence bundle for one question. | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`retrieval.packet_member`](../relations/retrieval/packet_member.md) | One member of an evidence packet — a verified claim, a guidance item or a source-faithful representation — wi… | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`retrieval.retrieval_run`](../relations/retrieval/retrieval_run.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |

## Functions

[`api.evidence_packet`](../functions/api/evidence_packet.md), [`api.hybrid_knowledge_search_1536`](../functions/api/hybrid_knowledge_search_1536.md), [`api.search_knowledge`](../functions/api/search_knowledge.md), [`api.search_unified`](../functions/api/search_unified.md), [`retrieval.index_text_item`](../functions/retrieval/index_text_item.md), [`retrieval.retire_items_for_passages`](../functions/retrieval/retire_items_for_passages.md)

## Named queries

[`q:retrieval.evidence_packet`](../queries/README.md), [`q:retrieval.hybrid_search`](../queries/README.md), [`q:retrieval.search_unified`](../queries/README.md)

## Tasks

[`build-evidence-packet`](../tasks/build-evidence-packet.md), [`modules-covering-concept`](../tasks/modules-covering-concept.md), [`run-hybrid-search`](../tasks/run-hybrid-search.md), [`search-my-notes`](../tasks/search-my-notes.md), [`talks-on-topic`](../tasks/talks-on-topic.md)

Schemas: [`retrieval`](../schemas/retrieval/README.md).
