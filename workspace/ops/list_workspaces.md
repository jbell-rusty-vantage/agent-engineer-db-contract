---
id: "op:list_workspaces"
kind: operation
name: list_workspaces
dispatcher: authoring
function: product.dispatch_authoring_read
call: api.product_read
lens: ours
relations: [authoring.workspace, authoring.workspace_member]
tokens: [list_workspaces, authoring, api.product_read]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# list_workspaces

Product operation: the `when 'list_workspaces' then` arm of [`product.dispatch_authoring_read`](../functions/product/dispatch_authoring_read.md) (dispatcher `authoring`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'list_workspaces', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.workspace`](../relations/authoring/workspace.md) | read |
| [`authoring.workspace_member`](../relations/authoring/workspace_member.md) | read |

## Helpers called

[`product.tenant`](../functions/product/tenant.md)
