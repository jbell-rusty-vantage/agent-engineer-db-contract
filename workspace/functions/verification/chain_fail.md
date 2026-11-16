---
id: "fn:verification.chain_fail(text,text,text)"
kind: function
schema: verification
name: chain_fail
domain: evidence
lens: evidence
overloads: ["fn:verification.chain_fail(text,text,text)"]
security: invoker
volatility: volatile
executors: []
raises: ["%"]
touches: { reads: [], writes: [] }
tokens: [verification, chain_fail, verification.chain_fail]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# verification.chain_fail

Domain `evidence`, lens `evidence`.

## chain_fail(text, text, text) → void

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_code` | `text` | — | — |
| `p_state` | `text` | — | — |
| `p_detail` | `text` | `NULL::text` | — |

Execute: no configured role.

Raises (mechanically extracted): `%`.

TypeScript: `Database["verification"]["Functions"]["chain_fail"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
