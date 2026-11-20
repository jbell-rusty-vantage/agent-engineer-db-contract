---
id: "fn:catalog.entity_references(uuid)"
kind: function
schema: catalog
name: entity_references
domain: identity
lens: corpus
overloads: ["fn:catalog.entity_references(uuid)"]
security: definer
volatility: stable
executors: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity], writes: [] }
tokens: [catalog, entity_references, catalog.entity_references]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# catalog.entity_references

Domain `identity`, lens `corpus`.

## entity_references(uuid) → TABLE(table_name text, column_name text, row_count bigint)

function, stable, security definer, language plpgsql, config `search_path=""`. Every table and column that points at this record, with a row count. What a merge has to move.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |

Execute: `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md); writes —; calls —.

TypeScript: `Database["catalog"]["Functions"]["entity_references"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
