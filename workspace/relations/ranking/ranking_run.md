---
id: "rel:ranking.ranking_run"
kind: table
schema: ranking
name: ranking_run
domain: ranking
aliases: []
tokens: [ranking, ranking_run, ranking.ranking_run, id, policy_version_id, snapshot_id, feature_set_hash, code_ref, work_item_id, executed_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"ranking_run\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# ranking.ranking_run

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `policy_version_id` | `uuid` | no | — | FK → [`ranking.ranking_policy_version`](ranking_policy_version.md).id |
| 3 | `snapshot_id` | `uuid` | yes | — | FK → [`ranking.membership_snapshot`](membership_snapshot.md).id |
| 4 | `feature_set_hash` | `text` | yes | — | — |
| 5 | `code_ref` | `text` | yes | — | — |
| 6 | `work_item_id` | `uuid` | yes | — | FK → [`orchestration.work_item`](../orchestration/work_item.md).id |
| 7 | `executed_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `policy_version_id` → [`ranking.ranking_policy_version`](ranking_policy_version.md)`.id`; `snapshot_id` → [`ranking.membership_snapshot`](membership_snapshot.md)`.id`; `work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.id`.
Inbound: [`ranking.leaderboard_edition`](leaderboard_edition.md).ranking_run_id, [`ranking.ranking_result`](ranking_result.md).ranking_run_id, [`ranking.selection`](selection.md).run_id.

## Indexes

_None._

## Triggers

- `ranking_run_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["ranking"]["Tables"]["ranking_run"]["Insert"]`; row: `Database["ranking"]["Tables"]["ranking_run"]["Row"]`; update: `Database["ranking"]["Tables"]["ranking_run"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
