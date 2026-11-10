---
id: "op:authorize_processing"
kind: operation
name: authorize_processing
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [access.guardian_link, access.processing_authorization]
tokens: [authorize_processing, command, api.product_command]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# authorize_processing

Product operation: the `when 'authorize_processing' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'authorize_processing', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`access.processing_authorization`](../relations/access/processing_authorization.md) | write |
| [`access.guardian_link`](../relations/access/guardian_link.md) | read |

## Helpers called

[`product.band`](../functions/product/band.md), [`product.band_rank`](../functions/product/band_rank.md), [`product.fail`](../functions/product/fail.md), [`product.policy`](../functions/product/policy.md)
