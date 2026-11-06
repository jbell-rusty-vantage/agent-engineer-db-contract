---
id: "rel:retrieval.retrieval_chunk"
kind: table
schema: retrieval
name: retrieval_chunk
domain: retrieval
aliases: [chunk]
tokens: [retrieval, retrieval_chunk, retrieval.retrieval_chunk, id, tenant_id, chunk_set_id, ordinal, parent_chunk_id, source_text, contextual_prefix, embedding_text, source_text_sha256, contextual_prefix_sha256, embedding_text_sha256, source_token_count, embedding_token_count, retrieval_role, language, promotion_state, lifecycle, created_at]
summary: Chunk produced by a chunking procedure; spans point into document nodes.
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"retrieval_chunk\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.retrieval_chunk

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Chunk produced by a chunking procedure; spans point into document nodes.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, chunk_set_id, ordinal); unique (tenant_id, id) |
| 3 | `chunk_set_id` | `uuid` | no | — | unique (tenant_id, chunk_set_id, ordinal); _curated:_ Parent set from the chunking procedure version. |
| 4 | `ordinal` | `integer` | no | — | unique (tenant_id, chunk_set_id, ordinal) |
| 5 | `parent_chunk_id` | `uuid` | yes | — | — |
| 6 | `source_text` | `text` | no | — | — |
| 7 | `contextual_prefix` | `text` | no | `''::text` | — |
| 8 | `embedding_text` | `text` | no | — | — |
| 9 | `source_text_sha256` | `text` | no | — | — |
| 10 | `contextual_prefix_sha256` | `text` | no | — | — |
| 11 | `embedding_text_sha256` | `text` | no | — | — |
| 12 | `source_token_count` | `integer` | no | — | — |
| 13 | `embedding_token_count` | `integer` | no | — | — |
| 14 | `retrieval_role` | `text` | no | — | — |
| 15 | `language` | `text` | yes | — | — |
| 16 | `promotion_state` | `text` | no | `'candidate'::text` | — |
| 17 | `lifecycle` | `text` | no | `'active'::text` | — |
| 18 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, chunk_set_id, ordinal)
- unique (tenant_id, id)
- check `retrieval_chunk_check`: `((parent_chunk_id IS NULL) OR (parent_chunk_id <> id))`
- check `retrieval_chunk_contextual_prefix_sha256_check`: `(contextual_prefix_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `retrieval_chunk_embedding_text_sha256_check`: `(embedding_text_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `retrieval_chunk_embedding_token_count_check`: `(embedding_token_count >= 0)`
- check `retrieval_chunk_ordinal_check`: `(ordinal >= 0)`
- check `retrieval_chunk_source_text_sha256_check`: `(source_text_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `retrieval_chunk_source_token_count_check`: `(source_token_count >= 0)`

## Relationships

Outbound: `tenant_id,chunk_set_id` → [`retrieval.chunk_set`](chunk_set.md)`.tenant_id,id` on delete restrict; `tenant_id,parent_chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.chunk_claim_link`](chunk_claim_link.md).chunk_id, [`retrieval.chunk_edge`](chunk_edge.md).from_chunk_id|to_chunk_id, [`retrieval.chunk_entity_mention`](chunk_entity_mention.md).chunk_id, [`retrieval.chunk_relationship_evidence`](chunk_relationship_evidence.md).chunk_id, [`retrieval.chunk_span`](chunk_span.md).chunk_id, [`retrieval.projection_target`](projection_target.md).chunk_id, [`retrieval.retrieval_chunk`](retrieval_chunk.md).parent_chunk_id, [`retrieval.search_projection_chunk_support`](search_projection_chunk_support.md).chunk_id, [`retrieval.vector_item`](vector_item.md).retrieval_chunk_id.
Polymorphic target of: [`retrieval.projection_target`](projection_target.md) (check constraint projection_target_check).

## Indexes

`retrieval_chunk_set_idx`; `retrieval_chunk_tenant_id_chunk_set_id_ordinal_key` unique; `retrieval_chunk_tenant_id_id_key` unique

## Triggers

- `retrieval_chunk_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["retrieval"]["Tables"]["retrieval_chunk"]["Insert"]`; row: `Database["retrieval"]["Tables"]["retrieval_chunk"]["Row"]`; update: `Database["retrieval"]["Tables"]["retrieval_chunk"]["Update"]`

## Examples

Packet members may cite chunks

```bash
knowledge db query retrieval.evidence_packet --param packet_id=0192c000-0000-7000-8000-000000000001
```
summary_evidence expands summaries to chunk_id plus locator_id.

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
