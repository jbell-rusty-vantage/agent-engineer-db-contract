---
id: "fn:retrieval.history_representation_authorized(uuid)"
kind: function
schema: retrieval
name: history_representation_authorized
domain: retrieval
overloads: ["fn:retrieval.history_representation_authorized(uuid)"]
security: definer
volatility: stable
executors: []
raises: []
touches: { reads: [content.document_representation, content.document_version, content.representation_decision, content.transformation_run, knowledge_service.operation, knowledge_service.review_decision, knowledge_service.review_subject, orchestration.artifact, orchestration.attempt], writes: [] }
tokens: [retrieval, history_representation_authorized, retrieval.history_representation_authorized]
defined_in: ["20260914011100_retrieval_history.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.history_representation_authorized

Domain `retrieval`.

## history_representation_authorized(uuid) → boolean

function, stable, security definer, language sql, config `search_path=""`. Latest independent guarded representation decision, including producer/reviewer separation for summaries.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_representation` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`content.document_representation`](../../relations/content/document_representation.md), [`content.document_version`](../../relations/content/document_version.md), [`content.representation_decision`](../../relations/content/representation_decision.md), [`content.transformation_run`](../../relations/content/transformation_run.md), [`knowledge_service.operation`](../../relations/knowledge_service/operation.md), [`knowledge_service.review_decision`](../../relations/knowledge_service/review_decision.md), [`knowledge_service.review_subject`](../../relations/knowledge_service/review_subject.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.attempt`](../../relations/orchestration/attempt.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["history_representation_authorized"]`.

Defined in: `20260914011100_retrieval_history.sql`.
