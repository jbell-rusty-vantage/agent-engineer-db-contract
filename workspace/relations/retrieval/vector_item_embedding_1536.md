---
id: "rel:retrieval.vector_item_embedding_1536"
kind: partitioned_table
schema: retrieval
name: vector_item_embedding_1536
domain: retrieval
aliases: []
tokens: [retrieval, vector_item_embedding_1536, retrieval.vector_item_embedding_1536, tenant_id, vector_space_key, vector_space_version_id, vector_item_id, embedding, embedding_sha256, created_at, physical_embedding_sha256]
summary: Canonical fixed-dimension pgvector storage; legacy vector_item.embedding is compatibility-only.
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_item_embedding_1536\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.vector_item_embedding_1536

partitioned table in domain `retrieval` — Canonical fixed-dimension pgvector storage; legacy vector_item.embedding is compatibility-only..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | — |
| 2 | `vector_space_key` | `text` | no | — | PK |
| 3 | `vector_space_version_id` | `uuid` | no | — | — |
| 4 | `vector_item_id` | `uuid` | no | — | PK |
| 5 | `embedding` | `halfvec(1536)` | no | — | — |
| 6 | `embedding_sha256` | `text` | no | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `physical_embedding_sha256` | `text` | yes | — | generated: `encode(digest((embedding)::text, 'sha256'::text), 'hex'::text)` |

## Constraints

- PK (vector_space_key, vector_item_id)
- check `vector_item_embedding_1536_embedding_sha256_check`: `(embedding_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,vector_item_id` → [`retrieval.vector_item`](vector_item.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_space_version_id` → [`retrieval.vector_space_version`](vector_space_version.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:retrieval.hybrid_search`.
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## Partitions

list by `LIST (vector_space_key)`; 11 children: `retrieval.vector_item_embedding_1536_benchmark_intelligence` FOR VALUES IN ('benchmark_intelligence'), `retrieval.vector_item_embedding_1536_document_summaries` FOR VALUES IN ('document_summaries'), `retrieval.vector_item_embedding_1536_engineering_claims` FOR VALUES IN ('engineering_claims'), `retrieval.vector_item_embedding_1536_entity_profiles` FOR VALUES IN ('entity_profiles'), `retrieval.vector_item_embedding_1536_entity_timeline` FOR VALUES IN ('entity_timeline'), `retrieval.vector_item_embedding_1536_implementation_examples` FOR VALUES IN ('implementation_examples'), `retrieval.vector_item_embedding_1536_market_intelligence` FOR VALUES IN ('market_intelligence'), `retrieval.vector_item_embedding_1536_model_capabilities` FOR VALUES IN ('model_capabilities'), `retrieval.vector_item_embedding_1536_paper_case_study_knowledge` FOR VALUES IN ('paper_case_study_knowledge'), `retrieval.vector_item_embedding_1536_source_native_sections` FOR VALUES IN ('source_native_sections'), `retrieval.vector_item_embedding_1536_tool_capabilities` FOR VALUES IN ('tool_capabilities').

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_item_embedding_1536"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_item_embedding_1536"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_item_embedding_1536"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
