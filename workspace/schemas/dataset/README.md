---
id: "sch:dataset"
kind: schema
name: dataset
lens: ours
domains: [inquiry]
relations: 4
functions: 0
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# dataset

Lens `ours`. Domains: [`inquiry`](../../domains/inquiry.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`cell`](../../relations/dataset/cell.md) | table | small | — | → `auth.users`, → `authoring.work`, → `dataset.proposal` |
| [`field`](../../relations/dataset/field.md) | table | unknown | — | → `auth.users`, → `authoring.work` |
| [`proposal`](../../relations/dataset/proposal.md) | table | unknown | — | → `auth.users`, → `inquiry.acceptance`, → `authoring.work_revision`, → `authoring.work` |
| [`row`](../../relations/dataset/row.md) | table | unknown | — | → `auth.users`, → `catalog.entity`, → `authoring.work`, → `dataset.proposal` |

Functions: none.

Types: none.
