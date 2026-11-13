---
id: "op:freeze_release"
kind: operation
name: freeze_release
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.event, authoring.release, authoring.release_item, authoring.work, authoring.work_revision, orchestration.artifact]
tokens: [freeze_release, command, api.product_command]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# freeze_release

Product operation: the `when 'freeze_release' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'freeze_release', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.release`](../relations/authoring/release.md) | write |
| [`authoring.release_item`](../relations/authoring/release_item.md) | write |
| [`authoring.event`](../relations/authoring/event.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | read |

## Helpers called

[`product.exposure`](../functions/product/exposure.md), [`product.fail`](../functions/product/fail.md), [`product.register_artifact`](../functions/product/register_artifact.md), [`product.require_role`](../functions/product/require_role.md), [`product.role_in`](../functions/product/role_in.md), [`product.sha256_text`](../functions/product/sha256_text.md)
