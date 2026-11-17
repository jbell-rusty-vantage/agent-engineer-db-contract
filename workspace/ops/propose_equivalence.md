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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
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
