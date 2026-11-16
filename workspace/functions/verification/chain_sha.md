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
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
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
