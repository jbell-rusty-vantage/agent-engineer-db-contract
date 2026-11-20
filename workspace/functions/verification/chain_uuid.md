---
id: "fn:verification.chain_uuid(text,text)"
kind: function
schema: verification
name: chain_uuid
domain: evidence
lens: evidence
overloads: ["fn:verification.chain_uuid(text,text)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [verification, chain_uuid, verification.chain_uuid]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# verification.chain_uuid

Domain `evidence`, lens `evidence`.

## chain_uuid(text, text) → uuid

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_text` | `text` | — | — |
| `p_code` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes —; calls [`verification.chain_fail`](chain_fail.md).

TypeScript: `Database["verification"]["Functions"]["chain_uuid"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
