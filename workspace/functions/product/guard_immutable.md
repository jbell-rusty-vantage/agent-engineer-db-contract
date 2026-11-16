---
id: "fn:product.guard_immutable()"
kind: function
schema: product
name: guard_immutable
domain: product-operations
lens: machinery
overloads: ["fn:product.guard_immutable()"]
security: invoker
volatility: volatile
executors: []
raises: ["%.% is append-only", "%.% row is immutable", "column % of %.% may be set only once"]
touches: { reads: [], writes: [] }
tokens: [product, guard_immutable, product.guard_immutable]
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# product.guard_immutable

Domain `product-operations`, lens `machinery`.

## guard_immutable() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `%.% is append-only`; `%.% row is immutable`; `column % of %.% may be set only once`.

Defined in: `20261105010100_product_foundation.sql`.
