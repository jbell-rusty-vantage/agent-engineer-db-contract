---
id: "fn:product.claims()"
kind: function
schema: product
name: claims
domain: product-operations
lens: ours
overloads: ["fn:product.claims()"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, claims, product.claims]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# product.claims

Domain `product-operations`, lens `ours`.

## claims() → jsonb

function, stable, security invoker, language sql, config `search_path=""`.

No arguments.

Execute: no configured role.

TypeScript: `Database["product"]["Functions"]["claims"]`.

Defined in: `20261105010300_product_api.sql`.
