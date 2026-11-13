---
id: "fn:product.new_event(uuid,uuid,uuid,uuid,text,jsonb,text,text,text,text)"
kind: function
schema: product
name: new_event
domain: product-operations
lens: ours
overloads: ["fn:product.new_event(uuid,uuid,uuid,uuid,text,jsonb,text,text,text,text)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [authoring.event] }
tokens: [product, new_event, product.new_event]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# product.new_event

Domain `product-operations`, lens `ours`.

## new_event(uuid, uuid, uuid, uuid, text, jsonb, text, text, text, text) → uuid

function, volatile, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `p` | `uuid` | — | — |
| `work` | `uuid` | — | — |
| `rev` | `uuid` | — | — |
| `kind` | `text` | — | — |
| `payload` | `jsonb` | — | — |
| `dedupe` | `text` | — | — |
| `actor_kind` | `text` | — | — |
| `surface` | `text` | — | — |
| `role` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`authoring.event`](../../relations/authoring/event.md); calls [`product.tenant`](tenant.md).

TypeScript: `Database["product"]["Functions"]["new_event"]`.

Defined in: `20261105010300_product_api.sql`.
