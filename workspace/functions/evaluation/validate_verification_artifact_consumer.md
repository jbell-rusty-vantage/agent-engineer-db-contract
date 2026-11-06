---
id: "fn:evaluation.validate_verification_artifact_consumer()"
kind: function
schema: evaluation
name: validate_verification_artifact_consumer
domain: evaluation
overloads: ["fn:evaluation.validate_verification_artifact_consumer()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["verification artifact consumer trigger attached to unsupported table %", verification evaluation case requires admitted input and label-provenance-compatible expectation artifacts from its exact dataset version, verification evaluation label requires an admitted gold-label artifact with matching digest, verification evaluation run requires admitted run-manifest and policy artifacts, verification evaluation score requires an admitted deterministic result artifact with matching digest, verification experiment arm requires an admitted configuration artifact with matching digest, verification grader version requires an admitted grader manifest with matching digest]
touches: { reads: [], writes: [] }
tokens: [evaluation, validate_verification_artifact_consumer, evaluation.validate_verification_artifact_consumer]
defined_in: ["20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.validate_verification_artifact_consumer

Domain `evaluation`.

## validate_verification_artifact_consumer() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification artifact consumer trigger attached to unsupported table %`; `verification evaluation case requires admitted input and label-provenance-compatible expectation artifacts from its exact dataset version`; `verification evaluation label requires an admitted gold-label artifact with matching digest`; `verification evaluation run requires admitted run-manifest and policy artifacts`; `verification evaluation score requires an admitted deterministic result artifact with matching digest`; `verification experiment arm requires an admitted configuration artifact with matching digest`; `verification grader version requires an admitted grader manifest with matching digest`.

Touches (best effort): reads —; writes —; calls [`evaluation.verification_case_artifacts_are_admitted`](verification_case_artifacts_are_admitted.md), [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

Defined in: `20260906021000_verification_artifact_consumer_admission.sql`.
