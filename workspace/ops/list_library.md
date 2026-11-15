---
id: "op:list_library"
kind: operation
name: list_library
dispatcher: read
function: product.dispatch_read
call: api.product_read
lens: ours
relations: [authoring.distribution, authoring.distribution_offer]
tokens: [list_library, read, api.product_read]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# list_library

Product operation: the `when 'list_library' then` arm of [`product.dispatch_read`](../functions/product/dispatch_read.md) (dispatcher `read`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'list_library', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.distribution`](../relations/authoring/distribution.md) | read |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | read |

## Helpers called

[`product.can_read_offer`](../functions/product/can_read_offer.md)
