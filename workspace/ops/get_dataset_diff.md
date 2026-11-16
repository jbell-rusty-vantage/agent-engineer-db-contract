---
id: "op:get_dataset_diff"
kind: operation
name: get_dataset_diff
dispatcher: research
function: product.dispatch_research_read
call: api.product_read
lens: ours
relations: [authoring.work, authoring.work_revision, dataset.cell, dataset.proposal, dataset.row]
tokens: [get_dataset_diff, research, api.product_read]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# get_dataset_diff

Product operation: the `when 'get_dataset_diff' then` arm of [`product.dispatch_research_read`](../functions/product/dispatch_research_read.md) (dispatcher `research`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_dataset_diff', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`dataset.cell`](../relations/dataset/cell.md) | read |
| [`dataset.proposal`](../relations/dataset/proposal.md) | read |
| [`dataset.row`](../relations/dataset/row.md) | read |

## Helpers called

[`product.dataset_snapshot`](../functions/product/dataset_snapshot.md), [`product.fail`](../functions/product/fail.md), [`product.readable_revision`](../functions/product/readable_revision.md), [`product.require_role`](../functions/product/require_role.md), [`product.support_counts`](../functions/product/support_counts.md)
