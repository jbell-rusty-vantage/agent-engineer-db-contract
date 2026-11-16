---
id: "op:complete_asset"
kind: operation
name: complete_asset
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [orchestration.artifact]
tokens: [complete_asset, worker, api.product_worker]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# complete_asset

Product operation: the `when 'complete_asset' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('complete_asset', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | write |

## Helpers called

[`product.fail`](../functions/product/fail.md)
