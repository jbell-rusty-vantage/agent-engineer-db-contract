---
id: "fn:product.sha256_text(text)"
kind: function
schema: product
name: sha256_text
domain: product-operations
lens: ours
overloads: ["fn:product.sha256_text(text)"]
security: invoker
volatility: immutable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, sha256_text, product.sha256_text]
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# product.sha256_text

Domain `product-operations`, lens `ours`.

## sha256_text(text) → text

function, immutable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `t` | `text` | — | — |

Execute: no configured role.

TypeScript: `Database["product"]["Functions"]["sha256_text"]`.

Defined in: `20261105010100_product_foundation.sql`.
