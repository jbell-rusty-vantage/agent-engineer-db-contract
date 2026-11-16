---
id: "rel:ranking.leaderboard_entry"
kind: table
schema: ranking
name: leaderboard_entry
domain: ranking
lens: corpus
aliases: [leaderboard row]
tokens: [ranking, leaderboard_entry, ranking.leaderboard_entry, tenant_id, edition_id, rank, entity_id, score, unit, explanation, source_segment_ids, conditions, subject_label, node_id]
summary: Ranked row of an edition with the fact segments that produced the score.
summary_basis: curated
rls: disabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"leaderboard_entry\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# ranking.leaderboard_entry

table in domain `ranking`, lens `corpus` — Ranked row of an edition with the fact segments that produced the score..

> curated (model_assisted, unreviewed) — Ranked row of an edition with the fact segments that produced the score.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 2 | `edition_id` | `uuid` | no | — | PK; FK → [`ranking.leaderboard_edition`](leaderboard_edition.md).id |
| 3 | `rank` | `integer` | no | — | PK |
| 4 | `entity_id` | `uuid` | no | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 5 | `score` | `numeric` | yes | — | — |
| 6 | `unit` | `text` | yes | — | — |
| 7 | `explanation` | `jsonb` | no | `'{}'::jsonb` | _curated:_ How the policy produced the score. |
| 8 | `source_segment_ids` | `uuid[]` | no | `'{}'::uuid[]` | _curated:_ temporal.segment ids behind the score; cite them. |
| 9 | `conditions` | `jsonb` | no | `'{}'::jsonb` | harness, reported_by, effort, tool_mode, step_budget ... as the board states them; the same conditions are on the benchmark_score segment payload. |
| 10 | `subject_label` | `text` | yes | — | — |
| 11 | `node_id` | `uuid` | yes | — | FK → [`content.document_node`](../content/document_node.md).id |

## Constraints

- PK (edition_id, rank)
- check `leaderboard_entry_rank_check`: `(rank >= 1)`

## Relationships

Outbound: `edition_id` → [`ranking.leaderboard_edition`](leaderboard_edition.md)`.id` on delete restrict; `entity_id` → [`catalog.entity`](../catalog/entity.md)`.id`; `node_id` → [`content.document_node`](../content/document_node.md)`.id`.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:ranking.leaderboard`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["ranking"]["Tables"]["leaderboard_entry"]["Insert"]`; row: `Database["ranking"]["Tables"]["leaderboard_entry"]["Row"]`; update: `Database["ranking"]["Tables"]["leaderboard_entry"]["Update"]`

## Examples

Rows of the latest edition

```bash
knowledge db query ranking.leaderboard --param limit=20 --param slug=cheapest-frontier-input
```
edition_no and published_at identify the snapshot.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
