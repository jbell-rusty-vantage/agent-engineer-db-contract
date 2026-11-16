---
id: "fn:api.fact_amount(uuid,text,text,timestamptz)"
kind: function
schema: api
name: fact_amount
domain: api-surface
lens: corpus
overloads: ["fn:api.fact_amount(uuid,text,text,timestamptz)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [temporal.segment, temporal.stream], writes: [] }
tokens: [api, fact_amount, api.fact_amount]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.fact_amount

Domain `api-surface`, lens `corpus`. Used by views: [`api.organizations`](../../relations/api/organizations.md), [`api.papers`](../../relations/api/papers.md), [`api.software`](../../relations/api/software.md).

## fact_amount(uuid, text, text, timestamp with time zone) → numeric

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_kind` | `text` | — | — |
| `p_scope_key` | `text` | `NULL::text` | — |
| `p_at` | `timestamp with time zone` | `now()` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["fact_amount"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
