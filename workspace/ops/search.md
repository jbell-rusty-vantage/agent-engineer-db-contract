---
id: "op:search"
kind: operation
name: search
dispatcher: read
function: product.dispatch_read
call: api.product_read
lens: ours
relations: [authoring.asset_scope, authoring.distribution_offer, authoring.release_item, authoring.work, authoring.work_revision, authoring.workspace_member, conversation.message, conversation.thread, library.passage, library.resource_control]
tokens: [search, read, api.product_read]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# search

Product operation: the `when 'search' then` arm of [`product.dispatch_read`](../functions/product/dispatch_read.md) (dispatcher `read`), reached through [`api.product_read`](../functions/api/product_read.md). Derived from the function body; relation list is best effort.

## How to call

```sql
select api.product_read(p_workspace_id, 'search', p_payload)
```
Execute: `authenticated`. The payload is a JSON object; errors come back as `product.fail(code, detail)` exceptions.

## Relations the arm touches

| Relation | Access |
| --- | --- |
| [`authoring.asset_scope`](../relations/authoring/asset_scope.md) | read |
| [`authoring.distribution_offer`](../relations/authoring/distribution_offer.md) | read |
| [`authoring.release_item`](../relations/authoring/release_item.md) | read |
| [`authoring.work`](../relations/authoring/work.md) | read |
| [`authoring.work_revision`](../relations/authoring/work_revision.md) | read |
| [`authoring.workspace_member`](../relations/authoring/workspace_member.md) | read |
| [`conversation.message`](../relations/conversation/message.md) | read |
| [`conversation.thread`](../relations/conversation/thread.md) | read |
| [`library.passage`](../relations/library/passage.md) | read |
| [`library.resource_control`](../relations/library/resource_control.md) | read |

## Helpers called

[`api.search_unified`](../functions/api/search_unified.md), [`product.can_read_offer`](../functions/product/can_read_offer.md), [`product.readable_revision`](../functions/product/readable_revision.md), [`product.restricted`](../functions/product/restricted.md), [`product.role_in`](../functions/product/role_in.md), [`product.tenant`](../functions/product/tenant.md)
