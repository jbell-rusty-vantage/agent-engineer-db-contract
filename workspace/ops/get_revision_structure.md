---
id: "op:get_revision_structure"
kind: operation
name: get_revision_structure
dispatcher: authoring
function: product.dispatch_authoring_read
call: api.product_read
lens: ours
relations: [authoring.revision_binding, authoring.runtime_requirement, authoring.work, authoring.work_revision, curriculum.outcome, curriculum.outcome_alignment, curriculum.part, curriculum.prerequisite, curriculum.requirement, curriculum.requirement_option, inquiry.assertion]
tokens: [get_revision_structure, authoring, api.product_read]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# get_revision_structure

Product operation: the `when 'get_revision_structure' then` arm of [`product.dispatch_authoring_read`](../functions/product/dispatch_authoring_read.md) (dispatcher `authoring`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'get_revision_structure', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.revision_binding`](../relations/authoring/revision_binding.md) | read |
| [`authoring.runtime_requirement`](../relations/authoring/runtime_requirement.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`curriculum.outcome`](../relations/curriculum/outcome.md) | read |
| [`curriculum.outcome_alignment`](../relations/curriculum/outcome_alignment.md) | read |
| [`curriculum.part`](../relations/curriculum/part.md) | read |
| [`curriculum.prerequisite`](../relations/curriculum/prerequisite.md) | read |
| [`curriculum.requirement`](../relations/curriculum/requirement.md) | read |
| [`curriculum.requirement_option`](../relations/curriculum/requirement_option.md) | read |
| [`inquiry.assertion`](../relations/inquiry/assertion.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.role_in`](../functions/product/role_in.md), [`product.tenant`](../functions/product/tenant.md)
