---
id: "op:record_equivalence_check"
kind: operation
name: record_equivalence_check
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [learning.equivalence_request]
tokens: [record_equivalence_check, worker, api.product_worker]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# record_equivalence_check

Product operation: the `when 'record_equivalence_check' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('record_equivalence_check', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.equivalence_request`](../relations/learning/equivalence_request.md) | write |
