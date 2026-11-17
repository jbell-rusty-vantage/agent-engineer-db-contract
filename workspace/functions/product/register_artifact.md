---
id: "fn:product.register_artifact(uuid,uuid,text,text,int8,text,text,text,text,interval)"
kind: function
schema: product
name: register_artifact
domain: product-operations
lens: ours
overloads: ["fn:product.register_artifact(uuid,uuid,text,text,int8,text,text,text,text,interval)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [authoring.asset_scope, orchestration.artifact] }
tokens: [product, register_artifact, product.register_artifact]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# product.register_artifact

Domain `product-operations`, lens `ours`.

## register_artifact(uuid, uuid, text, text, bigint, text, text, text, text, interval) → uuid

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `p` | `uuid` | — | — |
| `atype` | `text` | — | — |
| `sha` | `text` | — | — |
| `size` | `bigint` | — | — |
| `media` | `text` | — | — |
| `usage` | `text` | — | — |
| `rights` | `text` | — | — |
| `retention` | `text` | `'durable'::text` | — |
| `ttl` | `interval` | `NULL::interval` | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`authoring.asset_scope`](../../relations/authoring/asset_scope.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md); calls [`product.tenant`](tenant.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["product"]["Functions"]["register_artifact"]`.

Defined in: `20261105010300_product_api.sql`.
