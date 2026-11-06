---
id: "fn:api.current_relationship_rows()"
kind: function
schema: api
name: current_relationship_rows
domain: api-surface
overloads: ["fn:api.current_relationship_rows()"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [corpus.relationship, taxonomy.relationship_kind, temporal.segment, temporal.stream], writes: [] }
tokens: [api, current_relationship_rows, api.current_relationship_rows]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.current_relationship_rows

Domain `api-surface`. Used by views: [`api.current_relationships`](../../relations/api/current_relationships.md).

## current_relationship_rows() → SETOF corpus.relationship

function, stable, security definer, language sql, config `search_path=""`.

No arguments.

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`corpus.relationship`](../../relations/corpus/relationship.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["current_relationship_rows"]`.

Defined in: `20260912011000_km_10_api.sql`.
