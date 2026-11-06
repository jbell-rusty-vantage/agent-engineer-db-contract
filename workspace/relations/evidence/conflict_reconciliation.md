---
id: "rel:evidence.conflict_reconciliation"
kind: table
schema: evidence
name: conflict_reconciliation
domain: evidence
aliases: []
tokens: [evidence, conflict_reconciliation, evidence.conflict_reconciliation, id, conflict_id, outcome, rationale, review_task_id, decided_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"conflict_reconciliation\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.conflict_reconciliation

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `conflict_id` | `uuid` | no | — | FK → [`evidence.claim_conflict`](claim_conflict.md).id |
| 3 | `outcome` | `text` | no | — | — |
| 4 | `rationale` | `text` | no | — | — |
| 5 | `review_task_id` | `uuid` | yes | — | FK → [`evaluation.review_task`](../evaluation/review_task.md).id |
| 6 | `decided_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `conflict_reconciliation_outcome_check`: `(outcome = ANY (ARRAY['reject'::text, 'supersede'::text, 'scope'::text, 'retain_dispute'::text, 'experiment'::text, 'review'::text]))`

## Relationships

Outbound: `conflict_id` → [`evidence.claim_conflict`](claim_conflict.md)`.id` on delete cascade; `review_task_id` → [`evaluation.review_task`](../evaluation/review_task.md)`.id`.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`.

## Read paths

- Direct SELECT: `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["evidence"]["Tables"]["conflict_reconciliation"]["Insert"]`; row: `Database["evidence"]["Tables"]["conflict_reconciliation"]["Row"]`; update: `Database["evidence"]["Tables"]["conflict_reconciliation"]["Update"]`

Defined in: `20260826000300_evidence_core.sql`.
