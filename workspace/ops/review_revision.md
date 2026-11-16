---
id: "op:review_revision"
kind: operation
name: review_revision
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.publisher_grant]
tokens: [review_revision, command, api.product_command]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# review_revision

Product operation: the `when 'review_revision' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'review_revision', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.publisher_grant`](../relations/authoring/publisher_grant.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.require_role`](../functions/product/require_role.md), [`util.uuidv7`](../functions/util/uuidv7.md)
