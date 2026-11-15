---
id: "op:revoke_asset"
kind: operation
name: revoke_asset
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.asset_scope]
tokens: [revoke_asset, command, api.product_command]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# revoke_asset

Product operation: the `when 'revoke_asset' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'revoke_asset', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.asset_scope`](../relations/authoring/asset_scope.md) | write |

## Helpers called

[`product.require_role`](../functions/product/require_role.md)
