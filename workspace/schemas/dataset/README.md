---
id: "sch:dataset"
kind: schema
name: dataset
lens: ours
domains: [inquiry]
relations: 4
functions: 0
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# dataset

Lens `ours`. Domains: [`inquiry`](../../domains/inquiry.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`cell`](../../relations/dataset/cell.md) | table | small | — | → `auth.users`, → `authoring.work`, → `dataset.proposal` |
| [`field`](../../relations/dataset/field.md) | table | small | — | → `auth.users`, → `authoring.work` |
| [`proposal`](../../relations/dataset/proposal.md) | table | unknown | — | → `auth.users`, → `inquiry.acceptance`, → `authoring.work_revision`, → `authoring.work` |
| [`row`](../../relations/dataset/row.md) | table | small | — | → `auth.users`, → `catalog.entity`, → `authoring.work`, → `dataset.proposal` |

Functions: none.

Types: none.
