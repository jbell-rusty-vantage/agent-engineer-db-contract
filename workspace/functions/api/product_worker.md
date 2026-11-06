---
id: "fn:api.product_worker(text,jsonb)"
kind: function
schema: api
name: product_worker
domain: api-surface
overloads: ["fn:api.product_worker(text,jsonb)"]
security: definer
volatility: volatile
executors: [service_role]
raises: []
touches: { reads: [], writes: [] }
tokens: [api, product_worker, api.product_worker]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.product_worker

Domain `api-surface`.

## product_worker(text, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_operation` | `text` | — | — |
| `p_payload` | `jsonb` | — | — |

Execute: `service_role`.

TypeScript: `Database["api"]["Functions"]["product_worker"]`.

Defined in: `20261105010300_product_api.sql`.
