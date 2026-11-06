---
id: "fn:retrieval.transition_vector_store_lifecycle(uuid,text,text,text,uuid)"
kind: function
schema: retrieval
name: transition_vector_store_lifecycle
domain: retrieval
overloads: ["fn:retrieval.transition_vector_store_lifecycle(uuid,text,text,text,uuid)"]
security: invoker
volatility: volatile
executors: [control_plane, service_role]
raises: [actor identity and reason are required, compatible active successor is required, control_plane role is required, invalid vector store lifecycle target, minimum retention period has not elapsed, review-required deletion is not admitted by this control-plane slice, successor is only valid for supersession, valid app.tenant_id context is required, vector store not found]
touches: { reads: [], writes: [retrieval.vector_store, retrieval.vector_store_lifecycle_event] }
tokens: [retrieval, transition_vector_store_lifecycle, retrieval.transition_vector_store_lifecycle]
defined_in: ["20260904015000_vector_store_lifecycle_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.transition_vector_store_lifecycle

Domain `retrieval`.

## transition_vector_store_lifecycle(uuid, text, text, text, uuid) → uuid

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_vector_store_id` | `uuid` | — | — |
| `p_target_lifecycle` | `text` | — | — |
| `p_actor_identity` | `text` | — | — |
| `p_reason` | `text` | — | — |
| `p_successor_id` | `uuid` | `NULL::uuid` | — |

Execute: `control_plane`, `service_role`.

Raises (mechanically extracted): `actor identity and reason are required`; `compatible active successor is required`; `control_plane role is required`; `invalid vector store lifecycle target`; `minimum retention period has not elapsed`; `review-required deletion is not admitted by this control-plane slice`; `successor is only valid for supersession`; `valid app.tenant_id context is required`; `vector store not found`.

Touches (best effort): reads —; writes [`retrieval.vector_store`](../../relations/retrieval/vector_store.md), [`retrieval.vector_store_lifecycle_event`](../../relations/retrieval/vector_store_lifecycle_event.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["retrieval"]["Functions"]["transition_vector_store_lifecycle"]`.

Defined in: `20260904015000_vector_store_lifecycle_control_plane.sql`.
