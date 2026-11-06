---
id: "rel:content.transformation_input"
kind: table
schema: content
name: transformation_input
domain: content
aliases: []
tokens: [content, transformation_input, content.transformation_input, tenant_id, transformation_run_id, ordinal, role, artifact_id, representation_id, source_capture_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"transformation_input\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content.transformation_input

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK |
| 2 | `transformation_run_id` | `uuid` | no | — | PK |
| 3 | `ordinal` | `integer` | no | — | PK |
| 4 | `role` | `text` | no | — | — |
| 5 | `artifact_id` | `uuid` | yes | — | — |
| 6 | `representation_id` | `uuid` | yes | — | — |
| 7 | `source_capture_id` | `uuid` | yes | — | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, transformation_run_id, ordinal)
- check `transformation_input_check`: `(num_nonnulls(artifact_id, representation_id, source_capture_id) = 1)`
- check `transformation_input_ordinal_check`: `(ordinal >= 0)`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_id` → [`content.document_representation`](document_representation.md)`.tenant_id,id` on delete restrict; `tenant_id,source_capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.tenant_id,id` on delete restrict; `tenant_id,transformation_run_id` → [`content.transformation_run`](transformation_run.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_ceebaeb22f049b429fd04d6f` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `transformation_input_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["transformation_input"]["Insert"]`; row: `Database["content"]["Tables"]["transformation_input"]["Row"]`; update: `Database["content"]["Tables"]["transformation_input"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
