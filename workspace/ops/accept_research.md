---
id: "op:accept_research"
kind: operation
name: accept_research
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [authoring.event, authoring.work_revision, inquiry.acceptance, inquiry.obligation]
tokens: [accept_research, research, api.product_command]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# accept_research

Product operation: the `when 'accept_research' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'accept_research', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.acceptance`](../relations/inquiry/acceptance.md) | write |
| [`inquiry.obligation`](../relations/inquiry/obligation.md) | write |
| [`authoring.event`](../relations/authoring/event.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.require_role`](../functions/product/require_role.md), [`util.uuidv7`](../functions/util/uuidv7.md)
