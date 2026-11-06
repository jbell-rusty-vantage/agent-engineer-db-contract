---
id: "fn:api.summary_evidence(uuid)"
kind: function
schema: api
name: summary_evidence
domain: api-surface
overloads: ["fn:api.summary_evidence(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [content.document_node, content.document_summary_source, retrieval.chunk_span], writes: [] }
tokens: [api, summary_evidence, api.summary_evidence]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.summary_evidence

Domain `api-surface`.

## summary_evidence(uuid) → TABLE(node_id uuid, chunk_id uuid, locator_id uuid, start_ms integer, end_ms integer)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_summary` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`content.document_node`](../../relations/content/document_node.md), [`content.document_summary_source`](../../relations/content/document_summary_source.md), [`retrieval.chunk_span`](../../relations/retrieval/chunk_span.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["summary_evidence"]`.

Defined in: `20260912011000_km_10_api.sql`.
