---
id: "fn:knowledge_service.ack_outbox(uuid,text,uuid)"
kind: function
schema: knowledge_service
name: ack_outbox
domain: knowledge-service-runtime
lens: machinery
overloads: ["fn:knowledge_service.ack_outbox(uuid,text,uuid)"]
security: definer
volatility: volatile
executors: [control_plane, executor_service, service_role]
raises: [stale or foreign outbox claim, valid app.tenant_id context is required]
touches: { reads: [], writes: [knowledge_service.outbox] }
tokens: [knowledge_service, ack_outbox, knowledge_service.ack_outbox]
defined_in: ["20260903010500_outbox_claiming_and_packet_materialization.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# knowledge_service.ack_outbox

Domain `knowledge-service-runtime`, lens `machinery`.

## ack_outbox(uuid, text, uuid) → boolean

function, volatile, security definer, language plpgsql, config `search_path=""`. Acknowledges only a live claim owned by the supplied consumer and token.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_outbox_id` | `uuid` | — | — |
| `p_claim_owner` | `text` | — | — |
| `p_claim_token` | `uuid` | — | — |

Execute: `control_plane`, `executor_service`, `service_role`.

Raises (mechanically extracted): `stale or foreign outbox claim`; `valid app.tenant_id context is required`.

Touches (best effort): reads —; writes [`knowledge_service.outbox`](../../relations/knowledge_service/outbox.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["knowledge_service"]["Functions"]["ack_outbox"]`.

Defined in: `20260903010500_outbox_claiming_and_packet_materialization.sql`.
