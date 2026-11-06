---
id: "rel:retrieval.embedding_item"
kind: table
schema: retrieval
name: embedding_item
domain: retrieval
aliases: []
tokens: [retrieval, embedding_item, retrieval.embedding_item, id, tenant_id, embedding_run_id, search_projection_id, input_sha256, output_sha256, dimensions, cache_key, status, provider_metadata, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"embedding_item\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.embedding_item

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, embedding_run_id, search_projection_id); unique (tenant_id, id) |
| 3 | `embedding_run_id` | `uuid` | no | — | unique (tenant_id, embedding_run_id, search_projection_id) |
| 4 | `search_projection_id` | `uuid` | no | — | unique (tenant_id, embedding_run_id, search_projection_id) |
| 5 | `input_sha256` | `text` | no | — | — |
| 6 | `output_sha256` | `text` | no | — | — |
| 7 | `dimensions` | `integer` | no | — | — |
| 8 | `cache_key` | `text` | no | — | — |
| 9 | `status` | `text` | no | — | — |
| 10 | `provider_metadata` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, embedding_run_id, search_projection_id)
- unique (tenant_id, id)
- check `embedding_item_input_sha256_check`: `(input_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `embedding_item_output_sha256_check`: `(output_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,embedding_run_id` → [`retrieval.embedding_run`](embedding_run.md)`.tenant_id,id` on delete restrict; `tenant_id,search_projection_id` → [`retrieval.search_projection`](search_projection.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.vector_item`](vector_item.md).embedding_item_id.

## Indexes

`embedding_item_cache_idx` where `(status = 'succeeded'::text)`; `embedding_item_tenant_id_embedding_run_id_search_projection_key` unique; `embedding_item_tenant_id_id_key` unique

## Triggers

- `embedding_item_dimensions` → [`retrieval.validate_embedding_item`](../../functions/retrieval/validate_embedding_item.md)
- `embedding_item_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["retrieval"]["Tables"]["embedding_item"]["Insert"]`; row: `Database["retrieval"]["Tables"]["embedding_item"]["Row"]`; update: `Database["retrieval"]["Tables"]["embedding_item"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
