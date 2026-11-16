---
id: "fn:api.model_offerings_at(timestamptz)"
kind: function
schema: api
name: model_offerings_at
domain: api-surface
lens: corpus
overloads: ["fn:api.model_offerings_at(timestamptz)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, evidence.segment_support, temporal.knowledge_head, temporal.segment, temporal.stream], writes: [] }
tokens: [api, model_offerings_at, api.model_offerings_at]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.model_offerings_at

Domain `api-surface`, lens `corpus`. Used by views: [`api.model_offerings`](../../relations/api/model_offerings.md).

## model_offerings_at(timestamp with time zone) → TABLE(offering_id uuid, offering text, offering_key text, model_version_id uuid, model text, provider_id uuid, provider text, region text, tier text, input_usd_per_1m numeric, output_usd_per_1m numeric, cached_input_usd_per_1m numeric, batch_input_usd_per_1m numeric, availability text, pricing_url text, price_valid_from timestamp with time zone, price_observed_at timestamp with time zone, price_claim_id uuid, price_locator_id uuid, as_of_knowledge_seq bigint)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_at` | `timestamp with time zone` | `now()` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`evidence.segment_support`](../../relations/evidence/segment_support.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`api.fact_status`](fact_status.md), [`api.price_per_1m`](price_per_1m.md), [`api.related`](related.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:catalog.model_offerings_at`.

TypeScript: `Database["api"]["Functions"]["model_offerings_at"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
