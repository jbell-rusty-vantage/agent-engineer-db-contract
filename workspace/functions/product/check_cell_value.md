---
id: "fn:product.check_cell_value(text,jsonb)"
kind: function
schema: product
name: check_cell_value
domain: inquiry
lens: ours
overloads: ["fn:product.check_cell_value(text,jsonb)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, check_cell_value, product.check_cell_value]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# product.check_cell_value

Domain `inquiry`, lens `ours`.

## check_cell_value(text, jsonb) → void

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ft` | `text` | — | — |
| `x` | `jsonb` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`product.fail`](fail.md).

TypeScript: `Database["product"]["Functions"]["check_cell_value"]`.

Defined in: `20261105010300_product_api.sql`.
