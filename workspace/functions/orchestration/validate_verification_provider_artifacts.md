---
id: "fn:orchestration.validate_verification_provider_artifacts()"
kind: function
schema: orchestration
name: validate_verification_provider_artifacts
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.validate_verification_provider_artifacts()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification provider attempt requires an admitted request and exact request-bound response-envelope lineage]
touches: { reads: [], writes: [] }
tokens: [orchestration, validate_verification_provider_artifacts, orchestration.validate_verification_provider_artifacts]
defined_in: ["20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# orchestration.validate_verification_provider_artifacts

Domain `orchestration-ledger`, lens `machinery`.

## validate_verification_provider_artifacts() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification provider attempt requires an admitted request and exact request-bound response-envelope lineage`.

Touches (best effort): reads —; writes —; calls [`orchestration.verification_provider_artifacts_are_admitted`](verification_provider_artifacts_are_admitted.md).

Defined in: `20260906021000_verification_artifact_consumer_admission.sql`.
