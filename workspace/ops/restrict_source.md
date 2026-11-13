---
id: "op:restrict_source"
kind: operation
name: restrict_source
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [access.source_restriction]
tokens: [restrict_source, worker, api.product_worker]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# restrict_source

Product operation: the `when 'restrict_source' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('restrict_source', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`access.source_restriction`](../relations/access/source_restriction.md) | write |
