---
id: "fn:api.entity_at(uuid,timestamptz,int8)"
kind: function
schema: api
name: entity_at
domain: api-surface
overloads: ["fn:api.entity_at(uuid,timestamptz,int8)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [corpus.entity, temporal.knowledge_head, temporal.segment, temporal.stream], writes: [] }
tokens: [api, entity_at, api.entity_at]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.entity_at

Domain `api-surface`.

## entity_at(uuid, timestamp with time zone, bigint) → TABLE(segment_id uuid, stream_kind text, scope_key text, valid_during tstzrange, status text, amount numeric, currency text, unit text, ref_entity_id uuid, ref_display_name text, payload jsonb, belief text, k_from bigint, k_to bigint)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_at` | `timestamp with time zone` | `now()` | — |
| `p_k` | `bigint` | `NULL::bigint` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`corpus.entity`](../../relations/corpus/entity.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:entity.at`.

TypeScript: `Database["api"]["Functions"]["entity_at"]`.

Defined in: `20260912011000_km_10_api.sql`.
