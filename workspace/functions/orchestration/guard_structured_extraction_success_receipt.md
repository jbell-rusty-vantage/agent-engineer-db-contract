---
id: "fn:orchestration.guard_structured_extraction_success_receipt()"
kind: function
schema: orchestration
name: guard_structured_extraction_success_receipt
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_structured_extraction_success_receipt()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction success receipt binding mismatch]
touches: { reads: [knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_event, knowledge_service.operation_step, knowledge_service.receipt], writes: [] }
tokens: [orchestration, guard_structured_extraction_success_receipt, orchestration.guard_structured_extraction_success_receipt]
defined_in: ["20260906032100_verification_structured_extraction_terminal.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.guard_structured_extraction_success_receipt

Domain `orchestration-ledger`.

## guard_structured_extraction_success_receipt() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction success receipt binding mismatch`.

Touches (best effort): reads [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_event`](../../relations/knowledge_service/operation_event.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`knowledge_service.receipt`](../../relations/knowledge_service/receipt.md); writes —; calls [`orchestration.structured_extraction_receipt_json`](structured_extraction_receipt_json.md), [`orchestration.structured_extraction_result_body`](structured_extraction_result_body.md).

Defined in: `20260906032100_verification_structured_extraction_terminal.sql`.
