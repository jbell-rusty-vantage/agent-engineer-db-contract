---
id: "fn:api.names(uuid[])"
kind: function
schema: api
name: names
domain: api-surface
lens: corpus
overloads: ["fn:api.names(uuid[])"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity], writes: [] }
tokens: [api, names, api.names]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.names

Domain `api-surface`, lens `corpus`. Used by views: [`api.capabilities`](../../relations/api/capabilities.md), [`api.claim_candidates`](../../relations/api/claim_candidates.md), [`api.claim_surfaces`](../../relations/api/claim_surfaces.md), [`api.compute_devices`](../../relations/api/compute_devices.md), [`api.compute_offerings`](../../relations/api/compute_offerings.md), [`api.events`](../../relations/api/events.md), [`api.papers`](../../relations/api/papers.md), [`api.people`](../../relations/api/people.md), [`api.protocol_versions`](../../relations/api/protocol_versions.md), [`api.software`](../../relations/api/software.md), [`api.talks`](../../relations/api/talks.md), [`api.works_authored`](../../relations/api/works_authored.md).

## names(uuid[]) → text[]

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_ids` | `uuid[]` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["names"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
