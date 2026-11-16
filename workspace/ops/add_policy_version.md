---
id: "op:add_policy_version"
kind: operation
name: add_policy_version
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [access.policy_version]
tokens: [add_policy_version, worker, api.product_worker]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# add_policy_version

Product operation: the `when 'add_policy_version' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('add_policy_version', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`access.policy_version`](../relations/access/policy_version.md) | write |

## Helpers called

[`product.sha256_text`](../functions/product/sha256_text.md)
