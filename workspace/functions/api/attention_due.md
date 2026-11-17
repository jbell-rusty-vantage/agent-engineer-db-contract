---
id: "fn:api.attention_due(timestamptz)"
kind: function
schema: api
name: attention_due
domain: source-intelligence
lens: corpus
overloads: ["fn:api.attention_due(timestamptz)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [acquisition.attention_policy, acquisition.attention_sweep, catalog.entity, catalog.relationship, orchestration.mission, temporal.event, temporal.event_occurrence], writes: [] }
tokens: [api, attention_due, api.attention_due]
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql", "20261113120100_build08_loop4_fixup_attention_due.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.attention_due

Domain `source-intelligence`, lens `corpus`.

## attention_due(timestamp with time zone) → TABLE(policy_id uuid, slug text, watch_level text, reason text, trigger_ref jsonb, last_sweep_at timestamp with time zone, budget_usd_per_run numeric, mission text)

function, stable, security definer, language sql, config `search_path=""`. The contract a Mission Control watch mission calls: which attention policies are due at a time, because a trigger event happened since the last non-backfill sweep inside the trigger window (a trigger with "only": "major" counts x.0.0 releases only), or because the cadence elapsed since any sweep. W0 and paused policies are never due.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_as_of` | `timestamp with time zone` | `now()` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`acquisition.attention_policy`](../../relations/acquisition/attention_policy.md), [`acquisition.attention_sweep`](../../relations/acquisition/attention_sweep.md), [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`orchestration.mission`](../../relations/orchestration/mission.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md); writes —; calls —.

Named queries: `q:acquisition.attention_due`.

TypeScript: `Database["api"]["Functions"]["attention_due"]`.

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`, `20261113120100_build08_loop4_fixup_attention_due.sql`.
