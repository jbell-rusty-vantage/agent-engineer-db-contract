---
id: "op:confirm_removal"
kind: operation
name: confirm_removal
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.work_revision, learning.evidence_item, library.connected_item, library.passage, library.removal]
tokens: [confirm_removal, command, api.product_command]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# confirm_removal

Product operation: the `when 'confirm_removal' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'confirm_removal', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | write |
| [`library.connected_item`](../relations/library/connected_item.md) | write |
| [`library.passage`](../relations/library/passage.md) | write |
| [`library.removal`](../relations/library/removal.md) | write |
| [`learning.evidence_item`](../relations/learning/evidence_item.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.require_role`](../functions/product/require_role.md), [`retrieval.retire_items_for_passages`](../functions/retrieval/retire_items_for_passages.md)
