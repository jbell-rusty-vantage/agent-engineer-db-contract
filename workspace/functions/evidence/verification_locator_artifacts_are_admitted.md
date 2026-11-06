---
id: "fn:evidence.verification_locator_artifacts_are_admitted(uuid,uuid,uuid)"
kind: function
schema: evidence
name: verification_locator_artifacts_are_admitted
domain: evidence
overloads: ["fn:evidence.verification_locator_artifacts_are_admitted(uuid,uuid,uuid)"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [evidence.source_capture, orchestration.artifact_lineage, orchestration.verification_artifact_metadata], writes: [] }
tokens: [evidence, verification_locator_artifacts_are_admitted, evidence.verification_locator_artifacts_are_admitted]
defined_in: ["20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.verification_locator_artifacts_are_admitted

Domain `evidence`.

## verification_locator_artifacts_are_admitted(uuid, uuid, uuid) → boolean

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant_id` | `uuid` | — | — |
| `p_capture_id` | `uuid` | — | — |
| `p_representation_artifact_id` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`evidence.source_capture`](../../relations/evidence/source_capture.md), [`orchestration.artifact_lineage`](../../relations/orchestration/artifact_lineage.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

TypeScript: `Database["evidence"]["Functions"]["verification_locator_artifacts_are_admitted"]`.

Defined in: `20260906021000_verification_artifact_consumer_admission.sql`.
