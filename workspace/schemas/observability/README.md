---
id: "sch:observability"
kind: schema
name: observability
lens: machinery
domains: [observability]
relations: 7
functions: 0
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# observability

Trace index, spans, raw/normalized events, I/O links, handoffs. Lens `machinery`. Domains: [`observability`](../../domains/observability.md).

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
