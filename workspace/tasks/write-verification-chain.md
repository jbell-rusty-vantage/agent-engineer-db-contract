---
id: "task:write-verification-chain"
kind: task
lens: evidence
domains: [verified-knowledge, source-intelligence, orchestration-ledger]
queries: [chain.governed_writes, evidence.claim, evidence.claim_verdicts, acquisition.attention_due]
aliases: [governed write, write a claim, agent write, mission write, idempotency key, p_actor, chain write, who may write, write functions]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# How do I write the verification chain (claim, probe, verdict, triage, assessment, sweep)?

Domains: [`verified-knowledge`](../domains/verified-knowledge.md), [`source-intelligence`](../domains/source-intelligence.md), [`orchestration-ledger`](../domains/orchestration-ledger.md). Queries: [`q:chain.governed_writes`](../queries/README.md), [`q:evidence.claim`](../queries/README.md), [`q:evidence.claim_verdicts`](../queries/README.md), [`q:acquisition.attention_due`](../queries/README.md).

## Navigation

`START_HERE.md` (Writing) → this page → the task for the step → `functions/api/<name>.md`.

## Operation

Nine functions, one per write. Call them as a bounded role with the tenant set for the transaction; never insert the rows.

| Step | Function | Roles | Task |
|---|---|---|---|
| record a claim with evidence | `api.record_claim` | pipeline_agent, executor_service | `tasks/record-claim-with-evidence.md` |
| restate a claim | `api.restate_claim` | pipeline_agent, executor_service | same |
| register a probe | `api.register_probe` | pipeline_agent, verifier_agent, control_plane | `tasks/propose-verdict-from-probe.md` |
| record a probe run | `api.record_probe_run` | same three | same |
| propose a verdict | `api.propose_verdict` | same three | same |
| triage a candidate | `api.record_triage` | same three | `tasks/triage-claims-and-assess-sources.md` |
| assess a source | `api.record_source_assessment` | same three | same |
| open and settle a sweep | `api.raise_attention_sweep`, `api.settle_attention_sweep` | pipeline_agent, control_plane | `tasks/run-attention-sweep.md` |

```sql
begin;
select set_config('app.tenant_id', '00000000-0000-7000-8000-000000000001', true);
set local role pipeline_agent;
select api.record_claim(
  p_idempotency_key => 'run-2fa5:claim:7',
  p_claim_type => 'assertion',
  p_statement => 'create_agent ends the loop when tool_calls is empty.',
  p_evidence => '[{"capture_id":"0192d000-0000-7000-8000-000000000001","node_id":"0192d000-0000-7000-8000-000000000002","quote":"the loop exits when tool_calls is empty"}]',
  p_actor => '{"label":"ks:claim-extractor","mission_id":"0192a000-0000-7000-8000-000000000001","mc":{"mission_id":"m-1","run_id":"2fa5e2ab","operation_id":"op-3","operation_attempt":1,"execution_generation":0,"lane":"deep_agents"}}');
commit;
```

Every function takes `p_idempotency_key` first and `p_actor` last. `p_actor` is optional: `label` (the agent or tool), `mission_id` (the `orchestration.mission` whose budget bounds the work), `mc` (the Mission Control invocation: all of `mission_id`, `run_id`, `operation_id`, `operation_attempt`, `execution_generation`, `lane`), `origin_digest`.

## Expected shape

One JSON object: the ids written, plus `intent_id`, `receipt_id` and `replayed`. The same key with the same arguments returns the first result with `replayed` true and writes nothing (the actor is not compared, so a later attempt of the same operation replays). `q:chain.governed_writes` lists the writes of a function, a key or a Mission Control run.

## Pitfalls

The tenant is `app.tenant_id` of the transaction, never an argument: without it the call fails `TENANT_CONTEXT_REQUIRED`. A failure's message is a stable code; the SQLSTATE is its class (42501 not allowed, 22023 malformed argument, P0002 not found in the tenant, 23514 the row's state refuses, 23505 taken). The same key with other arguments is `IDEMPOTENCY_KEY_REUSED`: derive the key from the operation, not from the attempt. A `label` that starts with `human` is `ACTOR_INVALID`. Order matters: a verdict needs a registered probe with a recorded run in every cell it cites.
