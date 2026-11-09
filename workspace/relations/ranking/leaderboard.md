---
id: "rel:ranking.leaderboard"
kind: table
schema: ranking
name: leaderboard
domain: ranking
lens: corpus
aliases: [leaderboard definition]
tokens: [ranking, leaderboard, ranking.leaderboard, id, tenant_id, slug, created_at, title, definition, description]
summary: "A named ranked view whose cohort, metric (a stream kind) and policy are data; values come from temporal.segment."
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"leaderboard\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
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

## Constraints

- PK (id)
- unique (tenant_id, slug)

## Relationships

Outbound: none.
Inbound: [`ranking.leaderboard_edition`](leaderboard_edition.md).leaderboard_id.

## Indexes

`leaderboard_tenant_id_slug_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:ranking.leaderboard`.
- Direct SELECT: `executor_service`.

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
