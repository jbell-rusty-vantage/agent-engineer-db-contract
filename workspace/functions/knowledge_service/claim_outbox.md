---
id: "fn:knowledge_service.claim_outbox(text,int4,int4,uuid)"
kind: function
schema: knowledge_service
name: claim_outbox
domain: knowledge-service-runtime
overloads: ["fn:knowledge_service.claim_outbox(text,int4,int4,uuid)"]
security: definer
volatility: volatile
executors: [control_plane, executor_service, service_role]
raises: [claim limit or visibility timeout is outside the admitted range, claim owner is required and must be at most 256 characters, valid app.tenant_id context is required]
touches: { reads: [], writes: [knowledge_service.outbox] }
tokens: [knowledge_service, claim_outbox, knowledge_service.claim_outbox]
defined_in: ["20260903010500_outbox_claiming_and_packet_materialization.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.claim_outbox

Domain `knowledge-service-runtime`.

## claim_outbox(text, integer, integer, uuid) → TABLE(id uuid, operation_id uuid, event_id uuid, topic text, payload jsonb, payload_sha256 text, delivery_attempts integer, claim_owner text, claim_token uuid, claimed_at timestamp with time zone, visibility_expires_at timestamp with time zone)

function, volatile, security definer, language plpgsql, config `search_path=""`. Atomically claims tenant-scoped due messages with FOR UPDATE SKIP LOCKED and a visibility-timeout fencing token.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_claim_owner` | `text` | — | — |
| `p_limit` | `integer` | `50` | — |
| `p_visibility_timeout_ms` | `integer` | `30000` | — |
| `p_operation_id` | `uuid` | `NULL::uuid` | — |

Execute: `control_plane`, `executor_service`, `service_role`.

Raises (mechanically extracted): `claim limit or visibility timeout is outside the admitted range`; `claim owner is required and must be at most 256 characters`; `valid app.tenant_id context is required`.

Touches (best effort): reads —; writes [`knowledge_service.outbox`](../../relations/knowledge_service/outbox.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["knowledge_service"]["Functions"]["claim_outbox"]`.

Defined in: `20260903010500_outbox_claiming_and_packet_materialization.sql`.
