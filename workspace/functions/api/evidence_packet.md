---
id: "fn:api.evidence_packet(uuid)"
kind: function
schema: api
name: evidence_packet
domain: api-surface
lens: corpus
overloads: ["fn:api.evidence_packet(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [content.document_node, retrieval.evidence_packet, retrieval.packet_member], writes: [] }
tokens: [api, evidence_packet, api.evidence_packet]
defined_in: ["20260826001500_api_and_grants.sql", "20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.evidence_packet

Domain `api-surface`, lens `corpus`.

## evidence_packet(uuid) → jsonb

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_packet` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`content.document_node`](../../relations/content/document_node.md), [`retrieval.evidence_packet`](../../relations/retrieval/evidence_packet.md), [`retrieval.packet_member`](../../relations/retrieval/packet_member.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:retrieval.evidence_packet`.

TypeScript: `Database["api"]["Functions"]["evidence_packet"]`.

Defined in: `20260826001500_api_and_grants.sql`, `20260912011000_km_10_api.sql`.
