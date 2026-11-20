---
id: "sch:dataset"
kind: schema
name: dataset
lens: ours
domains: [inquiry]
relations: 4
functions: 0
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
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
