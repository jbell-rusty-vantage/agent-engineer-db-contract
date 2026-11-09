---
id: "op:set_control"
kind: operation
name: set_control
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [library.resource_control]
tokens: [set_control, command, api.product_command]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# set_control

Product operation: the `when 'set_control' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'set_control', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`library.resource_control`](../relations/library/resource_control.md) | write |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.processing_allowed`](../functions/product/processing_allowed.md), [`product.require_role`](../functions/product/require_role.md)
