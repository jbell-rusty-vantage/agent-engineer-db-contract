---
id: "dom:ranking"
kind: domain
lens: corpus
schemas: [ranking]
aliases: [leaderboard, ranking, editions, scores]
relations: [ranking.leaderboard, ranking.leaderboard_edition, ranking.leaderboard_entry, temporal.segment]
functions: [api.leaderboard]
tasks: [cheapest-qualified-model, compare-models]
summary: A leaderboard is a named ranked view over fact segments; editions freeze membership at a knowledge head.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# Leaderboards

A leaderboard is a named ranked view over fact segments; editions freeze membership at a knowledge head.

> curated (model_assisted, unreviewed) — Build 08 reduced `ranking` to three tables. `ranking.leaderboard` names a ranked view:
> the cohort filter, the metric (a `temporal.stream_kind`) and the policy are data in
> `definition`; the values come from `temporal.segment`, never from a metric table of their
> own. `ranking.leaderboard_edition` freezes one publication (membership, `knowledge_seq`,
> `cohort`); `ranking.leaderboard_entry` is a ranked row with `score`, `unit`,
> `explanation` and the `source_segment_ids` that produced it.
> 
> `q:ranking.leaderboard` (`api.leaderboard(p_slug, p_limit)`) returns the latest published
> edition for `app_reader`. For ad-hoc comparison use the L1 views directly:
> `q:catalog.models` (min price, capabilities), `q:catalog.benchmark_scores` (benchmark facts).
> Trap: treating an edition as current world facts — it is a snapshot at its knowledge head;
> cite the segments in `source_segment_ids` when you quote a score.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`ranking.leaderboard`](../relations/ranking/leaderboard.md) | A named ranked view whose cohort, metric (a stream kind) and policy are data; values come from temporal.segme… | PK (id); unique (tenant_id, slug); RLS | helpers only |
| [`ranking.leaderboard_edition`](../relations/ranking/leaderboard_edition.md) | One frozen edition of a leaderboard: membership and knowledge head at publication. | PK (id); unique (leaderboard_id, edition_no); RLS | helpers only |
| [`ranking.leaderboard_entry`](../relations/ranking/leaderboard_entry.md) | Ranked row of an edition with the fact segments that produced the score. | PK (edition_id, rank) | helpers only |
| [`temporal.segment`](../relations/temporal/segment.md) | A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to). One home for every number. | PK (id); unique (tenant_id, id); 1 exclusion; RLS | helpers only |

## Functions

[`api.leaderboard`](../functions/api/leaderboard.md)

## Named queries

[`q:catalog.benchmark_scores`](../queries/README.md), [`q:ranking.leaderboard`](../queries/README.md)

## Tasks

[`cheapest-qualified-model`](../tasks/cheapest-qualified-model.md), [`compare-models`](../tasks/compare-models.md)

Schemas: [`ranking`](../schemas/ranking/README.md).
