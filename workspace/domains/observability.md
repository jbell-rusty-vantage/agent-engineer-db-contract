---
id: "dom:observability"
kind: domain
lens: machinery
schemas: [observability]
aliases: [traces, spans, events]
relations: [observability.trace, observability.span, observability.raw_event, observability.normalized_event, observability.usage_rollup, observability.io_link, observability.coordinator_handoff]
functions: []
tasks: [check-knowledge-head]
summary: "Traces, spans, and normalized runtime events, month-partitioned (machinery lens)."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# Observability

Traces, spans, and normalized runtime events, month-partitioned (machinery lens).

> curated (model_assisted, unreviewed) — Observability stores traces, spans, raw and normalized events, usage rollups, IO
> links, and coordinator handoffs. Event and span tables are month-partitioned.
> This is runtime telemetry for missions and executors, not industry knowledge.
> 
> Agents debugging a failed ingest should look here only after the receipt and
> knowledge head. Do not copy span attributes into `temporal.segment`. Normalized
> events are the query surface; raw events are the append-only capture.
> `observability.usage_rollup` aggregates tokens and cost for experiment metrics;
> acquisition spend is in `acquisition.fetch`, not here.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`observability.trace`](../relations/observability/trace.md) | table | PK (trace_id); RLS | `control_plane`, `pipeline_agent` |
| [`observability.span`](../relations/observability/span.md) | partitioned_table | PK (id, occurred_at); RLS | `control_plane`, `pipeline_agent` |
| [`observability.raw_event`](../relations/observability/raw_event.md) | partitioned_table | PK (id, occurred_at); unique (idempotency_key, occurred_at); RLS | `control_plane`, `pipeline_agent` |
| [`observability.normalized_event`](../relations/observability/normalized_event.md) | partitioned_table | PK (id, occurred_at); RLS | `control_plane` |
| [`observability.usage_rollup`](../relations/observability/usage_rollup.md) | table | PK (id); unique (mission_id, day); RLS | `control_plane` |
| [`observability.io_link`](../relations/observability/io_link.md) | table | PK (id); RLS | `control_plane` |
| [`observability.coordinator_handoff`](../relations/observability/coordinator_handoff.md) | table | PK (id); RLS | `control_plane` |

## Named queries

[`q:knowledge.head`](../queries/README.md)

## Tasks

[`check-knowledge-head`](../tasks/check-knowledge-head.md)

Schemas: [`observability`](../schemas/observability/README.md).
