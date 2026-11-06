---
id: "rel:knowledge.record_reconciliation"
kind: table
schema: knowledge
name: record_reconciliation
domain: knowledge-records
aliases: []
tokens: [knowledge, record_reconciliation, knowledge.record_reconciliation, id, record_kind, surviving_id, merged_id, outcome, rationale, created_by_receipt_id, created_at]
summary: Reconciliation decisions between knowledge records. The authorizing review is found through evaluation.review_task.record_reconciliation_id.
summary_basis: comment
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge\"][\"Tables\"][\"record_reconciliation\"][\"Row\"]"
defined_in: ["20260826000600_knowledge.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge.record_reconciliation

table in domain `knowledge-records` — Reconciliation decisions between knowledge records. The authorizing review is found through evaluation.review_task.record_reconciliation_id..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `record_kind` | `text` | no | — | — |
| 3 | `surviving_id` | `uuid` | no | — | — |
| 4 | `merged_id` | `uuid` | no | — | — |
| 5 | `outcome` | `text` | no | — | — |
| 6 | `rationale` | `text` | no | — | — |
| 8 | `created_by_receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `record_reconciliation_distinct`: `(surviving_id <> merged_id)`
- check `record_reconciliation_outcome_check`: `(outcome = ANY (ARRAY['merged'::text, 'kept_separate'::text, 'scoped'::text]))`
- check `record_reconciliation_record_kind_check`: `(record_kind = ANY (ARRAY['technical_problem'::text, 'solution_pattern'::text, 'advanced_usage_pattern'::text, 'implementation_example'::te…`

## Relationships

Outbound: `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`.
Inbound: [`evaluation.review_task`](../evaluation/review_task.md).record_reconciliation_id.
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

`record_reconciliation_merged_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`.

## Read paths

- Direct SELECT: `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["knowledge"]["Tables"]["record_reconciliation"]["Insert"]`; row: `Database["knowledge"]["Tables"]["record_reconciliation"]["Row"]`; update: `Database["knowledge"]["Tables"]["record_reconciliation"]["Update"]`

Defined in: `20260826000600_knowledge.sql`.
