---
id: "op:set_watch_state"
kind: operation
name: set_watch_state
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [inquiry.watch]
tokens: [set_watch_state, research, api.product_command]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# set_watch_state

Product operation: the `when 'set_watch_state' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'set_watch_state', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.watch`](../relations/inquiry/watch.md) | write |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
