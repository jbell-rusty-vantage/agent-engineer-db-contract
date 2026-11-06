---
id: "rel:orchestration.mission_event"
kind: table
schema: orchestration
name: mission_event
domain: orchestration-ledger
aliases: []
tokens: [orchestration, mission_event, orchestration.mission_event, id, mission_id, from_status, to_status, actor, reason, causation_id, payload, occurred_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"mission_event\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.mission_event

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `mission_id` | `uuid` | no | — | FK → [`orchestration.mission`](mission.md).id |
| 3 | `from_status` | `orchestration.mission_status` | yes | — | — |
| 4 | `to_status` | `orchestration.mission_status` | no | — | — |
| 5 | `actor` | `text` | no | — | — |
| 6 | `reason` | `text` | yes | — | — |
| 7 | `causation_id` | `uuid` | yes | — | — |
| 8 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `occurred_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `mission_id` → [`orchestration.mission`](mission.md)`.id` on delete cascade.
Inbound: none.

## Indexes

`mission_event_mission_idx`

## Triggers

- `mission_event_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["mission_event"]["Insert"]`; row: `Database["orchestration"]["Tables"]["mission_event"]["Row"]`; update: `Database["orchestration"]["Tables"]["mission_event"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
