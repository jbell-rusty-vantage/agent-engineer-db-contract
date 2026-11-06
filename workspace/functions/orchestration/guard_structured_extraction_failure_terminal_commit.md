---
id: "fn:orchestration.guard_structured_extraction_failure_terminal_commit()"
kind: function
schema: orchestration
name: guard_structured_extraction_failure_terminal_commit
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_structured_extraction_failure_terminal_commit()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction terminal transaction requires exact receipt and operation]
touches: { reads: [knowledge_service.operation, knowledge_service.receipt, orchestration.verification_structured_extraction_failure], writes: [] }
tokens: [orchestration, guard_structured_extraction_failure_terminal_commit, orchestration.guard_structured_extraction_failure_terminal_commit]
defined_in: ["20260906032600_verification_structured_extraction_failure_terminal.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.guard_structured_extraction_failure_terminal_commit

Domain `orchestration-ledger`.

## guard_structured_extraction_failure_terminal_commit() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction terminal transaction requires exact receipt and operation`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.receipt`](../../relations/knowledge_service/receipt.md), [`orchestration.verification_structured_extraction_failure`](../../relations/orchestration/verification_structured_extraction_failure.md); writes —; calls [`orchestration.structured_extraction_failure_result_body`](structured_extraction_failure_result_body.md).

Defined in: `20260906032600_verification_structured_extraction_failure_terminal.sql`.
