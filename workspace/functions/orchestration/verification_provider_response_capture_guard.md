---
id: "fn:orchestration.verification_provider_response_capture_guard()"
kind: function
schema: orchestration
name: verification_provider_response_capture_guard
domain: orchestration-ledger
overloads: ["fn:orchestration.verification_provider_response_capture_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [provider response capture active claim required, provider response capture append-only, provider response capture ledger binding mismatch, provider response capture stale claim, provider response capture transport artifact inadmissible, provider response capture transport semantic binding mismatch]
touches: { reads: [knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_step, orchestration.artifact, orchestration.verification_artifact_metadata, orchestration.verification_provider_attempt], writes: [] }
tokens: [orchestration, verification_provider_response_capture_guard, orchestration.verification_provider_response_capture_guard]
defined_in: ["20260906031400_verification_provider_response_capture.sql", "20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.verification_provider_response_capture_guard

Domain `orchestration-ledger`.

## verification_provider_response_capture_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `provider response capture active claim required`; `provider response capture append-only`; `provider response capture ledger binding mismatch`; `provider response capture stale claim`; `provider response capture transport artifact inadmissible`; `provider response capture transport semantic binding mismatch`.

Touches (best effort): reads [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md), [`orchestration.verification_provider_attempt`](../../relations/orchestration/verification_provider_attempt.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md), [`orchestration.verification_provider_artifacts_are_admitted`](verification_provider_artifacts_are_admitted.md).

Defined in: `20260906031400_verification_provider_response_capture.sql`, `20260907013000_verification_semantic_provider_observation.sql`.
