---
id: "rel:ranking.selection"
kind: table
schema: ranking
name: selection
domain: ranking
aliases: []
tokens: [ranking, selection, ranking.selection, id, tenant_id, run_id, purpose, selected, diversity_rationale, coverage_rationale, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"selection\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# ranking.selection

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `run_id` | `uuid` | yes | — | FK → [`ranking.ranking_run`](ranking_run.md).id |
| 4 | `purpose` | `text` | no | — | — |
| 5 | `selected` | `jsonb` | no | `'[]'::jsonb` | — |
| 6 | `diversity_rationale` | `text` | yes | — | — |
| 7 | `coverage_rationale` | `text` | yes | — | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `run_id` → [`ranking.ranking_run`](ranking_run.md)`.id`.
Inbound: [`orchestration.mission`](../orchestration/mission.md).selection_id.

## Indexes

_None._

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

insert: `Database["ranking"]["Tables"]["selection"]["Insert"]`; row: `Database["ranking"]["Tables"]["selection"]["Row"]`; update: `Database["ranking"]["Tables"]["selection"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
