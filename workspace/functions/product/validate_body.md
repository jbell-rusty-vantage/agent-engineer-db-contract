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
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
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
