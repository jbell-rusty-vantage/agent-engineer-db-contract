---
id: "op:decide_dataset_change"
kind: operation
name: decide_dataset_change
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [dataset.cell, dataset.proposal, dataset.row]
tokens: [decide_dataset_change, research, api.product_command]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# decide_dataset_change

Product operation: the `when 'decide_dataset_change' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'decide_dataset_change', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`dataset.cell`](../relations/dataset/cell.md) | write |
| [`dataset.proposal`](../relations/dataset/proposal.md) | write |
| [`dataset.row`](../relations/dataset/row.md) | write |

## Helpers called

[`product.dataset_close_cell`](../functions/product/dataset_close_cell.md), [`product.dataset_commit`](../functions/product/dataset_commit.md), [`product.dataset_draft_no`](../functions/product/dataset_draft_no.md), [`product.dataset_work`](../functions/product/dataset_work.md), [`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.require_role`](../functions/product/require_role.md)
