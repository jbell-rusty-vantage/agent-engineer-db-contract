---
id: "rel:retrieval.vector_store"
kind: table
schema: retrieval
name: vector_store
domain: retrieval
aliases: []
tokens: [retrieval, vector_store, retrieval.vector_store, id, tenant_id, owner_identity, store_class, slug, name, purpose, visibility, lifecycle, quota_profile, retention_policy, deletion_policy, created_by_attempt_id, supersedes_id, created_at, created_by_operation_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_store\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.vector_store

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, created_by_operation_id); unique (tenant_id, id); unique (tenant_id, slug) |
| 3 | `owner_identity` | `text` | no | — | — |
| 4 | `store_class` | `text` | no | — | — |
| 5 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 6 | `name` | `text` | no | — | — |
| 7 | `purpose` | `text` | no | — | — |
| 8 | `visibility` | `text` | no | — | — |
| 9 | `lifecycle` | `text` | no | `'active'::text` | — |
| 10 | `quota_profile` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `retention_policy` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `deletion_policy` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `created_by_attempt_id` | `uuid` | yes | — | — |
| 14 | `supersedes_id` | `uuid` | yes | — | — |
| 15 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 16 | `created_by_operation_id` | `uuid` | yes | — | unique (tenant_id, created_by_operation_id) |

## Constraints

- PK (id)
- unique (tenant_id, created_by_operation_id)
- unique (tenant_id, id)
- unique (tenant_id, slug)
- check `vector_store_check`: `((supersedes_id IS NULL) OR (supersedes_id <> id))`
- check `vector_store_lifecycle_check`: `(lifecycle = ANY (ARRAY['active'::text, 'suspended'::text, 'superseded'::text, 'deleted'::text]))`
- check `vector_store_store_class_check`: `(store_class = ANY (ARRAY['official'::text, 'exploratory'::text, 'user_managed'::text]))`

## Relationships

Outbound: `tenant_id,created_by_operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,created_by_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id` on delete restrict; `tenant_id,supersedes_id` → [`retrieval.vector_store`](vector_store.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.vector_store`](vector_store.md).supersedes_id, [`retrieval.vector_store_document`](vector_store_document.md).vector_store_id, [`retrieval.vector_store_ingestion_run`](vector_store_ingestion_run.md).vector_store_id, [`retrieval.vector_store_lifecycle_event`](vector_store_lifecycle_event.md).vector_store_id, [`retrieval.vector_store_space`](vector_store_space.md).vector_store_id.

## Indexes

`vector_store_created_by_operation_uq` unique; `vector_store_tenant_id_id_key` unique; `vector_store_tenant_id_slug_key` unique

## Triggers

- `predecessor_direction` → [`util.validate_predecessor`](../../functions/util/validate_predecessor.md)
- `vector_store_configuration_immutable` → [`retrieval.reject_vector_store_identity_mutation`](../../functions/retrieval/reject_vector_store_identity_mutation.md)
- `vector_store_delete_forbidden` → [`retrieval.reject_vector_store_identity_mutation`](../../functions/retrieval/reject_vector_store_identity_mutation.md)
- `vector_store_identity_immutable` → [`retrieval.reject_vector_store_identity_mutation`](../../functions/retrieval/reject_vector_store_identity_mutation.md)
- `vector_store_lifecycle_guard` → [`retrieval.guard_vector_store_lifecycle_transition`](../../functions/retrieval/guard_vector_store_lifecycle_transition.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`retrieval.transition_vector_store_lifecycle`](../../functions/retrieval/transition_vector_store_lifecycle.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_store"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_store"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_store"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
