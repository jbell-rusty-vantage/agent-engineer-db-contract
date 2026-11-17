---
id: "fn:orchestration.verification_provider_artifacts_are_admitted(uuid,uuid,text,uuid)"
kind: function
schema: orchestration
name: verification_provider_artifacts_are_admitted
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.verification_provider_artifacts_are_admitted(uuid,uuid,text,uuid)"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [orchestration.verification_artifact_metadata], writes: [] }
tokens: [orchestration, verification_provider_artifacts_are_admitted, orchestration.verification_provider_artifacts_are_admitted]
defined_in: ["20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# orchestration.verification_provider_artifacts_are_admitted

Domain `orchestration-ledger`, lens `machinery`.

## verification_provider_artifacts_are_admitted(uuid, uuid, text, uuid) → boolean

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant_id` | `uuid` | — | — |
| `p_request_artifact_id` | `uuid` | — | — |
| `p_request_sha256` | `text` | — | — |
| `p_response_artifact_id` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md).

TypeScript: `Database["orchestration"]["Functions"]["verification_provider_artifacts_are_admitted"]`.

Defined in: `20260906021000_verification_artifact_consumer_admission.sql`.
