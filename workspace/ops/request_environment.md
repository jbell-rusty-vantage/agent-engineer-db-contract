---
id: "op:request_environment"
kind: operation
name: request_environment
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [access.provided_credential, learning.environment_session]
tokens: [request_environment, command, api.product_command]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# request_environment

Product operation: the `when 'request_environment' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'request_environment', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.environment_session`](../relations/learning/environment_session.md) | write |
| [`access.provided_credential`](../relations/access/provided_credential.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.readable_revision`](../functions/product/readable_revision.md), [`product.require_role`](../functions/product/require_role.md)
