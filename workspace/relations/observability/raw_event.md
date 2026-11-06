---
id: "rel:observability.raw_event"
kind: partitioned_table
schema: observability
name: raw_event
domain: observability
aliases: []
tokens: [observability, raw_event, observability.raw_event, id, stream_cursor, idempotency_key, event, trace_id, occurred_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, pipeline_agent, service_role]
typescript: "Database[\"observability\"][\"Tables\"][\"raw_event\"][\"Row\"]"
defined_in: ["20260826001200_observability.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# observability.raw_event

partitioned table in domain `observability`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `stream_cursor` | `text` | yes | — | — |
| 3 | `idempotency_key` | `text` | no | — | unique (idempotency_key, occurred_at) |
| 4 | `event` | `jsonb` | no | — | — |
| 5 | `trace_id` | `text` | yes | — | — |
| 6 | `occurred_at` | `timestamp with time zone` | no | `now()` | PK; unique (idempotency_key, occurred_at) |

## Constraints

- PK (id, occurred_at)
- unique (idempotency_key, occurred_at)

## Relationships

Outbound: none.
Inbound: none.

## Indexes

`raw_event_idempotency_key_occurred_at_key` unique; `raw_event_trace_idx`

## Triggers

- `raw_event_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT; `pipeline_agent`: INSERT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`.

## Partitions

range by `RANGE (occurred_at)`; 8 children: `observability.raw_event_202609` FOR VALUES FROM ('2026-09-01 00:00:00+00') TO ('2026-10-01 00:00:00+00'), `observability.raw_event_202610` FOR VALUES FROM ('2026-10-01 00:00:00+00') TO ('2026-11-01 00:00:00+00'), `observability.raw_event_202611` FOR VALUES FROM ('2026-11-01 00:00:00+00') TO ('2026-12-01 00:00:00+00'), `observability.raw_event_202612` FOR VALUES FROM ('2026-12-01 00:00:00+00') TO ('2027-01-01 00:00:00+00'), `observability.raw_event_202701` FOR VALUES FROM ('2027-01-01 00:00:00+00') TO ('2027-02-01 00:00:00+00'), `observability.raw_event_202702` FOR VALUES FROM ('2027-02-01 00:00:00+00') TO ('2027-03-01 00:00:00+00'), `observability.raw_event_202703` FOR VALUES FROM ('2027-03-01 00:00:00+00') TO ('2027-04-01 00:00:00+00'), `observability.raw_event_202704` FOR VALUES FROM ('2027-04-01 00:00:00+00') TO ('2027-05-01 00:00:00+00').

## TypeScript

insert: `Database["observability"]["Tables"]["raw_event"]["Insert"]`; row: `Database["observability"]["Tables"]["raw_event"]["Row"]`; update: `Database["observability"]["Tables"]["raw_event"]["Update"]`

Defined in: `20260826001200_observability.sql`.
