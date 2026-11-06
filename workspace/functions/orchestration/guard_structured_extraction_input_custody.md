---
id: "fn:orchestration.guard_structured_extraction_input_custody()"
kind: function
schema: orchestration
name: guard_structured_extraction_input_custody
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_structured_extraction_input_custody()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction bound operation input is immutable, structured extraction bound step input is immutable, structured extraction bound step set is immutable, structured extraction terminal requires exactly one step]
touches: { reads: [knowledge_service.operation, knowledge_service.operation_step, orchestration.verification_structured_extraction_execution], writes: [] }
tokens: [orchestration, guard_structured_extraction_input_custody, orchestration.guard_structured_extraction_input_custody]
defined_in: ["20260906032200_verification_structured_extraction_input_custody.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.guard_structured_extraction_input_custody

Domain `orchestration-ledger`.

## guard_structured_extraction_input_custody() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction bound operation input is immutable`; `structured extraction bound step input is immutable`; `structured extraction bound step set is immutable`; `structured extraction terminal requires exactly one step`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md); writes —; calls —.

Defined in: `20260906032200_verification_structured_extraction_input_custody.sql`.
