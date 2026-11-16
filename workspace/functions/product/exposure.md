---
id: "fn:product.exposure(uuid,text)"
kind: function
schema: product
name: exposure
domain: authoring
lens: ours
overloads: ["fn:product.exposure(uuid,text)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.asset_scope, authoring.file_set_entry, authoring.revision_binding, authoring.work_revision, curriculum.part, curriculum.prerequisite, curriculum.requirement, curriculum.requirement_option, dataset.cell, inquiry.assertion, inquiry.support], writes: [] }
tokens: [product, exposure, product.exposure]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# product.exposure

Domain `authoring`, lens `ours`.

## exposure(uuid, text) → jsonb

function, stable, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `root_rev` | `uuid` | — | — |
| `ceiling` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.asset_scope`](../../relations/authoring/asset_scope.md), [`authoring.file_set_entry`](../../relations/authoring/file_set_entry.md), [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`curriculum.part`](../../relations/curriculum/part.md), [`curriculum.prerequisite`](../../relations/curriculum/prerequisite.md), [`curriculum.requirement`](../../relations/curriculum/requirement.md), [`curriculum.requirement_option`](../../relations/curriculum/requirement_option.md), [`dataset.cell`](../../relations/dataset/cell.md), [`inquiry.assertion`](../../relations/inquiry/assertion.md), [`inquiry.support`](../../relations/inquiry/support.md); writes —; calls [`product.restricted`](restricted.md), [`product.sha256_text`](sha256_text.md).

TypeScript: `Database["product"]["Functions"]["exposure"]`.

Defined in: `20261105010300_product_api.sql`.
