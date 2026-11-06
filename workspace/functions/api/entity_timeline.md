---
id: "fn:api.entity_timeline(uuid,timestamptz,timestamptz,int8)"
kind: function
schema: api
name: entity_timeline
domain: api-surface
overloads: ["fn:api.entity_timeline(uuid,timestamptz,timestamptz,int8)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [temporal.event, temporal.event_occurrence, temporal.knowledge_head, temporal.segment, temporal.stream], writes: [] }
tokens: [api, entity_timeline, api.entity_timeline]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.entity_timeline

Domain `api-surface`.

## entity_timeline(uuid, timestamp with time zone, timestamp with time zone, bigint) → TABLE(item_kind text, item_id uuid, world_interval tstzrange, details jsonb)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_from` | `timestamp with time zone` | — | — |
| `p_to` | `timestamp with time zone` | — | — |
| `p_k` | `bigint` | `NULL::bigint` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:entity.timeline`.

TypeScript: `Database["api"]["Functions"]["entity_timeline"]`.

Defined in: `20260912011000_km_10_api.sql`.
