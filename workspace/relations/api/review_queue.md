---
id: "rel:api.review_queue"
kind: view
schema: api
name: review_queue
domain: api-surface
aliases: [review queue view]
tokens: [api, review_queue, api.review_queue, id, tenant_id, task_kind, state, priority, assignee, quorum_required, summary, detail, candidate_id, claim_id, claim_conflict_id, entity_merge_id, record_reconciliation_id, ranking_result_id, operation_intent_id, report_version_id, capability_version_id, vector_space_version_id, subject_kind, created_at, updated_at]
summary: Invoker view of evaluation.review_task for app_reader.
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"review_queue\"][\"Row\"]"
defined_in: ["20260826001500_api_and_grants.sql", "20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.review_queue

view in domain `api-surface`.

> curated (model_assisted, unreviewed) — Invoker view of evaluation.review_task for app_reader.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | yes | — | — |
| 2 | `tenant_id` | `uuid` | yes | — | — |
| 3 | `task_kind` | `text` | yes | — | _curated:_ What kind of review this is. |
| 4 | `state` | `evaluation.review_state` | yes | — | — |
| 5 | `priority` | `integer` | yes | — | — |
| 6 | `assignee` | `text` | yes | — | — |
| 7 | `quorum_required` | `integer` | yes | — | — |
| 8 | `summary` | `text` | yes | — | — |
| 9 | `detail` | `jsonb` | yes | — | — |
| 10 | `candidate_id` | `uuid` | yes | — | _curated:_ Set when the task points at a staging.candidate. |
| 11 | `claim_id` | `uuid` | yes | — | — |
| 12 | `claim_conflict_id` | `uuid` | yes | — | — |
| 13 | `entity_merge_id` | `uuid` | yes | — | — |
| 14 | `record_reconciliation_id` | `uuid` | yes | — | — |
| 15 | `ranking_result_id` | `uuid` | yes | — | — |
| 16 | `operation_intent_id` | `uuid` | yes | — | — |
| 17 | `report_version_id` | `uuid` | yes | — | — |
| 18 | `capability_version_id` | `uuid` | yes | — | — |
| 19 | `vector_space_version_id` | `uuid` | yes | — | — |
| 20 | `subject_kind` | `text` | yes | — | — |
| 21 | `created_at` | `timestamp with time zone` | yes | — | — |
| 22 | `updated_at` | `timestamp with time zone` | yes | — | — |

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

`app_reader`: SELECT; `authenticated`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](review_queue.details.md).

## TypeScript

row: `Database["api"]["Views"]["review_queue"]["Row"]`

## Examples

Unresolved identity work

```bash
knowledge db query staging.unresolved --param limit=50
```
Review tasks may later point at these candidate ids.

Defined in: `20260826001500_api_and_grants.sql`, `20260912011000_km_10_api.sql`.
