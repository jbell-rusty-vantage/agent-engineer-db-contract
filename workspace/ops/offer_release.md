---
id: "op:offer_release"
kind: operation
name: offer_release
dispatcher: command
function: product.dispatch_command
call: api.product_command
lens: ours
relations: [authoring.distribution, authoring.distribution_offer, authoring.event, authoring.publisher_grant, authoring.release, orchestration.artifact]
tokens: [offer_release, command, api.product_command]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# offer_release

Product operation: the `when 'offer_release' then` arm of [`product.dispatch_command`](../functions/product/dispatch_command.md) (dispatcher `command`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'offer_release', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | write |
| [`authoring.distribution`](../relations/authoring/distribution.md) | read |
| [`authoring.event`](../relations/authoring/event.md) | read |
| [`authoring.publisher_grant`](../relations/authoring/publisher_grant.md) | read |
| [`authoring.release`](../relations/authoring/release.md) | read |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
