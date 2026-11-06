---
id: "fn:orchestration.guard_structured_extraction_step_membership()"
kind: function
schema: orchestration
name: guard_structured_extraction_step_membership
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_structured_extraction_step_membership()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction bound step membership is immutable]
touches: { reads: [orchestration.verification_structured_extraction_execution], writes: [] }
tokens: [orchestration, guard_structured_extraction_step_membership, orchestration.guard_structured_extraction_step_membership]
defined_in: ["20260906032300_verification_structured_extraction_step_membership.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.guard_structured_extraction_step_membership

Domain `orchestration-ledger`.

## guard_structured_extraction_step_membership() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction bound step membership is immutable`.

Touches (best effort): reads [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md); writes —; calls —.

Defined in: `20260906032300_verification_structured_extraction_step_membership.sql`.
