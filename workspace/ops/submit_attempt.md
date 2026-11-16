---
id: "op:submit_attempt"
kind: operation
name: submit_attempt
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.work_revision, learning.attempt, learning.evidence_item, learning.submission, orchestration.artifact]
tokens: [submit_attempt, command, api.product_command]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# submit_attempt

Product operation: the `when 'submit_attempt' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'submit_attempt', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.attempt`](../relations/learning/attempt.md) | write |
| [`learning.evidence_item`](../relations/learning/evidence_item.md) | write |
| [`learning.submission`](../relations/learning/submission.md) | write |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.register_artifact`](../functions/product/register_artifact.md), [`product.sha256_text`](../functions/product/sha256_text.md)
