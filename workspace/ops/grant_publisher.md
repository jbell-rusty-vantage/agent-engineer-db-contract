---
id: "op:grant_publisher"
kind: operation
name: grant_publisher
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [authoring.publisher_grant]
tokens: [grant_publisher, worker, api.product_worker]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# grant_publisher

Product operation: the `when 'grant_publisher' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('grant_publisher', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.publisher_grant`](../relations/authoring/publisher_grant.md) | write |
