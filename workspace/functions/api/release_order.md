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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
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
