---
id: "fn:api.entity_rows()"
kind: function
schema: api
name: entity_rows
domain: api-surface
lens: corpus
overloads: ["fn:api.entity_rows()"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity], writes: [] }
tokens: [api, entity_rows, api.entity_rows]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# api.entity_rows

Domain `api-surface`, lens `corpus`. Used by views: [`api.entities`](../../relations/api/entities.md).

## entity_rows() → SETOF catalog.entity

function, stable, security definer, language sql, config `search_path=""`.

No arguments.

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["entity_rows"]`.

Defined in: `20260912011000_km_10_api.sql`.
