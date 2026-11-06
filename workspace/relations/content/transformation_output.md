---
id: "rel:content.transformation_output"
kind: table
schema: content
name: transformation_output
domain: content
aliases: []
tokens: [content, transformation_output, content.transformation_output, tenant_id, transformation_run_id, ordinal, role, artifact_id, representation_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"transformation_output\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.transformation_output

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
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, transformation_run_id, ordinal)
- check `transformation_output_check`: `(num_nonnulls(artifact_id, representation_id) = 1)`
- check `transformation_output_ordinal_check`: `(ordinal >= 0)`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_id` → [`content.document_representation`](document_representation.md)`.tenant_id,id` on delete restrict; `tenant_id,transformation_run_id` → [`content.transformation_run`](transformation_run.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_77305d145e11e391df83c60b` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `transformation_output_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["content"]["Tables"]["transformation_output"]["Insert"]`; row: `Database["content"]["Tables"]["transformation_output"]["Row"]`; update: `Database["content"]["Tables"]["transformation_output"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
