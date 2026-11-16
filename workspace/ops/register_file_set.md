---
id: "op:register_file_set"
kind: operation
name: register_file_set
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.asset_scope, authoring.file_set, authoring.file_set_entry, orchestration.artifact]
tokens: [register_file_set, command, api.product_command]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# register_file_set

Product operation: the `when 'register_file_set' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'register_file_set', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.file_set`](../relations/authoring/file_set.md) | write |
| [`authoring.file_set_entry`](../relations/authoring/file_set_entry.md) | write |
| [`authoring.asset_scope`](../relations/authoring/asset_scope.md) | read |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md), [`product.sha256_text`](../functions/product/sha256_text.md)
