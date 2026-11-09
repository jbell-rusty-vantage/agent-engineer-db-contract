---
id: "fn:orchestration.validate_verification_artifact_metadata()"
kind: function
schema: orchestration
name: validate_verification_artifact_metadata
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.validate_verification_artifact_metadata()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [verification metadata requires a marked same-tenant artifact, verification parents and attestations require available marked same-tenant registrations, verification parents must be distinct and nonnull, verification parents require a transformation signature]
touches: { reads: [orchestration.artifact, orchestration.verification_artifact_metadata], writes: [] }
tokens: [orchestration, validate_verification_artifact_metadata, orchestration.validate_verification_artifact_metadata]
defined_in: ["20260906020000_verification_artifact_contract_marker.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# orchestration.validate_verification_artifact_metadata

Domain `orchestration-ledger`, lens `machinery`.

## validate_verification_artifact_metadata() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `verification metadata requires a marked same-tenant artifact`; `verification parents and attestations require available marked same-tenant registrations`; `verification parents must be distinct and nonnull`; `verification parents require a transformation signature`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

Defined in: `20260906020000_verification_artifact_contract_marker.sql`.
