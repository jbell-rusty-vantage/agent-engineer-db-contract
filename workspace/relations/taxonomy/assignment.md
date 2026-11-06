---
id: "rel:taxonomy.assignment"
kind: table
schema: taxonomy
name: assignment
domain: relationships
aliases: []
tokens: [taxonomy, assignment, taxonomy.assignment, id, tenant_id, term_id, target_work_id, method, confidence, provenance_claim_id, review_task_id, valid_from, valid_to, created_by_receipt_id, created_at, target_entity_id, target_record_id]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"taxonomy\"][\"Tables\"][\"assignment\"][\"Row\"]"
defined_in: ["20260826001400_deferred_fks.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# taxonomy.assignment

table in domain `relationships`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `term_id` | `uuid` | no | — | FK → [`taxonomy.term`](term.md).id |
| 21 | `target_work_id` | `uuid` | yes | — | — |
| 23 | `method` | `text` | no | — | — |
| 24 | `confidence` | `corpus.confidence` | yes | — | — |
| 25 | `provenance_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 26 | `review_task_id` | `uuid` | yes | — | FK → [`evaluation.review_task`](../evaluation/review_task.md).id |
| 27 | `valid_from` | `timestamp with time zone` | no | `now()` | — |
| 28 | `valid_to` | `timestamp with time zone` | yes | — | — |
| 29 | `created_by_receipt_id` | `uuid` | yes | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 30 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 36 | `target_entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 37 | `target_record_id` | `uuid` | yes | — | FK → [`knowledge.record`](../knowledge/record.md).id |

## Constraints

- PK (id)
- check `assignment_method_check`: `(method = ANY (ARRAY['rule'::text, 'model'::text, 'human'::text]))`
- check `assignment_one_target_ck`: `(num_nonnulls(target_entity_id, target_record_id, target_work_id) = 1)`

## Relationships

Outbound: `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`; `provenance_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `review_task_id` → [`evaluation.review_task`](../evaluation/review_task.md)`.id`; `target_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `target_record_id` → [`knowledge.record`](../knowledge/record.md)`.id`; `tenant_id,target_work_id` → `authoring.work``.tenant_id,id` on delete restrict; `term_id` → [`taxonomy.term`](term.md)`.id` on delete cascade.
Inbound: none.
Polymorphic: exactly one of `target_entity_id`, `target_record_id`, `target_work_id` → [`corpus.entity`](../corpus/entity.md) | [`knowledge.record`](../knowledge/record.md) — basis: check constraint assignment_one_target_ck.

## Indexes

`assignment_current_idx` where `(valid_to IS NULL)`; `assignment_lesson_id_idx` where `(target_work_id IS NOT NULL)`; `assignment_target_work_ix` where `(target_work_id IS NOT NULL)`; `assignment_term_idx`

## Triggers

- `assignment_facet_cardinality` → [`taxonomy.enforce_facet_cardinality`](../../functions/taxonomy/enforce_facet_cardinality.md)
- `assignment_term_target_scope` → [`taxonomy.enforce_term_target_scope`](../../functions/taxonomy/enforce_term_target_scope.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["taxonomy"]["Tables"]["assignment"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["assignment"]["Row"]`; update: `Database["taxonomy"]["Tables"]["assignment"]["Update"]`

Defined in: `20260826001400_deferred_fks.sql`.
