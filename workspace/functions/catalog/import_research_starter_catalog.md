---
id: "fn:catalog.import_research_starter_catalog(uuid)"
kind: function
schema: catalog
name: import_research_starter_catalog
domain: identity
lens: legacy
overloads: ["fn:catalog.import_research_starter_catalog(uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [receipt tenant mismatch]
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt], writes: [catalog.entity, catalog.entity_identifier, content.document, content.document_identifier, evidence.source] }
tokens: [catalog, import_research_starter_catalog, catalog.import_research_starter_catalog]
defined_in: []
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# catalog.import_research_starter_catalog

Domain `identity`, lens `legacy`.

## import_research_starter_catalog(uuid) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_receipt` | `uuid` | — | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `receipt tenant mismatch`.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md); writes [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.entity_identifier`](../../relations/catalog/entity_identifier.md), [`content.document`](../../relations/content/document.md), [`content.document_identifier`](../../relations/content/document_identifier.md), [`evidence.source`](../../relations/evidence/source.md); calls [`temporal.assert_relationship`](../temporal/assert_relationship.md), [`temporal.begin_batch`](../temporal/begin_batch.md), [`temporal.commit_batch`](../temporal/commit_batch.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["catalog"]["Functions"]["import_research_starter_catalog"]`.

Defined in: unknown.
