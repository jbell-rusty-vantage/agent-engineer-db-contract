---
id: "fn:evidence.validate_locator_capture_lineage()"
kind: function
schema: evidence
name: validate_locator_capture_lineage
domain: evidence
overloads: ["fn:evidence.validate_locator_capture_lineage()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification.v1 locator requires available marked metadata-backed capture and representation artifacts with exact registered lineage]
touches: { reads: [], writes: [] }
tokens: [evidence, validate_locator_capture_lineage, evidence.validate_locator_capture_lineage]
defined_in: ["20260905013000_verification_legacy_compatibility_and_isolation.sql", "20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.validate_locator_capture_lineage

Domain `evidence`.

## validate_locator_capture_lineage() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification.v1 locator requires available marked metadata-backed capture and representation artifacts with exact registered lineage`.

Touches (best effort): reads —; writes —; calls [`evidence.verification_locator_artifacts_are_admitted`](verification_locator_artifacts_are_admitted.md).

Defined in: `20260905013000_verification_legacy_compatibility_and_isolation.sql`, `20260906021000_verification_artifact_consumer_admission.sql`.
