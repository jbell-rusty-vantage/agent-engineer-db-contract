---
id: "fn:product.session_reads_workspace(uuid)"
kind: function
schema: product
name: session_reads_workspace
domain: product-operations
lens: ours
overloads: ["fn:product.session_reads_workspace(uuid)"]
security: definer
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, session_reads_workspace, product.session_reads_workspace]
defined_in: ["20261116120000_build08_api_default_closed.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# product.session_reads_workspace

Domain `product-operations`, lens `ours`.

## session_reads_workspace(uuid) → boolean

function, stable, security definer, language sql, config `search_path=""`. True when the reading session may see a workspace's own records: a signed-in user who is a member of it (product.role_in); a trusted role always. The row filter of api.releases_needing_review.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`product.role_in`](role_in.md), [`product.session_reader`](session_reader.md).

TypeScript: `Database["product"]["Functions"]["session_reads_workspace"]`.

Defined in: `20261116120000_build08_api_default_closed.sql`.
