---
id: "rel:observability.trace"
kind: table
schema: observability
name: trace
domain: observability
aliases: []
tokens: [observability, trace, observability.trace, trace_id, tenant_id, mission_id, work_item_id, attempt_id, causation_id, root_span_id, started_at, ended_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, pipeline_agent, service_role]
typescript: "Database[\"observability\"][\"Tables\"][\"trace\"][\"Row\"]"
defined_in: ["20260826001200_observability.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# observability.trace

table in domain `observability`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `trace_id` | `text` | no | — | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](../orchestration/mission.md).id |
| 4 | `work_item_id` | `uuid` | yes | — | FK → [`orchestration.work_item`](../orchestration/work_item.md).id |
| 5 | `attempt_id` | `uuid` | yes | — | FK → [`orchestration.attempt`](../orchestration/attempt.md).id |
| 6 | `causation_id` | `uuid` | yes | — | — |
| 7 | `root_span_id` | `text` | yes | — | — |
| 8 | `started_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `ended_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (trace_id)

## Relationships

Outbound: `attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id` on delete set null; `mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.id` on delete set null; `work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.id` on delete set null.
Inbound: none.

## Indexes

`trace_attempt_idx`; `trace_mission_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `pipeline_agent`: INSERT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`.

## TypeScript

insert: `Database["observability"]["Tables"]["trace"]["Insert"]`; row: `Database["observability"]["Tables"]["trace"]["Row"]`; update: `Database["observability"]["Tables"]["trace"]["Update"]`

Defined in: `20260826001200_observability.sql`.
