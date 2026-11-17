---
id: "fn:verification.chain_begin(text,text,jsonb,jsonb)"
kind: function
schema: verification
name: chain_begin
domain: evidence
lens: evidence
overloads: ["fn:verification.chain_begin(text,text,jsonb,jsonb)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [orchestration.mission, orchestration.operation_intent, orchestration.operation_receipt], writes: [] }
tokens: [verification, chain_begin, verification.chain_begin]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# verification.chain_begin

Domain `evidence`, lens `evidence`.

## chain_begin(text, text, jsonb, jsonb) → jsonb

function, volatile, security invoker, language plpgsql, config `search_path=""`. Opens a governed chain write: resolves the tenant (util.current_tenant_id), takes the idempotency key (stored as chain:<key>; same key and same arguments replays the first result, other arguments are refused), reads the session role and validates the actor the caller passes (label, the AI Engineer mission, the Mission Control invocation).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_function` | `text` | — | — |
| `p_key` | `text` | — | — |
| `p_request` | `jsonb` | — | — |
| `p_actor` | `jsonb` | — | — |

Execute: no configured role.

Touches (best effort): reads [`orchestration.mission`](../../relations/orchestration/mission.md), [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md), [`verification.chain_fail`](chain_fail.md), [`verification.chain_sha`](chain_sha.md), [`verification.chain_uuid`](chain_uuid.md).

TypeScript: `Database["verification"]["Functions"]["chain_begin"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
