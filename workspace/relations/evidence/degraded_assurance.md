---
id: "rel:evidence.degraded_assurance"
kind: table
schema: evidence
name: degraded_assurance
domain: evidence
aliases: []
tokens: [evidence, degraded_assurance, evidence.degraded_assurance, id, source_id, reason, what_was_seen, attempted_methods, approved_by_review_task_id, approved_at, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"degraded_assurance\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.degraded_assurance

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `source_id` | `uuid` | no | — | FK → [`evidence.source`](source.md).id |
| 3 | `reason` | `text` | no | — | — |
| 4 | `what_was_seen` | `text` | no | — | — |
| 5 | `attempted_methods` | `jsonb` | no | `'[]'::jsonb` | — |
| 6 | `approved_by_review_task_id` | `uuid` | yes | — | FK → [`evaluation.review_task`](../evaluation/review_task.md).id |
| 7 | `approved_at` | `timestamp with time zone` | yes | — | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `approved_by_review_task_id` → [`evaluation.review_task`](../evaluation/review_task.md)`.id`; `source_id` → [`evidence.source`](source.md)`.id`.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`.

## Read paths

- Direct SELECT: `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["degraded_assurance"]["Insert"]`; row: `Database["evidence"]["Tables"]["degraded_assurance"]["Row"]`; update: `Database["evidence"]["Tables"]["degraded_assurance"]["Update"]`

Defined in: `20260826000300_evidence_core.sql`.
