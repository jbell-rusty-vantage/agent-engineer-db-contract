---
id: "rel:knowledge_service.operation_step#details"
kind: details
schema: knowledge_service
name: operation_step
of: "rel:knowledge_service.operation_step"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.operation_step — details

Spill-over from [the main page](operation_step.md).

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](operation.md)`.tenant_id,id` on delete restrict.
Inbound: [`knowledge_service.lease`](lease.md).operation_step_id, [`knowledge_service.operation_event`](operation_event.md).step_id, [`knowledge_service.receipt`](receipt.md).step_id, [`orchestration.verification_provider_attempt`](../orchestration/verification_provider_attempt.md).operation_step_id, [`orchestration.verification_provider_response_capture`](../orchestration/verification_provider_response_capture.md).operation_step_id, [`orchestration.verification_semantic_response_observation`](../orchestration/verification_semantic_response_observation.md).operation_step_id, [`orchestration.verification_structured_extraction`](../orchestration/verification_structured_extraction.md).operation_step_id, [`orchestration.verification_structured_extraction_execution`](../orchestration/verification_structured_extraction_execution.md).operation_step_id.

## Indexes

| Index | Definition |
| --- | --- |
| `knowledge_step_queue_idx` | `CREATE INDEX knowledge_step_queue_idx ON knowledge_service.operation_step USING btree (tenant_id, status, available_at) WHERE (status = 'queued'::text)` |
| `operation_step_tenant_id_id_key` | `CREATE UNIQUE INDEX operation_step_tenant_id_id_key ON knowledge_service.operation_step USING btree (tenant_id, id)` |
| `operation_step_tenant_id_operation_id_step_key_key` | `CREATE UNIQUE INDEX operation_step_tenant_id_operation_id_step_key_key ON knowledge_service.operation_step USING btree (tenant_id, operation_id, step_key)` |

## Triggers

- `operation_step_terminal_guard` → [`knowledge_service.guard_operation_terminal`](../../functions/knowledge_service/guard_operation_terminal.md): `CREATE TRIGGER operation_step_terminal_guard BEFORE DELETE OR UPDATE ON knowledge_service.operation_step FOR EACH ROW EXECUTE FUNCTION knowledge_service.guard_operation_terminal()`
- `verification_benchmark_comparison_step_success` → [`evaluation.guard_verification_benchmark_comparison_step_success`](../../functions/evaluation/guard_verification_benchmark_comparison_step_success.md): `CREATE TRIGGER verification_benchmark_comparison_step_success BEFORE INSERT OR UPDATE ON knowledge_service.operation_step FOR EACH ROW EXECUTE FUNCTION evaluation.guard_verification_benchmark_comparison_step_success()`
- `verification_benchmark_comparison_terminal_artifact` → [`evaluation.guard_verification_benchmark_comparison_terminal_artifact`](../../functions/evaluation/guard_verification_benchmark_comparison_terminal_artifact.md): `CREATE TRIGGER verification_benchmark_comparison_terminal_artifact BEFORE INSERT OR UPDATE ON knowledge_service.operation_step FOR EACH ROW EXECUTE FUNCTION evaluation.guard_verification_benchmark_comparison_terminal_artifact()`
- `verification_structured_extraction_completion_guard` → [`orchestration.verification_structured_extraction_completion_guard`](../../functions/orchestration/verification_structured_extraction_completion_guard.md): `CREATE TRIGGER verification_structured_extraction_completion_guard BEFORE INSERT OR UPDATE ON knowledge_service.operation_step FOR EACH ROW EXECUTE FUNCTION orchestration.verification_structured_extraction_completion_guard()`
- `verification_structured_extraction_failure_step` → [`orchestration.structured_extraction_failure_terminal_guard`](../../functions/orchestration/structured_extraction_failure_terminal_guard.md): `CREATE TRIGGER verification_structured_extraction_failure_step BEFORE INSERT OR UPDATE ON knowledge_service.operation_step FOR EACH ROW EXECUTE FUNCTION orchestration.structured_extraction_failure_terminal_guard()`
- `verification_structured_extraction_failure_terminal_commit` → [`orchestration.guard_structured_extraction_failure_terminal_commit`](../../functions/orchestration/guard_structured_extraction_failure_terminal_commit.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER verification_structured_extraction_failure_terminal_commit AFTER INSERT OR UPDATE ON knowledge_service.operation_step DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION orchestration.guard_structured_extraction_failure_terminal_commit()`
- `verification_structured_extraction_input_custody` → [`orchestration.guard_structured_extraction_input_custody`](../../functions/orchestration/guard_structured_extraction_input_custody.md): `CREATE TRIGGER verification_structured_extraction_input_custody BEFORE INSERT OR UPDATE ON knowledge_service.operation_step FOR EACH ROW EXECUTE FUNCTION orchestration.guard_structured_extraction_input_custody()`
- `verification_structured_extraction_owner_custody` → [`orchestration.guard_structured_extraction_owner_custody`](../../functions/orchestration/guard_structured_extraction_owner_custody.md): `CREATE TRIGGER verification_structured_extraction_owner_custody BEFORE UPDATE ON knowledge_service.operation_step FOR EACH ROW EXECUTE FUNCTION orchestration.guard_structured_extraction_owner_custody()`
- `verification_structured_extraction_step_membership` → [`orchestration.guard_structured_extraction_step_membership`](../../functions/orchestration/guard_structured_extraction_step_membership.md): `CREATE TRIGGER verification_structured_extraction_step_membership BEFORE INSERT OR UPDATE ON knowledge_service.operation_step FOR EACH ROW EXECUTE FUNCTION orchestration.guard_structured_extraction_step_membership()`
- `verification_structured_extraction_terminal_commit` → [`orchestration.guard_structured_extraction_terminal_commit`](../../functions/orchestration/guard_structured_extraction_terminal_commit.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER verification_structured_extraction_terminal_commit AFTER INSERT OR UPDATE ON knowledge_service.operation_step DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION orchestration.guard_structured_extraction_terminal_commit()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
