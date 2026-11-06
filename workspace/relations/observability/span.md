---
id: "rel:observability.span"
kind: partitioned_table
schema: observability
name: span
domain: observability
aliases: []
tokens: [observability, span, observability.span, id, trace_id, span_id, parent_span_id, name, kind, status, started_at, ended_at, duration_ms, cost_usd, token_input, token_output, attributes, occurred_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, pipeline_agent, service_role]
typescript: "Database[\"observability\"][\"Tables\"][\"span\"][\"Row\"]"
defined_in: ["20260826001200_observability.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# observability.span

partitioned table in domain `observability`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `trace_id` | `text` | no | — | Soft reference by design: spans can arrive before their trace row exists. |
| 3 | `span_id` | `text` | no | — | — |
| 4 | `parent_span_id` | `text` | yes | — | — |
| 5 | `name` | `text` | no | — | — |
| 6 | `kind` | `text` | no | — | — |
| 7 | `status` | `text` | no | `'ok'::text` | — |
| 8 | `started_at` | `timestamp with time zone` | no | — | — |
| 9 | `ended_at` | `timestamp with time zone` | yes | — | — |
| 10 | `duration_ms` | `bigint` | yes | — | — |
| 11 | `cost_usd` | `numeric(12,6)` | yes | — | — |
| 12 | `token_input` | `bigint` | yes | — | — |
| 13 | `token_output` | `bigint` | yes | — | — |
| 14 | `attributes` | `jsonb` | no | `'{}'::jsonb` | — |
| 15 | `occurred_at` | `timestamp with time zone` | no | `now()` | PK |

## Constraints

- PK (id, occurred_at)
- check `span_kind_check`: `(kind = ANY (ARRAY['model'::text, 'tool'::text, 'mcp'::text, 'retrieval'::text, 'executor'::text, 'http'::text, 'db'::text, 'internal'::tex…`
- check `span_status_check`: `(status = ANY (ARRAY['ok'::text, 'error'::text, 'cancelled'::text]))`

## Relationships

Outbound: none.
Inbound: none.

## Indexes

`span_kind_idx`; `span_trace_idx`

## Triggers

- `span_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

range by `RANGE (occurred_at)`; 8 children: `observability.span_202609` FOR VALUES FROM ('2026-09-01 00:00:00+00') TO ('2026-10-01 00:00:00+00'), `observability.span_202610` FOR VALUES FROM ('2026-10-01 00:00:00+00') TO ('2026-11-01 00:00:00+00'), `observability.span_202611` FOR VALUES FROM ('2026-11-01 00:00:00+00') TO ('2026-12-01 00:00:00+00'), `observability.span_202612` FOR VALUES FROM ('2026-12-01 00:00:00+00') TO ('2027-01-01 00:00:00+00'), `observability.span_202701` FOR VALUES FROM ('2027-01-01 00:00:00+00') TO ('2027-02-01 00:00:00+00'), `observability.span_202702` FOR VALUES FROM ('2027-02-01 00:00:00+00') TO ('2027-03-01 00:00:00+00'), `observability.span_202703` FOR VALUES FROM ('2027-03-01 00:00:00+00') TO ('2027-04-01 00:00:00+00'), `observability.span_202704` FOR VALUES FROM ('2027-04-01 00:00:00+00') TO ('2027-05-01 00:00:00+00').

## TypeScript

insert: `Database["observability"]["Tables"]["span"]["Insert"]`; row: `Database["observability"]["Tables"]["span"]["Row"]`; update: `Database["observability"]["Tables"]["span"]["Update"]`

Defined in: `20260826001200_observability.sql`.
