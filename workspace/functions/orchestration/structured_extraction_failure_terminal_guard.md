---
id: "fn:orchestration.structured_extraction_failure_terminal_guard()"
kind: function
schema: orchestration
name: structured_extraction_failure_terminal_guard
domain: orchestration-ledger
overloads: ["fn:orchestration.structured_extraction_failure_terminal_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [captured extraction failure cannot requeue, captured extraction failure requires exactly one step, structured extraction operation failure requires one exact receipt, structured extraction terminal output binding mismatch, structured extraction terminal requires published custody and active claim, structured extraction terminal stale lease, structured extraction terminal step binding mismatch]
touches: { reads: [knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_step, knowledge_service.receipt, orchestration.verification_structured_extraction, orchestration.verification_structured_extraction_failure], writes: [] }
tokens: [orchestration, structured_extraction_failure_terminal_guard, orchestration.structured_extraction_failure_terminal_guard]
defined_in: ["20260906032600_verification_structured_extraction_failure_terminal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.structured_extraction_failure_terminal_guard

Domain `orchestration-ledger`.

## structured_extraction_failure_terminal_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `captured extraction failure cannot requeue`; `captured extraction failure requires exactly one step`; `structured extraction operation failure requires one exact receipt`; `structured extraction terminal output binding mismatch`; `structured extraction terminal requires published custody and active claim`; `structured extraction terminal stale lease`; `structured extraction terminal step binding mismatch`.

Touches (best effort): reads [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`knowledge_service.receipt`](../../relations/knowledge_service/receipt.md), [`orchestration.verification_structured_extraction`](../../relations/orchestration/verification_structured_extraction.md), [`orchestration.verification_structured_extraction_failure`](../../relations/orchestration/verification_structured_extraction_failure.md); writes —; calls [`orchestration.structured_extraction_failure_result_body`](structured_extraction_failure_result_body.md), [`orchestration.structured_extraction_receipt_json`](structured_extraction_receipt_json.md).

Defined in: `20260906032600_verification_structured_extraction_failure_terminal.sql`.
