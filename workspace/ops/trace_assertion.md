---
id: "op:trace_assertion"
kind: operation
name: trace_assertion
dispatcher: research
function: product.dispatch_research_read
call: api.product_read
lens: ours
relations: [inquiry.assertion, inquiry.support]
tokens: [trace_assertion, research, api.product_read]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# trace_assertion

Product operation: the `when 'trace_assertion' then` arm of [`product.dispatch_research_read`](../functions/product/dispatch_research_read.md) (dispatcher `research`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'trace_assertion', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.assertion`](../relations/inquiry/assertion.md) | read |
| [`inquiry.support`](../relations/inquiry/support.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.readable_revision`](../functions/product/readable_revision.md), [`product.support_detail`](../functions/product/support_detail.md)
