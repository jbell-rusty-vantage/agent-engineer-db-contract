---
id: "fn:util.uuidv7()"
kind: function
schema: util
name: uuidv7
domain: api-surface
lens: machinery
overloads: ["fn:util.uuidv7()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [util, uuidv7, util.uuidv7]
defined_in: ["20260826000100_foundation.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# util.uuidv7

Domain `api-surface`, lens `machinery`.

## uuidv7() → uuid

function, volatile, security invoker, language sql, config `search_path=""`. Time-ordered UUID v7. Replace with the built-in uuidv7() on PostgreSQL 18+.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

TypeScript: `Database["util"]["Functions"]["uuidv7"]`.

Defined in: `20260826000100_foundation.sql`.
