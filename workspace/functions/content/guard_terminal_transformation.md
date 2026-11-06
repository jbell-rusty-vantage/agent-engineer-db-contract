---
id: "fn:content.guard_terminal_transformation()"
kind: function
schema: content
name: guard_terminal_transformation
domain: content
overloads: ["fn:content.guard_terminal_transformation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [terminal transformation runs are immutable, transformation runs cannot be deleted]
touches: { reads: [], writes: [] }
tokens: [content, guard_terminal_transformation, content.guard_terminal_transformation]
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content.guard_terminal_transformation

Domain `content`.

## guard_terminal_transformation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `terminal transformation runs are immutable`; `transformation runs cannot be deleted`.

Defined in: `20260903010000_knowledge_content_contract.sql`.
