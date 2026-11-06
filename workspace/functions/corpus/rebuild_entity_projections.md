---
id: "fn:corpus.rebuild_entity_projections(int8)"
kind: function
schema: corpus
name: rebuild_entity_projections
domain: identity
overloads: ["fn:corpus.rebuild_entity_projections(int8)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [projection rebuild requires current sealed head]
touches: { reads: [content.document, content.document_summary, content.document_version, temporal.knowledge_head], writes: [corpus.entity] }
tokens: [corpus, rebuild_entity_projections, corpus.rebuild_entity_projections]
defined_in: ["20260912011200_km_12_projection_workers.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.rebuild_entity_projections

Domain `identity`.

## rebuild_entity_projections(bigint) → bigint

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_k` | `bigint` | `NULL::bigint` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `projection rebuild requires current sealed head`.

Touches (best effort): reads [`content.document`](../../relations/content/document.md), [`content.document_summary`](../../relations/content/document_summary.md), [`content.document_version`](../../relations/content/document_version.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); writes [`corpus.entity`](../../relations/corpus/entity.md); calls [`api.entity_at`](../api/entity_at.md), [`temporal.emit_outbox`](../temporal/emit_outbox.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["corpus"]["Functions"]["rebuild_entity_projections"]`.

Defined in: `20260912011200_km_12_projection_workers.sql`.
