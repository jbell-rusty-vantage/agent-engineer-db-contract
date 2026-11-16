---
id: "op:set_acceptance_state"
kind: operation
name: set_acceptance_state
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [inquiry.acceptance, inquiry.delivery, inquiry.obligation]
tokens: [set_acceptance_state, research, api.product_command]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# set_acceptance_state

Product operation: the `when 'set_acceptance_state' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'set_acceptance_state', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.acceptance`](../relations/inquiry/acceptance.md) | write |
| [`inquiry.delivery`](../relations/inquiry/delivery.md) | read |
| [`inquiry.obligation`](../relations/inquiry/obligation.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
