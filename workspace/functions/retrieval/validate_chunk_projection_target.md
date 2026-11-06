---
id: "fn:retrieval.validate_chunk_projection_target(uuid,uuid)"
kind: function
schema: retrieval
name: validate_chunk_projection_target
domain: retrieval
overloads: ["fn:retrieval.validate_chunk_projection_target(uuid,uuid)"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [content.document_representation, content.representation_decision, retrieval.chunk_set, retrieval.retrieval_chunk], writes: [] }
tokens: [retrieval, validate_chunk_projection_target, retrieval.validate_chunk_projection_target]
defined_in: ["20260904011000_governed_projection_embedding_publication.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.validate_chunk_projection_target

Domain `retrieval`.

## validate_chunk_projection_target(uuid, uuid) → boolean

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant_id` | `uuid` | — | — |
| `p_chunk_id` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`content.document_representation`](../../relations/content/document_representation.md), [`content.representation_decision`](../../relations/content/representation_decision.md), [`retrieval.chunk_set`](../../relations/retrieval/chunk_set.md), [`retrieval.retrieval_chunk`](../../relations/retrieval/retrieval_chunk.md); writes —; calls —.

TypeScript: `Database["retrieval"]["Functions"]["validate_chunk_projection_target"]`.

Defined in: `20260904011000_governed_projection_embedding_publication.sql`.
