---
id: "rel:retrieval.authorized_publication_execution"
kind: table
schema: retrieval
name: authorized_publication_execution
domain: retrieval
aliases: []
tokens: [retrieval, authorized_publication_execution, retrieval.authorized_publication_execution, id, tenant_id, operation_id, switch_receipt_id, action, guarded_sha256, publisher_identity, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"authorized_publication_execution\"][\"Row\"]"
defined_in: ["20260904011000_governed_projection_embedding_publication.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.authorized_publication_execution

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, operation_id, switch_receipt_id); unique (tenant_id, id) |
| 3 | `operation_id` | `uuid` | no | — | unique (tenant_id, operation_id, switch_receipt_id) |
| 4 | `switch_receipt_id` | `uuid` | no | — | unique (tenant_id, operation_id, switch_receipt_id) |
| 5 | `action` | `text` | no | — | — |
| 6 | `guarded_sha256` | `text` | no | — | — |
| 7 | `publisher_identity` | `text` | no | — | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, operation_id, switch_receipt_id)
- unique (tenant_id, id)
- check `authorized_publication_execution_action_check`: `(action = ANY (ARRAY['publish'::text, 'rollback'::text]))`
- check `authorized_publication_execution_guarded_sha256_check`: `(guarded_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,switch_receipt_id` → [`retrieval.publication_switch_receipt`](publication_switch_receipt.md)`.tenant_id,id` on delete restrict; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`authorized_publication_execut_tenant_id_operation_id_switch_key` unique; `authorized_publication_execution_tenant_id_id_key` unique

## Triggers

- `authorized_publication_execution_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["retrieval"]["Tables"]["authorized_publication_execution"]["Insert"]`; row: `Database["retrieval"]["Tables"]["authorized_publication_execution"]["Row"]`; update: `Database["retrieval"]["Tables"]["authorized_publication_execution"]["Update"]`

Defined in: `20260904011000_governed_projection_embedding_publication.sql`.
