---
id: "fn:api.resolve_entity(text)"
kind: function
schema: api
name: resolve_entity
domain: api-surface
overloads: ["fn:api.resolve_entity(text)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [corpus.entity, corpus.entity_alias, corpus.entity_identifier], writes: [] }
tokens: [api, resolve_entity, api.resolve_entity]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.resolve_entity

Domain `api-surface`.

## resolve_entity(text) → TABLE(entity_id uuid, kind text, display_name text, score real)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_text` | `text` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`corpus.entity`](../../relations/corpus/entity.md), [`corpus.entity_alias`](../../relations/corpus/entity_alias.md), [`corpus.entity_identifier`](../../relations/corpus/entity_identifier.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:entity.resolve`.

TypeScript: `Database["api"]["Functions"]["resolve_entity"]`.

Defined in: `20260912011000_km_10_api.sql`.
