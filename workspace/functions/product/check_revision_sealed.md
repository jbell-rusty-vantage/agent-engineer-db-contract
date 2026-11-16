---
id: "fn:product.check_revision_sealed()"
kind: function
schema: product
name: check_revision_sealed
domain: product-operations
lens: machinery
overloads: ["fn:product.check_revision_sealed()"]
security: definer
volatility: volatile
executors: []
raises: ["revision % committed without a seal"]
touches: { reads: [authoring.work_revision], writes: [] }
tokens: [product, check_revision_sealed, product.check_revision_sealed]
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# product.check_revision_sealed

Domain `product-operations`, lens `machinery`.

## check_revision_sealed() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `revision % committed without a seal`.

Touches (best effort): reads [`authoring.work_revision`](../../relations/authoring/work_revision.md); writes —; calls —.

Defined in: `20261105010100_product_foundation.sql`.
