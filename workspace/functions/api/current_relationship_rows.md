---
id: "fn:api.current_relationship_rows()"
kind: function
schema: api
name: current_relationship_rows
domain: api-surface
lens: corpus
overloads: ["fn:api.current_relationship_rows()"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.relationship, taxonomy.relationship_kind, temporal.segment, temporal.stream], writes: [] }
tokens: [api, current_relationship_rows, api.current_relationship_rows]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# api.current_relationship_rows

Domain `api-surface`, lens `corpus`. Used by views: [`api.current_relationships`](../../relations/api/current_relationships.md).

## current_relationship_rows() → SETOF catalog.relationship

function, stable, security definer, language sql, config `search_path=""`.

No arguments.

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.relationship`](../../relations/catalog/relationship.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["current_relationship_rows"]`.

Defined in: `20260912011000_km_10_api.sql`.
