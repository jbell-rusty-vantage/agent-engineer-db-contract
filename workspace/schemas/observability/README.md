---
id: "sch:observability"
kind: schema
name: observability
lens: machinery
domains: [observability]
relations: 7
functions: 0
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
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
