---
id: "sch:ranking"
kind: schema
name: ranking
lens: corpus
domains: [ranking]
relations: 3
functions: 0
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# ranking

Metric definitions/observations, features, groups, policies, snapshots. Lens `corpus`. Domains: [`ranking`](../../domains/ranking.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`leaderboard`](../../relations/ranking/leaderboard.md) | table | unknown | A named ranked view whose cohort, metric (a stream kind) and policy are data; values come… | — |
| [`leaderboard_edition`](../../relations/ranking/leaderboard_edition.md) | table | unknown | One frozen edition of a leaderboard: membership and knowledge head at publication. | → `ranking.leaderboard` |
| [`leaderboard_entry`](../../relations/ranking/leaderboard_entry.md) | table | unknown | Ranked row of an edition with the fact segments that produced the score. | → `ranking.leaderboard_edition`, → `catalog.entity` |

Functions: none.

Types: [`types/ranking.md`](../../types/ranking.md).
