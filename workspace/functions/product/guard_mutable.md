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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# product.guard_mutable

Domain `product-operations`, lens `machinery`.

## guard_mutable() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `%.% rows are removed only by a tracked removal`; `immutable columns of %.% changed`.

Defined in: `20261105010100_product_foundation.sql`.
