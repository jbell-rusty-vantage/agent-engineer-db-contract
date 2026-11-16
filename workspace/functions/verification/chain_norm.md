---
id: "fn:verification.chain_norm(text)"
kind: function
schema: verification
name: chain_norm
domain: evidence
lens: evidence
overloads: ["fn:verification.chain_norm(text)"]
security: invoker
volatility: immutable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [verification, chain_norm, verification.chain_norm]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# verification.chain_norm

Domain `evidence`, lens `evidence`.

## chain_norm(text) → text

function, immutable, security invoker, language sql, config `search_path=""`. The comparison form of a quote and of the unit it is read from: typographic quotes folded to plain ones, runs of whitespace to one space (the rule the lab used to accept a verbatim quote).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_text` | `text` | — | — |

Execute: no configured role.

TypeScript: `Database["verification"]["Functions"]["chain_norm"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
