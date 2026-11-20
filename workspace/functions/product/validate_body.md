---
id: "fn:product.validate_body(text,jsonb)"
kind: function
schema: product
name: validate_body
domain: authoring
lens: ours
overloads: ["fn:product.validate_body(text,jsonb)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, validate_body, product.validate_body]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# product.validate_body

Domain `authoring`, lens `ours`.

## validate_body(text, jsonb) → void

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `kind` | `text` | — | — |
| `body` | `jsonb` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`product.fail`](fail.md).

TypeScript: `Database["product"]["Functions"]["validate_body"]`.

Defined in: `20261105010300_product_api.sql`.
