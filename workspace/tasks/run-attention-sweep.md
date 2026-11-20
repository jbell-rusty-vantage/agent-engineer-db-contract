---
id: "task:run-attention-sweep"
kind: task
lens: evidence
domains: [source-intelligence]
queries: [acquisition.attention_due, acquisition.attention_policies, acquisition.open_sweeps]
aliases: [raise sweep, open sweep, settle sweep, close sweep, attention sweep write, budget gate, budget stopped, watch tick, watch mission write]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# How do I open and settle an attention sweep under a mission budget?

Domains: [`source-intelligence`](../domains/source-intelligence.md). Queries: [`q:acquisition.attention_due`](../queries/README.md), [`q:acquisition.attention_policies`](../queries/README.md), [`q:acquisition.open_sweeps`](../queries/README.md).

## Navigation

`tasks/what-is-due.md` → `q:acquisition.attention_due` → `functions/api/raise_attention_sweep.md` → the work → `functions/api/settle_attention_sweep.md`.

## Operation

A sweep is one execution of an attention policy (pipeline_agent or control_plane). Open it before the work, settle it once after.

```sql
select api.raise_attention_sweep(
  p_idempotency_key => 'run-2fa5:op-3:sweep:vendor-issues-on-release', p_policy => 'vendor-issues-on-release',
  p_trigger_kind => 'event', p_trigger_ref => '{"release":"langgraph 1.2.22"}', p_note => 'watch tick',
  p_actor => '{"label":"mc:watch","mission_id":"0192a000-0000-7000-8000-000000000001","mc":{"mission_id":"m-1","run_id":"2fa5e2ab","operation_id":"op-3","operation_attempt":1,"execution_generation":0,"lane":"deep_agents"}}');
-- do the work only when the result has "open": true
select api.settle_attention_sweep(
  p_idempotency_key => 'run-2fa5:op-3:settle:vendor-issues-on-release', p_sweep_id => '0192f000-0000-7000-8000-000000000001',
  p_outcome => 'completed', p_items_seen => 30, p_items_selected => 4, p_items_captured => 4,
  p_rejected => '{"off_topic":26}', p_spend_usd => 0.12, p_credits => 0,
  p_actor => '{"label":"mc:watch","mission_id":"0192a000-0000-7000-8000-000000000001"}');
```

`p_policy` is the policy slug or id. Fetches and probe runs made in the sweep carry its id (`p_sweep_id` of `api.record_probe_run`).

## Expected shape

`raise_attention_sweep`: `sweep_id`, `policy`, `origin_kind`, `open`, `budget_stopped`, `mission_spent_usd`, `mission_budget_usd`, `budget_usd_per_run`, `budget_credits_per_run`. `settle_attention_sweep`: `outcome`, `settled`, `over_budget_usd`, `over_budget_credits`, `mission_spent_usd`, `mission_budget_usd`, `mission_budget_exhausted`.

## Pitfalls

The budget gate runs before any work: when the mission's sweeps already spent its budget the sweep is written settled as `budget_stopped` and `open` is false; stop. A call made by a Mission Control invocation (`mc`) must name the mission (`MISSION_REQUIRED`). Only an active policy above W0 is swept (`ATTENTION_POLICY_NOT_SWEEPABLE`). A sweep is settled once, under the mission that opened it (`SWEEP_ALREADY_SETTLED`, `SWEEP_MISSION_MISMATCH`); `captured <= selected <= seen`. Spend is recorded as reported, even over the per-run budget (`over_budget_usd`). An unsettled sweep is found with `q:acquisition.open_sweeps`. Policies are a person's decisions: no function creates or changes one.
