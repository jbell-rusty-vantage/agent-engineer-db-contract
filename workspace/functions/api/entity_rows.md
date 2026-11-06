---
id: "fn:api.entity_rows()"
kind: function
schema: api
name: entity_rows
domain: api-surface
overloads: ["fn:api.entity_rows()"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [corpus.entity], writes: [] }
tokens: [api, entity_rows, api.entity_rows]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.entity_rows

Domain `api-surface`. Used by views: [`api.entities`](../../relations/api/entities.md).

## entity_rows() → SETOF corpus.entity

function, stable, security definer, language sql, config `search_path=""`.

No arguments.

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`corpus.entity`](../../relations/corpus/entity.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["entity_rows"]`.

Defined in: `20260912011000_km_10_api.sql`.
