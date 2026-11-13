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
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
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
