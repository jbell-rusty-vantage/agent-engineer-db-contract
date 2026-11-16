---
id: "op:add_support"
kind: operation
name: add_support
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [authoring.work, authoring.work_revision, dataset.cell, inquiry.assertion, inquiry.support]
tokens: [add_support, research, api.product_command]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# add_support

Product operation: the `when 'add_support' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'add_support', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.support`](../relations/inquiry/support.md) | write |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`dataset.cell`](../relations/dataset/cell.md) | read |
| [`inquiry.assertion`](../relations/inquiry/assertion.md) | read |

## Helpers called

[`product.dataset_work`](../functions/product/dataset_work.md), [`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
