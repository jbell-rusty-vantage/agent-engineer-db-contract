---
id: "fn:evidence.validate_capture_artifact()"
kind: function
schema: evidence
name: validate_capture_artifact
domain: evidence
overloads: ["fn:evidence.validate_capture_artifact()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [capture must bind a same-tenant registered source artifact with matching bytes, verification.v1 capture requires an available marked metadata-backed same-tenant source artifact with matching bytes and media type]
touches: { reads: [evidence.source, orchestration.artifact], writes: [] }
tokens: [evidence, validate_capture_artifact, evidence.validate_capture_artifact]
defined_in: ["20260905010000_verification_persistence_contract.sql", "20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.validate_capture_artifact

Domain `evidence`.

## validate_capture_artifact() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `capture must bind a same-tenant registered source artifact with matching bytes`; `verification.v1 capture requires an available marked metadata-backed same-tenant source artifact with matching bytes and media type`.

Touches (best effort): reads [`evidence.source`](../../relations/evidence/source.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

Defined in: `20260905010000_verification_persistence_contract.sql`, `20260906021000_verification_artifact_consumer_admission.sql`.
