---
id: "op:consent_guardian"
kind: operation
name: consent_guardian
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [access.guardian_link]
tokens: [consent_guardian, command, api.product_command]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# consent_guardian

Product operation: the `when 'consent_guardian' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'consent_guardian', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`access.guardian_link`](../relations/access/guardian_link.md) | write |

## Helpers called

[`product.fail`](../functions/product/fail.md)
