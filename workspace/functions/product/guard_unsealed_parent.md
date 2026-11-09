---
id: "fn:product.guard_unsealed_parent()"
kind: function
schema: product
name: guard_unsealed_parent
domain: product-operations
lens: machinery
overloads: ["fn:product.guard_unsealed_parent()"]
security: invoker
volatility: volatile
executors: []
raises: ["cannot add to sealed revision %"]
touches: { reads: [authoring.work_revision, curriculum.outcome, curriculum.requirement], writes: [] }
tokens: [product, guard_unsealed_parent, product.guard_unsealed_parent]
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# product.guard_unsealed_parent

Domain `product-operations`, lens `machinery`.

## guard_unsealed_parent() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `cannot add to sealed revision %`.

Touches (best effort): reads [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`curriculum.outcome`](../../relations/curriculum/outcome.md), [`curriculum.requirement`](../../relations/curriculum/requirement.md); writes —; calls —.

Defined in: `20261105010100_product_foundation.sql`.
