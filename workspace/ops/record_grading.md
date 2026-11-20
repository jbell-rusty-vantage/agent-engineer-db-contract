---
id: "op:record_grading"
kind: operation
name: record_grading
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [authoring.work_revision, learning.assessment_result, learning.criterion_result, learning.grading_run, learning.submission, orchestration.artifact]
tokens: [record_grading, worker, api.product_worker]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# record_grading

Product operation: the `when 'record_grading' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('record_grading', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.assessment_result`](../relations/learning/assessment_result.md) | write |
| [`learning.criterion_result`](../relations/learning/criterion_result.md) | write |
| [`learning.grading_run`](../relations/learning/grading_run.md) | write |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`learning.submission`](../relations/learning/submission.md) | read |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.finalize`](../functions/product/finalize.md)
