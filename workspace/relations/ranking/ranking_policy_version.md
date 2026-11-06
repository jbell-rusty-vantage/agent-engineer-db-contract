---
id: "rel:ranking.ranking_policy_version"
kind: table
schema: ranking
name: ranking_policy_version
domain: ranking
aliases: []
tokens: [ranking, ranking_policy_version, ranking.ranking_policy_version, id, ranking_policy_id, version, weights, penalties, approval_state, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"ranking_policy_version\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# ranking.ranking_policy_version

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `ranking_policy_id` | `uuid` | no | — | unique (ranking_policy_id, version); FK → [`ranking.ranking_policy`](ranking_policy.md).id |
| 3 | `version` | `integer` | no | — | unique (ranking_policy_id, version) |
| 4 | `weights` | `jsonb` | no | `'{}'::jsonb` | — |
| 5 | `penalties` | `jsonb` | no | `'{}'::jsonb` | — |
| 6 | `approval_state` | `ranking.approval_state` | no | `'draft'::ranking.approval_state` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (ranking_policy_id, version)

## Relationships

Outbound: `ranking_policy_id` → [`ranking.ranking_policy`](ranking_policy.md)`.id` on delete cascade.
Inbound: [`evaluation.eval_run`](../evaluation/eval_run.md).ranking_policy_version_id, [`ranking.leaderboard`](leaderboard.md).policy_version_id, [`ranking.ranking_run`](ranking_run.md).policy_version_id.
Polymorphic target of: [`evaluation.eval_run`](../evaluation/eval_run.md) (check constraint eval_run_exactly_one_target).

## Indexes

`ranking_policy_version_ranking_policy_id_version_key` unique

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

insert: `Database["ranking"]["Tables"]["ranking_policy_version"]["Insert"]`; row: `Database["ranking"]["Tables"]["ranking_policy_version"]["Row"]`; update: `Database["ranking"]["Tables"]["ranking_policy_version"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
