---
id: "rel:orchestration.mission_run_effects"
kind: view
schema: orchestration
name: mission_run_effects
domain: orchestration-ledger
aliases: []
tokens: [orchestration, mission_run_effects, orchestration.mission_run_effects, tenant_id, mc_run_id, mc_mission_id, mc_activation_id, mc_operation_id, mc_operation_attempt, mc_execution_generation, mc_lane, origin_digest, intent_id, receipt_id, receipt_outcome, applied_at, use_decision_id, ordinal, target_schema, target_table, target_id, entity_id, entity_kind, role, action, proposal_id, claim_id]
summary: "Native effects by Mission Control run: intent (with its mc_* coordinates and origin digest) -> receipt -> receipt targets, for intents that carry mission coordinates. security_invoker: the caller's grants and tenant policies on the three tables apply, so only roles that can read operation_receipt (executor_service, control_plane) can read it."
summary_basis: comment
rls: disabled
readers: [control_plane, executor_service, service_role]
writers: []
typescript: "Database[\"orchestration\"][\"Views\"][\"mission_run_effects\"][\"Row\"]"
defined_in: ["20261031010000_operation_receipt_targets.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.mission_run_effects

view in domain `orchestration-ledger` — Native effects by Mission Control run: intent (with its mc_* coordinates and origin digest) -> receipt -> receipt targets, for intents that carry mission coordinates. security_invoker: the caller's grants and tenant policies on the three tables apply, so only roles that can read operation_receipt (executor_service, control_plane) can read it..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | yes | — | — |
| 2 | `mc_run_id` | `text` | yes | — | — |
| 3 | `mc_mission_id` | `text` | yes | — | — |
| 4 | `mc_activation_id` | `text` | yes | — | — |
| 5 | `mc_operation_id` | `text` | yes | — | — |
| 6 | `mc_operation_attempt` | `integer` | yes | — | — |
| 7 | `mc_execution_generation` | `integer` | yes | — | — |
| 8 | `mc_lane` | `text` | yes | — | — |
| 9 | `origin_digest` | `text` | yes | — | — |
| 10 | `intent_id` | `uuid` | yes | — | — |
| 11 | `receipt_id` | `uuid` | yes | — | — |
| 12 | `receipt_outcome` | `text` | yes | — | — |
| 13 | `applied_at` | `timestamp with time zone` | yes | — | — |
| 14 | `use_decision_id` | `text` | yes | — | — |
| 15 | `ordinal` | `integer` | yes | — | — |
| 16 | `target_schema` | `text` | yes | — | — |
| 17 | `target_table` | `text` | yes | — | — |
| 18 | `target_id` | `text` | yes | — | — |
| 19 | `entity_id` | `uuid` | yes | — | — |
| 20 | `entity_kind` | `text` | yes | — | — |
| 21 | `role` | `text` | yes | — | — |
| 22 | `action` | `text` | yes | — | — |
| 23 | `proposal_id` | `text` | yes | — | — |
| 24 | `claim_id` | `uuid` | yes | — | — |

## Constraints

_None._

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

Views are not written.

## View definition

See [details](mission_run_effects.details.md).

## TypeScript

row: `Database["orchestration"]["Views"]["mission_run_effects"]["Row"]`

Defined in: `20261031010000_operation_receipt_targets.sql`.
