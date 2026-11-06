---
id: "rel:orchestration.attempt#details"
kind: details
schema: orchestration
name: attempt
of: "rel:orchestration.attempt"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.attempt — details

Spill-over from [the main page](attempt.md).

## Relationships

Outbound: `agent_session_id` → [`orchestration.agent_session`](agent_session.md)`.id`; `work_item_id` → [`orchestration.work_item`](work_item.md)`.id` on delete cascade.
Inbound: [`content.document`](../content/document.md).created_by_attempt_id, [`content.transformation_run`](../content/transformation_run.md).attempt_id, [`evaluation.eval_run`](../evaluation/eval_run.md).attempt_id, [`evidence.claim`](../evidence/claim.md).producer_attempt_id, [`evidence.extraction_run`](../evidence/extraction_run.md).attempt_id, [`evidence.extraction_signature`](../evidence/extraction_signature.md).produced_by_attempt_id, [`evidence.source_capture`](../evidence/source_capture.md).produced_by_attempt_id, [`evidence.source_query`](../evidence/source_query.md).attempt_id, [`knowledge_service.eve_operation_binding`](../knowledge_service/eve_operation_binding.md).attempt_id, [`knowledge_service.operation`](../knowledge_service/operation.md).attempt_id, [`observability.trace`](../observability/trace.md).attempt_id, [`orchestration.artifact`](artifact.md).producer_attempt_id, [`orchestration.operation_intent`](operation_intent.md).proposed_by_attempt, [`orchestration.verification_semantic_response_observation`](verification_semantic_response_observation.md).producer_attempt_id, [`orchestration.verification_structured_extraction`](verification_structured_extraction.md).producer_attempt_id, [`orchestration.verification_structured_extraction_execution`](verification_structured_extraction_execution.md).producer_attempt_id, [`orchestration.work_item_event`](work_item_event.md).attempt_id, [`research.report_package`](../research/report_package.md).producer_attempt_id, [`retrieval.retrieval_plan`](../retrieval/retrieval_plan.md).proposed_by_attempt_id, [`retrieval.vector_store`](../retrieval/vector_store.md).created_by_attempt_id.

## Indexes

| Index | Definition |
| --- | --- |
| `attempt_deployment_idx` | `CREATE INDEX attempt_deployment_idx ON orchestration.attempt USING btree (agent_deployment_id)` |
| `attempt_session_idx` | `CREATE INDEX attempt_session_idx ON orchestration.attempt USING btree (agent_session_id)` |
| `attempt_tenant_id_uq` | `CREATE UNIQUE INDEX attempt_tenant_id_uq ON orchestration.attempt USING btree (tenant_id, id)` |
| `attempt_work_item_id_attempt_no_key` | `CREATE UNIQUE INDEX attempt_work_item_id_attempt_no_key ON orchestration.attempt USING btree (work_item_id, attempt_no)` |

## Triggers

- `attempt_identity_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER attempt_identity_immutable BEFORE UPDATE OF work_item_id, attempt_no, agent_deployment_id, agent_session_id, started_at ON orchestration.attempt FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
