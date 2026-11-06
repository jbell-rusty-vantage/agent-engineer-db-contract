---
id: "fn:evaluation.validate_verification_dataset_manifest()"
kind: function
schema: evaluation
name: validate_verification_dataset_manifest
domain: evaluation
overloads: ["fn:evaluation.validate_verification_dataset_manifest()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification dataset version requires an available marked metadata-backed same-tenant dataset manifest artifact with matching digest]
touches: { reads: [], writes: [] }
tokens: [evaluation, validate_verification_dataset_manifest, evaluation.validate_verification_dataset_manifest]
defined_in: ["20260906019000_verification_evaluation_dataset_manifest.sql", "20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.validate_verification_dataset_manifest

Domain `evaluation`.

## validate_verification_dataset_manifest() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification dataset version requires an available marked metadata-backed same-tenant dataset manifest artifact with matching digest`.

Touches (best effort): reads —; writes —; calls [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

Defined in: `20260906019000_verification_evaluation_dataset_manifest.sql`, `20260906021000_verification_artifact_consumer_admission.sql`.
