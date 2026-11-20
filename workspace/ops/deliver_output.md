---
id: "op:deliver_output"
kind: operation
name: deliver_output
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [authoring.asset_scope, authoring.file_set, authoring.work, authoring.work_revision, inquiry.acceptance, inquiry.delivery, inquiry.obligation]
tokens: [deliver_output, research, api.product_command]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# deliver_output

Product operation: the `when 'deliver_output' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'deliver_output', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`inquiry.acceptance`](../relations/inquiry/acceptance.md) | write |
| [`inquiry.delivery`](../relations/inquiry/delivery.md) | write |
| [`authoring.asset_scope`](../relations/authoring/asset_scope.md) | read |
| [`authoring.file_set`](../relations/authoring/file_set.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`inquiry.obligation`](../relations/inquiry/obligation.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.require_role`](../functions/product/require_role.md), [`util.uuidv7`](../functions/util/uuidv7.md)
