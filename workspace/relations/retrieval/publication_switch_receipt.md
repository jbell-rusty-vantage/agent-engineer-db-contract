---
id: "rel:retrieval.publication_switch_receipt"
kind: table
schema: retrieval
name: publication_switch_receipt
domain: retrieval
aliases: []
tokens: [retrieval, publication_switch_receipt, retrieval.publication_switch_receipt, id, tenant_id, vector_store_space_id, from_publication_id, to_publication_id, action, reason, guarded_sha256, actor_identity, idempotency_key, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"publication_switch_receipt\"][\"Row\"]"
defined_in: ["20260903010400_atomic_publication_and_hybrid_retrieval.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.publication_switch_receipt

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, idempotency_key) |
| 3 | `vector_store_space_id` | `uuid` | no | — | — |
| 4 | `from_publication_id` | `uuid` | yes | — | — |
| 5 | `to_publication_id` | `uuid` | no | — | — |
| 6 | `action` | `text` | no | — | — |
| 7 | `reason` | `text` | no | — | — |
| 8 | `guarded_sha256` | `text` | no | — | — |
| 9 | `actor_identity` | `text` | no | — | — |
| 10 | `idempotency_key` | `text` | no | — | unique (tenant_id, idempotency_key) |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, idempotency_key)
- check `publication_switch_receipt_action_check`: `(action = ANY (ARRAY['publish'::text, 'rollback'::text]))`
- check `publication_switch_receipt_guarded_sha256_check`: `(guarded_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `publication_switch_receipt_reason_check`: `(length(btrim(reason)) > 0)`

## Relationships

Outbound: `tenant_id,from_publication_id` → [`retrieval.space_publication`](space_publication.md)`.tenant_id,id` on delete restrict; `tenant_id,to_publication_id` → [`retrieval.space_publication`](space_publication.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_store_space_id` → [`retrieval.vector_store_space`](vector_store_space.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.authorized_publication_execution`](authorized_publication_execution.md).switch_receipt_id.

## Indexes

`publication_switch_receipt_tenant_id_id_key` unique; `publication_switch_receipt_tenant_id_idempotency_key_key` unique

## Triggers

- `publication_switch_receipt_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.
- Via functions (best effort): [`retrieval.publish_vector_space`](../../functions/retrieval/publish_vector_space.md), [`retrieval.rollback_vector_space`](../../functions/retrieval/rollback_vector_space.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["publication_switch_receipt"]["Insert"]`; row: `Database["retrieval"]["Tables"]["publication_switch_receipt"]["Row"]`; update: `Database["retrieval"]["Tables"]["publication_switch_receipt"]["Update"]`

Defined in: `20260903010400_atomic_publication_and_hybrid_retrieval.sql`.
