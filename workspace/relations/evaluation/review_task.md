---
id: "rel:evaluation.review_task"
kind: table
schema: evaluation
name: review_task
domain: evaluation
lens: machinery
aliases: []
tokens: [evaluation, review_task, evaluation.review_task, id, tenant_id, task_kind, state, priority, assignee, quorum_required, summary, detail, candidate_id, claim_id, claim_conflict_id, entity_merge_id, operation_intent_id, capability_version_id, vector_space_version_id, created_at, updated_at, subject_kind]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"review_task\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# evaluation.review_task

table in domain `evaluation`, lens `machinery`.

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
| 13 | `entity_merge_id` | `uuid` | yes | — | FK → [`catalog.entity_merge`](../catalog/entity_merge.md).id |
| 16 | `operation_intent_id` | `uuid` | yes | — | FK → [`orchestration.operation_intent`](../orchestration/operation_intent.md).id |
| 18 | `capability_version_id` | `uuid` | yes | — | FK → [`orchestration.capability_version`](../orchestration/capability_version.md).id |
| 19 | `vector_space_version_id` | `uuid` | yes | — | FK → [`retrieval.vector_space_version`](../retrieval/vector_space_version.md).id |
| 21 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 22 | `updated_at` | `timestamp with time zone` | no | `now()` | — |
| 23 | `subject_kind` | `text` | yes | — | generated: ` CASE     WHEN (candidate_id IS NOT NULL) THEN 'candidate'::text     WHEN (claim_id IS NOT NULL) THEN 'claim'::text     WHEN (claim_conflict_id IS NOT NULL) THEN 'claim_conflict'::text     WHEN (entity_merge_id IS NOT NULL) THEN 'entity_merge'::text     WHEN (operation_intent_id IS NOT NULL) THEN 'operation_intent'::text     WHEN (capability_version_id IS NOT NULL) THEN 'capability_version'::text     WHEN (vector_space_version_id IS NOT NULL) THEN 'vector_space_version'::text     ELSE NULL::text END` |

## Constraints

- PK (id)
- check `review_task_exactly_one_subject`: `(num_nonnulls(candidate_id, claim_id, claim_conflict_id, entity_merge_id, operation_intent_id, capability_version_id, vector_space_version_…`
- check `review_task_task_kind_check`: `(task_kind = ANY (ARRAY['identity'::text, 'merge'::text, 'claim_support'::text, 'conflict'::text, 'extraction_failure'::text, 'ranking_anom…`

## Relationships

Outbound: `candidate_id` → [`staging.candidate`](../staging/candidate.md)`.id` on delete cascade; `capability_version_id` → [`orchestration.capability_version`](../orchestration/capability_version.md)`.id` on delete cascade; `claim_conflict_id` → [`evidence.claim_conflict`](../evidence/claim_conflict.md)`.id` on delete cascade; `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` on delete cascade; `entity_merge_id` → [`catalog.entity_merge`](../catalog/entity_merge.md)`.id` on delete cascade; `operation_intent_id` → [`orchestration.operation_intent`](../orchestration/operation_intent.md)`.id` on delete cascade; `vector_space_version_id` → [`retrieval.vector_space_version`](../retrieval/vector_space_version.md)`.id` on delete cascade.
Inbound: [`evaluation.review_decision`](review_decision.md).review_task_id, [`evidence.conflict_reconciliation`](../evidence/conflict_reconciliation.md).review_task_id, [`evidence.degraded_assurance`](../evidence/degraded_assurance.md).approved_by_review_task_id, [`taxonomy.assignment`](../taxonomy/assignment.md).review_task_id, [`taxonomy.facet_version`](../taxonomy/facet_version.md).approved_by_review_task_id.
Polymorphic: exactly one of `candidate_id`, `claim_id`, `claim_conflict_id`, `entity_merge_id`, `operation_intent_id`, `capability_version_id`, `vector_space_version_id` → [`catalog.entity_merge`](../catalog/entity_merge.md) | [`evidence.claim`](../evidence/claim.md) | [`evidence.claim_conflict`](../evidence/claim_conflict.md) | [`orchestration.capability_version`](../orchestration/capability_version.md) | [`orchestration.operation_intent`](../orchestration/operation_intent.md) | [`retrieval.vector_space_version`](../retrieval/vector_space_version.md) | [`staging.candidate`](../staging/candidate.md) — basis: check constraint review_task_exactly_one_subject.

## Indexes

8 indexes; see [details](review_task.details.md).

## Triggers

- `review_task_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

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
