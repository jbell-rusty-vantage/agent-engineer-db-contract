---
id: "rel:knowledge_service.operation#details"
kind: details
schema: knowledge_service
name: operation
of: "rel:knowledge_service.operation"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge_service.operation — details

Spill-over from [the main page](operation.md).

## Relationships

Outbound: `capability_version_id` → [`orchestration.capability_version`](../orchestration/capability_version.md)`.id` on delete restrict; `tenant_id,attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id` on delete restrict; `tenant_id,work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.representation_decision`](../content/representation_decision.md).decision_operation_id, [`evaluation.verification_benchmark_arm_publication`](../evaluation/verification_benchmark_arm_publication.md).operation_id, [`evaluation.verification_benchmark_comparison`](../evaluation/verification_benchmark_comparison.md).operation_id, [`evaluation.verification_benchmark_run`](../evaluation/verification_benchmark_run.md).operation_id, [`evidence.source_capture`](../evidence/source_capture.md).knowledge_operation_id, [`knowledge_service.callback_delivery`](callback_delivery.md).operation_id, [`knowledge_service.operation_event`](operation_event.md).operation_id, [`knowledge_service.operation_step`](operation_step.md).operation_id, [`knowledge_service.outbox`](outbox.md).operation_id, [`knowledge_service.receipt`](receipt.md).operation_id, [`knowledge_service.review_decision`](review_decision.md).decision_operation_id, [`knowledge_service.review_subject`](review_subject.md).operation_id, [`orchestration.verification_provider_attempt`](../orchestration/verification_provider_attempt.md).operation_id, [`orchestration.verification_provider_reconciliation`](../orchestration/verification_provider_reconciliation.md).operation_id, [`orchestration.verification_provider_response_capture`](../orchestration/verification_provider_response_capture.md).operation_id, [`orchestration.verification_semantic_response_observation`](../orchestration/verification_semantic_response_observation.md).operation_id, [`orchestration.verification_structured_extraction`](../orchestration/verification_structured_extraction.md).operation_id, [`orchestration.verification_structured_extraction_execution`](../orchestration/verification_structured_extraction_execution.md).operation_id, [`retrieval.authorized_publication_execution`](../retrieval/authorized_publication_execution.md).operation_id, [`retrieval.content_promotion_decision`](../retrieval/content_promotion_decision.md).decision_operation_id, [`retrieval.content_promotion_proposal`](../retrieval/content_promotion_proposal.md).operation_id, [`retrieval.embedding_run`](../retrieval/embedding_run.md).operation_id, [`retrieval.retrieval_run`](../retrieval/retrieval_run.md).operation_id, [`retrieval.space_publication`](../retrieval/space_publication.md).operation_id, [`retrieval.vector_store`](../retrieval/vector_store.md).created_by_operation_id, [`retrieval.vector_store_document`](../retrieval/vector_store_document.md).created_by_operation_id, [`retrieval.vector_store_ingestion_run`](../retrieval/vector_store_ingestion_run.md).operation_id, [`temporal.knowledge_batch`](../temporal/knowledge_batch.md).operation_id.

## Indexes

| Index | Definition |
| --- | --- |
| `knowledge_operation_queue_idx` | `CREATE INDEX knowledge_operation_queue_idx ON knowledge_service.operation USING btree (tenant_id, status, created_at) WHERE (status = ANY (ARRAY['queued'::text, 'running'::text]))` |
| `operation_tenant_id_id_key` | `CREATE UNIQUE INDEX operation_tenant_id_id_key ON knowledge_service.operation USING btree (tenant_id, id)` |
| `operation_tenant_id_idempotency_key_key` | `CREATE UNIQUE INDEX operation_tenant_id_idempotency_key_key ON knowledge_service.operation USING btree (tenant_id, idempotency_key)` |

## Triggers

- `operation_terminal_guard` → [`knowledge_service.guard_operation_terminal`](../../functions/knowledge_service/guard_operation_terminal.md): `CREATE TRIGGER operation_terminal_guard BEFORE DELETE OR UPDATE ON knowledge_service.operation FOR EACH ROW EXECUTE FUNCTION knowledge_service.guard_operation_terminal()`
- `verification_benchmark_comparison_operation_success` → [`evaluation.guard_verification_benchmark_comparison_operation_success`](../../functions/evaluation/guard_verification_benchmark_comparison_operation_success.md): `CREATE TRIGGER verification_benchmark_comparison_operation_success BEFORE INSERT OR UPDATE ON knowledge_service.operation FOR EACH ROW EXECUTE FUNCTION evaluation.guard_verification_benchmark_comparison_operation_success()`
- `verification_structured_extraction_completion_guard` → [`orchestration.verification_structured_extraction_completion_guard`](../../functions/orchestration/verification_structured_extraction_completion_guard.md): `CREATE TRIGGER verification_structured_extraction_completion_guard BEFORE INSERT OR UPDATE ON knowledge_service.operation FOR EACH ROW EXECUTE FUNCTION orchestration.verification_structured_extraction_completion_guard()`
- `verification_structured_extraction_failure_operation` → [`orchestration.structured_extraction_failure_terminal_guard`](../../functions/orchestration/structured_extraction_failure_terminal_guard.md): `CREATE TRIGGER verification_structured_extraction_failure_operation BEFORE INSERT OR UPDATE ON knowledge_service.operation FOR EACH ROW EXECUTE FUNCTION orchestration.structured_extraction_failure_terminal_guard()`
- `verification_structured_extraction_input_custody` → [`orchestration.guard_structured_extraction_input_custody`](../../functions/orchestration/guard_structured_extraction_input_custody.md): `CREATE TRIGGER verification_structured_extraction_input_custody BEFORE INSERT OR UPDATE ON knowledge_service.operation FOR EACH ROW EXECUTE FUNCTION orchestration.guard_structured_extraction_input_custody()`
- `verification_structured_extraction_owner_custody` → [`orchestration.guard_structured_extraction_owner_custody`](../../functions/orchestration/guard_structured_extraction_owner_custody.md): `CREATE TRIGGER verification_structured_extraction_owner_custody BEFORE UPDATE ON knowledge_service.operation FOR EACH ROW EXECUTE FUNCTION orchestration.guard_structured_extraction_owner_custody()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
