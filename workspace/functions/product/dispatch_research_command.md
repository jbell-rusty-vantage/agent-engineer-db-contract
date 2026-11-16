---
id: "fn:product.dispatch_research_command(uuid,text,uuid,jsonb,uuid,client_grant,bool,text)"
kind: function
schema: product
name: dispatch_research_command
domain: product-operations
lens: ours
overloads: ["fn:product.dispatch_research_command(uuid,text,uuid,jsonb,uuid,client_grant,bool,text)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [authoring.asset_scope, authoring.event, authoring.file_set, authoring.work_revision, dataset.field, inquiry.assertion], writes: [authoring.work, dataset.cell, dataset.proposal, dataset.row, inquiry.acceptance, inquiry.delivery, inquiry.obligation, inquiry.support, inquiry.watch] }
tokens: [product, dispatch_research_command, product.dispatch_research_command]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# product.dispatch_research_command

Domain `product-operations`, lens `ours`.

## dispatch_research_command(uuid, text, uuid, jsonb, uuid, access.client_grant, boolean, text) → jsonb

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `op` | `text` | — | — |
| `head` | `uuid` | — | — |
| `pl` | `jsonb` | — | — |
| `p` | `uuid` | — | — |
| `g` | `access.client_grant` | — | — |
| `human` | `boolean` | — | — |
| `surface` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.asset_scope`](../../relations/authoring/asset_scope.md), [`authoring.event`](../../relations/authoring/event.md), [`authoring.file_set`](../../relations/authoring/file_set.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`dataset.field`](../../relations/dataset/field.md), [`inquiry.assertion`](../../relations/inquiry/assertion.md); writes [`authoring.work`](../../relations/authoring/work.md), [`dataset.cell`](../../relations/dataset/cell.md), [`dataset.proposal`](../../relations/dataset/proposal.md), [`dataset.row`](../../relations/dataset/row.md), [`inquiry.acceptance`](../../relations/inquiry/acceptance.md), [`inquiry.delivery`](../../relations/inquiry/delivery.md), [`inquiry.obligation`](../../relations/inquiry/obligation.md), [`inquiry.support`](../../relations/inquiry/support.md), [`inquiry.watch`](../../relations/inquiry/watch.md); calls [`product.check_cell_value`](check_cell_value.md), [`product.dataset_close_cell`](dataset_close_cell.md), [`product.dataset_commit`](dataset_commit.md), [`product.dataset_draft_no`](dataset_draft_no.md), [`product.dataset_edit`](dataset_edit.md), [`product.dataset_work`](dataset_work.md), [`product.fail`](fail.md), [`product.new_event`](new_event.md), [`product.proposal_problems`](proposal_problems.md), [`product.require_role`](require_role.md), [`product.tenant`](tenant.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["product"]["Functions"]["dispatch_research_command"]`.

Defined in: `20261105010300_product_api.sql`.
