---
id: "fn:orchestration.guard_verification_structured_extraction_publication()"
kind: function
schema: orchestration
name: guard_verification_structured_extraction_publication
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_verification_structured_extraction_publication()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction publication accounting drift, structured extraction publication active claim required, structured extraction publication is immutable, structured extraction publication lifecycle mismatch, structured extraction publication operation not active, structured extraction publication provider mismatch, structured extraction publication semantic binding mismatch, structured extraction publication stale lease]
touches: { reads: [knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_step, orchestration.artifact, orchestration.verification_artifact_metadata, orchestration.verification_provider_attempt, orchestration.verification_structured_extraction, orchestration.verification_structured_extraction_execution], writes: [] }
tokens: [orchestration, guard_verification_structured_extraction_publication, orchestration.guard_verification_structured_extraction_publication]
defined_in: ["20260906031900_verification_structured_extraction_publication.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.guard_verification_structured_extraction_publication

Domain `orchestration-ledger`.

## guard_verification_structured_extraction_publication() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction publication accounting drift`; `structured extraction publication active claim required`; `structured extraction publication is immutable`; `structured extraction publication lifecycle mismatch`; `structured extraction publication operation not active`; `structured extraction publication provider mismatch`; `structured extraction publication semantic binding mismatch`; `structured extraction publication stale lease`.

Touches (best effort): reads [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md), [`orchestration.verification_provider_attempt`](../../relations/orchestration/verification_provider_attempt.md), [`orchestration.verification_structured_extraction`](../../relations/orchestration/verification_structured_extraction.md), [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md).

Defined in: `20260906031900_verification_structured_extraction_publication.sql`.
