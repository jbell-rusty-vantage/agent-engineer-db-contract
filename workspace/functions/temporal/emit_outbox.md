---
id: "fn:temporal.emit_outbox(text,int8,jsonb)"
kind: function
schema: temporal
name: emit_outbox
domain: knowledge-service-runtime
overloads: ["fn:temporal.emit_outbox(text,int8,jsonb)"]
security: definer
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [knowledge_service.operation, knowledge_service.operation_event, knowledge_service.outbox] }
tokens: [temporal, emit_outbox, temporal.emit_outbox]
defined_in: ["20260912011200_km_12_projection_workers.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.emit_outbox

Domain `knowledge-service-runtime`.

## emit_outbox(text, bigint, jsonb) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_topic` | `text` | — | — |
| `p_k` | `bigint` | — | — |
| `p_payload` | `jsonb` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.operation_event`](../../relations/knowledge_service/operation_event.md), [`knowledge_service.outbox`](../../relations/knowledge_service/outbox.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["temporal"]["Functions"]["emit_outbox"]`.

Defined in: `20260912011200_km_12_projection_workers.sql`.
