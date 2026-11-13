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
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
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
