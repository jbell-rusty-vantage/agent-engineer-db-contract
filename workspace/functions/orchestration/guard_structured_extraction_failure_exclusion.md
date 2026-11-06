---
id: "fn:orchestration.guard_structured_extraction_failure_exclusion()"
kind: function
schema: orchestration
name: guard_structured_extraction_failure_exclusion
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_structured_extraction_failure_exclusion()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction failure forbids candidate retention]
touches: { reads: [orchestration.verification_structured_extraction_failure], writes: [] }
tokens: [orchestration, guard_structured_extraction_failure_exclusion, orchestration.guard_structured_extraction_failure_exclusion]
defined_in: ["20260906032500_verification_structured_extraction_failure.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.guard_structured_extraction_failure_exclusion

Domain `orchestration-ledger`.

## guard_structured_extraction_failure_exclusion() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction failure forbids candidate retention`.

Touches (best effort): reads [`orchestration.verification_structured_extraction_failure`](../../relations/orchestration/verification_structured_extraction_failure.md); writes —; calls —.

Defined in: `20260906032500_verification_structured_extraction_failure.sql`.
