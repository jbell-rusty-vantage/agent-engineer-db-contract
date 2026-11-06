---
id: "fn:retrieval.rollback_vector_space(uuid,uuid,text,text,text,text,uuid)"
kind: function
schema: retrieval
name: rollback_vector_space
domain: retrieval
overloads: ["fn:retrieval.rollback_vector_space(uuid,uuid,text,text,text,text,uuid)"]
security: definer
volatility: volatile
executors: [control_plane, executor_service, service_role]
raises: [authorized rollback operation is required, current and rollback target publications are invalid, "rollback reason, actor identity, idempotency key, and operation are required", rollback target guarded digest is invalid, valid app.tenant_id context is required]
touches: { reads: [knowledge_service.operation, retrieval.content_promotion_decision], writes: [retrieval.publication_switch_receipt, retrieval.space_publication, retrieval.vector_space_version, retrieval.vector_store_space] }
tokens: [retrieval, rollback_vector_space, retrieval.rollback_vector_space]
defined_in: ["20260903010400_atomic_publication_and_hybrid_retrieval.sql", "20260904011000_governed_projection_embedding_publication.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.rollback_vector_space

Domain `retrieval`.

## rollback_vector_space(uuid, uuid, text, text, text, text, uuid) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_current_publication_id` | `uuid` | — | — |
| `p_target_publication_id` | `uuid` | — | — |
| `p_expected_guarded_sha256` | `text` | — | — |
| `p_reason` | `text` | — | — |
| `p_actor_identity` | `text` | — | — |
| `p_idempotency_key` | `text` | — | — |
| `p_operation_id` | `uuid` | — | — |

Execute: `control_plane`, `executor_service`, `service_role`.

Raises (mechanically extracted): `authorized rollback operation is required`; `current and rollback target publications are invalid`; `rollback reason, actor identity, idempotency key, and operation are required`; `rollback target guarded digest is invalid`; `valid app.tenant_id context is required`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`retrieval.content_promotion_decision`](../../relations/retrieval/content_promotion_decision.md); writes [`retrieval.publication_switch_receipt`](../../relations/retrieval/publication_switch_receipt.md), [`retrieval.space_publication`](../../relations/retrieval/space_publication.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md), [`retrieval.vector_store_space`](../../relations/retrieval/vector_store_space.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["retrieval"]["Functions"]["rollback_vector_space"]`.

Defined in: `20260903010400_atomic_publication_and_hybrid_retrieval.sql`, `20260904011000_governed_projection_embedding_publication.sql`.
