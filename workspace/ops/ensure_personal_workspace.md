---
id: "op:ensure_personal_workspace"
kind: operation
name: ensure_personal_workspace
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: []
tokens: [ensure_personal_workspace, command, api.product_command]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# ensure_personal_workspace

Product operation: the `when 'ensure_personal_workspace' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'ensure_personal_workspace', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

_None._

## Helpers called

[`product.personal_workspace`](../functions/product/personal_workspace.md)
