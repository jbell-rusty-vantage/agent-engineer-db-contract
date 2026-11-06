---
id: "fn:orchestration.guard_verification_structured_extraction_execution()"
kind: function
schema: orchestration
name: guard_verification_structured_extraction_execution
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_verification_structured_extraction_execution()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction dirty source artifact inadmissible, structured extraction execution active claim required, structured extraction execution artifact inadmissible, structured extraction execution canonical operation mismatch, structured extraction execution is immutable, structured extraction execution must precede provider reservation, structured extraction execution semantic binding mismatch, structured extraction execution stale lease, structured extraction execution timestamp invalid]
touches: { reads: [knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_step, orchestration.artifact, orchestration.verification_artifact_metadata, orchestration.verification_provider_attempt], writes: [] }
tokens: [orchestration, guard_verification_structured_extraction_execution, orchestration.guard_verification_structured_extraction_execution]
defined_in: ["20260906031800_verification_structured_extraction_execution.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.guard_verification_structured_extraction_execution

Domain `orchestration-ledger`.

## guard_verification_structured_extraction_execution() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction dirty source artifact inadmissible`; `structured extraction execution active claim required`; `structured extraction execution artifact inadmissible`; `structured extraction execution canonical operation mismatch`; `structured extraction execution is immutable`; `structured extraction execution must precede provider reservation`; `structured extraction execution semantic binding mismatch`; `structured extraction execution stale lease`; `structured extraction execution timestamp invalid`.

Touches (best effort): reads [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md), [`orchestration.verification_provider_attempt`](../../relations/orchestration/verification_provider_attempt.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md).

Defined in: `20260906031800_verification_structured_extraction_execution.sql`.
