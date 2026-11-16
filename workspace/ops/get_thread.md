---
id: "op:get_thread"
kind: operation
name: get_thread
dispatcher: read
function: product.dispatch_read
call: api.product_read
lens: ours
relations: [conversation.message, conversation.thread]
tokens: [get_thread, read, api.product_read]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# get_thread

Product operation: the `when 'get_thread' then` arm of [`product.dispatch_read`](../functions/product/dispatch_read.md) (dispatcher `read`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_thread', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`conversation.message`](../relations/conversation/message.md) | read |
| [`conversation.thread`](../relations/conversation/thread.md) | read |

## Helpers called

[`product.role_in`](../functions/product/role_in.md)
