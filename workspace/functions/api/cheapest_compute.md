---
id: "fn:api.cheapest_compute(text,text,timestamptz)"
kind: function
schema: api
name: cheapest_compute
domain: api-surface
lens: corpus
overloads: ["fn:api.cheapest_compute(text,text,timestamptz)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, catalog.relationship, evidence.segment_support, temporal.knowledge_batch, temporal.segment, temporal.stream], writes: [] }
tokens: [api, cheapest_compute, api.cheapest_compute]
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# api.cheapest_compute

Domain `api-surface`, lens `corpus`.

## cheapest_compute(text, text, timestamp with time zone) → TABLE(offering text, provider text, offering_class text, region text, commitment text, amount numeric, unit text, usd_per_gpu_hour numeric, gpu_count integer, valid_from timestamp with time zone, learned_k bigint, claim_id uuid, locator_count bigint)

function, stable, security definer, language sql, config `search_path=""`. L1→L2: current (or as-of) prices of offerings that run on a device, cheapest per GPU-hour first, with the claim id behind each price; commitment on_demand | spot | preemptible | reserved_*.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_device` | `text` | — | — |
| `p_commitment` | `text` | `'on_demand'::text` | — |
| `p_at` | `timestamp with time zone` | `now()` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`evidence.segment_support`](../../relations/evidence/segment_support.md), [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`api.names`](names.md), [`api.related`](related.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["cheapest_compute"]`.

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
