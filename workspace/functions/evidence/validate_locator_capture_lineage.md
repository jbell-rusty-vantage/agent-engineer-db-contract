---
id: "fn:evidence.validate_locator_capture_lineage()"
kind: function
schema: evidence
name: validate_locator_capture_lineage
domain: evidence
lens: machinery
overloads: ["fn:evidence.validate_locator_capture_lineage()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification.v1 locator requires available marked metadata-backed capture and representation artifacts with exact registered lineage]
touches: { reads: [], writes: [] }
tokens: [evidence, validate_locator_capture_lineage, evidence.validate_locator_capture_lineage]
defined_in: ["20260905013000_verification_legacy_compatibility_and_isolation.sql", "20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# evidence.validate_locator_capture_lineage

Domain `evidence`, lens `machinery`.

## validate_locator_capture_lineage() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification.v1 locator requires available marked metadata-backed capture and representation artifacts with exact registered lineage`.

Touches (best effort): reads —; writes —; calls [`evidence.verification_locator_artifacts_are_admitted`](verification_locator_artifacts_are_admitted.md).

Defined in: `20260905013000_verification_legacy_compatibility_and_isolation.sql`, `20260906021000_verification_artifact_consumer_admission.sql`.
