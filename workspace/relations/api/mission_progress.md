---
id: "rel:api.mission_progress"
kind: view
schema: api
name: mission_progress
domain: api-surface
lens: machinery
aliases: []
tokens: [api, mission_progress, api.mission_progress, mission_id, slug, goal, status, started_at, ended_at, work_items, succeeded, failed, outstanding, cost_usd, budget_cost_usd]
summary: null
summary_basis: none
rls: disabled
readers: [app_reader, authenticated, service_role]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"mission_progress\"][\"Row\"]"
defined_in: ["20260826001500_api_and_grants.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.mission_progress

view in domain `api-surface`, lens `machinery`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `mission_id` | `uuid` | yes | — | — |
| 2 | `slug` | `text` | yes | — | — |
| 3 | `goal` | `text` | yes | — | — |
| 4 | `status` | `orchestration.mission_status` | yes | — | — |
| 5 | `started_at` | `timestamp with time zone` | yes | — | — |
| 6 | `ended_at` | `timestamp with time zone` | yes | — | — |
| 7 | `work_items` | `bigint` | yes | — | — |
| 8 | `succeeded` | `bigint` | yes | — | — |
| 9 | `failed` | `bigint` | yes | — | — |
| 10 | `outstanding` | `bigint` | yes | — | — |
| 11 | `cost_usd` | `numeric` | yes | — | — |
| 12 | `budget_cost_usd` | `numeric(12,4)` | yes | — | — |

## Constraints

_None._

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `authenticated`: SELECT; `service_role`: SELECT. None: `anon`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `app_reader`.

## Write path

Views are not written.

## View definition

See [details](mission_progress.details.md).

## TypeScript

row: `Database["api"]["Views"]["mission_progress"]["Row"]`

Defined in: `20260826001500_api_and_grants.sql`.
