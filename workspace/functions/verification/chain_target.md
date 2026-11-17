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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
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
