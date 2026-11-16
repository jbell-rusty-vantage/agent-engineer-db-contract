---
id: "fn:api.fact_payload(uuid,text,text,timestamptz)"
kind: function
schema: api
name: fact_payload
domain: api-surface
lens: corpus
overloads: ["fn:api.fact_payload(uuid,text,text,timestamptz)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [temporal.segment, temporal.stream], writes: [] }
tokens: [api, fact_payload, api.fact_payload]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.fact_payload

Domain `api-surface`, lens `corpus`. Used by views: [`api.software`](../../relations/api/software.md).

## fact_payload(uuid, text, text, timestamp with time zone) → jsonb

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_kind` | `text` | — | — |
| `p_scope_key` | `text` | `NULL::text` | — |
| `p_at` | `timestamp with time zone` | `now()` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["fact_payload"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
