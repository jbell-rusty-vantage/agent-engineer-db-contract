---
id: "fn:api.raise_attention_sweep(text,text,text,jsonb,text,timestamptz,timestamptz,jsonb)"
kind: function
schema: api
name: raise_attention_sweep
domain: source-intelligence
lens: corpus
overloads: ["fn:api.raise_attention_sweep(text,text,text,jsonb,text,timestamptz,timestamptz,jsonb)"]
security: definer
volatility: volatile
executors: [control_plane, pipeline_agent, service_role]
raises: []
touches: { reads: [acquisition.attention_policy], writes: [acquisition.attention_sweep] }
tokens: [api, raise_attention_sweep, api.raise_attention_sweep]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.raise_attention_sweep

Domain `source-intelligence`, lens `corpus`.

## raise_attention_sweep(text, text, text, jsonb, text, timestamp with time zone, timestamp with time zone, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Governed write: open one execution (a sweep) of an active attention policy above W0, by slug or id. Under a mission the budget gate runs first: when the mission's sweeps already spent its budget, the sweep is written settled as budget_stopped and the result says budget_stopped true: do no work. Policies themselves (what to watch, how often, on what budget) are decided by a person and are not written here. Idempotent on p_idempotency_key. Returns {sweep_id, policy_id, policy, origin_kind, open, budget_stopped, mission_spent_usd, mission_budget_usd, budget_usd_per_run, budget_credits_per_run, receipt_id, intent_id, replayed}. Errors: the common ones, ATTENTION_POLICY_NOT_FOUND, ATTENTION_POLICY_NOT_SWEEPABLE, SWEEP_INVALID, MISSION_REQUIRED.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_policy` | `text` | — | — |
| `p_trigger_kind` | `text` | — | — |
| `p_trigger_ref` | `jsonb` | `'{}'::jsonb` | — |
| `p_note` | `text` | `NULL::text` | — |
| `p_window_from` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_window_to` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `control_plane`, `pipeline_agent`, `service_role`.

Touches (best effort): reads [`acquisition.attention_policy`](../../relations/acquisition/attention_policy.md); writes [`acquisition.attention_sweep`](../../relations/acquisition/attention_sweep.md); calls [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md).

TypeScript: `Database["api"]["Functions"]["raise_attention_sweep"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
