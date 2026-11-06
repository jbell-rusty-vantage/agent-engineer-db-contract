---
id: "rel:orchestration.verification_structured_extraction_execution"
kind: table
schema: orchestration
name: verification_structured_extraction_execution
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_structured_extraction_execution, orchestration.verification_structured_extraction_execution, tenant_id, operation_id, operation_step_id, producer_attempt_id, request_sha256, step_input_sha256, profile_artifact_id, profile_sha256, execution_artifact_id, execution_sha256, runtime_sha256, execution_mode, dirty_artifact_id, dirty_sha256, execution_created_at, bound_at]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_structured_extraction_execution\"][\"Row\"]"
defined_in: ["20260906031800_verification_structured_extraction_execution.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_structured_extraction_execution

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `operation_id` | `uuid` | no | — | PK |
| 3 | `operation_step_id` | `uuid` | no | — | — |
| 4 | `producer_attempt_id` | `uuid` | no | — | — |
| 5 | `request_sha256` | `text` | no | — | — |
| 6 | `step_input_sha256` | `text` | no | — | — |
| 7 | `profile_artifact_id` | `uuid` | no | — | — |
| 8 | `profile_sha256` | `text` | no | — | — |
| 9 | `execution_artifact_id` | `uuid` | no | — | — |
| 10 | `execution_sha256` | `text` | no | — | — |
| 11 | `runtime_sha256` | `text` | no | — | — |
| 12 | `execution_mode` | `text` | no | — | — |
| 13 | `dirty_artifact_id` | `uuid` | yes | — | — |
| 14 | `dirty_sha256` | `text` | yes | — | — |
| 15 | `execution_created_at` | `timestamp with time zone` | no | — | — |
| 16 | `bound_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, operation_id)
- check `verification_structured_extraction_exec_step_input_sha256_check`: `(step_input_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_structured_extraction_execu_execution_sha256_check`: `(execution_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_structured_extraction_executi_execution_mode_check`: `(execution_mode = ANY (ARRAY['synthetic_transport'::text, 'live_provider'::text]))`
- check `verification_structured_extraction_executi_profile_sha256_check`: `(profile_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_structured_extraction_executi_request_sha256_check`: `(request_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_structured_extraction_executi_runtime_sha256_check`: `(runtime_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_structured_extraction_execution_check`: `((dirty_artifact_id IS NULL) = (dirty_sha256 IS NULL))`
- check `verification_structured_extraction_execution_dirty_sha256_check`: `((dirty_sha256 IS NULL) OR (dirty_sha256 ~ '^[0-9a-f]{64}$'::text))`

## Relationships

Outbound: `tenant_id,producer_attempt_id` → [`orchestration.attempt`](attempt.md)`.tenant_id,id`; `tenant_id,profile_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,execution_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,operation_step_id` → [`knowledge_service.operation_step`](../knowledge_service/operation_step.md)`.tenant_id,id`; `tenant_id,dirty_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id`.
Inbound: [`orchestration.verification_structured_extraction_failure`](verification_structured_extraction_failure.md).operation_id, [`orchestration.verification_structured_extraction_publication`](verification_structured_extraction_publication.md).operation_id.

## Indexes

0 indexes; see [details](verification_structured_extraction_execution.details.md).

## Triggers

- `artifact_retirement_03dfe7d63ead38cf6b8b527f` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_0951a2f767de80a2cb3c8b32` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_16fbe6fa517b63b7940dff78` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `verification_structured_extraction_execution_guard` → [`orchestration.guard_verification_structured_extraction_execution`](../../functions/orchestration/guard_verification_structured_extraction_execution.md)
- `verification_structured_extraction_execution_source_guard` → [`orchestration.guard_structured_extraction_source_custody`](../../functions/orchestration/guard_structured_extraction_source_custody.md)

## Row-level security

Enabled; 2 policies in [details](verification_structured_extraction_execution.details.md).

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: INSERT, SELECT. None: `anon`, `authenticated`, `pipeline_agent`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `verifier_agent`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_structured_extraction_execution"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_structured_extraction_execution"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_structured_extraction_execution"]["Update"]`

Defined in: `20260906031800_verification_structured_extraction_execution.sql`.
