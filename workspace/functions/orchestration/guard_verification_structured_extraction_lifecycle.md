---
id: "fn:orchestration.guard_verification_structured_extraction_lifecycle()"
kind: function
schema: orchestration
name: guard_verification_structured_extraction_lifecycle
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_verification_structured_extraction_lifecycle()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction candidate semantic binding mismatch, structured extraction canonical operation identity mismatch, structured extraction lifecycle active claim required, structured extraction lifecycle cannot be deleted, structured extraction lifecycle immutable identity, structured extraction lifecycle must initialize running, structured extraction lifecycle transition invalid, structured extraction live step identity mismatch, structured extraction original capture binding mismatch, structured extraction precontext semantic binding mismatch, structured extraction provenance semantic binding mismatch, structured extraction response ancestry mismatch, structured extraction retained transition changes immutable state, structured extraction retaining transition changes immutable state, structured extraction source/profile/schema admission mismatch]
touches: { reads: [evidence.source_capture, knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_step, orchestration.artifact, orchestration.verification_artifact_metadata, orchestration.verification_provider_attempt, orchestration.verification_provider_response_capture], writes: [] }
tokens: [orchestration, guard_verification_structured_extraction_lifecycle, orchestration.guard_verification_structured_extraction_lifecycle]
defined_in: ["20260906031700_verification_structured_extraction_lifecycle.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.guard_verification_structured_extraction_lifecycle

Domain `orchestration-ledger`.

## guard_verification_structured_extraction_lifecycle() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction candidate semantic binding mismatch`; `structured extraction canonical operation identity mismatch`; `structured extraction lifecycle active claim required`; `structured extraction lifecycle cannot be deleted`; `structured extraction lifecycle immutable identity`; `structured extraction lifecycle must initialize running`; `structured extraction lifecycle transition invalid`; `structured extraction live step identity mismatch`; `structured extraction original capture binding mismatch`; `structured extraction precontext semantic binding mismatch`; `structured extraction provenance semantic binding mismatch`; `structured extraction response ancestry mismatch`; `structured extraction retained transition changes immutable state`; `structured extraction retaining transition changes immutable state`; `structured extraction source/profile/schema admission mismatch`.

Touches (best effort): reads [`evidence.source_capture`](../../relations/evidence/source_capture.md), [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md), [`orchestration.verification_provider_attempt`](../../relations/orchestration/verification_provider_attempt.md), [`orchestration.verification_provider_response_capture`](../../relations/orchestration/verification_provider_response_capture.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md), [`orchestration.verification_provider_artifacts_are_admitted`](verification_provider_artifacts_are_admitted.md), [`orchestration.verification_structured_extraction_signature`](verification_structured_extraction_signature.md).

Defined in: `20260906031700_verification_structured_extraction_lifecycle.sql`.
