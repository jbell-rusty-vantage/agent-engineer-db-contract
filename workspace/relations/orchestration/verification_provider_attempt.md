---
id: "rel:orchestration.verification_provider_attempt"
kind: table
schema: orchestration
name: verification_provider_attempt
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_provider_attempt, orchestration.verification_provider_attempt, id, tenant_id, budget_id, request_sha256, attempt_ordinal, provider_id, model, reservation_cost_micros, state, estimated_cost_micros, actual_cost_micros, request_artifact_id, response_artifact_id, created_at, dispatched_at, reconciled_at, dispatch_fence, operation_id, operation_step_id, profile_artifact_id, profile_sha256, reserved_fencing_token, dispatch_fencing_token, semantic_request_sha256, semantic_dispatch_lease_token, semantic_dispatch_holder_identity]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_provider_attempt\"][\"Row\"]"
defined_in: ["20260906010000_verification_provider_budget_accounting.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_provider_attempt

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `budget_id` | `uuid` | no | — | — |
| 4 | `request_sha256` | `text` | no | — | — |
| 5 | `attempt_ordinal` | `integer` | no | — | — |
| 6 | `provider_id` | `text` | no | — | — |
| 7 | `model` | `text` | no | — | — |
| 8 | `reservation_cost_micros` | `bigint` | no | — | — |
| 9 | `state` | `text` | no | — | — |
| 10 | `estimated_cost_micros` | `bigint` | yes | — | — |
| 11 | `actual_cost_micros` | `bigint` | yes | — | — |
| 12 | `request_artifact_id` | `uuid` | yes | — | — |
| 13 | `response_artifact_id` | `uuid` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `dispatched_at` | `timestamp with time zone` | yes | — | — |
| 16 | `reconciled_at` | `timestamp with time zone` | yes | — | — |
| 17 | `dispatch_fence` | `uuid` | yes | — | — |
| 18 | `operation_id` | `uuid` | yes | — | — |
| 19 | `operation_step_id` | `uuid` | yes | — | — |
| 20 | `profile_artifact_id` | `uuid` | yes | — | — |
| 21 | `profile_sha256` | `text` | yes | — | — |
| 22 | `reserved_fencing_token` | `bigint` | yes | — | — |
| 23 | `dispatch_fencing_token` | `bigint` | yes | — | — |
| 24 | `semantic_request_sha256` | `text` | yes | — | — |
| 25 | `semantic_dispatch_lease_token` | `uuid` | yes | — | — |
| 26 | `semantic_dispatch_holder_identity` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- 15 check constraints; see [details](verification_provider_attempt.details.md)

## Relationships

6 outbound and 4 inbound foreign keys; full list in [details](verification_provider_attempt.details.md).

## Indexes

6 indexes; see [details](verification_provider_attempt.details.md).

## Triggers

9 triggers; see [details](verification_provider_attempt.details.md).

## Row-level security

Enabled; 2 policies in [details](verification_provider_attempt.details.md).

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT, UPDATE. None: `anon`, `authenticated`, `pipeline_agent`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `verifier_agent`.
- Via functions (best effort): [`orchestration.apply_provider_reconciliation`](../../functions/orchestration/apply_provider_reconciliation.md).

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_provider_attempt"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_provider_attempt"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_provider_attempt"]["Update"]`

Defined in: `20260906010000_verification_provider_budget_accounting.sql`.
