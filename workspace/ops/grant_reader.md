---
id: "op:grant_reader"
kind: operation
name: grant_reader
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.distribution, authoring.distribution_member]
tokens: [grant_reader, command, api.product_command]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# grant_reader

Product operation: the `when 'grant_reader' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'grant_reader', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.distribution_member`](../relations/authoring/distribution_member.md) | write |
| [`authoring.distribution`](../relations/authoring/distribution.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
