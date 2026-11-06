---
id: "fn:orchestration.verification_structured_extraction_completion_guard()"
kind: function
schema: orchestration
name: verification_structured_extraction_completion_guard
domain: orchestration-ledger
overloads: ["fn:orchestration.verification_structured_extraction_completion_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction operation success requires one exact receipt, structured extraction terminal output binding mismatch, structured extraction terminal requires published custody and active claim, structured extraction terminal stale lease, structured extraction terminal step binding mismatch]
touches: { reads: [knowledge_service.lease, knowledge_service.operation, knowledge_service.operation_step, knowledge_service.receipt, orchestration.verification_structured_extraction], writes: [] }
tokens: [orchestration, verification_structured_extraction_completion_guard, orchestration.verification_structured_extraction_completion_guard]
defined_in: ["20260906031500_verification_structured_extraction_candidate_artifacts.sql", "20260906032100_verification_structured_extraction_terminal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_structured_extraction_completion_guard

Domain `orchestration-ledger`.

## verification_structured_extraction_completion_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction operation success requires one exact receipt`; `structured extraction terminal output binding mismatch`; `structured extraction terminal requires published custody and active claim`; `structured extraction terminal stale lease`; `structured extraction terminal step binding mismatch`.

Touches (best effort): reads [`knowledge_service.lease`](../../relations/knowledge_service/lease.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_step`](../../relations/knowledge_service/operation_step.md), [`knowledge_service.receipt`](../../relations/knowledge_service/receipt.md), [`orchestration.verification_structured_extraction`](../../relations/orchestration/verification_structured_extraction.md); writes —; calls [`orchestration.structured_extraction_receipt_json`](structured_extraction_receipt_json.md), [`orchestration.structured_extraction_result_body`](structured_extraction_result_body.md).

Defined in: `20260906031500_verification_structured_extraction_candidate_artifacts.sql`, `20260906032100_verification_structured_extraction_terminal.sql`.
