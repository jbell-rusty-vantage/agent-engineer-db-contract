---
id: "fn:knowledge_service.nack_outbox(uuid,text,uuid,text,int4)"
kind: function
schema: knowledge_service
name: nack_outbox
domain: knowledge-service-runtime
overloads: ["fn:knowledge_service.nack_outbox(uuid,text,uuid,text,int4)"]
security: definer
volatility: volatile
executors: [control_plane, executor_service, service_role]
raises: [error class or retry delay is invalid, stale or foreign outbox claim, valid app.tenant_id context is required]
touches: { reads: [], writes: [knowledge_service.outbox] }
tokens: [knowledge_service, nack_outbox, knowledge_service.nack_outbox]
defined_in: ["20260903010500_outbox_claiming_and_packet_materialization.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge_service.nack_outbox

Domain `knowledge-service-runtime`.

## nack_outbox(uuid, text, uuid, text, integer) → boolean

function, volatile, security definer, language plpgsql, config `search_path=""`. Rejects only a live owned claim, applies bounded backoff, and archives exhausted poison messages.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_outbox_id` | `uuid` | — | — |
| `p_claim_owner` | `text` | — | — |
| `p_claim_token` | `uuid` | — | — |
| `p_error_class` | `text` | — | — |
| `p_retry_delay_ms` | `integer` | `0` | — |

Execute: `control_plane`, `executor_service`, `service_role`.

Raises (mechanically extracted): `error class or retry delay is invalid`; `stale or foreign outbox claim`; `valid app.tenant_id context is required`.

Touches (best effort): reads —; writes [`knowledge_service.outbox`](../../relations/knowledge_service/outbox.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["knowledge_service"]["Functions"]["nack_outbox"]`.

Defined in: `20260903010500_outbox_claiming_and_packet_materialization.sql`.
