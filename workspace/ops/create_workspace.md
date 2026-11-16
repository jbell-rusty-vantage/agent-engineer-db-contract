---
id: "op:create_workspace"
kind: operation
name: create_workspace
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.workspace, authoring.workspace_member]
tokens: [create_workspace, command, api.product_command]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# create_workspace

Product operation: the `when 'create_workspace' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'create_workspace', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.workspace`](../relations/authoring/workspace.md) | write |
| [`authoring.workspace_member`](../relations/authoring/workspace_member.md) | write |
