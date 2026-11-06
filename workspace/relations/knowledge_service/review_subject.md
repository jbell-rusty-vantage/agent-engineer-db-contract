---
id: "rel:knowledge_service.review_subject"
kind: table
schema: knowledge_service
name: review_subject
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, review_subject, knowledge_service.review_subject, id, tenant_id, operation_id, subject_kind, subject_ref, guarded_sha256, eligible_roles, quorum_required, expires_at, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"review_subject\"][\"Row\"]"
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge_service.review_subject

table in domain `knowledge-service-runtime`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `operation_id` | `uuid` | no | — | — |
| 4 | `subject_kind` | `text` | no | — | — |
| 5 | `subject_ref` | `jsonb` | no | — | — |
| 6 | `guarded_sha256` | `text` | no | — | — |
| 7 | `eligible_roles` | `text[]` | no | — | — |
| 8 | `quorum_required` | `integer` | no | `1` | — |
| 9 | `expires_at` | `timestamp with time zone` | yes | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `review_subject_guarded_sha256_check`: `(guarded_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `review_subject_quorum_required_check`: `(quorum_required > 0)`
- check `review_subject_subject_kind_check`: `(subject_kind = ANY (ARRAY['source_vetting'::text, 'conversion'::text, 'representation'::text, 'domain_mapping'::text, 'chunking'::text, 'p…`

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](operation.md)`.tenant_id,id` on delete restrict.
Inbound: [`knowledge_service.review_decision`](review_decision.md).review_subject_id.

## Indexes

`review_subject_tenant_id_id_key` unique

## Triggers

- `review_subject_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["review_subject"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["review_subject"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["review_subject"]["Update"]`

Defined in: `20260903010200_knowledge_runtime_security.sql`.
