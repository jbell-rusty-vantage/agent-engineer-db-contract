---
id: "fn:api.price_history(uuid,text)"
kind: function
schema: api
name: price_history
domain: api-surface
lens: corpus
overloads: ["fn:api.price_history(uuid,text)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [temporal.knowledge_batch, temporal.segment, temporal.stream], writes: [] }
tokens: [api, price_history, api.price_history]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# api.price_history

Domain `api-surface`, lens `corpus`.

## price_history(uuid, text) → TABLE(segment_id uuid, meter text, tier text, region text, amount numeric, currency text, unit text, valid_during tstzrange, belief text, temporal_basis text, k_from bigint, k_to bigint, learned_at timestamp with time zone, retracted_at timestamp with time zone, claim_id uuid, replaces_segment_id uuid)

function, stable, security definer, language sql, config `search_path=""`. L2: every price segment of an offering and meter with both clocks (valid_during; k_from/k_to with learned_at), including superseded beliefs.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_offering` | `uuid` | — | — |
| `p_meter` | `text` | `'input_tokens'::text` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:facts.price_history`.

TypeScript: `Database["api"]["Functions"]["price_history"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
