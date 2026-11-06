---
id: "rel:evaluation.review_task#details"
kind: details
schema: evaluation
name: review_task
of: "rel:evaluation.review_task"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.review_task — details

Spill-over from [the main page](review_task.md).

## Relationships

Outbound: `candidate_id` → [`staging.candidate`](../staging/candidate.md)`.id` on delete cascade; `capability_version_id` → [`orchestration.capability_version`](../orchestration/capability_version.md)`.id` on delete cascade; `claim_conflict_id` → [`evidence.claim_conflict`](../evidence/claim_conflict.md)`.id` on delete cascade; `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` on delete cascade; `entity_merge_id` → [`corpus.entity_merge`](../corpus/entity_merge.md)`.id` on delete cascade; `operation_intent_id` → [`orchestration.operation_intent`](../orchestration/operation_intent.md)`.id` on delete cascade; `ranking_result_id` → [`ranking.ranking_result`](../ranking/ranking_result.md)`.id` on delete cascade; `record_reconciliation_id` → [`knowledge.record_reconciliation`](../knowledge/record_reconciliation.md)`.id` on delete cascade; `report_version_id` → [`research.report_version`](../research/report_version.md)`.id` on delete cascade; `vector_space_version_id` → [`retrieval.vector_space_version`](../retrieval/vector_space_version.md)`.id` on delete cascade.
Inbound: [`evaluation.review_decision`](review_decision.md).review_task_id, [`evidence.conflict_reconciliation`](../evidence/conflict_reconciliation.md).review_task_id, [`evidence.degraded_assurance`](../evidence/degraded_assurance.md).approved_by_review_task_id, [`taxonomy.assignment`](../taxonomy/assignment.md).review_task_id, [`taxonomy.facet_version`](../taxonomy/facet_version.md).approved_by_review_task_id.
Polymorphic: exactly one of `candidate_id`, `claim_id`, `claim_conflict_id`, `entity_merge_id`, `record_reconciliation_id`, `ranking_result_id`, `operation_intent_id`, `report_version_id`, `capability_version_id`, `vector_space_version_id` → [`corpus.entity_merge`](../corpus/entity_merge.md) | [`evidence.claim`](../evidence/claim.md) | [`evidence.claim_conflict`](../evidence/claim_conflict.md) | [`knowledge.record_reconciliation`](../knowledge/record_reconciliation.md) | [`orchestration.capability_version`](../orchestration/capability_version.md) | [`orchestration.operation_intent`](../orchestration/operation_intent.md) | [`ranking.ranking_result`](../ranking/ranking_result.md) | [`research.report_version`](../research/report_version.md) | [`retrieval.vector_space_version`](../retrieval/vector_space_version.md) | [`staging.candidate`](../staging/candidate.md) — basis: check constraint review_task_exactly_one_subject.

## Indexes

| Index | Definition |
| --- | --- |
| `review_task_candidate_id_idx` | `CREATE INDEX review_task_candidate_id_idx ON evaluation.review_task USING btree (candidate_id) WHERE (candidate_id IS NOT NULL)` |
| `review_task_capability_version_id_idx` | `CREATE INDEX review_task_capability_version_id_idx ON evaluation.review_task USING btree (capability_version_id) WHERE (capability_version_id IS NOT NULL)` |
| `review_task_claim_conflict_id_idx` | `CREATE INDEX review_task_claim_conflict_id_idx ON evaluation.review_task USING btree (claim_conflict_id) WHERE (claim_conflict_id IS NOT NULL)` |
| `review_task_claim_id_idx` | `CREATE INDEX review_task_claim_id_idx ON evaluation.review_task USING btree (claim_id) WHERE (claim_id IS NOT NULL)` |
| `review_task_entity_merge_id_idx` | `CREATE INDEX review_task_entity_merge_id_idx ON evaluation.review_task USING btree (entity_merge_id) WHERE (entity_merge_id IS NOT NULL)` |
| `review_task_operation_intent_id_idx` | `CREATE INDEX review_task_operation_intent_id_idx ON evaluation.review_task USING btree (operation_intent_id) WHERE (operation_intent_id IS NOT NULL)` |
| `review_task_queue_idx` | `CREATE INDEX review_task_queue_idx ON evaluation.review_task USING btree (state, task_kind, priority, created_at) WHERE (state = ANY (ARRAY['open'::evaluation.review_state, 'claimed'::evaluation.review_state, 'in_review'::evaluation.review_state]))` |
| `review_task_ranking_result_id_idx` | `CREATE INDEX review_task_ranking_result_id_idx ON evaluation.review_task USING btree (ranking_result_id) WHERE (ranking_result_id IS NOT NULL)` |
| `review_task_record_reconciliation_id_idx` | `CREATE INDEX review_task_record_reconciliation_id_idx ON evaluation.review_task USING btree (record_reconciliation_id) WHERE (record_reconciliation_id IS NOT NULL)` |
| `review_task_report_version_id_idx` | `CREATE INDEX review_task_report_version_id_idx ON evaluation.review_task USING btree (report_version_id) WHERE (report_version_id IS NOT NULL)` |
| `review_task_subject_idx` | `CREATE INDEX review_task_subject_idx ON evaluation.review_task USING btree (subject_kind)` |
| `review_task_vector_space_version_id_idx` | `CREATE INDEX review_task_vector_space_version_id_idx ON evaluation.review_task USING btree (vector_space_version_id) WHERE (vector_space_version_id IS NOT NULL)` |

## Triggers

- `review_task_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md): `CREATE TRIGGER review_task_set_updated_at BEFORE UPDATE ON evaluation.review_task FOR EACH ROW EXECUTE FUNCTION util.set_updated_at()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
