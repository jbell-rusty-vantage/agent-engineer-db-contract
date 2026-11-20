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
defined_in: ["20260912011000_km_10_api.sql", "20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.resolve_entity

Domain `api-surface`, lens `corpus`.

## resolve_entity(text) → TABLE(entity_id uuid, kind text, display_name text, score real)

function, stable, security definer, language sql, config `search_path=""`. Find a record by name, alias (former names included) or identifier. A merged record's name leads to its winner.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_text` | `text` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_alias`](../../relations/catalog/entity_alias.md), [`catalog.entity_identifier`](../../relations/catalog/entity_identifier.md); writes —; calls [`catalog.canonical_entity`](../catalog/canonical_entity.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:entity.resolve`.

TypeScript: `Database["api"]["Functions"]["resolve_entity"]`.

Defined in: `20260912011000_km_10_api.sql`, `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
