---
id: "fn:api.related(uuid,text,text,timestamptz)"
kind: function
schema: api
name: related
domain: relationships
lens: corpus
overloads: ["fn:api.related(uuid,text,text,timestamptz)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.relationship, taxonomy.relationship_kind, temporal.segment, temporal.stream], writes: [] }
tokens: [api, related, api.related]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.related

Domain `relationships`, lens `corpus`. Used by views: [`api.capabilities`](../../relations/api/capabilities.md), [`api.compute_devices`](../../relations/api/compute_devices.md), [`api.compute_offerings`](../../relations/api/compute_offerings.md), [`api.concepts`](../../relations/api/concepts.md), [`api.events`](../../relations/api/events.md), [`api.organizations`](../../relations/api/organizations.md), [`api.papers`](../../relations/api/papers.md), [`api.people`](../../relations/api/people.md), [`api.protocol_versions`](../../relations/api/protocol_versions.md), [`api.software`](../../relations/api/software.md), [`api.talks`](../../relations/api/talks.md).

## related(uuid, text, text, timestamp with time zone) → SETOF uuid

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_kind` | `text` | — | — |
| `p_direction` | `text` | `'outgoing'::text` | — |
| `p_at` | `timestamp with time zone` | `now()` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.relationship`](../../relations/catalog/relationship.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["related"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
