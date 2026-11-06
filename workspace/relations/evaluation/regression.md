---
id: "rel:evaluation.regression"
kind: table
schema: evaluation
name: regression
domain: evaluation
aliases: []
tokens: [evaluation, regression, evaluation.regression, id, gate_id, baseline_run_id, current_run_id, metric, baseline_value, current_value, delta, detected_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"regression\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.regression

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `gate_id` | `uuid` | yes | — | FK → [`evaluation.gate`](gate.md).id |
| 3 | `baseline_run_id` | `uuid` | no | — | FK → [`evaluation.eval_run`](eval_run.md).id |
| 4 | `current_run_id` | `uuid` | no | — | FK → [`evaluation.eval_run`](eval_run.md).id |
| 5 | `metric` | `text` | no | — | — |
| 6 | `baseline_value` | `numeric` | yes | — | — |
| 7 | `current_value` | `numeric` | yes | — | — |
| 8 | `delta` | `numeric` | yes | — | — |
| 9 | `detected_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `regression_distinct_runs`: `(baseline_run_id <> current_run_id)`

## Relationships

Outbound: `baseline_run_id` → [`evaluation.eval_run`](eval_run.md)`.id`; `current_run_id` → [`evaluation.eval_run`](eval_run.md)`.id`; `gate_id` → [`evaluation.gate`](gate.md)`.id`.
Inbound: none.

## Indexes

_None._

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

insert: `Database["evaluation"]["Tables"]["regression"]["Insert"]`; row: `Database["evaluation"]["Tables"]["regression"]["Row"]`; update: `Database["evaluation"]["Tables"]["regression"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
