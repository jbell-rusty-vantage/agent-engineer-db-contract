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
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
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
