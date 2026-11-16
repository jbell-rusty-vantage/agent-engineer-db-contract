---
id: "fn:product.dataset_draft_no(uuid)"
kind: function
schema: product
name: dataset_draft_no
domain: product-operations
lens: ours
overloads: ["fn:product.dataset_draft_no(uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.work, authoring.work_revision], writes: [] }
tokens: [product, dataset_draft_no, product.dataset_draft_no]
defined_in: ["20261105010300_product_api.sql", "20261108120000_build08_r2_knowledge_continuum.sql", part3b_product.sql]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# product.dataset_draft_no

Domain `product-operations`, lens `ours`.

## dataset_draft_no(uuid) → integer

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `dw` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.work`](../../relations/authoring/work.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md); writes —; calls —.

TypeScript: `Database["product"]["Functions"]["dataset_draft_no"]`.

Defined in: `20261105010300_product_api.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `part3b_product.sql`.
