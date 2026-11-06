---
id: "sch:ranking"
kind: schema
name: ranking
domains: [ranking]
relations: 16
functions: 0
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# ranking

Metric definitions/observations, features, groups, policies, snapshots. Domains: [`ranking`](../../domains/ranking.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`entity_group`](../../relations/ranking/entity_group.md) | table | unknown | — | — |
| [`entity_group_version`](../../relations/ranking/entity_group_version.md) | table | unknown | — | → `ranking.entity_group` |
| [`feature_definition`](../../relations/ranking/feature_definition.md) | table | unknown | — | — |
| [`feature_value`](../../relations/ranking/feature_value.md) | table | unknown | — | → `ranking.feature_definition`, → `corpus.entity` |
| [`group_membership`](../../relations/ranking/group_membership.md) | table | unknown | — | → `corpus.entity`, → `ranking.entity_group_version`, → `evidence.claim` |
| [`leaderboard`](../../relations/ranking/leaderboard.md) | table | unknown | — | → `ranking.entity_group_version`, → `ranking.ranking_policy_version` |
| [`leaderboard_edition`](../../relations/ranking/leaderboard_edition.md) | table | unknown | — | → `ranking.leaderboard`, → `ranking.ranking_run` |
| [`membership_snapshot`](../../relations/ranking/membership_snapshot.md) | table | unknown | — | → `ranking.entity_group_version` |
| [`metric_definition`](../../relations/ranking/metric_definition.md) | table | unknown | — | — |
| [`metric_definition_version`](../../relations/ranking/metric_definition_version.md) | table | unknown | — | → `ranking.metric_definition` |
| [`metric_observation`](../../relations/ranking/metric_observation.md) | table | unknown | — | → `corpus.benchmark_run`, → `evidence.claim`, → `evidence.locator`, → `ranking.metric_definition_version` |
| [`ranking_policy`](../../relations/ranking/ranking_policy.md) | table | unknown | — | — |
| [`ranking_policy_version`](../../relations/ranking/ranking_policy_version.md) | table | unknown | — | → `ranking.ranking_policy` |
| [`ranking_result`](../../relations/ranking/ranking_result.md) | table | unknown | — | → `ranking.ranking_run`, → `corpus.entity` |
| [`ranking_run`](../../relations/ranking/ranking_run.md) | table | unknown | — | → `ranking.ranking_policy_version`, → `ranking.membership_snapshot`, → `orchestration.work_item` |
| [`selection`](../../relations/ranking/selection.md) | table | unknown | — | → `ranking.ranking_run` |

Functions: none.

Types: [`types/ranking.md`](../../types/ranking.md).
