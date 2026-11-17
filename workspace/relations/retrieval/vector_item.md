---
id: "rel:retrieval.vector_item"
kind: table
schema: retrieval
name: vector_item
domain: retrieval
lens: corpus
aliases: [vector item, searchable item]
tokens: [retrieval, vector_item, retrieval.vector_item, id, tenant_id, space_version_id, source_version_hash, content_sha256, chunk_index, backend_location, generation_run_id, receipt_id, verification_state, superseded_by_id, created_at, search_projection_id, embedding_item_id, language, visibility, classification, lifecycle, authority_level, freshness_at, search_text, search_tsv, retrieval_chunk_id, projection_target_id, entity_id, entity_kind, secondary_entity_ids, document_type_code, content_kind, valid_during, knowledge_seq, assurance_rank, start_ms, end_ms, lens, source_tier, workspace_id, unit_kind, document_id, document_version_id, source_role_code, observed_at, search_tsv_en]
summary: "One searchable item in one space version with lens, source tier and facets; the one thing api.search_unified ranks."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_item\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# retrieval.vector_item

table in domain `retrieval`, lens `corpus` — One searchable item in one vector space version: the text, its lens/tier/facets (document kind, unit kind, entity, time, assurance) and lifecycle. Embeddings live in vector_item_embedding_1536 partitions..

> curated (model_assisted, unreviewed) — One searchable item in one space version with lens, source tier and facets; the one thing api.search_unified ranks.

## Columns

`id` uuid not null, `tenant_id` uuid not null, `space_version_id` uuid not null, `source_version_hash` text, `content_sha256` text not null, `chunk_index` integer not null, `backend_location` text, `generation_run_id` uuid, `receipt_id` uuid, `verification_state` text not null, `superseded_by_id` uuid, `created_at` timestamp with time zone not null, `search_projection_id` uuid, `embedding_item_id` uuid, `language` text, `visibility` text, `classification` text, `lifecycle` text not null, `authority_level` text, `freshness_at` timestamp with time zone, `search_text` text, `search_tsv` tsvector, `retrieval_chunk_id` uuid, `projection_target_id` uuid, `entity_id` uuid, `entity_kind` text, `secondary_entity_ids` uuid[] not null, `document_type_code` text, `content_kind` text not null, `valid_during` tstzrange, `knowledge_seq` bigint, `assurance_rank` smallint, `start_ms` integer, `end_ms` integer, `lens` text not null, `source_tier` smallint, `workspace_id` uuid, `unit_kind` text, `document_id` uuid, `document_version_id` uuid, `source_role_code` text, `observed_at` timestamp with time zone, `search_tsv_en` tsvector

Full column table: [details](vector_item.details.md).

## Constraints

- PK (id)
- unique (tenant_id, id)
- 6 check constraints; see [details](vector_item.details.md)

## Relationships

13 outbound and 6 inbound foreign keys; full list in [details](vector_item.details.md).

## Indexes

13 indexes; see [details](vector_item.details.md).

## Triggers

2 triggers; see [details](vector_item.details.md).

## Row-level security

Enabled; 2 policies in [details](vector_item.details.md).

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:retrieval.hybrid_search`, `q:retrieval.search_unified`.
- Exposed through: [`api.api_symbols`](../api/api_symbols.md).
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`retrieval.index_text_item`](../../functions/retrieval/index_text_item.md), [`retrieval.promote_revision_passages`](../../functions/retrieval/promote_revision_passages.md), [`retrieval.retire_deterministic_digest_items`](../../functions/retrieval/retire_deterministic_digest_items.md), [`retrieval.retire_items_for_passages`](../../functions/retrieval/retire_items_for_passages.md), [`retrieval.supersede_duplicate_items`](../../functions/retrieval/supersede_duplicate_items.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_item"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_item"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_item"]["Update"]`

## Examples

Scoped lexical search

```bash
knowledge db query retrieval.search_unified --param lenses=["corpus","ours"] --param limit=20 --param query=context engineering
```
Result column vector_item_id points here; lens and source_tier are echoed per row.

Defined in: `20260826001000_retrieval.sql`.
