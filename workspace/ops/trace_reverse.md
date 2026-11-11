---
id: "op:trace_reverse"
kind: operation
name: trace_reverse
dispatcher: research
function: product.dispatch_research_read
call: api.product_read
lens: ours
relations: [authoring.revision_binding, authoring.work, authoring.work_revision, dataset.cell, dataset.row, inquiry.assertion, inquiry.delivery, inquiry.obligation, inquiry.support]
tokens: [trace_reverse, research, api.product_read]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# trace_reverse

Product operation: the `when 'trace_reverse' then` arm of [`product.dispatch_research_read`](../functions/product/dispatch_research_read.md) (dispatcher `research`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'trace_reverse', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.revision_binding`](../relations/authoring/revision_binding.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`dataset.cell`](../relations/dataset/cell.md) | read |
| [`dataset.row`](../relations/dataset/row.md) | read |
| [`inquiry.assertion`](../relations/inquiry/assertion.md) | read |
| [`inquiry.delivery`](../relations/inquiry/delivery.md) | read |
| [`inquiry.obligation`](../relations/inquiry/obligation.md) | read |
| [`inquiry.support`](../relations/inquiry/support.md) | read |

## Helpers called

[`product.require_role`](../functions/product/require_role.md)
