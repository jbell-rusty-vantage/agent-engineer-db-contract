---
id: "fn:api.symbol_history(text,text)"
kind: function
schema: api
name: symbol_history
domain: content
lens: corpus
overloads: ["fn:api.symbol_history(text,text)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [api.api_symbols], writes: [] }
tokens: [api, symbol_history, api.symbol_history]
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql", "20261110140100_build08_loop3_fixups.sql", "20261110140200_build08_loop3_fixups2.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.symbol_history

Domain `content`, lens `corpus`.

## symbol_history(text, text) → TABLE(qualified_name text, symbol_kind text, package text, first_tag text, first_released_on text, last_tag text, releases_present integer, releases_total integer, in_latest boolean, latest_node_id uuid)

function, stable, security definer, language sql, config `search_path=""`. L2: per public symbol of a repository, the first and the last ingested release that defines it. Releases are ordered by release date when recorded, then by tag digits. Only as complete as the releases ingested as api_surface documents.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_repository` | `text` | — | — |
| `p_package` | `text` | `NULL::text` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`api.api_symbols`](../../relations/api/api_symbols.md); writes —; calls [`api.release_order`](release_order.md).

TypeScript: `Database["api"]["Functions"]["symbol_history"]`.

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`, `20261110140100_build08_loop3_fixups.sql`, `20261110140200_build08_loop3_fixups2.sql`.
