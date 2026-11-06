---
id: "sch:observability"
kind: schema
name: observability
domains: [observability]
relations: 7
functions: 0
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# observability

Trace index, spans, raw/normalized events, I/O links, handoffs. Domains: [`observability`](../../domains/observability.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`coordinator_handoff`](../../relations/observability/coordinator_handoff.md) | table | unknown | — | → `orchestration.continuation_checkpoint`, → `orchestration.agent_session` |
| [`io_link`](../../relations/observability/io_link.md) | table | unknown | — | → `orchestration.artifact` |
| [`normalized_event`](../../relations/observability/normalized_event.md) | partitioned table | unknown | — | — |
| [`raw_event`](../../relations/observability/raw_event.md) | partitioned table | unknown | — | — |
| [`span`](../../relations/observability/span.md) | partitioned table | unknown | — | — |
| [`trace`](../../relations/observability/trace.md) | table | unknown | — | → `orchestration.attempt`, → `orchestration.mission`, → `orchestration.work_item` |
| [`usage_rollup`](../../relations/observability/usage_rollup.md) | table | unknown | — | → `orchestration.mission` |

Functions: none.

Types: none.
