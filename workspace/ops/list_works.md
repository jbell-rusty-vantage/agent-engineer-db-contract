---
id: "op:list_works"
kind: operation
name: list_works
dispatcher: read
function: product.dispatch_read
call: api.product_read
lens: ours
relations: [authoring.work]
tokens: [list_works, read, api.product_read]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# list_works

Product operation: the `when 'list_works' then` arm of [`product.dispatch_read`](../functions/product/dispatch_read.md) (dispatcher `read`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'list_works', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.work`](../relations/authoring/work.md) | read |

## Helpers called

[`product.require_role`](../functions/product/require_role.md)
