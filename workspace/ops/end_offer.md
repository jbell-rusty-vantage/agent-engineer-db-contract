---
id: "op:end_offer"
kind: operation
name: end_offer
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.distribution_offer]
tokens: [end_offer, command, api.product_command]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# end_offer

Product operation: the `when 'end_offer' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'end_offer', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | write |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.require_role`](../functions/product/require_role.md)
