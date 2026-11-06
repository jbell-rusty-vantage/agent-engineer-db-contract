---
id: "fn:orchestration.guard_structured_extraction_failure()"
kind: function
schema: orchestration
name: guard_structured_extraction_failure
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_structured_extraction_failure()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction failure accounting drift, structured extraction failure active claim required, structured extraction failure identity is immutable, structured extraction failure is immutable, structured extraction failure lifecycle or classification mismatch, structured extraction failure must initialize first, structured extraction failure operation not active, structured extraction failure provider mismatch, structured extraction failure publication semantic mismatch, structured extraction failure stale lease, structured extraction failure typed source required]
touches: { reads: [knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_step, orchestration.artifact, orchestration.verification_artifact_metadata, orchestration.verification_provider_attempt, orchestration.verification_structured_extraction, orchestration.verification_structured_extraction_execution, orchestration.verification_structured_extraction_publication], writes: [] }
tokens: [orchestration, guard_structured_extraction_failure, orchestration.guard_structured_extraction_failure]
defined_in: ["20260906032500_verification_structured_extraction_failure.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.guard_structured_extraction_failure

Domain `orchestration-ledger`.

## guard_structured_extraction_failure() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction failure accounting drift`; `structured extraction failure active claim required`; `structured extraction failure identity is immutable`; `structured extraction failure is immutable`; `structured extraction failure lifecycle or classification mismatch`; `structured extraction failure must initialize first`; `structured extraction failure operation not active`; `structured extraction failure provider mismatch`; `structured extraction failure publication semantic mismatch`; `structured extraction failure stale lease`; `structured extraction failure typed source required`.

Touches (best effort): reads [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md), [`orchestration.verification_provider_attempt`](../../relations/orchestration/verification_provider_attempt.md), [`orchestration.verification_structured_extraction`](../../relations/orchestration/verification_structured_extraction.md), [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md), [`orchestration.verification_structured_extraction_publication`](../../relations/orchestration/verification_structured_extraction_publication.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md).

Defined in: `20260906032500_verification_structured_extraction_failure.sql`.
