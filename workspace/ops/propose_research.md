---
id: "op:propose_research"
kind: operation
name: propose_research
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [authoring.event, authoring.work, authoring.work_revision]
tokens: [propose_research, research, api.product_command]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# propose_research

Product operation: the `when 'propose_research' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'propose_research', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.event`](../relations/authoring/event.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.new_event`](../functions/product/new_event.md), [`product.proposal_problems`](../functions/product/proposal_problems.md), [`product.require_role`](../functions/product/require_role.md)
