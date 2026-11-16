---
id: "fn:verification.chain_record(text,jsonb,jsonb,jsonb,jsonb)"
kind: function
schema: verification
name: chain_record
domain: evidence
lens: evidence
overloads: ["fn:verification.chain_record(text,jsonb,jsonb,jsonb,jsonb)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [orchestration.operation_intent, orchestration.operation_receipt] }
tokens: [verification, chain_record, verification.chain_record]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# verification.chain_record

Domain `evidence`, lens `evidence`.

## chain_record(text, jsonb, jsonb, jsonb, jsonb) → jsonb

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_function` | `text` | — | — |
| `p_ctx` | `jsonb` | — | — |
| `p_request` | `jsonb` | — | — |
| `p_result` | `jsonb` | — | — |
| `p_refs` | `jsonb` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md); calls [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["verification"]["Functions"]["chain_record"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
