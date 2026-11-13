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
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity], writes: [] }
tokens: [api, names, api.names]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.names

Domain `api-surface`, lens `corpus`. Used by views: [`api.capabilities`](../../relations/api/capabilities.md), [`api.claim_candidates`](../../relations/api/claim_candidates.md), [`api.claim_surfaces`](../../relations/api/claim_surfaces.md), [`api.compute_devices`](../../relations/api/compute_devices.md), [`api.compute_offerings`](../../relations/api/compute_offerings.md), [`api.events`](../../relations/api/events.md), [`api.papers`](../../relations/api/papers.md), [`api.people`](../../relations/api/people.md), [`api.protocol_versions`](../../relations/api/protocol_versions.md), [`api.software`](../../relations/api/software.md), [`api.talks`](../../relations/api/talks.md), [`api.works_authored`](../../relations/api/works_authored.md).

## names(uuid[]) → text[]

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_ids` | `uuid[]` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["names"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
