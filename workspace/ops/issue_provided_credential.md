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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
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
