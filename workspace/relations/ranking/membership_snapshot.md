---
id: "rel:ranking.membership_snapshot"
kind: table
schema: ranking
name: membership_snapshot
domain: ranking
aliases: []
tokens: [ranking, membership_snapshot, ranking.membership_snapshot, id, group_version_id, members, member_count, frozen_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"membership_snapshot\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# ranking.membership_snapshot

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `group_version_id` | `uuid` | no | — | FK → [`ranking.entity_group_version`](entity_group_version.md).id |
| 3 | `members` | `jsonb` | no | — | — |
| 4 | `member_count` | `integer` | no | — | — |
| 5 | `frozen_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `group_version_id` → [`ranking.entity_group_version`](entity_group_version.md)`.id`.
Inbound: [`ranking.ranking_run`](ranking_run.md).snapshot_id.

## Indexes

_None._

## Triggers

- `membership_snapshot_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["ranking"]["Tables"]["membership_snapshot"]["Insert"]`; row: `Database["ranking"]["Tables"]["membership_snapshot"]["Row"]`; update: `Database["ranking"]["Tables"]["membership_snapshot"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
