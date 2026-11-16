---
id: "op:list_watches"
kind: operation
name: list_watches
dispatcher: research
function: product.dispatch_research_read
call: api.product_read
lens: ours
relations: [inquiry.acceptance, inquiry.watch]
tokens: [list_watches, research, api.product_read]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# list_watches

Product operation: the `when 'list_watches' then` arm of [`product.dispatch_research_read`](../functions/product/dispatch_research_read.md) (dispatcher `research`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'list_watches', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.acceptance`](../relations/inquiry/acceptance.md) | read |
| [`inquiry.watch`](../relations/inquiry/watch.md) | read |

## Helpers called

[`product.require_role`](../functions/product/require_role.md)
