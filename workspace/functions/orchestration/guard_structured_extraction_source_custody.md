---
id: "fn:orchestration.guard_structured_extraction_source_custody()"
kind: function
schema: orchestration
name: guard_structured_extraction_source_custody
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_structured_extraction_source_custody()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction typed source custody required]
touches: { reads: [orchestration.verification_structured_extraction_execution], writes: [] }
tokens: [orchestration, guard_structured_extraction_source_custody, orchestration.guard_structured_extraction_source_custody]
defined_in: ["20260906032000_verification_structured_extraction_source_custody.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# orchestration.guard_structured_extraction_source_custody

Domain `orchestration-ledger`, lens `machinery`.

## guard_structured_extraction_source_custody() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction typed source custody required`.

Touches (best effort): reads [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md); writes —; calls [`orchestration.verification_artifact_is_admitted`](verification_artifact_is_admitted.md).

Defined in: `20260906032000_verification_structured_extraction_source_custody.sql`.
