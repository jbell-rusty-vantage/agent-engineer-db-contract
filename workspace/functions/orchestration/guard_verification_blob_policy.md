---
id: "fn:orchestration.guard_verification_blob_policy()"
kind: function
schema: orchestration
name: guard_verification_blob_policy
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_verification_blob_policy()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [artifact blob policy mismatch]
touches: { reads: [orchestration.artifact, orchestration.verification_artifact_metadata], writes: [] }
tokens: [orchestration, guard_verification_blob_policy, orchestration.guard_verification_blob_policy]
defined_in: ["20260914010000_artifact_logical_custody.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.guard_verification_blob_policy

Domain `orchestration-ledger`.

## guard_verification_blob_policy() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `artifact blob policy mismatch`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

Defined in: `20260914010000_artifact_logical_custody.sql`.
