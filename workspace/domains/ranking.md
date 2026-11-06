---
id: "dom:ranking"
kind: domain
schemas: [ranking]
aliases: [metrics, leaderboard, scores]
relations: [ranking.metric_definition, ranking.metric_definition_version, ranking.metric_observation, ranking.feature_value, ranking.ranking_result, ranking.ranking_run, ranking.leaderboard, ranking.ranking_policy]
functions: [api.leaderboard]
tasks: [what-do-we-know-about-entity]
summary: Entity-keyed metric observations and ranking results.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Ranking and metrics

Entity-keyed metric observations and ranking results.

> curated (model_assisted, unreviewed) — Observations land on `ranking.metric_observation`: a versioned metric definition, a
> `subject_entity_id`, a numeric value, `observed_at`, and optional claim/locator.
> Feature values and ranking results (`ranking.ranking_result`) are computed artifacts
> of a `ranking.ranking_run` under a policy. `api.leaderboard` returns current
> `ranking.ranking_result` rows for the tenant.
> 
> Control tables (groups, policies, selections, leaderboard editions) remain for
> runtime. They are not a place to assert industry facts. A price belongs on
> `model_offering_price`; a benchmark score that should be a first-class identity may
> also be a `corpus.benchmark_run` plus relationships.
> 
> Ingestion uses metric.observe. Writers are executor_service. Agents read
> leaderboard and observation rows when comparing models or libraries, and they cite
> the claim that backs the number. `ranking.metric_definition` plus
> `ranking.metric_definition_version` are the vocabulary for those numbers; do not
> invent a unit that the version does not define. Group membership tables still
> point at corpus entities and are not a second identity system.
> 
> Invariant: an observation without `subject_entity_id` cannot join the leaderboard.
> Trap: treating `api.leaderboard` as current world facts — it is a computed ranking
> snapshot. After `what-do-we-know-about-entity` / `q:entity.card`, come here only
> when the question is “how does this entity score on a defined metric,” then cite
> the backing claim on the observation. Writers use metric.observe inside a batch.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`ranking.metric_definition`](../relations/ranking/metric_definition.md) | table | PK (id); unique (tenant_id, id), (tenant_id, slug); RLS | `executor_service` |
| [`ranking.metric_definition_version`](../relations/ranking/metric_definition_version.md) | table | PK (id); unique (tenant_id, id), (tenant_id, metric_definition_id, version); RLS | `executor_service` |
| [`ranking.metric_observation`](../relations/ranking/metric_observation.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`ranking.feature_value`](../relations/ranking/feature_value.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`ranking.ranking_result`](../relations/ranking/ranking_result.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`ranking.ranking_run`](../relations/ranking/ranking_run.md) | table | PK (id); RLS | helpers only |
| [`ranking.leaderboard`](../relations/ranking/leaderboard.md) | table | PK (id); unique (tenant_id, slug); RLS | helpers only |
| [`ranking.ranking_policy`](../relations/ranking/ranking_policy.md) | table | PK (id); unique (tenant_id, slug); RLS | helpers only |

## Functions

[`api.leaderboard`](../functions/api/leaderboard.md)

## Named queries

[`q:entity.card`](../queries/README.md)

## Tasks

[`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`ranking`](../schemas/ranking/README.md).
