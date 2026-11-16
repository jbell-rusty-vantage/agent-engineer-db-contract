---
id: "fn:api.leaderboard_diff(text,int4,int4)"
kind: function
schema: api
name: leaderboard_diff
domain: ranking
lens: corpus
overloads: ["fn:api.leaderboard_diff(text,int4,int4)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [ranking.leaderboard, ranking.leaderboard_edition, ranking.leaderboard_entry], writes: [] }
tokens: [api, leaderboard_diff, api.leaderboard_diff]
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# api.leaderboard_diff

Domain `ranking`, lens `corpus`.

## leaderboard_diff(text, integer, integer) → TABLE(change text, subject_label text, entity_id uuid, rank_a integer, rank_b integer, score_a numeric, score_b numeric, conditions jsonb, edition_a integer, edition_b integer, observed_a timestamp with time zone, observed_b timestamp with time zone, board_date_a date, board_date_b date)

function, stable, security definer, language sql, config `search_path=""`. L2: what changed on a leaderboard between two editions (captures): entered, left, moved, score_changed, unchanged; both clocks (board_date vs observed_at).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_slug` | `text` | — | — |
| `p_edition_a` | `integer` | `NULL::integer` | — |
| `p_edition_b` | `integer` | `NULL::integer` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`ranking.leaderboard`](../../relations/ranking/leaderboard.md), [`ranking.leaderboard_edition`](../../relations/ranking/leaderboard_edition.md), [`ranking.leaderboard_entry`](../../relations/ranking/leaderboard_entry.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["leaderboard_diff"]`.

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
