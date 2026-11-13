---
id: "fn:api.models_at(timestamptz)"
kind: function
schema: api
name: models_at
domain: api-surface
lens: corpus
overloads: ["fn:api.models_at(timestamptz)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, temporal.event, temporal.event_occurrence, temporal.knowledge_head, temporal.segment, temporal.stream], writes: [] }
tokens: [api, models_at, api.models_at]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.models_at

Domain `api-surface`, lens `corpus`. Used by views: [`api.models`](../../relations/api/models.md).

## models_at(timestamp with time zone) → TABLE(model_version_id uuid, model text, slug text, version_label text, provider_model_id text, model_family_id uuid, model_family text, developer_id uuid, developer text, released_on date, context_tokens numeric, max_output_tokens numeric, modalities text[], tool_use text, structured_output text, reasoning text, vision text, open_weights boolean, knowledge_cutoff text, availability text, min_input_usd_per_1m numeric, min_output_usd_per_1m numeric, offering_count bigint, observed_at timestamp with time zone, as_of_knowledge_seq bigint)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_at` | `timestamp with time zone` | `now()` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`api.fact_amount`](fact_amount.md), [`api.fact_payload`](fact_payload.md), [`api.fact_status`](fact_status.md), [`api.price_per_1m`](price_per_1m.md), [`api.related`](related.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:catalog.models_at`.

TypeScript: `Database["api"]["Functions"]["models_at"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
