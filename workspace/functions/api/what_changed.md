---
id: "fn:api.what_changed(uuid,int8,int8)"
kind: function
schema: api
name: what_changed
domain: api-surface
lens: corpus
overloads: ["fn:api.what_changed(uuid,int8,int8)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.relationship, temporal.event, temporal.event_occurrence, temporal.segment, temporal.stream], writes: [] }
tokens: [api, what_changed, api.what_changed]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.what_changed

Domain `api-surface`, lens `corpus`.

## what_changed(uuid, bigint, bigint) → TABLE(change_kind text, item_kind text, item_id uuid, knowledge_seq bigint, details jsonb)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_k1` | `bigint` | — | — |
| `p_k2` | `bigint` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.relationship`](../../relations/catalog/relationship.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:entity.what_changed`.

TypeScript: `Database["api"]["Functions"]["what_changed"]`.

Defined in: `20260912011000_km_10_api.sql`.
