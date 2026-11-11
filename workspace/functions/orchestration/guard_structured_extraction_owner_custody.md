---
id: "fn:orchestration.guard_structured_extraction_owner_custody()"
kind: function
schema: orchestration
name: guard_structured_extraction_owner_custody
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_structured_extraction_owner_custody()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction bound owner and creation identity is immutable, structured extraction bound step creation and retry limit is immutable]
touches: { reads: [orchestration.verification_structured_extraction_execution], writes: [] }
tokens: [orchestration, guard_structured_extraction_owner_custody, orchestration.guard_structured_extraction_owner_custody]
defined_in: ["20260906032400_verification_structured_extraction_owner_custody.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# orchestration.guard_structured_extraction_owner_custody

Domain `orchestration-ledger`, lens `machinery`.

## guard_structured_extraction_owner_custody() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction bound owner and creation identity is immutable`; `structured extraction bound step creation and retry limit is immutable`.

Touches (best effort): reads [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md); writes —; calls —.

Defined in: `20260906032400_verification_structured_extraction_owner_custody.sql`.
