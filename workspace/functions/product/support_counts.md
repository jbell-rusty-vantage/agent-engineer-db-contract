---
id: "fn:product.support_counts(uuid,uuid)"
kind: function
schema: product
name: support_counts
domain: inquiry
lens: ours
overloads: ["fn:product.support_counts(uuid,uuid)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [inquiry.support], writes: [] }
tokens: [product, support_counts, product.support_counts]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# product.support_counts

Domain `inquiry`, lens `ours`.

## support_counts(uuid, uuid) → jsonb

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `aid` | `uuid` | — | — |
| `cid` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`inquiry.support`](../../relations/inquiry/support.md); writes —; calls —.

TypeScript: `Database["product"]["Functions"]["support_counts"]`.

Defined in: `20261105010300_product_api.sql`.
