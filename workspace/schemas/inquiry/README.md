---
id: "sch:inquiry"
kind: schema
name: inquiry
lens: ours
domains: [inquiry]
relations: 6
functions: 0
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
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
