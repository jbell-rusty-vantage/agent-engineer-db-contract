---
id: "op:revise_work"
kind: operation
name: revise_work
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.work]
tokens: [revise_work, command, api.product_command]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# revise_work

Product operation: the `when 'revise_work' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'revise_work', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.work`](../relations/authoring/work.md) | write |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.insert_revision`](../functions/product/insert_revision.md), [`product.require_role`](../functions/product/require_role.md)
