---
id: "op:get_lesson_view"
kind: operation
name: get_lesson_view
dispatcher: read
function: product.dispatch_read
call: api.product_read
lens: ours
relations: [authoring.release_item, authoring.revision_binding, authoring.revision_block, authoring.work, authoring.work_revision, authoring.workspace]
tokens: [get_lesson_view, read, api.product_read]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# get_lesson_view

Product operation: the `when 'get_lesson_view' then` arm of [`product.dispatch_read`](../functions/product/dispatch_read.md) (dispatcher `read`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_lesson_view', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.release_item`](../relations/authoring/release_item.md) | read |
| [`authoring.revision_binding`](../relations/authoring/revision_binding.md) | read |
| [`authoring.revision_block`](../relations/authoring/revision_block.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`authoring.workspace`](../relations/authoring/workspace.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.readable_revision`](../functions/product/readable_revision.md)
