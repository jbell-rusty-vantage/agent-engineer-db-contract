---
id: "fn:product.session_reader()"
kind: function
schema: product
name: session_reader
domain: product-operations
lens: ours
overloads: ["fn:product.session_reader()"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [product, session_reader, product.session_reader]
defined_in: ["20261116120000_build08_api_default_closed.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# product.session_reader

Domain `product-operations`, lens `ours`.

## session_reader(boolean, uuid) → record

function, stable, security invoker, language plpgsql, config `search_path=""`. Who reads an api knowledge reader directly: trusted for every role but authenticated and anon (database roles and service_role keep reading what their grants allow); for a PostgREST session of role authenticated the principal is the verified JWT subject, else null (entitled to nothing).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `trusted` | `boolean` | — | out |
| `principal` | `uuid` | — | out |

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`product.claims`](claims.md).

TypeScript: `Database["product"]["Functions"]["session_reader"]`.

Defined in: `20261116120000_build08_api_default_closed.sql`.
