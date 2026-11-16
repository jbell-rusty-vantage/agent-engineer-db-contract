---
id: "op:index_passages"
kind: operation
name: index_passages
dispatcher: worker
function: product.dispatch_worker
call: api.product_worker
lens: ours
relations: [authoring.release_item, library.passage, library.preparation]
tokens: [index_passages, worker, api.product_worker]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# index_passages

Product operation: the `when 'index_passages' then` arm of [`product.dispatch_worker`](../functions/product/dispatch_worker.md) (dispatcher `worker`), reached through [`api.product_worker`](../functions/api/product_worker.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_worker('index_passages', p_payload)
```
Execute: `service_role`. Worker credential (service_role JWT) required.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`library.passage`](../relations/library/passage.md) | write |
| [`library.preparation`](../relations/library/preparation.md) | write |
| [`authoring.release_item`](../relations/authoring/release_item.md) | read |

## Helpers called

[`product.sha256_text`](../functions/product/sha256_text.md), [`retrieval.index_text_item`](../functions/retrieval/index_text_item.md), [`retrieval.retire_items_for_passages`](../functions/retrieval/retire_items_for_passages.md)
