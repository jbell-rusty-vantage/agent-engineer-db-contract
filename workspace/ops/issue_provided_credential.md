---
id: "op:issue_provided_credential"
kind: operation
name: issue_provided_credential
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [access.provided_credential]
tokens: [issue_provided_credential, worker, api.product_worker]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# issue_provided_credential

Product operation: the `when 'issue_provided_credential' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('issue_provided_credential', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`access.provided_credential`](../relations/access/provided_credential.md) | write |
