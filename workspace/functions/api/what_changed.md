---
id: "fn:api.what_changed(uuid,int8,int8)"
kind: function
schema: api
name: what_changed
domain: api-surface
overloads: ["fn:api.what_changed(uuid,int8,int8)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [corpus.relationship, temporal.event, temporal.event_occurrence, temporal.segment, temporal.stream], writes: [] }
tokens: [api, what_changed, api.what_changed]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.what_changed

Domain `api-surface`.

## what_changed(uuid, bigint, bigint) → TABLE(change_kind text, item_kind text, item_id uuid, knowledge_seq bigint, details jsonb)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_k1` | `bigint` | — | — |
| `p_k2` | `bigint` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`corpus.relationship`](../../relations/corpus/relationship.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:entity.what_changed`.

TypeScript: `Database["api"]["Functions"]["what_changed"]`.

Defined in: `20260912011000_km_10_api.sql`.
