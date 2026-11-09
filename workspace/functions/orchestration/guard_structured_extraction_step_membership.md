---
id: "fn:orchestration.guard_structured_extraction_step_membership()"
kind: function
schema: orchestration
name: guard_structured_extraction_step_membership
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_structured_extraction_step_membership()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction bound step membership is immutable]
touches: { reads: [orchestration.verification_structured_extraction_execution], writes: [] }
tokens: [orchestration, guard_structured_extraction_step_membership, orchestration.guard_structured_extraction_step_membership]
defined_in: ["20260906032300_verification_structured_extraction_step_membership.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# orchestration.guard_structured_extraction_step_membership

Domain `orchestration-ledger`, lens `machinery`.

## guard_structured_extraction_step_membership() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction bound step membership is immutable`.

Touches (best effort): reads [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md); writes —; calls —.

Defined in: `20260906032300_verification_structured_extraction_step_membership.sql`.
