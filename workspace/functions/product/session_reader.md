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
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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
