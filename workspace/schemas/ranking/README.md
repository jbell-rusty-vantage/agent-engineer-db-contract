---
id: "sch:ranking"
kind: schema
name: ranking
lens: corpus
domains: [ranking]
relations: 3
functions: 0
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# ranking

Metric definitions/observations, features, groups, policies, snapshots. Lens `corpus`. Domains: [`ranking`](../../domains/ranking.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`leaderboard`](../../relations/ranking/leaderboard.md) | table | unknown | A named ranked view whose cohort, metric (a stream kind) and policy are data; values come… | → `catalog.entity` |
| [`leaderboard_edition`](../../relations/ranking/leaderboard_edition.md) | table | unknown | One frozen edition of a leaderboard: membership and knowledge head at publication. | → `evidence.source_capture`, → `ranking.leaderboard` |
| [`leaderboard_entry`](../../relations/ranking/leaderboard_entry.md) | table | small | Ranked row of an edition with the fact segments that produced the score. | → `ranking.leaderboard_edition`, → `catalog.entity`, → `content.document_node` |

Functions: none.

Types: [`types/ranking.md`](../../types/ranking.md).
