---
id: "rel:observability.normalized_event"
kind: partitioned_table
schema: observability
name: normalized_event
domain: observability
aliases: []
tokens: [observability, normalized_event, observability.normalized_event, id, raw_event_id, trace_id, mission_id, event_kind, lifecycle_phase, payload, occurred_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"observability\"][\"Tables\"][\"normalized_event\"][\"Row\"]"
defined_in: ["20260826001200_observability.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# observability.normalized_event

partitioned table in domain `observability`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `raw_event_id` | `uuid` | yes | — | Soft reference. raw_event is partitioned with a composite PK, so a single-column FK cannot target it. |
| 3 | `trace_id` | `text` | yes | — | — |
| 4 | `mission_id` | `uuid` | yes | — | Soft reference by design: append-only high-volume telemetry, decoupled from mission lifecycle. |
| 5 | `event_kind` | `text` | no | — | — |
| 6 | `lifecycle_phase` | `text` | yes | — | — |
| 7 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `occurred_at` | `timestamp with time zone` | no | `now()` | PK |

## Constraints

- PK (id, occurred_at)

## Relationships

Outbound: none.
Inbound: none.

## Indexes

`normalized_event_kind_idx`; `normalized_event_mission_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## Partitions

range by `RANGE (occurred_at)`; 8 children: `observability.normalized_event_202610` FOR VALUES FROM ('2026-10-01 00:00:00+00') TO ('2026-11-01 00:00:00+00'), `observability.normalized_event_202611` FOR VALUES FROM ('2026-11-01 00:00:00+00') TO ('2026-12-01 00:00:00+00'), `observability.normalized_event_202612` FOR VALUES FROM ('2026-12-01 00:00:00+00') TO ('2027-01-01 00:00:00+00'), `observability.normalized_event_202701` FOR VALUES FROM ('2027-01-01 00:00:00+00') TO ('2027-02-01 00:00:00+00'), `observability.normalized_event_202702` FOR VALUES FROM ('2027-02-01 00:00:00+00') TO ('2027-03-01 00:00:00+00'), `observability.normalized_event_202703` FOR VALUES FROM ('2027-03-01 00:00:00+00') TO ('2027-04-01 00:00:00+00'), `observability.normalized_event_202704` FOR VALUES FROM ('2027-04-01 00:00:00+00') TO ('2027-05-01 00:00:00+00'), `observability.normalized_event_202705` FOR VALUES FROM ('2027-05-01 00:00:00+00') TO ('2027-06-01 00:00:00+00').

## TypeScript

insert: `Database["observability"]["Tables"]["normalized_event"]["Insert"]`; row: `Database["observability"]["Tables"]["normalized_event"]["Row"]`; update: `Database["observability"]["Tables"]["normalized_event"]["Update"]`

Defined in: `20260826001200_observability.sql`.
