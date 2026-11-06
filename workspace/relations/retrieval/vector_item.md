---
id: "rel:retrieval.vector_item"
kind: table
schema: retrieval
name: vector_item
domain: retrieval
aliases: [vector item]
tokens: [retrieval, vector_item, retrieval.vector_item, id, tenant_id, space_version_id, source_version_hash, content_sha256, chunk_index, backend_location, generation_run_id, receipt_id, verification_state, superseded_by_id, created_at, search_projection_id, embedding_item_id, language, visibility, classification, lifecycle, authority_level, freshness_at, search_text, search_tsv, retrieval_chunk_id, projection_target_id, entity_id, entity_kind, secondary_entity_ids, document_type_code, content_kind, valid_during, knowledge_seq, assurance_rank, start_ms, end_ms]
summary: Searchable item in a space version; child halfvec partitions are not a direct read path.
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_item\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.vector_item

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Searchable item in a space version; child halfvec partitions are not a direct read path.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `space_version_id` | `uuid` | no | — | FK → [`retrieval.vector_space_version`](vector_space_version.md).id |
| 18 | `source_version_hash` | `text` | yes | — | — |
| 19 | `content_sha256` | `text` | no | — | — |
| 20 | `chunk_index` | `integer` | no | `0` | — |
| 21 | `backend_location` | `text` | yes | — | — |
| 23 | `generation_run_id` | `uuid` | yes | — | FK → [`evaluation.eval_run`](../evaluation/eval_run.md).id |
| 24 | `receipt_id` | `uuid` | yes | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 25 | `verification_state` | `text` | no | `'pending'::text` | — |
| 26 | `superseded_by_id` | `uuid` | yes | — | FK → [`retrieval.vector_item`](vector_item.md).id |
| 27 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 28 | `search_projection_id` | `uuid` | yes | — | — |
| 29 | `embedding_item_id` | `uuid` | yes | — | — |
| 30 | `language` | `text` | yes | — | — |
| 31 | `visibility` | `text` | yes | — | — |
| 32 | `classification` | `text` | yes | — | — |
| 33 | `lifecycle` | `text` | no | `'active'::text` | _curated:_ Only active items are searchable. |
| 34 | `authority_level` | `text` | yes | — | — |
| 35 | `freshness_at` | `timestamp with time zone` | yes | — | — |
| 36 | `search_text` | `text` | yes | — | — |
| 37 | `search_tsv` | `tsvector` | yes | — | generated: `to_tsvector('simple'::regconfig, COALESCE(search_text, ''::text))` |
| 38 | `retrieval_chunk_id` | `uuid` | yes | — | — |
| 40 | `projection_target_id` | `uuid` | yes | — | FK → [`retrieval.projection_target`](projection_target.md).id |
| 41 | `entity_id` | `uuid` | yes | — | — |
| 42 | `entity_kind` | `text` | yes | — | — |
| 43 | `secondary_entity_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 44 | `document_type_code` | `text` | yes | — | FK → [`content.document_type`](../content/document_type.md).code |
| 45 | `content_kind` | `text` | no | `'chunk'::text` | — |
| 46 | `valid_during` | `tstzrange` | yes | — | — |
| 47 | `knowledge_seq` | `bigint` | yes | — | _curated:_ Upper bound filter for as-of-knowledge reads. |
| 48 | `assurance_rank` | `smallint` | yes | — | — |
| 49 | `start_ms` | `integer` | yes | — | — |
| 50 | `end_ms` | `integer` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `vector_item_content_kind_check`: `(content_kind = ANY (ARRAY['chunk'::text, 'summary'::text, 'claim'::text, 'record'::text, 'profile'::text, 'timeline'::text, 'measurement':…`
- check `vector_item_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `vector_item_verification_state_check`: `(verification_state = ANY (ARRAY['pending'::text, 'verified'::text, 'failed'::text]))`

## Relationships

12 outbound and 6 inbound foreign keys; full list in [details](vector_item.details.md).

## Indexes

9 indexes; see [details](vector_item.details.md).

## Triggers

2 triggers; see [details](vector_item.details.md).

## Row-level security

Enabled; 1 policies in [details](vector_item.details.md).

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:retrieval.hybrid_search`.
- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_item"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_item"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_item"]["Update"]`

## Examples

Hybrid search ranks vector items

```bash
knowledge db query retrieval.hybrid_search --param filters={} --param limit=20 --param query_text=OpenAI API pricing 2026 --param vector_space_version_id=0192b100-0000-7000-8000-000000000001
```
Result column vector_item_id points here.

Defined in: `20260826001000_retrieval.sql`.
