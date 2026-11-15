---
id: "op:create_dataset"
kind: operation
name: create_dataset
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [authoring.work]
tokens: [create_dataset, research, api.product_command]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# create_dataset

Product operation: the `when 'create_dataset' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'create_dataset', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.work`](../relations/authoring/work.md) | write |

## Helpers called

[`product.dataset_commit`](../functions/product/dataset_commit.md), [`product.dataset_edit`](../functions/product/dataset_edit.md), [`product.require_role`](../functions/product/require_role.md)
