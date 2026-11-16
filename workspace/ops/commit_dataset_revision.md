---
id: "op:commit_dataset_revision"
kind: operation
name: commit_dataset_revision
dispatcher: research
function: product.dispatch_research_command
call: api.product_command
lens: ours
relations: [dataset.proposal]
tokens: [commit_dataset_revision, research, api.product_command]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# commit_dataset_revision

Product operation: the `when 'commit_dataset_revision' then` arm of [`product.dispatch_research_command`](../functions/product/dispatch_research_command.md) (dispatcher `research`), reached through [`api.product_command`](../functions/api/product_command.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_command(p_workspace_id, 'commit_dataset_revision', p_idempotency_key, p_expected_head, p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`dataset.proposal`](../relations/dataset/proposal.md) | write |

## Helpers called

[`product.dataset_commit`](../functions/product/dataset_commit.md), [`product.dataset_draft_no`](../functions/product/dataset_draft_no.md), [`product.dataset_work`](../functions/product/dataset_work.md), [`product.fail`](../functions/product/fail.md), [`product.require_role`](../functions/product/require_role.md)
