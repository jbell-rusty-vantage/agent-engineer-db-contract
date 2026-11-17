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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
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
