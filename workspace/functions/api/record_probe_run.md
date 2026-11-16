---
id: "fn:api.record_probe_run(text,uuid,text,text,timestamptz,jsonb,jsonb,jsonb,jsonb,jsonb,uuid,jsonb)"
kind: function
schema: api
name: record_probe_run
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.record_probe_run(text,uuid,text,text,timestamptz,jsonb,jsonb,jsonb,jsonb,jsonb,uuid,jsonb)"]
security: definer
volatility: volatile
executors: [control_plane, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [acquisition.attention_sweep, verification.probe], writes: [verification.probe_run] }
tokens: [api, record_probe_run, api.record_probe_run]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.record_probe_run

Domain `verified-knowledge`, lens `corpus`.

## record_probe_run(text, uuid, text, text, timestamp with time zone, jsonb, jsonb, jsonb, jsonb, jsonb, uuid, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Governed write: record one execution of an active probe in one cell: outcome (about the probe's own checks), observations, the versions it resolved, and its captured output as an evidence anchor (required when it passed or failed). A probe that is not live reports no tokens or cost. A run under a mission names it; under a sweep, an open one of the same mission. Idempotent on p_idempotency_key. Returns {probe_run_id, probe_id, probe, cell_label, outcome, output_capture_id, output_locator_id, origin_kind, over_budget, receipt_id, intent_id, replayed}. Errors: the common ones and the evidence ones, PROBE_NOT_FOUND, PROBE_NOT_ACTIVE, PROBE_RUN_INVALID, PROBE_RUN_SPEND_NOT_ALLOWED, PROBE_RUN_OUTPUT_REQUIRED, PROBE_RUN_DUPLICATE, MISSION_REQUIRED, SWEEP_NOT_FOUND, SWEEP_NOT_OPEN, SWEEP_MISSION_MISMATCH.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_probe_id` | `uuid` | — | — |
| `p_cell_label` | `text` | — | — |
| `p_outcome` | `text` | — | — |
| `p_started_at` | `timestamp with time zone` | — | — |
| `p_observations` | `jsonb` | `'{}'::jsonb` | — |
| `p_output` | `jsonb` | `NULL::jsonb` | — |
| `p_cell` | `jsonb` | `'{}'::jsonb` | — |
| `p_resolved` | `jsonb` | `'{}'::jsonb` | — |
| `p_run` | `jsonb` | `'{}'::jsonb` | — |
| `p_sweep_id` | `uuid` | `NULL::uuid` | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `control_plane`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`acquisition.attention_sweep`](../../relations/acquisition/attention_sweep.md), [`verification.probe`](../../relations/verification/probe.md); writes [`verification.probe_run`](../../relations/verification/probe_run.md); calls [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_anchor`](../verification/chain_anchor.md), [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md).

TypeScript: `Database["api"]["Functions"]["record_probe_run"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
