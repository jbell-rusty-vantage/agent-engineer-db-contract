---
id: "fn:orchestration.guard_verification_blob_policy()"
kind: function
schema: orchestration
name: guard_verification_blob_policy
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_verification_blob_policy()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [artifact blob policy mismatch]
touches: { reads: [orchestration.artifact, orchestration.verification_artifact_metadata], writes: [] }
tokens: [orchestration, guard_verification_blob_policy, orchestration.guard_verification_blob_policy]
defined_in: ["20260914010000_artifact_logical_custody.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# orchestration.guard_verification_blob_policy

Domain `orchestration-ledger`, lens `machinery`.

## guard_verification_blob_policy() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `artifact blob policy mismatch`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

Defined in: `20260914010000_artifact_logical_custody.sql`.
