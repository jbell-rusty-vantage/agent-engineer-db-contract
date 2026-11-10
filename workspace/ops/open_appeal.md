---
id: "op:open_appeal"
kind: operation
name: open_appeal
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [learning.appeal, learning.assessment_result, learning.submission]
tokens: [open_appeal, command, api.product_command]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# open_appeal

Product operation: the `when 'open_appeal' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'open_appeal', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.appeal`](../relations/learning/appeal.md) | write |
| [`learning.assessment_result`](../relations/learning/assessment_result.md) | read |
| [`learning.submission`](../relations/learning/submission.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md)
