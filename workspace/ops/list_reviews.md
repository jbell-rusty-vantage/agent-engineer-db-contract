---
id: "op:list_reviews"
kind: operation
name: list_reviews
dispatcher: authoring
function: product.dispatch_authoring_read
call: api.product_read
lens: ours
relations: [authoring.event, authoring.work, authoring.work_revision, conversation.message, conversation.thread]
tokens: [list_reviews, authoring, api.product_read]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# list_reviews

Product operation: the `when 'list_reviews' then` arm of [`product.dispatch_authoring_read`](../functions/product/dispatch_authoring_read.md) (dispatcher `authoring`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'list_reviews', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.event`](../relations/authoring/event.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`conversation.message`](../relations/conversation/message.md) | read |
| [`conversation.thread`](../relations/conversation/thread.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
