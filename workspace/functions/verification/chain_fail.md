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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
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
