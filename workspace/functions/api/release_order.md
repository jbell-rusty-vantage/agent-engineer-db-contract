---
id: "fn:api.release_order(text)"
kind: function
schema: api
name: release_order
domain: api-surface
lens: corpus
overloads: ["fn:api.release_order(text)"]
security: invoker
volatility: immutable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [api, release_order, api.release_order]
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.release_order

Domain `api-surface`, lens `corpus`.

## release_order(text) → integer[]

function, immutable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tag` | `text` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

TypeScript: `Database["api"]["Functions"]["release_order"]`.

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
