---
id: "op:open_distribution"
kind: operation
name: open_distribution
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.distribution]
tokens: [open_distribution, command, api.product_command]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# open_distribution

Product operation: the `when 'open_distribution' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'open_distribution', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.distribution`](../relations/authoring/distribution.md) | write |

## Helpers called

[`product.band`](../functions/product/band.md), [`product.band_rank`](../functions/product/band_rank.md), [`product.fail`](../functions/product/fail.md), [`product.policy`](../functions/product/policy.md), [`product.require_role`](../functions/product/require_role.md)
