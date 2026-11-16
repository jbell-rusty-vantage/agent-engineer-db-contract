---
id: "fn:retrieval.guard_terminal_status()"
kind: function
schema: retrieval
name: guard_terminal_status
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.guard_terminal_status()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["% cannot be deleted", "terminal % is immutable"]
touches: { reads: [], writes: [] }
tokens: [retrieval, guard_terminal_status, retrieval.guard_terminal_status]
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# retrieval.guard_terminal_status

Domain `retrieval`, lens `machinery`.

## guard_terminal_status() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `% cannot be deleted`; `terminal % is immutable`.

Defined in: `20260903010200_knowledge_runtime_security.sql`.
