---
id: "op:finalize_result"
kind: operation
name: finalize_result
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [learning.assessment_result, learning.attempt, learning.enrollment, learning.submission]
tokens: [finalize_result, command, api.product_command]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# finalize_result

Product operation: the `when 'finalize_result' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'finalize_result', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.assessment_result`](../relations/learning/assessment_result.md) | read |
| [`learning.attempt`](../relations/learning/attempt.md) | read |
| [`learning.enrollment`](../relations/learning/enrollment.md) | read |
| [`learning.submission`](../relations/learning/submission.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.finalize`](../functions/product/finalize.md), [`product.role_in`](../functions/product/role_in.md)
