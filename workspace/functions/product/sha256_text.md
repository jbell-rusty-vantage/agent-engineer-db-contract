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
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
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
