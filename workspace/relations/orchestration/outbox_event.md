---
id: "rel:orchestration.outbox_event"
kind: table
schema: orchestration
name: outbox_event
domain: orchestration-ledger
aliases: []
tokens: [orchestration, outbox_event, orchestration.outbox_event, id, topic, payload, mission_id, causation_id, published_at, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"outbox_event\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.outbox_event

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `bigint` | no | `nextval('orchestration.outbox_event_id_seq'::regclass)` | PK |
| 2 | `topic` | `text` | no | — | — |
| 3 | `payload` | `jsonb` | no | — | — |
| 4 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](mission.md).id |
| 5 | `causation_id` | `uuid` | yes | — | — |
| 6 | `published_at` | `timestamp with time zone` | yes | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `mission_id` → [`orchestration.mission`](mission.md)`.id` on delete cascade.
Inbound: none.

## Indexes

`outbox_event_unpublished_idx` where `(published_at IS NULL)`

## Triggers

_None._

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

insert: `Database["orchestration"]["Tables"]["outbox_event"]["Insert"]`; row: `Database["orchestration"]["Tables"]["outbox_event"]["Row"]`; update: `Database["orchestration"]["Tables"]["outbox_event"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
