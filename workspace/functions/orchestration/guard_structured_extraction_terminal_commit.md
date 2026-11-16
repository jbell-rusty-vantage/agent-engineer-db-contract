---
id: "fn:orchestration.guard_structured_extraction_terminal_commit()"
kind: function
schema: orchestration
name: guard_structured_extraction_terminal_commit
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_structured_extraction_terminal_commit()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction terminal transaction requires exact receipt and operation]
touches: { reads: [knowledge_service.operation, knowledge_service.receipt], writes: [] }
tokens: [orchestration, guard_structured_extraction_terminal_commit, orchestration.guard_structured_extraction_terminal_commit]
defined_in: ["20260906032100_verification_structured_extraction_terminal.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# orchestration.guard_structured_extraction_terminal_commit

Domain `orchestration-ledger`, lens `machinery`.

## guard_structured_extraction_terminal_commit() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction terminal transaction requires exact receipt and operation`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.receipt`](../../relations/knowledge_service/receipt.md); writes —; calls [`orchestration.structured_extraction_result_body`](structured_extraction_result_body.md).

Defined in: `20260906032100_verification_structured_extraction_terminal.sql`.
