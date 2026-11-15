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
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
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
