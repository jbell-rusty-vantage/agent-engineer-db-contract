---
id: "sch:library"
kind: schema
name: library
lens: ours
domains: [library]
relations: 6
functions: 0
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# library

Lens `ours`. Domains: [`library`](../../domains/library.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`connected_item`](../../relations/library/connected_item.md) | table | unknown | — | → `library.connection`, → `authoring.work`, → `authoring.work_revision` |
| [`connection`](../../relations/library/connection.md) | table | unknown | — | → `auth.users`, → `authoring.workspace` |
| [`passage`](../../relations/library/passage.md) | table | small | Indexed text unit of a workspace's own material (a revision, an uploaded artifact or a co… | → `orchestration.artifact`, → `conversation.message`, → `authoring.work_revision` |
| [`preparation`](../../relations/library/preparation.md) | table | small | — | → `orchestration.artifact`, → `authoring.work_revision` |
| [`removal`](../../relations/library/removal.md) | table | unknown | — | → `auth.users`, → `authoring.workspace`, → `authoring.event` |
| [`resource_control`](../../relations/library/resource_control.md) | table | unknown | — | → `auth.users`, → `authoring.work` |

Functions: none.

Types: none.
