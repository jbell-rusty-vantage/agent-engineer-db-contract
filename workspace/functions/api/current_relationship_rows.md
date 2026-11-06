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
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
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
