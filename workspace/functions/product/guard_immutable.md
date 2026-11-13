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
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# product.guard_immutable

Domain `product-operations`, lens `machinery`.

## guard_immutable() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `%.% is append-only`; `%.% row is immutable`; `column % of %.% may be set only once`.

Defined in: `20261105010100_product_foundation.sql`.
