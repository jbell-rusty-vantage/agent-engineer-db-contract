---
id: "fn:orchestration.guard_structured_extraction_owner_custody()"
kind: function
schema: orchestration
name: guard_structured_extraction_owner_custody
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_structured_extraction_owner_custody()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction bound owner and creation identity is immutable, structured extraction bound step creation and retry limit is immutable]
touches: { reads: [orchestration.verification_structured_extraction_execution], writes: [] }
tokens: [orchestration, guard_structured_extraction_owner_custody, orchestration.guard_structured_extraction_owner_custody]
defined_in: ["20260906032400_verification_structured_extraction_owner_custody.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.guard_structured_extraction_owner_custody

Domain `orchestration-ledger`.

## guard_structured_extraction_owner_custody() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction bound owner and creation identity is immutable`; `structured extraction bound step creation and retry limit is immutable`.

Touches (best effort): reads [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md); writes —; calls —.

Defined in: `20260906032400_verification_structured_extraction_owner_custody.sql`.
