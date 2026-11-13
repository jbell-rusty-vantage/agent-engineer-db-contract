---
id: "op:append_message"
kind: operation
name: append_message
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.distribution_offer, authoring.release_item, authoring.work_revision, conversation.context_item, conversation.context_snapshot, conversation.message, conversation.thread]
tokens: [append_message, command, api.product_command]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# append_message

Product operation: the `when 'append_message' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'append_message', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`conversation.context_item`](../relations/conversation/context_item.md) | write |
| [`conversation.context_snapshot`](../relations/conversation/context_snapshot.md) | write |
| [`conversation.message`](../relations/conversation/message.md) | write |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | read |
| [`authoring.release_item`](../relations/authoring/release_item.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`conversation.thread`](../relations/conversation/thread.md) | read |

## Helpers called

[`product.can_read_offer`](../functions/product/can_read_offer.md), [`product.fail`](../functions/product/fail.md), [`product.readable_revision`](../functions/product/readable_revision.md), [`product.role_in`](../functions/product/role_in.md), [`product.sha256_text`](../functions/product/sha256_text.md)
