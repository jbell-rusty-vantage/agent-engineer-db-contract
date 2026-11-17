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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
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
