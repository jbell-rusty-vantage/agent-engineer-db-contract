---
id: "fn:evaluation.validate_verification_dataset_manifest()"
kind: function
schema: evaluation
name: validate_verification_dataset_manifest
domain: evaluation
lens: machinery
overloads: ["fn:evaluation.validate_verification_dataset_manifest()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification dataset version requires an available marked metadata-backed same-tenant dataset manifest artifact with matching digest]
touches: { reads: [], writes: [] }
tokens: [evaluation, validate_verification_dataset_manifest, evaluation.validate_verification_dataset_manifest]
defined_in: ["20260906019000_verification_evaluation_dataset_manifest.sql", "20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# evaluation.validate_verification_dataset_manifest

Domain `evaluation`, lens `machinery`.

## validate_verification_dataset_manifest() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification dataset version requires an available marked metadata-backed same-tenant dataset manifest artifact with matching digest`.

Touches (best effort): reads —; writes —; calls [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

Defined in: `20260906019000_verification_evaluation_dataset_manifest.sql`, `20260906021000_verification_artifact_consumer_admission.sql`.
