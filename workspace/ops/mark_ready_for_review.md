---
id: "op:mark_ready_for_review"
kind: operation
name: mark_ready_for_review
dispatcher: authoring
function: product.dispatch_authoring_command
call: api.product_command
lens: ours
relations: [authoring.event, authoring.work_revision, conversation.message, conversation.thread]
tokens: [mark_ready_for_review, authoring, api.product_command]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# mark_ready_for_review

Product operation: the `when 'mark_ready_for_review' then` arm of [`product.dispatch_authoring_command`](../functions/product/dispatch_authoring_command.md) (dispatcher `authoring`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'mark_ready_for_review', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.event`](../relations/authoring/event.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`conversation.message`](../relations/conversation/message.md) | read |
| [`conversation.thread`](../relations/conversation/thread.md) | read |

## Helpers called

[`product.exposure`](../functions/product/exposure.md), [`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.nonblank`](../functions/product/nonblank.md), [`product.require_role`](../functions/product/require_role.md)
