---
id: "op:register_asset"
kind: operation
name: register_asset
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [orchestration.artifact]
tokens: [register_asset, command, api.product_command]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# register_asset

Product operation: the `when 'register_asset' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'register_asset', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.register_artifact`](../functions/product/register_artifact.md), [`product.require_role`](../functions/product/require_role.md)
