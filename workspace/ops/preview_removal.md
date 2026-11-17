---
id: "op:preview_removal"
kind: operation
name: preview_removal
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.distribution_offer, authoring.release_item, authoring.revision_binding, authoring.work, authoring.work_revision, conversation.context_item, learning.evidence_item, library.passage, library.removal]
tokens: [preview_removal, command, api.product_command]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# preview_removal

Product operation: the `when 'preview_removal' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'preview_removal', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`library.removal`](../relations/library/removal.md) | write |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | read |
| [`authoring.release_item`](../relations/authoring/release_item.md) | read |
| [`authoring.revision_binding`](../relations/authoring/revision_binding.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`conversation.context_item`](../relations/conversation/context_item.md) | read |
| [`learning.evidence_item`](../relations/learning/evidence_item.md) | read |
| [`library.passage`](../relations/library/passage.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
