---
id: "fn:api.summary_evidence(uuid)"
kind: function
schema: api
name: summary_evidence
domain: api-surface
lens: corpus
overloads: ["fn:api.summary_evidence(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [content.document_node, content.document_summary_source, retrieval.chunk_span], writes: [] }
tokens: [api, summary_evidence, api.summary_evidence]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.summary_evidence

Domain `api-surface`, lens `corpus`.

## summary_evidence(uuid) → TABLE(node_id uuid, chunk_id uuid, locator_id uuid, start_ms integer, end_ms integer)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_summary` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`content.document_node`](../../relations/content/document_node.md), [`content.document_summary_source`](../../relations/content/document_summary_source.md), [`retrieval.chunk_span`](../../relations/retrieval/chunk_span.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["summary_evidence"]`.

Defined in: `20260912011000_km_10_api.sql`.
