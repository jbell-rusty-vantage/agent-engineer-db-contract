---
id: "rel:retrieval.vector_store_ingestion_run"
kind: table
schema: retrieval
name: vector_store_ingestion_run
domain: retrieval
aliases: []
tokens: [retrieval, vector_store_ingestion_run, retrieval.vector_store_ingestion_run, id, tenant_id, operation_id, vector_store_id, actor_identity, request_sha256, manifest, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_store_ingestion_run\"][\"Row\"]"
defined_in: ["20260904014000_vector_store_ingestion_evidence.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.vector_store_ingestion_run

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, operation_id) |
| 3 | `operation_id` | `uuid` | no | — | unique (tenant_id, operation_id) |
| 4 | `vector_store_id` | `uuid` | no | — | — |
| 5 | `actor_identity` | `text` | no | — | — |
| 6 | `request_sha256` | `text` | no | — | — |
| 7 | `manifest` | `jsonb` | no | — | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, operation_id)
- check `vector_store_ingestion_run_request_sha256_check`: `(request_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_store_id` → [`retrieval.vector_store`](vector_store.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.vector_store_ingestion_checkpoint`](vector_store_ingestion_checkpoint.md).ingestion_run_id.

## Indexes

`vector_store_ingestion_run_tenant_id_id_key` unique; `vector_store_ingestion_run_tenant_id_operation_id_key` unique

## Triggers

- `vector_store_ingestion_active_parent` → [`retrieval.require_active_vector_store_reference`](../../functions/retrieval/require_active_vector_store_reference.md)
- `vector_store_ingestion_operation_guard` → [`retrieval.validate_vector_store_ingestion_operation`](../../functions/retrieval/validate_vector_store_ingestion_operation.md)
- `vector_store_ingestion_run_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled and forced.
- `bounded_role_access` (ALL) for `control_plane`, `executor_service`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_store_ingestion_run"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_store_ingestion_run"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_store_ingestion_run"]["Update"]`

Defined in: `20260904014000_vector_store_ingestion_evidence.sql`.
