---
id: "fn:api.relationships(uuid,text,timestamptz,int8,text)"
kind: function
schema: api
name: relationships
domain: api-surface
overloads: ["fn:api.relationships(uuid,text,timestamptz,int8,text)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [corpus.relationship, taxonomy.relationship_kind, temporal.knowledge_head, temporal.segment, temporal.stream], writes: [] }
tokens: [api, relationships, api.relationships]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.relationships

Domain `api-surface`.

## relationships(uuid, text, timestamp with time zone, bigint, text) → SETOF corpus.relationship

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_kind` | `text` | `NULL::text` | — |
| `p_at` | `timestamp with time zone` | `now()` | — |
| `p_k` | `bigint` | `NULL::bigint` | — |
| `p_direction` | `text` | `'both'::text` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`corpus.relationship`](../../relations/corpus/relationship.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:entity.relationships`.

TypeScript: `Database["api"]["Functions"]["relationships"]`.

Defined in: `20260912011000_km_10_api.sql`.
