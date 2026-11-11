---
id: "op:record_embeddings"
kind: operation
name: record_embeddings
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [authoring.work_revision, library.passage, library.resource_control, retrieval.projection_target, retrieval.vector_item]
tokens: [record_embeddings, worker, api.product_worker]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# record_embeddings

Product operation: the `when 'record_embeddings' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('record_embeddings', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`library.passage`](../relations/library/passage.md) | read |
| [`library.resource_control`](../relations/library/resource_control.md) | read |
| [`retrieval.projection_target`](../relations/retrieval/projection_target.md) | read |
| [`retrieval.vector_item`](../relations/retrieval/vector_item.md) | read |

## Helpers called

[`product.fail`](../functions/product/fail.md), [`product.processing_allowed`](../functions/product/processing_allowed.md), [`product.sha256_text`](../functions/product/sha256_text.md), [`retrieval.store_embedding`](../functions/retrieval/store_embedding.md)
