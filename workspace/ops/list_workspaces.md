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
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
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
