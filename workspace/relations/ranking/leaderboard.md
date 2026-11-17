---
id: "rel:ranking.leaderboard"
kind: table
schema: ranking
name: leaderboard
domain: ranking
lens: corpus
aliases: [leaderboard definition]
tokens: [ranking, leaderboard, ranking.leaderboard, id, tenant_id, slug, created_at, title, definition, description, publisher_entity_id, benchmark_version_id, source_url, methodology]
summary: "A named ranked view whose cohort, metric (a stream kind) and policy are data; values come from temporal.segment."
summary_basis: curated
rls: enabled
readers: [app_reader, executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"leaderboard\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# ranking.leaderboard

table in domain `ranking`, lens `corpus` — A named ranked view: cohort filter, metric (a stream kind) and policy are data in definition; values come from temporal.segment..

> curated (model_assisted, unreviewed) — A named ranked view whose cohort, metric (a stream kind) and policy are data; values come from temporal.segment.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug); _curated:_ api.leaderboard(p_slug) key. |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 7 | `title` | `text` | no | `''::text` | — |
| 8 | `definition` | `jsonb` | no | `'{}'::jsonb` | _curated:_ cohort filter, metric stream kind, policy. |
| 9 | `description` | `text` | yes | — | — |
| 10 | `publisher_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 11 | `benchmark_version_id` | `uuid` | yes | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 12 | `source_url` | `text` | yes | — | — |
| 13 | `methodology` | `jsonb` | no | `'{}'::jsonb` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)

## Relationships

Outbound: `benchmark_version_id` → [`catalog.entity`](../catalog/entity.md)`.id`; `publisher_entity_id` → [`catalog.entity`](../catalog/entity.md)`.id`.
Inbound: [`ranking.leaderboard_edition`](leaderboard_edition.md).leaderboard_id.

## Indexes

`leaderboard_tenant_id_slug_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:ranking.leaderboard`.
- Direct SELECT: `app_reader`, `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["ranking"]["Tables"]["leaderboard"]["Insert"]`; row: `Database["ranking"]["Tables"]["leaderboard"]["Row"]`; update: `Database["ranking"]["Tables"]["leaderboard"]["Update"]`

## Examples

Latest edition

```bash
knowledge db query ranking.leaderboard --param limit=20 --param slug=cheapest-frontier-input
```
Empty when no edition has been published under that slug.

Defined in: `20260826000800_ranking.sql`.
