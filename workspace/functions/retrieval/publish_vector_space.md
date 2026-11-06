---
id: "fn:retrieval.publish_vector_space(uuid,text,text,text,text)"
kind: function
schema: retrieval
name: publish_vector_space
domain: retrieval
overloads: ["fn:retrieval.publish_vector_space(uuid,text,text,text,text)"]
security: definer
volatility: volatile
executors: [control_plane, executor_service, service_role]
raises: [guarded publication digest changed, publication must exist and be approved, "reason, actor identity, and idempotency key are required", valid app.tenant_id context is required]
touches: { reads: [retrieval.content_promotion_decision], writes: [retrieval.publication_switch_receipt, retrieval.space_publication, retrieval.vector_space_version, retrieval.vector_store_space] }
tokens: [retrieval, publish_vector_space, retrieval.publish_vector_space]
defined_in: ["20260903010400_atomic_publication_and_hybrid_retrieval.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.publish_vector_space

Domain `retrieval`.

## publish_vector_space(uuid, text, text, text, text) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`. Atomically validates and publishes a version, supersedes the prior publication, changes the active pointer, and appends a receipt.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_publication_id` | `uuid` | — | — |
| `p_expected_guarded_sha256` | `text` | — | — |
| `p_reason` | `text` | — | — |
| `p_actor_identity` | `text` | — | — |
| `p_idempotency_key` | `text` | — | — |

Execute: `control_plane`, `executor_service`, `service_role`.

Raises (mechanically extracted): `guarded publication digest changed`; `publication must exist and be approved`; `reason, actor identity, and idempotency key are required`; `valid app.tenant_id context is required`.

Touches (best effort): reads [`retrieval.content_promotion_decision`](../../relations/retrieval/content_promotion_decision.md); writes [`retrieval.publication_switch_receipt`](../../relations/retrieval/publication_switch_receipt.md), [`retrieval.space_publication`](../../relations/retrieval/space_publication.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md), [`retrieval.vector_store_space`](../../relations/retrieval/vector_store_space.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["publish_vector_space"]`.

Defined in: `20260903010400_atomic_publication_and_hybrid_retrieval.sql`.
