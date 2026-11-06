---
id: "fn:api.entity_aliases(uuid)"
kind: function
schema: api
name: entity_aliases
domain: api-surface
overloads: ["fn:api.entity_aliases(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [corpus.entity_alias], writes: [] }
tokens: [api, entity_aliases, api.entity_aliases]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.entity_aliases

Domain `api-surface`. Used by views: [`api.entities`](../../relations/api/entities.md).

## entity_aliases(uuid) → text[]

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`corpus.entity_alias`](../../relations/corpus/entity_alias.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["entity_aliases"]`.

Defined in: `20260912011000_km_10_api.sql`.
