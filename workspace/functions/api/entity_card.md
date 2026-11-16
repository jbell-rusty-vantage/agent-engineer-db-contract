---
id: "fn:api.entity_card(uuid)"
kind: function
schema: api
name: entity_card
domain: api-surface
lens: corpus
overloads: ["fn:api.entity_card(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, catalog.entity_alias, evidence.source, temporal.event, temporal.event_occurrence], writes: [] }
tokens: [api, entity_card, api.entity_card]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.entity_card

Domain `api-surface`, lens `corpus`.

## entity_card(uuid) → jsonb

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_alias`](../../relations/catalog/entity_alias.md), [`evidence.source`](../../relations/evidence/source.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md); writes —; calls [`api.entity_at`](entity_at.md), [`api.relationships`](relationships.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:entity.card`.

TypeScript: `Database["api"]["Functions"]["entity_card"]`.

Defined in: `20260912011000_km_10_api.sql`.
