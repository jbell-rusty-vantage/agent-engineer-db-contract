---
id: "fn:verification.chain_sha(text)"
kind: function
schema: verification
name: chain_sha
domain: evidence
lens: evidence
overloads: ["fn:verification.chain_sha(text)"]
security: invoker
volatility: immutable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [verification, chain_sha, verification.chain_sha]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# verification.chain_sha

Domain `evidence`, lens `evidence`.

## chain_sha(text) → text

function, immutable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_text` | `text` | — | — |

Execute: no configured role.

TypeScript: `Database["verification"]["Functions"]["chain_sha"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
