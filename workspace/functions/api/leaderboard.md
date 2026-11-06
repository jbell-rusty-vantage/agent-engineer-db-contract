---
id: "fn:api.leaderboard(int4)"
kind: function
schema: api
name: leaderboard
domain: api-surface
overloads: ["fn:api.leaderboard(int4)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [ranking.ranking_result], writes: [] }
tokens: [api, leaderboard, api.leaderboard]
defined_in: ["20260826001500_api_and_grants.sql", "20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.leaderboard

Domain `api-surface`.

## leaderboard(integer) → SETOF ranking.ranking_result

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_limit` | `integer` | `20` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`ranking.ranking_result`](../../relations/ranking/ranking_result.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["leaderboard"]`.

Defined in: `20260826001500_api_and_grants.sql`, `20260912011000_km_10_api.sql`.
