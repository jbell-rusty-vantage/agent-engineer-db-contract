---
id: "rel:ranking.leaderboard"
kind: table
schema: ranking
name: leaderboard
domain: ranking
aliases: []
tokens: [ranking, leaderboard, ranking.leaderboard, id, tenant_id, slug, group_version_id, policy_version_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"leaderboard\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# ranking.leaderboard

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `group_version_id` | `uuid` | no | — | FK → [`ranking.entity_group_version`](entity_group_version.md).id |
| 5 | `policy_version_id` | `uuid` | no | — | FK → [`ranking.ranking_policy_version`](ranking_policy_version.md).id |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)

## Relationships

Outbound: `group_version_id` → [`ranking.entity_group_version`](entity_group_version.md)`.id`; `policy_version_id` → [`ranking.ranking_policy_version`](ranking_policy_version.md)`.id`.
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

- Direct SELECT: `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["ranking"]["Tables"]["leaderboard"]["Insert"]`; row: `Database["ranking"]["Tables"]["leaderboard"]["Row"]`; update: `Database["ranking"]["Tables"]["leaderboard"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
