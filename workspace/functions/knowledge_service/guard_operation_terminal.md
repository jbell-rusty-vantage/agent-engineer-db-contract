---
id: "fn:knowledge_service.guard_operation_terminal()"
kind: function
schema: knowledge_service
name: guard_operation_terminal
domain: knowledge-service-runtime
lens: machinery
overloads: ["fn:knowledge_service.guard_operation_terminal()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["% state cannot be deleted", retry may only reset execution state, "terminal % state is immutable"]
touches: { reads: [], writes: [] }
tokens: [knowledge_service, guard_operation_terminal, knowledge_service.guard_operation_terminal]
defined_in: ["20260903010200_knowledge_runtime_security.sql", "20260903010800_authorized_operation_retry.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# knowledge_service.guard_operation_terminal

Domain `knowledge-service-runtime`, lens `machinery`.

## guard_operation_terminal() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `% state cannot be deleted`; `retry may only reset execution state`; `terminal % state is immutable`.

Defined in: `20260903010200_knowledge_runtime_security.sql`, `20260903010800_authorized_operation_retry.sql`.
