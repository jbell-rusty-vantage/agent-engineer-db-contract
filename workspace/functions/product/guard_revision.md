---
id: "fn:product.guard_revision()"
kind: function
schema: product
name: guard_revision
domain: product-operations
lens: machinery
overloads: ["fn:product.guard_revision()"]
security: invoker
volatility: volatile
executors: []
raises: [authoring.work_revision is append-only, purge may change only body and purge columns, saved revisions are immutable]
touches: { reads: [authoring.work_revision], writes: [] }
tokens: [product, guard_revision, product.guard_revision]
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# product.guard_revision

Domain `product-operations`, lens `machinery`.

## guard_revision() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `authoring.work_revision is append-only`; `purge may change only body and purge columns`; `saved revisions are immutable`.

Touches (best effort): reads [`authoring.work_revision`](../../relations/authoring/work_revision.md); writes —; calls —.

Defined in: `20261105010100_product_foundation.sql`.
