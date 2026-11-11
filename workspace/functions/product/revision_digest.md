---
id: "fn:product.revision_digest(uuid)"
kind: function
schema: product
name: revision_digest
domain: product-operations
lens: ours
overloads: ["fn:product.revision_digest(uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [authoring.revision_binding, authoring.runtime_requirement, authoring.work_revision, curriculum.outcome, curriculum.outcome_alignment, curriculum.part, curriculum.prerequisite, curriculum.requirement, curriculum.requirement_option, inquiry.assertion], writes: [] }
tokens: [product, revision_digest, product.revision_digest]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# product.revision_digest

Domain `product-operations`, lens `ours`.

## revision_digest(uuid) → text

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `rid` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.runtime_requirement`](../../relations/authoring/runtime_requirement.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`curriculum.outcome`](../../relations/curriculum/outcome.md), [`curriculum.outcome_alignment`](../../relations/curriculum/outcome_alignment.md), [`curriculum.part`](../../relations/curriculum/part.md), [`curriculum.prerequisite`](../../relations/curriculum/prerequisite.md), [`curriculum.requirement`](../../relations/curriculum/requirement.md), [`curriculum.requirement_option`](../../relations/curriculum/requirement_option.md), [`inquiry.assertion`](../../relations/inquiry/assertion.md); writes —; calls [`product.sha256_text`](sha256_text.md).

TypeScript: `Database["product"]["Functions"]["revision_digest"]`.

Defined in: `20261105010300_product_api.sql`.
