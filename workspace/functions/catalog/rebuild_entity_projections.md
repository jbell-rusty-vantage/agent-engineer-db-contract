---
id: "fn:catalog.rebuild_entity_projections(int8)"
kind: function
schema: catalog
name: rebuild_entity_projections
domain: identity
lens: corpus
overloads: ["fn:catalog.rebuild_entity_projections(int8)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [projection rebuild requires current sealed head]
touches: { reads: [content.document, content.document_summary, content.document_version, temporal.knowledge_head], writes: [catalog.entity] }
tokens: [catalog, rebuild_entity_projections, catalog.rebuild_entity_projections]
defined_in: []
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# catalog.rebuild_entity_projections

Domain `identity`, lens `corpus`.

## rebuild_entity_projections(bigint) → bigint

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_k` | `bigint` | `NULL::bigint` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `projection rebuild requires current sealed head`.

Touches (best effort): reads [`content.document`](../../relations/content/document.md), [`content.document_summary`](../../relations/content/document_summary.md), [`content.document_version`](../../relations/content/document_version.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); writes [`catalog.entity`](../../relations/catalog/entity.md); calls [`api.entity_at`](../api/entity_at.md), [`temporal.emit_outbox`](../temporal/emit_outbox.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["catalog"]["Functions"]["rebuild_entity_projections"]`.

Defined in: unknown.
