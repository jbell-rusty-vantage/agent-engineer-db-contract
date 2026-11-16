---
id: "fn:api.leaderboard(text,int4)"
kind: function
schema: api
name: leaderboard
domain: api-surface
lens: corpus
overloads: ["fn:api.leaderboard(text,int4)"]
security: definer
volatility: stable
executors: [app_reader, service_role]
raises: []
touches: { reads: [catalog.entity, ranking.leaderboard, ranking.leaderboard_edition, ranking.leaderboard_entry], writes: [] }
tokens: [api, leaderboard, api.leaderboard]
defined_in: ["20260826001500_api_and_grants.sql", "20260912011000_km_10_api.sql", "20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.leaderboard

Domain `api-surface`, lens `corpus`.

## leaderboard(text, integer) → TABLE(rank integer, entity_id uuid, display_name text, score numeric, unit text, explanation jsonb, edition_no integer, published_at timestamp with time zone)

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_slug` | `text` | — | — |
| `p_limit` | `integer` | `20` | — |

Execute: `app_reader`, `service_role`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`ranking.leaderboard`](../../relations/ranking/leaderboard.md), [`ranking.leaderboard_edition`](../../relations/ranking/leaderboard_edition.md), [`ranking.leaderboard_entry`](../../relations/ranking/leaderboard_entry.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:ranking.leaderboard`.

TypeScript: `Database["api"]["Functions"]["leaderboard"]`.

Defined in: `20260826001500_api_and_grants.sql`, `20260912011000_km_10_api.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
