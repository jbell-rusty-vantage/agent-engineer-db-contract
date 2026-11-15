---
id: "sch:library"
kind: schema
name: library
lens: ours
domains: [library]
relations: 6
functions: 0
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# library

Lens `ours`. Domains: [`library`](../../domains/library.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`connected_item`](../../relations/library/connected_item.md) | table | unknown | — | → `library.connection`, → `authoring.work`, → `authoring.work_revision` |
| [`connection`](../../relations/library/connection.md) | table | unknown | — | → `auth.users`, → `authoring.workspace` |
| [`passage`](../../relations/library/passage.md) | table | unknown | Indexed text unit of a workspace's own material (a revision, an uploaded artifact or a co… | → `orchestration.artifact`, → `conversation.message`, → `authoring.work_revision` |
| [`preparation`](../../relations/library/preparation.md) | table | unknown | — | → `orchestration.artifact`, → `authoring.work_revision` |
| [`removal`](../../relations/library/removal.md) | table | unknown | — | → `auth.users`, → `authoring.workspace`, → `authoring.event` |
| [`resource_control`](../../relations/library/resource_control.md) | table | unknown | — | → `auth.users`, → `authoring.work` |

Functions: none.

Types: none.
