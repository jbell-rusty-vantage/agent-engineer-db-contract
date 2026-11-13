---
id: "op:propose_equivalence"
kind: operation
name: propose_equivalence
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.work_revision, learning.enrollment, learning.equivalence_request]
tokens: [propose_equivalence, command, api.product_command]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# propose_equivalence

Product operation: the `when 'propose_equivalence' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'propose_equivalence', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.equivalence_request`](../relations/learning/equivalence_request.md) | write |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`learning.enrollment`](../relations/learning/enrollment.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.role_in`](../functions/product/role_in.md)
