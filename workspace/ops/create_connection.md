---
id: "op:create_connection"
kind: operation
name: create_connection
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [library.connection]
tokens: [create_connection, command, api.product_command]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# create_connection

Product operation: the `when 'create_connection' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'create_connection', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`library.connection`](../relations/library/connection.md) | write |

## Helpers called

[`product.band`](../functions/product/band.md), [`product.band_rank`](../functions/product/band_rank.md), [`product.fail`](../functions/product/fail.md), [`product.policy`](../functions/product/policy.md), [`product.processing_allowed`](../functions/product/processing_allowed.md), [`product.require_role`](../functions/product/require_role.md)
