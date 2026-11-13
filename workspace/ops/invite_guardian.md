---
id: "op:invite_guardian"
kind: operation
name: invite_guardian
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [access.guardian_link]
tokens: [invite_guardian, command, api.product_command]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# invite_guardian

Product operation: the `when 'invite_guardian' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'invite_guardian', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`access.guardian_link`](../relations/access/guardian_link.md) | write |
