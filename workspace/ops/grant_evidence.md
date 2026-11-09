---
id: "op:grant_evidence"
kind: operation
name: grant_evidence
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [access.guardian_link, learning.evidence_grant]
tokens: [grant_evidence, command, api.product_command]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# grant_evidence

Product operation: the `when 'grant_evidence' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'grant_evidence', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.evidence_grant`](../relations/learning/evidence_grant.md) | write |
| [`access.guardian_link`](../relations/access/guardian_link.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
