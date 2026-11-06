---
id: "fn:orchestration.validate_verification_artifact_lineage()"
kind: function
schema: orchestration
name: validate_verification_artifact_lineage
domain: orchestration-ledger
overloads: ["fn:orchestration.validate_verification_artifact_lineage()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification lineage must match immutable registered parent metadata]
touches: { reads: [orchestration.artifact, orchestration.verification_artifact_metadata], writes: [] }
tokens: [orchestration, validate_verification_artifact_lineage, orchestration.validate_verification_artifact_lineage]
defined_in: ["20260906020000_verification_artifact_contract_marker.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.validate_verification_artifact_lineage

Domain `orchestration-ledger`.

## validate_verification_artifact_lineage() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification lineage must match immutable registered parent metadata`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

Defined in: `20260906020000_verification_artifact_contract_marker.sql`.
