---
id: "op:grant_member"
kind: operation
name: grant_member
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.workspace_member]
tokens: [grant_member, command, api.product_command]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# grant_member

Product operation: the `when 'grant_member' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'grant_member', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.workspace_member`](../relations/authoring/workspace_member.md) | write |

## Helpers called

[`product.require_role`](../functions/product/require_role.md)
