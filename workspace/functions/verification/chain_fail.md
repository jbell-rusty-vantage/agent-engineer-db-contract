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
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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
