---
id: "fn:api.product_read(uuid,text,jsonb)"
kind: function
schema: api
name: product_read
domain: api-surface
lens: ours
overloads: ["fn:api.product_read(uuid,text,jsonb)"]
security: definer
volatility: volatile
executors: [authenticated]
raises: []
touches: { reads: [access.client_grant], writes: [] }
tokens: [api, product_read, api.product_read]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# api.product_read

Domain `api-surface`, lens `ours`.

## product_read(uuid, text, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_workspace_id` | `uuid` | — | — |
| `p_operation` | `text` | — | — |
| `p_payload` | `jsonb` | — | — |

Execute: `authenticated`.

Touches (best effort): reads [`access.client_grant`](../../relations/access/client_grant.md); writes —; calls [`product.actor`](../product/actor.md), [`product.client_grant`](../product/client_grant.md), [`product.dispatch_read`](../product/dispatch_read.md).

TypeScript: `Database["api"]["Functions"]["product_read"]`.

Defined in: `20261105010300_product_api.sql`.
