---
id: "fn:api.settle_attention_sweep(text,uuid,text,int4,int4,int4,jsonb,numeric,int4,jsonb)"
kind: function
schema: api
name: settle_attention_sweep
domain: source-intelligence
lens: corpus
overloads: ["fn:api.settle_attention_sweep(text,uuid,text,int4,int4,int4,jsonb,numeric,int4,jsonb)"]
security: definer
volatility: volatile
executors: [control_plane, pipeline_agent, service_role]
raises: []
touches: { reads: [acquisition.attention_policy], writes: [acquisition.attention_sweep] }
tokens: [api, settle_attention_sweep, api.settle_attention_sweep]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.settle_attention_sweep

Domain `source-intelligence`, lens `corpus`.

## settle_attention_sweep(text, uuid, text, integer, integer, integer, jsonb, numeric, integer, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Governed write: settle an open sweep once, with what it saw, selected and captured, the rejections by reason, and what it spent. Spend is recorded as reported; the result says whether it exceeds the policy's per-run budget and whether the mission's budget is now exhausted. Idempotent on p_idempotency_key. Returns {sweep_id, policy, outcome, settled, over_budget_usd, over_budget_credits, mission_spent_usd, mission_budget_usd, mission_budget_exhausted, receipt_id, intent_id, replayed}. Errors: the common ones, SWEEP_NOT_FOUND, SWEEP_ALREADY_SETTLED, SWEEP_MISSION_MISMATCH, SWEEP_INVALID, SWEEP_COUNTS_INVALID.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_sweep_id` | `uuid` | — | — |
| `p_outcome` | `text` | — | — |
| `p_items_seen` | `integer` | — | — |
| `p_items_selected` | `integer` | — | — |
| `p_items_captured` | `integer` | — | — |
| `p_rejected` | `jsonb` | `'{}'::jsonb` | — |
| `p_spend_usd` | `numeric` | `0` | — |
| `p_credits` | `integer` | `0` | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `control_plane`, `pipeline_agent`, `service_role`.

Touches (best effort): reads [`acquisition.attention_policy`](../../relations/acquisition/attention_policy.md); writes [`acquisition.attention_sweep`](../../relations/acquisition/attention_sweep.md); calls [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md).

TypeScript: `Database["api"]["Functions"]["settle_attention_sweep"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
