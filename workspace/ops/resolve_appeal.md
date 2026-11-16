---
id: "op:resolve_appeal"
kind: operation
name: resolve_appeal
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [learning.appeal, learning.assessment_result, learning.attempt, learning.enrollment, learning.submission]
tokens: [resolve_appeal, command, api.product_command]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# resolve_appeal

Product operation: the `when 'resolve_appeal' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'resolve_appeal', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.appeal`](../relations/learning/appeal.md) | write |
| [`learning.assessment_result`](../relations/learning/assessment_result.md) | write |
| [`learning.attempt`](../relations/learning/attempt.md) | read |
| [`learning.enrollment`](../relations/learning/enrollment.md) | read |
| [`learning.submission`](../relations/learning/submission.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.finalize`](../functions/product/finalize.md), [`product.role_in`](../functions/product/role_in.md)
