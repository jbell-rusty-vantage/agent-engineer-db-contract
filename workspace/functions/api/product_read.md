---
id: "fn:api.product_read(uuid,text,jsonb)"
kind: function
schema: api
name: product_read
domain: api-surface
overloads: ["fn:api.product_read(uuid,text,jsonb)"]
security: definer
volatility: volatile
executors: [authenticated]
raises: []
touches: { reads: [], writes: [] }
tokens: [api, product_read, api.product_read]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.product_read

Domain `api-surface`.

## product_read(uuid, text, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_workspace_id` | `uuid` | — | — |
| `p_operation` | `text` | — | — |
| `p_payload` | `jsonb` | — | — |

Execute: `authenticated`.

TypeScript: `Database["api"]["Functions"]["product_read"]`.

Defined in: `20261105010300_product_api.sql`.
