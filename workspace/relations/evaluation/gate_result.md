---
id: "rel:evaluation.gate_result"
kind: table
schema: evaluation
name: gate_result
domain: evaluation
aliases: []
tokens: [evaluation, gate_result, evaluation.gate_result, id, gate_id, eval_run_id, passed, action, detail, spawned_work_item_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"gate_result\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.gate_result

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `gate_id` | `uuid` | no | — | FK → [`evaluation.gate`](gate.md).id |
| 3 | `eval_run_id` | `uuid` | yes | — | FK → [`evaluation.eval_run`](eval_run.md).id |
| 4 | `passed` | `boolean` | no | — | — |
| 5 | `action` | `evaluation.gate_action` | no | — | — |
| 6 | `detail` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `spawned_work_item_id` | `uuid` | yes | — | FK → [`orchestration.work_item`](../orchestration/work_item.md).id |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `eval_run_id` → [`evaluation.eval_run`](eval_run.md)`.id`; `gate_id` → [`evaluation.gate`](gate.md)`.id`; `spawned_work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.id`.
Inbound: none.

## Indexes

`gate_result_gate_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["gate_result"]["Insert"]`; row: `Database["evaluation"]["Tables"]["gate_result"]["Row"]`; update: `Database["evaluation"]["Tables"]["gate_result"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
