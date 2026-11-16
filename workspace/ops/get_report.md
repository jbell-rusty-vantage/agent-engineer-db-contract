---
id: "op:get_report"
kind: operation
name: get_report
dispatcher: research
function: product.dispatch_research_read
call: api.product_read
lens: ours
relations: [authoring.revision_binding, authoring.revision_block, authoring.work, authoring.work_revision, inquiry.assertion]
tokens: [get_report, research, api.product_read]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# get_report

Product operation: the `when 'get_report' then` arm of [`product.dispatch_research_read`](../functions/product/dispatch_research_read.md) (dispatcher `research`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_report', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.revision_binding`](../relations/authoring/revision_binding.md) | read |
| [`authoring.revision_block`](../relations/authoring/revision_block.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`inquiry.assertion`](../relations/inquiry/assertion.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.readable_revision`](../functions/product/readable_revision.md), [`product.support_counts`](../functions/product/support_counts.md)
