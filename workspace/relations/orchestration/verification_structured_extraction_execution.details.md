---
id: "rel:orchestration.verification_structured_extraction_execution#details"
kind: details
schema: orchestration
name: verification_structured_extraction_execution
of: "rel:orchestration.verification_structured_extraction_execution"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.verification_structured_extraction_execution — details

Spill-over from [the main page](verification_structured_extraction_execution.md).

## Relationships

Outbound: `tenant_id,producer_attempt_id` → [`orchestration.attempt`](attempt.md)`.tenant_id,id`; `tenant_id,profile_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,execution_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,operation_step_id` → [`knowledge_service.operation_step`](../knowledge_service/operation_step.md)`.tenant_id,id`; `tenant_id,dirty_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id`.
Inbound: [`orchestration.verification_structured_extraction_failure`](verification_structured_extraction_failure.md).operation_id, [`orchestration.verification_structured_extraction_publication`](verification_structured_extraction_publication.md).operation_id.

## Indexes

_None._

## Triggers

- `artifact_retirement_03dfe7d63ead38cf6b8b527f` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_03dfe7d63ead38cf6b8b527f BEFORE INSERT OR UPDATE ON orchestration.verification_structured_extraction_execution FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "dirty_artifact_id", "parent": "id"}]')`
- `artifact_retirement_0951a2f767de80a2cb3c8b32` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_0951a2f767de80a2cb3c8b32 BEFORE INSERT OR UPDATE ON orchestration.verification_structured_extraction_execution FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "execution_artifact_id", "parent": "id"}]')`
- `artifact_retirement_16fbe6fa517b63b7940dff78` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_16fbe6fa517b63b7940dff78 BEFORE INSERT OR UPDATE ON orchestration.verification_structured_extraction_execution FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "profile_artifact_id", "parent": "id"}]')`
- `verification_structured_extraction_execution_guard` → [`orchestration.guard_verification_structured_extraction_execution`](../../functions/orchestration/guard_verification_structured_extraction_execution.md): `CREATE TRIGGER verification_structured_extraction_execution_guard BEFORE INSERT OR DELETE OR UPDATE ON orchestration.verification_structured_extraction_execution FOR EACH ROW EXECUTE FUNCTION orchestration.guard_verification_structured_extraction_execution()`
- `verification_structured_extraction_execution_source_guard` → [`orchestration.guard_structured_extraction_source_custody`](../../functions/orchestration/guard_structured_extraction_source_custody.md): `CREATE TRIGGER verification_structured_extraction_execution_source_guard BEFORE INSERT ON orchestration.verification_structured_extraction_execution FOR EACH ROW EXECUTE FUNCTION orchestration.guard_structured_extraction_source_custody()`

## Row-level security

Enabled.
- `verification_structured_extraction_execution_reader` (SELECT) for `app_reader`: using `(tenant_id = util.current_tenant_id())`
- `verification_structured_extraction_execution_worker` (ALL) for `control_plane`, `executor_service`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
