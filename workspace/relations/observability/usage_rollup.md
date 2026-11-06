---
id: "rel:observability.usage_rollup"
kind: table
schema: observability
name: usage_rollup
domain: observability
aliases: []
tokens: [observability, usage_rollup, observability.usage_rollup, id, mission_id, day, cost_usd, token_input, token_output, latency_ms_p50, latency_ms_p95, retry_count, span_count, computed_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"observability\"][\"Tables\"][\"usage_rollup\"][\"Row\"]"
defined_in: ["20260826001200_observability.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# observability.usage_rollup

table in domain `observability`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `mission_id` | `uuid` | yes | — | unique (mission_id, day); FK → [`orchestration.mission`](../orchestration/mission.md).id |
| 3 | `day` | `date` | no | — | unique (mission_id, day) |
| 4 | `cost_usd` | `numeric(14,6)` | no | `0` | — |
| 5 | `token_input` | `bigint` | no | `0` | — |
| 6 | `token_output` | `bigint` | no | `0` | — |
| 7 | `latency_ms_p50` | `bigint` | yes | — | — |
| 8 | `latency_ms_p95` | `bigint` | yes | — | — |
| 9 | `retry_count` | `integer` | no | `0` | — |
| 10 | `span_count` | `bigint` | no | `0` | — |
| 11 | `computed_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (mission_id, day)

## Relationships

Outbound: `mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.id` on delete cascade.
Inbound: none.

## Indexes

`usage_rollup_day_idx`; `usage_rollup_mission_id_day_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Exposed through: [`api.mission_progress`](../api/mission_progress.md).
- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["observability"]["Tables"]["usage_rollup"]["Insert"]`; row: `Database["observability"]["Tables"]["usage_rollup"]["Row"]`; update: `Database["observability"]["Tables"]["usage_rollup"]["Update"]`

Defined in: `20260826001200_observability.sql`.
