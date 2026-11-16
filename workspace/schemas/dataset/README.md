---
id: "sch:dataset"
kind: schema
name: dataset
lens: ours
domains: [inquiry]
relations: 4
functions: 0
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
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
