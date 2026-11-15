---
id: "op:get_result"
kind: operation
name: get_result
dispatcher: read
function: product.dispatch_read
call: api.product_read
lens: ours
relations: [learning.assessment_result, learning.criterion_result, learning.evidence_grant, learning.grading_run, learning.submission]
tokens: [get_result, read, api.product_read]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# get_result

Product operation: the `when 'get_result' then` arm of [`product.dispatch_read`](../functions/product/dispatch_read.md) (dispatcher `read`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_result', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`learning.assessment_result`](../relations/learning/assessment_result.md) | read |
| [`learning.criterion_result`](../relations/learning/criterion_result.md) | read |
| [`learning.evidence_grant`](../relations/learning/evidence_grant.md) | read |
| [`learning.grading_run`](../relations/learning/grading_run.md) | read |
| [`learning.submission`](../relations/learning/submission.md) | read |
