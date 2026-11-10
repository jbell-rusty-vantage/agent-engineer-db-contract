---
id: "op:get_support"
kind: operation
name: get_support
dispatcher: research
function: product.dispatch_research_read
call: api.product_read
lens: ours
relations: [dataset.cell, inquiry.assertion, inquiry.support]
tokens: [get_support, research, api.product_read]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# get_support

Product operation: the `when 'get_support' then` arm of [`product.dispatch_research_read`](../functions/product/dispatch_research_read.md) (dispatcher `research`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_support', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`dataset.cell`](../relations/dataset/cell.md) | read |
| [`inquiry.assertion`](../relations/inquiry/assertion.md) | read |
| [`inquiry.support`](../relations/inquiry/support.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.readable_revision`](../functions/product/readable_revision.md), [`product.require_role`](../functions/product/require_role.md), [`product.support_detail`](../functions/product/support_detail.md)
