---
id: "rel:retrieval.vector_store_ingestion_checkpoint"
kind: table
schema: retrieval
name: vector_store_ingestion_checkpoint
domain: retrieval
aliases: []
tokens: [retrieval, vector_store_ingestion_checkpoint, retrieval.vector_store_ingestion_checkpoint, id, tenant_id, ingestion_run_id, stage, evidence_sha256, evidence, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_store_ingestion_checkpoint\"][\"Row\"]"
defined_in: ["20260904014000_vector_store_ingestion_evidence.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.vector_store_ingestion_checkpoint

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, ingestion_run_id, stage); unique (tenant_id, id) |
| 3 | `ingestion_run_id` | `uuid` | no | — | unique (tenant_id, ingestion_run_id, stage) |
| 4 | `stage` | `text` | no | — | unique (tenant_id, ingestion_run_id, stage) |
| 5 | `evidence_sha256` | `text` | no | — | — |
| 6 | `evidence` | `jsonb` | no | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, ingestion_run_id, stage)
- unique (tenant_id, id)
- check `vector_store_ingestion_checkpoint_evidence_sha256_check`: `(evidence_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `vector_store_ingestion_checkpoint_stage_check`: `(stage = ANY (ARRAY['prepared'::text, 'embedded'::text, 'indexed'::text]))`

## Relationships

Outbound: `tenant_id,ingestion_run_id` → [`retrieval.vector_store_ingestion_run`](vector_store_ingestion_run.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`vector_store_ingestion_checkp_tenant_id_ingestion_run_id_st_key` unique; `vector_store_ingestion_checkpoint_tenant_id_id_key` unique

## Triggers

- `vector_store_ingestion_checkpoint_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["retrieval"]["Tables"]["vector_store_ingestion_checkpoint"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_store_ingestion_checkpoint"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_store_ingestion_checkpoint"]["Update"]`

Defined in: `20260904014000_vector_store_ingestion_evidence.sql`.
