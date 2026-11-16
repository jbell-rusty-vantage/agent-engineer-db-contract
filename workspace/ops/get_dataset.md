---
id: "op:get_dataset"
kind: operation
name: get_dataset
dispatcher: research
function: product.dispatch_research_read
call: api.product_read
lens: ours
relations: [authoring.work, authoring.work_revision, inquiry.support]
tokens: [get_dataset, research, api.product_read]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# get_dataset

Product operation: the `when 'get_dataset' then` arm of [`product.dispatch_research_read`](../functions/product/dispatch_research_read.md) (dispatcher `research`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_dataset', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`inquiry.support`](../relations/inquiry/support.md) | read |

## Helpers called

[`product.dataset_content_sha256`](../functions/product/dataset_content_sha256.md), [`product.dataset_draft_no`](../functions/product/dataset_draft_no.md), [`product.dataset_snapshot`](../functions/product/dataset_snapshot.md), [`product.fail`](../functions/product/fail.md), [`product.readable_revision`](../functions/product/readable_revision.md), [`product.require_role`](../functions/product/require_role.md), [`product.support_counts`](../functions/product/support_counts.md)
