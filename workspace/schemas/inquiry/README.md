---
id: "sch:inquiry"
kind: schema
name: inquiry
lens: ours
domains: [inquiry]
relations: 6
functions: 0
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# inquiry

Lens `ours`. Domains: [`inquiry`](../../domains/inquiry.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`acceptance`](../../relations/inquiry/acceptance.md) | table | unknown | — | → `auth.users`, → `authoring.event`, → `authoring.work_revision` |
| [`assertion`](../../relations/inquiry/assertion.md) | table | unknown | — | → `auth.users`, → `evidence.claim`, → `authoring.work_revision` |
| [`delivery`](../../relations/inquiry/delivery.md) | table | unknown | — | → `auth.users`, → `orchestration.artifact`, → `authoring.event`, → `authoring.file_set` |
| [`obligation`](../../relations/inquiry/obligation.md) | table | unknown | — | → `inquiry.acceptance` |
| [`support`](../../relations/inquiry/support.md) | table | small | — | → `auth.users`, → `evidence.source_capture`, → `evidence.claim`, → `evidence.locator` |
| [`watch`](../../relations/inquiry/watch.md) | table | unknown | — | → `auth.users`, → `authoring.work` |

Functions: none.

Types: none.
