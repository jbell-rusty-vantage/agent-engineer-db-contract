---
id: "op:start_attempt"
kind: operation
name: start_attempt
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.distribution_offer, authoring.release_item, curriculum.requirement, curriculum.requirement_option, learning.attempt, learning.enrollment, learning.environment_session, learning.equivalence_request, learning.release_adoption]
tokens: [start_attempt, command, api.product_command]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# start_attempt

Product operation: the `when 'start_attempt' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'start_attempt', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.attempt`](../relations/learning/attempt.md) | write |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | read |
| [`authoring.release_item`](../relations/authoring/release_item.md) | read |
| [`curriculum.requirement`](../relations/curriculum/requirement.md) | read |
| [`curriculum.requirement_option`](../relations/curriculum/requirement_option.md) | read |
| [`learning.enrollment`](../relations/learning/enrollment.md) | read |
| [`learning.environment_session`](../relations/learning/environment_session.md) | read |
| [`learning.equivalence_request`](../relations/learning/equivalence_request.md) | read |
| [`learning.release_adoption`](../relations/learning/release_adoption.md) | read |

## Helpers called

[`product.can_read_offer`](../functions/product/can_read_offer.md), [`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
