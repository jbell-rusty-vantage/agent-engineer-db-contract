---
id: "op:revoke_client_grant"
kind: operation
name: revoke_client_grant
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [access.client_grant]
tokens: [revoke_client_grant, command, api.product_command]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# revoke_client_grant

Product operation: the `when 'revoke_client_grant' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'revoke_client_grant', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`access.client_grant`](../relations/access/client_grant.md) | write |
