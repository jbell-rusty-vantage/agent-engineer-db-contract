---
id: "fn:api.advisories_for(text,text)"
kind: function
schema: api
name: advisories_for
domain: api-surface
lens: corpus
overloads: ["fn:api.advisories_for(text,text)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [api.advisories, catalog.entity], writes: [] }
tokens: [api, advisories_for, api.advisories_for]
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# api.advisories_for

Domain `api-surface`, lens `corpus`.

## advisories_for(text, text) → TABLE(ghsa_id text, cve_id text, severity text, summary text, affected_range text, fixed_version text, affects_version boolean, published_at text, url text, claim_id uuid)

function, stable, security definer, language sql, config `search_path=""`. L2: advisories affecting a software thing, and whether a given version falls in each vulnerable range (numeric component comparison, not string compare: 1.2.3 < 1.2.14).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_software` | `text` | — | — |
| `p_version` | `text` | `NULL::text` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`api.advisories`](../../relations/api/advisories.md), [`catalog.entity`](../../relations/catalog/entity.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["advisories_for"]`.

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
