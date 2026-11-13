---
id: "op:preview_exposure"
kind: operation
name: preview_exposure
dispatcher: read
function: product.dispatch_read
call: api.product_read
lens: ours
relations: [authoring.work_revision]
tokens: [preview_exposure, read, api.product_read]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# preview_exposure

Product operation: the `when 'preview_exposure' then` arm of [`product.dispatch_read`](../functions/product/dispatch_read.md) (dispatcher `read`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'preview_exposure', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |

## Helpers called

[`product.exposure`](../functions/product/exposure.md), [`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
