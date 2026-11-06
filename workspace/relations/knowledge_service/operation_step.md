---
id: "rel:knowledge_service.operation_step"
kind: table
schema: knowledge_service
name: operation_step
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, operation_step, knowledge_service.operation_step, id, tenant_id, operation_id, step_key, step_kind, input, input_sha256, status, attempt_count, max_attempts, available_at, row_version, created_at, updated_at, completed_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"operation_step\"][\"Row\"]"
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge_service.operation_step

table in domain `knowledge-service-runtime`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, operation_id, step_key) |
| 3 | `operation_id` | `uuid` | no | — | unique (tenant_id, operation_id, step_key) |
| 4 | `step_key` | `text` | no | — | unique (tenant_id, operation_id, step_key) |
| 5 | `step_kind` | `text` | no | — | — |
| 6 | `input` | `jsonb` | no | — | — |
| 7 | `input_sha256` | `text` | no | — | — |
| 8 | `status` | `text` | no | `'queued'::text` | — |
| 9 | `attempt_count` | `integer` | no | `0` | — |
| 10 | `max_attempts` | `integer` | no | `3` | — |
| 11 | `available_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `row_version` | `bigint` | no | `0` | — |
| 13 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 14 | `updated_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `completed_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, operation_id, step_key)
- check `operation_step_input_sha256_check`: `(input_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](operation.md)`.tenant_id,id` on delete restrict.
Inbound: [`knowledge_service.lease`](lease.md).operation_step_id, [`knowledge_service.operation_event`](operation_event.md).step_id, [`knowledge_service.receipt`](receipt.md).step_id, [`orchestration.verification_provider_attempt`](../orchestration/verification_provider_attempt.md).operation_step_id, [`orchestration.verification_provider_response_capture`](../orchestration/verification_provider_response_capture.md).operation_step_id, [`orchestration.verification_semantic_response_observation`](../orchestration/verification_semantic_response_observation.md).operation_step_id, [`orchestration.verification_structured_extraction`](../orchestration/verification_structured_extraction.md).operation_step_id, [`orchestration.verification_structured_extraction_execution`](../orchestration/verification_structured_extraction_execution.md).operation_step_id.

## Indexes

3 indexes; see [details](operation_step.details.md).

## Triggers

- `operation_step_terminal_guard` → [`knowledge_service.guard_operation_terminal`](../../functions/knowledge_service/guard_operation_terminal.md)
- `verification_benchmark_comparison_step_success` → [`evaluation.guard_verification_benchmark_comparison_step_success`](../../functions/evaluation/guard_verification_benchmark_comparison_step_success.md)
- `verification_benchmark_comparison_terminal_artifact` → [`evaluation.guard_verification_benchmark_comparison_terminal_artifact`](../../functions/evaluation/guard_verification_benchmark_comparison_terminal_artifact.md)
- `verification_structured_extraction_completion_guard` → [`orchestration.verification_structured_extraction_completion_guard`](../../functions/orchestration/verification_structured_extraction_completion_guard.md)
- `verification_structured_extraction_failure_step` → [`orchestration.structured_extraction_failure_terminal_guard`](../../functions/orchestration/structured_extraction_failure_terminal_guard.md)
- `verification_structured_extraction_failure_terminal_commit` → [`orchestration.guard_structured_extraction_failure_terminal_commit`](../../functions/orchestration/guard_structured_extraction_failure_terminal_commit.md) (constraint trigger, deferred)
- `verification_structured_extraction_input_custody` → [`orchestration.guard_structured_extraction_input_custody`](../../functions/orchestration/guard_structured_extraction_input_custody.md)
- `verification_structured_extraction_owner_custody` → [`orchestration.guard_structured_extraction_owner_custody`](../../functions/orchestration/guard_structured_extraction_owner_custody.md)
- `verification_structured_extraction_step_membership` → [`orchestration.guard_structured_extraction_step_membership`](../../functions/orchestration/guard_structured_extraction_step_membership.md)
- `verification_structured_extraction_terminal_commit` → [`orchestration.guard_structured_extraction_terminal_commit`](../../functions/orchestration/guard_structured_extraction_terminal_commit.md) (constraint trigger, deferred)

## Row-level security

Enabled; 1 policies in [details](operation_step.details.md).

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["operation_step"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["operation_step"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["operation_step"]["Update"]`

Defined in: `20260903010200_knowledge_runtime_security.sql`.
