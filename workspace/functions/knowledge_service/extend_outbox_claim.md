---
id: "fn:knowledge_service.extend_outbox_claim(uuid,text,uuid,int4)"
kind: function
schema: knowledge_service
name: extend_outbox_claim
domain: knowledge-service-runtime
lens: machinery
overloads: ["fn:knowledge_service.extend_outbox_claim(uuid,text,uuid,int4)"]
security: definer
volatility: volatile
executors: [control_plane, executor_service, service_role]
raises: [stale or foreign outbox claim, valid app.tenant_id context is required, visibility timeout is outside the admitted range]
touches: { reads: [], writes: [knowledge_service.outbox] }
tokens: [knowledge_service, extend_outbox_claim, knowledge_service.extend_outbox_claim]
defined_in: ["20260903010500_outbox_claiming_and_packet_materialization.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# knowledge_service.extend_outbox_claim

Domain `knowledge-service-runtime`, lens `machinery`.

## extend_outbox_claim(uuid, text, uuid, integer) → timestamp with time zone

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_outbox_id` | `uuid` | — | — |
| `p_claim_owner` | `text` | — | — |
| `p_claim_token` | `uuid` | — | — |
| `p_visibility_timeout_ms` | `integer` | — | — |

Execute: `control_plane`, `executor_service`, `service_role`.

Raises (mechanically extracted): `stale or foreign outbox claim`; `valid app.tenant_id context is required`; `visibility timeout is outside the admitted range`.

Touches (best effort): reads —; writes [`knowledge_service.outbox`](../../relations/knowledge_service/outbox.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["knowledge_service"]["Functions"]["extend_outbox_claim"]`.

Defined in: `20260903010500_outbox_claiming_and_packet_materialization.sql`.
