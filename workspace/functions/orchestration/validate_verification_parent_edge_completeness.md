---
id: "fn:orchestration.validate_verification_parent_edge_completeness()"
kind: function
schema: orchestration
name: validate_verification_parent_edge_completeness
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.validate_verification_parent_edge_completeness()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification metadata requires complete generated parent edges before commit]
touches: { reads: [orchestration.artifact_lineage], writes: [] }
tokens: [orchestration, validate_verification_parent_edge_completeness, orchestration.validate_verification_parent_edge_completeness]
defined_in: ["20260906020000_verification_artifact_contract_marker.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# orchestration.validate_verification_parent_edge_completeness

Domain `orchestration-ledger`, lens `machinery`.

## validate_verification_parent_edge_completeness() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification metadata requires complete generated parent edges before commit`.

Touches (best effort): reads [`orchestration.artifact_lineage`](../../relations/orchestration/artifact_lineage.md); writes —; calls —.

Defined in: `20260906020000_verification_artifact_contract_marker.sql`.
