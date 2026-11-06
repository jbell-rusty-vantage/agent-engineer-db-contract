---
id: "rel:retrieval.vector_store_document"
kind: table
schema: retrieval
name: vector_store_document
domain: retrieval
aliases: []
tokens: [retrieval, vector_store_document, retrieval.vector_store_document, id, tenant_id, vector_store_id, document_id, document_version_id, representation_id, admission_state, requested_profile, lifecycle, tombstone_receipt_id, supersedes_id, created_at, created_by_operation_id]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_store_document\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.vector_store_document

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, created_by_operation_id, document_id); unique (tenant_id, id) |
| 3 | `vector_store_id` | `uuid` | no | — | — |
| 4 | `document_id` | `uuid` | no | — | unique (tenant_id, created_by_operation_id, document_id) |
| 5 | `document_version_id` | `uuid` | yes | — | — |
| 6 | `representation_id` | `uuid` | yes | — | — |
| 7 | `admission_state` | `text` | no | `'requested'::text` | — |
| 8 | `requested_profile` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `lifecycle` | `text` | no | `'active'::text` | — |
| 10 | `tombstone_receipt_id` | `uuid` | yes | — | — |
| 11 | `supersedes_id` | `uuid` | yes | — | — |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 13 | `created_by_operation_id` | `uuid` | yes | — | unique (tenant_id, created_by_operation_id, document_id) |

## Constraints

- PK (id)
- unique (tenant_id, created_by_operation_id, document_id)
- unique (tenant_id, id)
- check `vector_store_document_check`: `((supersedes_id IS NULL) OR (supersedes_id <> id))`

## Relationships

Outbound: `tenant_id,created_by_operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,document_id` → [`content.document`](../content/document.md)`.tenant_id,id` on delete restrict; `tenant_id,document_version_id` → [`content.document_version`](../content/document_version.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_id` → [`content.document_representation`](../content/document_representation.md)`.tenant_id,id` on delete restrict; `tenant_id,supersedes_id` → [`retrieval.vector_store_document`](vector_store_document.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_store_id` → [`retrieval.vector_store`](vector_store.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.vector_store_document`](vector_store_document.md).supersedes_id.

## Indexes

`vector_store_document_active_membership_uq` unique where `(lifecycle = 'active'::text)`; `vector_store_document_operation_document_uq` unique; `vector_store_document_tenant_id_id_key` unique

## Triggers

- `predecessor_direction` → [`util.validate_predecessor`](../../functions/util/validate_predecessor.md)
- `vector_store_document_active_parent` → [`retrieval.require_active_vector_store_reference`](../../functions/retrieval/require_active_vector_store_reference.md)
- `vector_store_document_identity_immutable` → [`retrieval.reject_vector_store_document_identity_mutation`](../../functions/retrieval/reject_vector_store_document_identity_mutation.md)
- `vector_store_document_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["retrieval"]["Tables"]["vector_store_document"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_store_document"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_store_document"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
