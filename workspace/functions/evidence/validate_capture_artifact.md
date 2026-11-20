---
id: "fn:evidence.validate_capture_artifact()"
kind: function
schema: evidence
name: validate_capture_artifact
domain: evidence
lens: machinery
overloads: ["fn:evidence.validate_capture_artifact()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [capture must bind a same-tenant registered source artifact with matching bytes, verification.v1 capture requires an available marked metadata-backed same-tenant source artifact with matching bytes and media type]
touches: { reads: [evidence.source, orchestration.artifact], writes: [] }
tokens: [evidence, validate_capture_artifact, evidence.validate_capture_artifact]
defined_in: ["20260905010000_verification_persistence_contract.sql", "20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# evidence.validate_capture_artifact

Domain `evidence`, lens `machinery`.

## validate_capture_artifact() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `capture must bind a same-tenant registered source artifact with matching bytes`; `verification.v1 capture requires an available marked metadata-backed same-tenant source artifact with matching bytes and media type`.

Touches (best effort): reads [`evidence.source`](../../relations/evidence/source.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

Defined in: `20260905010000_verification_persistence_contract.sql`, `20260906021000_verification_artifact_consumer_admission.sql`.
