---
id: "fn:orchestration.verification_semantic_response_observation_guard()"
kind: function
schema: orchestration
name: verification_semantic_response_observation_guard
domain: orchestration-ledger
overloads: ["fn:orchestration.verification_semantic_response_observation_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [semantic observation artifact inadmissible, semantic observation exact blinded-input request closure mismatch, semantic observation exact response-envelope closure mismatch, semantic observation producer attempt binding mismatch, semantic observation provider attempt binding mismatch, semantic observation stale closed-scope lease, semantic observations append-only]
touches: { reads: [knowledge_service.operation, knowledge_service.operation_step, orchestration.artifact, orchestration.verification_artifact_metadata, orchestration.verification_provider_attempt, orchestration.verification_provider_response_capture], writes: [] }
tokens: [orchestration, verification_semantic_response_observation_guard, orchestration.verification_semantic_response_observation_guard]
defined_in: ["20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_semantic_response_observation_guard

Domain `orchestration-ledger`.

## verification_semantic_response_observation_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `semantic observation artifact inadmissible`; `semantic observation exact blinded-input request closure mismatch`; `semantic observation exact response-envelope closure mismatch`; `semantic observation producer attempt binding mismatch`; `semantic observation provider attempt binding mismatch`; `semantic observation stale closed-scope lease`; `semantic observations append-only`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md), [`orchestration.verification_provider_attempt`](../../relations/orchestration/verification_provider_attempt.md), [`orchestration.verification_provider_response_capture`](../../relations/orchestration/verification_provider_response_capture.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md), [`orchestration.verification_provider_scope_tuple_is_live`](verification_provider_scope_tuple_is_live.md).

Defined in: `20260907013000_verification_semantic_provider_observation.sql`.
