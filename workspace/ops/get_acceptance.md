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
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
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
