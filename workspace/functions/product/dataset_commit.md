---
id: "fn:product.dataset_commit(uuid,work,uuid,text,text,text)"
kind: function
schema: product
name: dataset_commit
domain: inquiry
lens: ours
overloads: ["fn:product.dataset_commit(uuid,work,uuid,text,text,text)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [authoring.work_revision, dataset.cell, dataset.field, dataset.row], writes: [authoring.work] }
tokens: [product, dataset_commit, product.dataset_commit]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# product.dataset_commit

Domain `inquiry`, lens `ours`.

## dataset_commit(uuid, authoring.work, uuid, text, text, text) → uuid

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `w` | `authoring.work` | — | — |
| `p` | `uuid` | — | — |
| `title` | `text` | — | — |
| `note` | `text` | — | — |
| `origin` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`dataset.cell`](../../relations/dataset/cell.md), [`dataset.field`](../../relations/dataset/field.md), [`dataset.row`](../../relations/dataset/row.md); writes [`authoring.work`](../../relations/authoring/work.md); calls [`product.dataset_content_sha256`](dataset_content_sha256.md), [`product.dataset_draft_no`](dataset_draft_no.md), [`product.dataset_snapshot`](dataset_snapshot.md), [`product.fail`](fail.md), [`product.insert_revision`](insert_revision.md).

TypeScript: `Database["product"]["Functions"]["dataset_commit"]`.

Defined in: `20261105010300_product_api.sql`.
