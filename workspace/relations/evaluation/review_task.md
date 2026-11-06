---
id: "rel:evaluation.review_task"
kind: table
schema: evaluation
name: review_task
domain: evaluation
aliases: []
tokens: [evaluation, review_task, evaluation.review_task, id, tenant_id, task_kind, state, priority, assignee, quorum_required, summary, detail, candidate_id, claim_id, claim_conflict_id, entity_merge_id, record_reconciliation_id, ranking_result_id, operation_intent_id, report_version_id, capability_version_id, vector_space_version_id, subject_kind, created_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"review_task\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.review_task

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `task_kind` | `text` | no | — | — |
| 4 | `state` | `evaluation.review_state` | no | `'open'::evaluation.review_state` | — |
| 5 | `priority` | `integer` | no | `100` | — |
| 6 | `assignee` | `text` | yes | — | — |
| 7 | `quorum_required` | `integer` | no | `1` | — |
| 8 | `summary` | `text` | no | — | — |
| 9 | `detail` | `jsonb` | no | `'{}'::jsonb` | — |
| 10 | `candidate_id` | `uuid` | yes | — | FK → [`staging.candidate`](../staging/candidate.md).id |
| 11 | `claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 12 | `claim_conflict_id` | `uuid` | yes | — | FK → [`evidence.claim_conflict`](../evidence/claim_conflict.md).id |
| 13 | `entity_merge_id` | `uuid` | yes | — | FK → [`corpus.entity_merge`](../corpus/entity_merge.md).id |
| 14 | `record_reconciliation_id` | `uuid` | yes | — | FK → [`knowledge.record_reconciliation`](../knowledge/record_reconciliation.md).id |
| 15 | `ranking_result_id` | `uuid` | yes | — | FK → [`ranking.ranking_result`](../ranking/ranking_result.md).id |
| 16 | `operation_intent_id` | `uuid` | yes | — | FK → [`orchestration.operation_intent`](../orchestration/operation_intent.md).id |
| 17 | `report_version_id` | `uuid` | yes | — | FK → [`research.report_version`](../research/report_version.md).id |
| 18 | `capability_version_id` | `uuid` | yes | — | FK → [`orchestration.capability_version`](../orchestration/capability_version.md).id |
| 19 | `vector_space_version_id` | `uuid` | yes | — | FK → [`retrieval.vector_space_version`](../retrieval/vector_space_version.md).id |
| 20 | `subject_kind` | `text` | yes | — | generated: ` CASE     WHEN (candidate_id IS NOT NULL) THEN 'candidate'::text     WHEN (claim_id IS NOT NULL) THEN 'claim'::text     WHEN (claim_conflict_id IS NOT NULL) THEN 'claim_conflict'::text     WHEN (entity_merge_id IS NOT NULL) THEN 'entity_merge'::text     WHEN (record_reconciliation_id IS NOT NULL) THEN 'record_reconciliation'::text     WHEN (ranking_result_id IS NOT NULL) THEN 'ranking_result'::text     WHEN (operation_intent_id IS NOT NULL) THEN 'operation_intent'::text     WHEN (report_version_id IS NOT NULL) THEN 'report_version'::text     WHEN (capability_version_id IS NOT NULL) THEN 'capability_version'::text     WHEN (vector_space_version_id IS NOT NULL) THEN 'vector_space_version'::text     ELSE NULL::text END` |
| 21 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 22 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `review_task_exactly_one_subject`: `(num_nonnulls(candidate_id, claim_id, claim_conflict_id, entity_merge_id, record_reconciliation_id, ranking_result_id, operation_intent_id,…`
- check `review_task_task_kind_check`: `(task_kind = ANY (ARRAY['identity'::text, 'merge'::text, 'claim_support'::text, 'conflict'::text, 'extraction_failure'::text, 'ranking_anom…`

## Relationships

10 outbound and 5 inbound foreign keys; full list in [details](review_task.details.md).

## Indexes

12 indexes; see [details](review_task.details.md).

## Triggers

1 triggers; see [details](review_task.details.md).

## Row-level security

Enabled; 1 policies in [details](review_task.details.md).

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Exposed through: [`api.review_queue`](../api/review_queue.md).
- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["review_task"]["Insert"]`; row: `Database["evaluation"]["Tables"]["review_task"]["Row"]`; update: `Database["evaluation"]["Tables"]["review_task"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
