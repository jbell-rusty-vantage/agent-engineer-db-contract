---
id: "rel:orchestration.verification_provider_attempt"
kind: table
schema: orchestration
name: verification_provider_attempt
domain: orchestration-ledger
lens: machinery
aliases: []
tokens: [orchestration, verification_provider_attempt, orchestration.verification_provider_attempt, id, tenant_id, budget_id, request_sha256, attempt_ordinal, provider_id, model, reservation_cost_micros, state, estimated_cost_micros, actual_cost_micros, request_artifact_id, response_artifact_id, created_at, dispatched_at, reconciled_at, dispatch_fence, operation_id, operation_step_id, profile_artifact_id, profile_sha256, reserved_fencing_token, dispatch_fencing_token, semantic_request_sha256, semantic_dispatch_lease_token, semantic_dispatch_holder_identity]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_provider_attempt\"][\"Row\"]"
defined_in: ["20260906010000_verification_provider_budget_accounting.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# orchestration.verification_provider_attempt

table in domain `orchestration-ledger`, lens `machinery`.

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
- check `semantic_dispatch_context_complete`: `(((semantic_dispatch_lease_token IS NULL) AND (semantic_dispatch_holder_identity IS NULL) AND ((semantic_request_sha256 IS NULL) OR (state …`
- check `verification_provider_attempt_actual_cost_micros_check`: `(actual_cost_micros >= 0)`
- check `verification_provider_attempt_attempt_ordinal_check`: `((attempt_ordinal >= 0) AND (attempt_ordinal <= 8))`
- check `verification_provider_attempt_check`: `(((state = 'reserved'::text) AND (dispatched_at IS NULL) AND (reconciled_at IS NULL) AND (actual_cost_micros IS NULL)) OR ((state = 'dispat…`
- check `verification_provider_attempt_check1`: `((semantic_request_sha256 IS NULL) OR ((operation_id IS NOT NULL) AND (semantic_request_sha256 = request_sha256)))`
- check `verification_provider_attempt_dispatch_fencing_token_check`: `((dispatch_fencing_token IS NULL) OR (dispatch_fencing_token > 0))`
- check `verification_provider_attempt_estimated_cost_micros_check`: `(estimated_cost_micros >= 0)`
- check `verification_provider_attempt_model_check`: `((length(model) >= 1) AND (length(model) <= 160))`
- check `verification_provider_attempt_operation_scope_ck`: `(((operation_id IS NULL) AND (operation_step_id IS NULL) AND (profile_artifact_id IS NULL) AND (profile_sha256 IS NULL) AND (reserved_fenci…`
- check `verification_provider_attempt_profile_sha256_check`: `((profile_sha256 IS NULL) OR (profile_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `verification_provider_attempt_provider_id_check`: `(provider_id ~ '^[a-z0-9][a-z0-9._-]{0,119}$'::text)`
- check `verification_provider_attempt_request_sha256_check`: `(request_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_provider_attempt_reservation_cost_micros_check`: `(reservation_cost_micros > 0)`
- check `verification_provider_attempt_reserved_fencing_token_check`: `((reserved_fencing_token IS NULL) OR (reserved_fencing_token > 0))`
- check `verification_provider_attempt_state_check`: `(state = ANY (ARRAY['reserved'::text, 'dispatched'::text, 'settled'::text, 'uncertain'::text, 'cancelled'::text]))`

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
