---
id: "fn:orchestration.guard_structured_extraction_input_custody()"
kind: function
schema: orchestration
name: guard_structured_extraction_input_custody
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_structured_extraction_input_custody()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction bound operation input is immutable, structured extraction bound step input is immutable, structured extraction bound step set is immutable, structured extraction terminal requires exactly one step]
touches: { reads: [knowledge_service.operation, knowledge_service.operation_step, orchestration.verification_structured_extraction_execution], writes: [] }
tokens: [orchestration, guard_structured_extraction_input_custody, orchestration.guard_structured_extraction_input_custody]
defined_in: ["20260906032200_verification_structured_extraction_input_custody.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# orchestration.guard_structured_extraction_input_custody

Domain `orchestration-ledger`, lens `machinery`.

## guard_structured_extraction_input_custody() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction bound operation input is immutable`; `structured extraction bound step input is immutable`; `structured extraction bound step set is immutable`; `structured extraction terminal requires exactly one step`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md); writes —; calls —.

Defined in: `20260906032200_verification_structured_extraction_input_custody.sql`.
