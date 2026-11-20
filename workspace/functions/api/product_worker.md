---
id: "fn:api.product_worker(text,jsonb)"
kind: function
schema: api
name: product_worker
domain: api-surface
lens: ours
overloads: ["fn:api.product_worker(text,jsonb)"]
security: definer
volatility: volatile
executors: [service_role]
raises: []
touches: { reads: [], writes: [] }
tokens: [api, product_worker, api.product_worker]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.product_worker

Domain `api-surface`, lens `ours`.

## product_worker(text, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_operation` | `text` | — | — |
| `p_payload` | `jsonb` | — | — |

Execute: `service_role`.

Touches (best effort): reads —; writes —; calls [`product.claims`](../product/claims.md), [`product.dispatch_worker`](../product/dispatch_worker.md), [`product.fail`](../product/fail.md).

TypeScript: `Database["api"]["Functions"]["product_worker"]`.

Defined in: `20261105010300_product_api.sql`.
