---
id: "fn:product.guard_mutable()"
kind: function
schema: product
name: guard_mutable
domain: product-operations
lens: machinery
overloads: ["fn:product.guard_mutable()"]
security: invoker
volatility: volatile
executors: []
raises: ["%.% rows are removed only by a tracked removal", "immutable columns of %.% changed"]
touches: { reads: [], writes: [] }
tokens: [product, guard_mutable, product.guard_mutable]
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# product.guard_mutable

Domain `product-operations`, lens `machinery`.

## guard_mutable() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `%.% rows are removed only by a tracked removal`; `immutable columns of %.% changed`.

Defined in: `20261105010100_product_foundation.sql`.
