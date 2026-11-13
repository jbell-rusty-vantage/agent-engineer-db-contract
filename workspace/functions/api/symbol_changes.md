---
id: "fn:api.symbol_changes(text,text,text)"
kind: function
schema: api
name: symbol_changes
domain: api-surface
lens: corpus
overloads: ["fn:api.symbol_changes(text,text,text)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [api.api_symbols], writes: [] }
tokens: [api, symbol_changes, api.symbol_changes]
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql", "20261109130500_build08_loop2_fixups5.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.symbol_changes

Domain `api-surface`, lens `corpus`.

## symbol_changes(text, text, text) → TABLE(change text, qualified_name text, symbol_kind text, signature_from text, signature_to text, module text, from_node_id uuid, to_node_id uuid)

function, stable, security definer, language sql, config `search_path=""`. L2: public symbols added, removed, re-signed or (un)deprecated between two releases of a repository; overloaded names are compared as one signature set (D-39).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_repository` | `text` | — | — |
| `p_from_tag` | `text` | — | — |
| `p_to_tag` | `text` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`api.api_symbols`](../../relations/api/api_symbols.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["symbol_changes"]`.

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`, `20261109130500_build08_loop2_fixups5.sql`.
