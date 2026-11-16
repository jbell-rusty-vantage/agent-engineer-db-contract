---
id: "rel:ranking.leaderboard_edition"
kind: table
schema: ranking
name: leaderboard_edition
domain: ranking
lens: corpus
aliases: []
tokens: [ranking, leaderboard_edition, ranking.leaderboard_edition, id, leaderboard_id, edition_no, published_at, tenant_id, knowledge_seq, cohort, capture_id, observed_at, board_date]
summary: "One frozen edition of a leaderboard: membership and knowledge head at publication."
summary_basis: comment
rls: enabled
readers: [app_reader, executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"leaderboard_edition\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# ranking.leaderboard_edition

table in domain `ranking`, lens `corpus` — One frozen edition of a leaderboard: membership and knowledge head at publication..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `leaderboard_id` | `uuid` | no | — | unique (leaderboard_id, edition_no); FK → [`ranking.leaderboard`](leaderboard.md).id |
| 4 | `edition_no` | `integer` | no | — | unique (leaderboard_id, edition_no) |
| 5 | `published_at` | `timestamp with time zone` | no | `now()` | — |
| 6 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 7 | `knowledge_seq` | `bigint` | yes | — | — |
| 8 | `cohort` | `jsonb` | no | `'[]'::jsonb` | — |
| 9 | `capture_id` | `uuid` | yes | — | FK → [`evidence.source_capture`](../evidence/source_capture.md).id |
| 10 | `observed_at` | `timestamp with time zone` | yes | — | — |
| 11 | `board_date` | `date` | yes | — | The date the publisher shows on the board (world time), if any; observed_at is when we captured it (knowledge time). |

## Constraints

- PK (id)
- unique (leaderboard_id, edition_no)

## Relationships

Outbound: `capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.id`; `leaderboard_id` → [`ranking.leaderboard`](leaderboard.md)`.id` on delete cascade.
Inbound: [`ranking.leaderboard_entry`](leaderboard_entry.md).edition_id.

## Indexes

`leaderboard_edition_leaderboard_id_edition_no_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`app_reader`: SELECT; `executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:ranking.leaderboard`.
- Direct SELECT: `app_reader`, `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["ranking"]["Tables"]["leaderboard_edition"]["Insert"]`; row: `Database["ranking"]["Tables"]["leaderboard_edition"]["Row"]`; update: `Database["ranking"]["Tables"]["leaderboard_edition"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
