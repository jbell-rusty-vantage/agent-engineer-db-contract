---
id: "op:enroll"
kind: operation
name: enroll
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.distribution, authoring.distribution_offer, authoring.work, authoring.workspace, learning.enrollment]
tokens: [enroll, command, api.product_command]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# enroll

Product operation: the `when 'enroll' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'enroll', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.enrollment`](../relations/learning/enrollment.md) | write |
| [`authoring.distribution`](../relations/authoring/distribution.md) | read |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.workspace`](../relations/authoring/workspace.md) | read |

## Helpers called

[`product.can_read_offer`](../functions/product/can_read_offer.md), [`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
