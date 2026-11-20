---
id: "op:propose_dataset_change"
kind: operation
name: propose_dataset_change
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [dataset.cell, dataset.field, dataset.proposal, dataset.row]
tokens: [propose_dataset_change, research, api.product_command]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# propose_dataset_change

Product operation: the `when 'propose_dataset_change' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'propose_dataset_change', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`dataset.cell`](../relations/dataset/cell.md) | write |
| [`dataset.proposal`](../relations/dataset/proposal.md) | write |
| [`dataset.row`](../relations/dataset/row.md) | write |
| [`dataset.field`](../relations/dataset/field.md) | read |

## Helpers called

[`product.check_cell_value`](../functions/product/check_cell_value.md), [`product.dataset_draft_no`](../functions/product/dataset_draft_no.md), [`product.dataset_work`](../functions/product/dataset_work.md), [`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.require_role`](../functions/product/require_role.md), [`util.uuidv7`](../functions/util/uuidv7.md)
