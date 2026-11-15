---
id: "op:set_deployment_status"
kind: operation
name: set_deployment_status
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [authoring.deployment]
tokens: [set_deployment_status, worker, api.product_worker]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# set_deployment_status

Product operation: the `when 'set_deployment_status' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('set_deployment_status', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.deployment`](../relations/authoring/deployment.md) | write |
