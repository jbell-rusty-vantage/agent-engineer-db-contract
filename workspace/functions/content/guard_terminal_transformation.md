---
id: "fn:content.guard_terminal_transformation()"
kind: function
schema: content
name: guard_terminal_transformation
domain: content
lens: machinery
overloads: ["fn:content.guard_terminal_transformation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [terminal transformation runs are immutable, transformation runs cannot be deleted]
touches: { reads: [], writes: [] }
tokens: [content, guard_terminal_transformation, content.guard_terminal_transformation]
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# content.guard_terminal_transformation

Domain `content`, lens `machinery`.

## guard_terminal_transformation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `terminal transformation runs are immutable`; `transformation runs cannot be deleted`.

Defined in: `20260903010000_knowledge_content_contract.sql`.
