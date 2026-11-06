---
id: "fn:retrieval.history_publication_authorized(uuid,uuid)"
kind: function
schema: retrieval
name: history_publication_authorized
domain: retrieval
overloads: ["fn:retrieval.history_publication_authorized(uuid,uuid)"]
security: definer
volatility: stable
executors: []
raises: []
touches: { reads: [evaluation.promotion_gate_result, knowledge_service.operation, knowledge_service.review_decision, knowledge_service.review_subject, retrieval.authorized_publication_execution, retrieval.content_promotion_decision, retrieval.content_promotion_proposal, retrieval.embedding_item, retrieval.embedding_run, retrieval.publication_switch_receipt, retrieval.space_publication, retrieval.vector_item, retrieval.vector_item_embedding_1536, retrieval.vector_space_version, retrieval.vector_store, retrieval.vector_store_space], writes: [] }
tokens: [retrieval, history_publication_authorized, retrieval.history_publication_authorized]
defined_in: ["20260914011100_retrieval_history.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.history_publication_authorized

Domain `retrieval`.

## history_publication_authorized(uuid, uuid) → uuid

function, stable, security definer, language sql, config `search_path=""`. Resolves the currently authorized publication for a vector-space version: the active one, or an explicitly pinned superseded one. Withdrawn or unreviewed publications never resolve.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_version` | `uuid` | — | — |
| `p_publication` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`evaluation.promotion_gate_result`](../../relations/evaluation/promotion_gate_result.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.review_decision`](../../relations/knowledge_service/review_decision.md), [`knowledge_service.review_subject`](../../relations/knowledge_service/review_subject.md), [`retrieval.authorized_publication_execution`](../../relations/retrieval/authorized_publication_execution.md), [`retrieval.content_promotion_decision`](../../relations/retrieval/content_promotion_decision.md), [`retrieval.content_promotion_proposal`](../../relations/retrieval/content_promotion_proposal.md), [`retrieval.embedding_item`](../../relations/retrieval/embedding_item.md), [`retrieval.embedding_run`](../../relations/retrieval/embedding_run.md), [`retrieval.publication_switch_receipt`](../../relations/retrieval/publication_switch_receipt.md), [`retrieval.space_publication`](../../relations/retrieval/space_publication.md), [`retrieval.vector_item`](../../relations/retrieval/vector_item.md), [`retrieval.vector_item_embedding_1536`](../../relations/retrieval/vector_item_embedding_1536.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md), [`retrieval.vector_store`](../../relations/retrieval/vector_store.md), [`retrieval.vector_store_space`](../../relations/retrieval/vector_store_space.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["history_publication_authorized"]`.

Defined in: `20260914011100_retrieval_history.sql`.
