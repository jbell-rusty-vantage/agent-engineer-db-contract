---
id: "fn:product.proposal_problems(jsonb)"
kind: function
schema: product
name: proposal_problems
domain: inquiry
lens: ours
overloads: ["fn:product.proposal_problems(jsonb)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, proposal_problems, product.proposal_problems]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# product.proposal_problems

Domain `inquiry`, lens `ours`.

## proposal_problems(jsonb) → jsonb

function, stable, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `m` | `jsonb` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`product.nonblank`](nonblank.md).

TypeScript: `Database["product"]["Functions"]["proposal_problems"]`.

Defined in: `20261105010300_product_api.sql`.
