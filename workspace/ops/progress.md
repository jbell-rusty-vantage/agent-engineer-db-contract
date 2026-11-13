---
id: "op:progress"
kind: operation
name: progress
dispatcher: read
function: product.dispatch_read
call: api.product_read
lens: ours
relations: [authoring.distribution_offer, authoring.release_item, curriculum.requirement, learning.credit, learning.enrollment, learning.evidence_grant, learning.release_adoption]
tokens: [progress, read, api.product_read]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# progress

Product operation: the `when 'progress' then` arm of [`product.dispatch_read`](../functions/product/dispatch_read.md) (dispatcher `read`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'progress', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | read |
| [`authoring.release_item`](../relations/authoring/release_item.md) | read |
| [`curriculum.requirement`](../relations/curriculum/requirement.md) | read |
| [`learning.credit`](../relations/learning/credit.md) | read |
| [`learning.enrollment`](../relations/learning/enrollment.md) | read |
| [`learning.evidence_grant`](../relations/learning/evidence_grant.md) | read |
| [`learning.release_adoption`](../relations/learning/release_adoption.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md)
