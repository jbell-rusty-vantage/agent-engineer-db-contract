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
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
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
