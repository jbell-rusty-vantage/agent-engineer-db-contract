---
id: "fn:api.resolve_entity(text)"
kind: function
schema: api
name: resolve_entity
domain: api-surface
lens: corpus
overloads: ["fn:api.resolve_entity(text)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, catalog.entity_alias, catalog.entity_identifier], writes: [] }
tokens: [api, resolve_entity, api.resolve_entity]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# api.resolve_entity

Domain `api-surface`, lens `corpus`.

## resolve_entity(text) → TABLE(entity_id uuid, kind text, display_name text, score real)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_text` | `text` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_alias`](../../relations/catalog/entity_alias.md), [`catalog.entity_identifier`](../../relations/catalog/entity_identifier.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:entity.resolve`.

TypeScript: `Database["api"]["Functions"]["resolve_entity"]`.

Defined in: `20260912011000_km_10_api.sql`.
