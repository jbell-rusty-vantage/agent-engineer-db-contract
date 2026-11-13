---
id: "fn:product.actor()"
kind: function
schema: product
name: actor
domain: access
lens: ours
overloads: ["fn:product.actor()"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, actor, product.actor]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# product.actor

Domain `access`, lens `ours`.

## actor() → uuid

function, stable, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`product.claims`](claims.md), [`product.fail`](fail.md).

TypeScript: `Database["product"]["Functions"]["actor"]`.

Defined in: `20261105010300_product_api.sql`.
