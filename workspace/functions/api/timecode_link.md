---
id: "fn:api.timecode_link(text,int4)"
kind: function
schema: api
name: timecode_link
domain: api-surface
lens: corpus
overloads: ["fn:api.timecode_link(text,int4)"]
security: invoker
volatility: immutable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [api, timecode_link, api.timecode_link]
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.timecode_link

Domain `api-surface`, lens `corpus`. Used by views: [`api.digest_items`](../../relations/api/digest_items.md).

## timecode_link(text, integer) → text

function, immutable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_url` | `text` | — | — |
| `p_start_ms` | `integer` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

TypeScript: `Database["api"]["Functions"]["timecode_link"]`.

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
