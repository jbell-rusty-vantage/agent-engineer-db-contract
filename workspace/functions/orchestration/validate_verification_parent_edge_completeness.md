---
id: "fn:orchestration.validate_verification_parent_edge_completeness()"
kind: function
schema: orchestration
name: validate_verification_parent_edge_completeness
domain: orchestration-ledger
overloads: ["fn:orchestration.validate_verification_parent_edge_completeness()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification metadata requires complete generated parent edges before commit]
touches: { reads: [orchestration.artifact_lineage], writes: [] }
tokens: [orchestration, validate_verification_parent_edge_completeness, orchestration.validate_verification_parent_edge_completeness]
defined_in: ["20260906020000_verification_artifact_contract_marker.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.validate_verification_parent_edge_completeness

Domain `orchestration-ledger`.

## validate_verification_parent_edge_completeness() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification metadata requires complete generated parent edges before commit`.

Touches (best effort): reads [`orchestration.artifact_lineage`](../../relations/orchestration/artifact_lineage.md); writes —; calls —.

Defined in: `20260906020000_verification_artifact_contract_marker.sql`.
