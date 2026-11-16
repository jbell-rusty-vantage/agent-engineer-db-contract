---
id: "op:get_offer"
kind: operation
name: get_offer
dispatcher: read
function: product.dispatch_read
call: api.product_read
lens: ours
relations: [authoring.distribution_offer, authoring.release_item]
tokens: [get_offer, read, api.product_read]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# get_offer

Product operation: the `when 'get_offer' then` arm of [`product.dispatch_read`](../functions/product/dispatch_read.md) (dispatcher `read`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_offer', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | read |
| [`authoring.release_item`](../relations/authoring/release_item.md) | read |

## Helpers called

[`product.can_read_offer`](../functions/product/can_read_offer.md), [`product.fail`](../functions/product/fail.md)
