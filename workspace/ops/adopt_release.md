---
id: "op:adopt_release"
kind: operation
name: adopt_release
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.distribution_offer, learning.enrollment, learning.release_adoption]
tokens: [adopt_release, command, api.product_command]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# adopt_release

Product operation: the `when 'adopt_release' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'adopt_release', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.release_adoption`](../relations/learning/release_adoption.md) | write |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | read |
| [`learning.enrollment`](../relations/learning/enrollment.md) | read |

## Helpers called

[`product.can_read_offer`](../functions/product/can_read_offer.md), [`product.fail`](../functions/product/fail.md)
