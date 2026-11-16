---
id: "fn:product.fail(text,text)"
kind: function
schema: product
name: fail
domain: product-operations
lens: ours
overloads: ["fn:product.fail(text,text)"]
security: invoker
volatility: volatile
executors: []
raises: ["%"]
touches: { reads: [], writes: [] }
tokens: [product, fail, product.fail]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# product.fail

Domain `product-operations`, lens `ours`.

## fail(text, text) → void

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `code` | `text` | — | — |
| `detail` | `text` | `NULL::text` | — |

Execute: no configured role.

Raises (mechanically extracted): `%`.

TypeScript: `Database["product"]["Functions"]["fail"]`.

Defined in: `20261105010300_product_api.sql`.
