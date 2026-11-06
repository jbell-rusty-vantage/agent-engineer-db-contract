---
id: "rel:ranking.leaderboard_edition"
kind: table
schema: ranking
name: leaderboard_edition
domain: ranking
aliases: []
tokens: [ranking, leaderboard_edition, ranking.leaderboard_edition, id, leaderboard_id, ranking_run_id, edition_no, published_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"leaderboard_edition\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# ranking.leaderboard_edition

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `leaderboard_id` | `uuid` | no | — | unique (leaderboard_id, edition_no); FK → [`ranking.leaderboard`](leaderboard.md).id |
| 3 | `ranking_run_id` | `uuid` | no | — | FK → [`ranking.ranking_run`](ranking_run.md).id |
| 4 | `edition_no` | `integer` | no | — | unique (leaderboard_id, edition_no) |
| 5 | `published_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (leaderboard_id, edition_no)

## Relationships

Outbound: `leaderboard_id` → [`ranking.leaderboard`](leaderboard.md)`.id` on delete cascade; `ranking_run_id` → [`ranking.ranking_run`](ranking_run.md)`.id`.
Inbound: none.

## Indexes

`leaderboard_edition_leaderboard_id_edition_no_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["ranking"]["Tables"]["leaderboard_edition"]["Insert"]`; row: `Database["ranking"]["Tables"]["leaderboard_edition"]["Row"]`; update: `Database["ranking"]["Tables"]["leaderboard_edition"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
