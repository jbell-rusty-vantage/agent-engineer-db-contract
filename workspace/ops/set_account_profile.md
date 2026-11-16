---
id: "op:set_account_profile"
kind: operation
name: set_account_profile
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [access.account_profile]
tokens: [set_account_profile, worker, api.product_worker]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# set_account_profile

Product operation: the `when 'set_account_profile' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('set_account_profile', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`access.account_profile`](../relations/access/account_profile.md) | write |

## Helpers called

[`product.policy`](../functions/product/policy.md)
