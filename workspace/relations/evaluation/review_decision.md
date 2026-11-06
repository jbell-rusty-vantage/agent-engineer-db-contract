---
id: "rel:evaluation.review_decision"
kind: table
schema: evaluation
name: review_decision
domain: evaluation
aliases: []
tokens: [evaluation, review_decision, evaluation.review_decision, id, review_task_id, decision, rationale, decided_by, eval_label_id, decided_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"review_decision\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.review_decision

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `review_task_id` | `uuid` | no | — | FK → [`evaluation.review_task`](review_task.md).id |
| 3 | `decision` | `text` | no | — | — |
| 4 | `rationale` | `text` | no | — | — |
| 5 | `decided_by` | `text` | no | — | — |
| 6 | `eval_label_id` | `uuid` | yes | — | FK → [`evaluation.eval_label`](eval_label.md).id |
| 7 | `decided_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `eval_label_id` → [`evaluation.eval_label`](eval_label.md)`.id`; `review_task_id` → [`evaluation.review_task`](review_task.md)`.id` on delete cascade.
Inbound: [`evaluation.eval_label`](eval_label.md).review_decision_id.

## Indexes

`review_decision_task_idx`

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

insert: `Database["evaluation"]["Tables"]["review_decision"]["Insert"]`; row: `Database["evaluation"]["Tables"]["review_decision"]["Row"]`; update: `Database["evaluation"]["Tables"]["review_decision"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
