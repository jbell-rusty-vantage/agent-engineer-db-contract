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
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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
