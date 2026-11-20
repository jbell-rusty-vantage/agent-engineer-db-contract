---
id: "op:record_deployment"
kind: operation
name: record_deployment
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.deployment]
tokens: [record_deployment, command, api.product_command]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# record_deployment

Product operation: the `when 'record_deployment' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'record_deployment', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.deployment`](../relations/authoring/deployment.md) | write |

## Helpers called

[`product.require_role`](../functions/product/require_role.md), [`util.uuidv7`](../functions/util/uuidv7.md)
