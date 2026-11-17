---
id: "fn:api.price_per_1m(uuid,text,timestamptz)"
kind: function
schema: api
name: price_per_1m
domain: api-surface
lens: corpus
overloads: ["fn:api.price_per_1m(uuid,text,timestamptz)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [temporal.segment, temporal.stream], writes: [] }
tokens: [api, price_per_1m, api.price_per_1m]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.price_per_1m

Domain `api-surface`, lens `corpus`.

## price_per_1m(uuid, text, timestamp with time zone) → numeric

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_offering` | `uuid` | — | — |
| `p_meter` | `text` | — | — |
| `p_at` | `timestamp with time zone` | `now()` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["price_per_1m"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
