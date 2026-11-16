---
id: "op:get_acceptance"
kind: operation
name: get_acceptance
dispatcher: research
function: product.dispatch_research_read
call: api.product_read
lens: ours
relations: [inquiry.acceptance, inquiry.delivery, inquiry.obligation]
tokens: [get_acceptance, research, api.product_read]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# get_acceptance

Product operation: the `when 'get_acceptance' then` arm of [`product.dispatch_research_read`](../functions/product/dispatch_research_read.md) (dispatcher `research`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_acceptance', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.acceptance`](../relations/inquiry/acceptance.md) | read |
| [`inquiry.delivery`](../relations/inquiry/delivery.md) | read |
| [`inquiry.obligation`](../relations/inquiry/obligation.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
