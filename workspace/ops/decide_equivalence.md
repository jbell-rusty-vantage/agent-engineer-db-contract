---
id: "op:decide_equivalence"
kind: operation
name: decide_equivalence
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [learning.enrollment, learning.equivalence_request]
tokens: [decide_equivalence, command, api.product_command]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# decide_equivalence

Product operation: the `when 'decide_equivalence' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'decide_equivalence', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.equivalence_request`](../relations/learning/equivalence_request.md) | write |
| [`learning.enrollment`](../relations/learning/enrollment.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.role_in`](../functions/product/role_in.md)
