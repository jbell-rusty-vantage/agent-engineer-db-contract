---
id: "fn:retrieval.project_entity_timeline(int8)"
kind: function
schema: retrieval
name: project_entity_timeline
domain: retrieval
overloads: ["fn:retrieval.project_entity_timeline(int8)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: []
touches: { reads: [corpus.entity, temporal.knowledge_head], writes: [retrieval.projection_procedure, retrieval.projection_target, retrieval.search_projection] }
tokens: [retrieval, project_entity_timeline, retrieval.project_entity_timeline]
defined_in: ["20260912011200_km_12_projection_workers.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.project_entity_timeline

Domain `retrieval`.

## project_entity_timeline(bigint) → bigint

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_k` | `bigint` | `NULL::bigint` | — |

Execute: `executor_service`, `service_role`.

Touches (best effort): reads [`corpus.entity`](../../relations/corpus/entity.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); writes [`retrieval.projection_procedure`](../../relations/retrieval/projection_procedure.md), [`retrieval.projection_target`](../../relations/retrieval/projection_target.md), [`retrieval.search_projection`](../../relations/retrieval/search_projection.md); calls [`api.entity_timeline`](../api/entity_timeline.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["project_entity_timeline"]`.

Defined in: `20260912011200_km_12_projection_workers.sql`.
