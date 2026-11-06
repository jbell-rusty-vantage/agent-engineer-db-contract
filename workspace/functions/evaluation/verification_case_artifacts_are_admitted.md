---
id: "fn:evaluation.verification_case_artifacts_are_admitted(uuid,uuid,uuid,uuid,uuid)"
kind: function
schema: evaluation
name: verification_case_artifacts_are_admitted
domain: evaluation
overloads: ["fn:evaluation.verification_case_artifacts_are_admitted(uuid,uuid,uuid,uuid,uuid)"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [evaluation.eval_dataset_version], writes: [] }
tokens: [evaluation, verification_case_artifacts_are_admitted, evaluation.verification_case_artifacts_are_admitted]
defined_in: ["20260906021000_verification_artifact_consumer_admission.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.verification_case_artifacts_are_admitted

Domain `evaluation`.

## verification_case_artifacts_are_admitted(uuid, uuid, uuid, uuid, uuid) → boolean

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant_id` | `uuid` | — | — |
| `p_dataset_id` | `uuid` | — | — |
| `p_dataset_version_id` | `uuid` | — | — |
| `p_input_artifact_id` | `uuid` | — | — |
| `p_gold_artifact_id` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`evaluation.eval_dataset_version`](../../relations/evaluation/eval_dataset_version.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](../orchestration/verification_artifact_is_admitted.md).

TypeScript: `Database["evaluation"]["Functions"]["verification_case_artifacts_are_admitted"]`.

Defined in: `20260906021000_verification_artifact_consumer_admission.sql`.
