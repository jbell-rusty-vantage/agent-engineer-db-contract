---
id: "rel:ranking.entity_group_version"
kind: table
schema: ranking
name: entity_group_version
domain: ranking
aliases: []
tokens: [ranking, entity_group_version, ranking.entity_group_version, id, entity_group_id, version, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"entity_group_version\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# ranking.entity_group_version

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `entity_group_id` | `uuid` | no | — | unique (entity_group_id, version); FK → [`ranking.entity_group`](entity_group.md).id |
| 3 | `version` | `integer` | no | — | unique (entity_group_id, version) |
| 4 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (entity_group_id, version)

## Relationships

Outbound: `entity_group_id` → [`ranking.entity_group`](entity_group.md)`.id` on delete cascade.
Inbound: [`ranking.group_membership`](group_membership.md).group_version_id, [`ranking.leaderboard`](leaderboard.md).group_version_id, [`ranking.membership_snapshot`](membership_snapshot.md).group_version_id.

## Indexes

`entity_group_version_entity_group_id_version_key` unique

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

insert: `Database["ranking"]["Tables"]["entity_group_version"]["Insert"]`; row: `Database["ranking"]["Tables"]["entity_group_version"]["Row"]`; update: `Database["ranking"]["Tables"]["entity_group_version"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
