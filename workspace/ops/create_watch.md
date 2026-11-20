---
id: "op:create_watch"
kind: operation
name: create_watch
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [authoring.work, inquiry.watch]
tokens: [create_watch, research, api.product_command]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# create_watch

Product operation: the `when 'create_watch' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'create_watch', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.watch`](../relations/inquiry/watch.md) | write |
| [`authoring.work`](../relations/authoring/work.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
