---
id: "op:decide_delivery"
kind: operation
name: decide_delivery
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [inquiry.acceptance, inquiry.delivery, inquiry.obligation]
tokens: [decide_delivery, research, api.product_command]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# decide_delivery

Product operation: the `when 'decide_delivery' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'decide_delivery', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.delivery`](../relations/inquiry/delivery.md) | write |
| [`inquiry.acceptance`](../relations/inquiry/acceptance.md) | read |
| [`inquiry.obligation`](../relations/inquiry/obligation.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.require_role`](../functions/product/require_role.md)
