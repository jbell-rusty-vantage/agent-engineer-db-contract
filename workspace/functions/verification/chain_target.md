---
id: "fn:verification.chain_target(jsonb,uuid,text,text,uuid,text,text,uuid)"
kind: function
schema: verification
name: chain_target
domain: evidence
lens: evidence
overloads: ["fn:verification.chain_target(jsonb,uuid,text,text,uuid,text,text,uuid)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [orchestration.operation_receipt_target] }
tokens: [verification, chain_target, verification.chain_target]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# verification.chain_target

Domain `evidence`, lens `evidence`.

## chain_target(jsonb, uuid, text, text, uuid, text, text, uuid) → void

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_ctx` | `jsonb` | — | — |
| `p_receipt` | `uuid` | — | — |
| `p_schema` | `text` | — | — |
| `p_table` | `text` | — | — |
| `p_id` | `uuid` | — | — |
| `p_role` | `text` | — | — |
| `p_action` | `text` | — | — |
| `p_claim` | `uuid` | `NULL::uuid` | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`orchestration.operation_receipt_target`](../../relations/orchestration/operation_receipt_target.md); calls —.

TypeScript: `Database["verification"]["Functions"]["chain_target"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
