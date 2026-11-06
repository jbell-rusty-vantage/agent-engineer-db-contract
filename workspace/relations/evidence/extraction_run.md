---
id: "rel:evidence.extraction_run"
kind: table
schema: evidence
name: extraction_run
domain: evidence
aliases: []
tokens: [evidence, extraction_run, evidence.extraction_run, id, tenant_id, representation_id, attempt_id, extractor_identity, extractor_version, parameters, input_digest, result_artifact_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"extraction_run\"][\"Row\"]"
defined_in: ["20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.extraction_run

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `representation_id` | `uuid` | yes | — | FK → [`content.document_representation`](../content/document_representation.md).id |
| 4 | `attempt_id` | `uuid` | yes | — | FK → [`orchestration.attempt`](../orchestration/attempt.md).id |
| 5 | `extractor_identity` | `text` | no | — | — |
| 6 | `extractor_version` | `text` | no | — | — |
| 7 | `parameters` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `input_digest` | `text` | no | — | — |
| 9 | `result_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)

## Relationships

Outbound: `attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id` (+tenant); `representation_id` → [`content.document_representation`](../content/document_representation.md)`.id` (+tenant); `result_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant).
Inbound: [`evidence.extraction_record`](extraction_record.md).extraction_run_id.

## Indexes

`extraction_run_tenant_id_id_key` unique

## Triggers

- `artifact_retirement_1c6d9be6d3dc9166db220e8b` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_dff8c8b3731da8f5c3414766` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `km_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["extraction_run"]["Insert"]`; row: `Database["evidence"]["Tables"]["extraction_run"]["Row"]`; update: `Database["evidence"]["Tables"]["extraction_run"]["Update"]`

Defined in: `20260912010500_km_05_evidence.sql`.
