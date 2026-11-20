---
id: "task:propose-verdict-from-probe"
kind: task
lens: evidence
domains: [verified-knowledge]
queries: [evidence.probes, evidence.probe_matrix, evidence.claim_verdicts, evidence.probe_revalidation_due]
aliases: [register probe, record probe run, propose verdict, write verdict, verdict write, agent proposed, revalidation write, probe write]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# How do I register a probe, record its runs and propose a verdict?

Domains: [`verified-knowledge`](../domains/verified-knowledge.md). Queries: [`q:evidence.probes`](../queries/README.md), [`q:evidence.probe_matrix`](../queries/README.md), [`q:evidence.claim_verdicts`](../queries/README.md), [`q:evidence.probe_revalidation_due`](../queries/README.md).

## Navigation

`tasks/write-verification-chain.md` → `functions/api/register_probe.md` → `functions/api/record_probe_run.md` → `functions/api/propose_verdict.md` → `q:evidence.claim_verdicts`.

## Operation

Three calls, in order (pipeline_agent, verifier_agent or control_plane).

```sql
select api.register_probe(
  p_idempotency_key => 'probe:P20', p_slug => 'P20-checkpoint-ns', p_title => 'Checkpoint namespaces',
  p_hypothesis => 'a root checkpoint_ns in the config is not stored', p_kind => 'executed',
  p_claims => '[{"claim_id":"0192b000-0000-7000-8000-000000000001","expectation":{"expected":"root_ns_stays_empty true in every cell"}}]',
  p_script => '{"path":"probes/p20.py","sha256":"<64 hex>"}', p_matrix => '[{"label":"D3-latest"}]', p_model_policy => 'fake');
select api.record_probe_run(
  p_idempotency_key => 'probe:P20:run:D3-latest:2026-11-16T09', p_probe_id => '0192e000-0000-7000-8000-000000000001',
  p_cell_label => 'D3-latest', p_outcome => 'pass', p_started_at => '2026-11-16T09:00:00Z',
  p_observations => '{"checks":{"root_ns_stays_empty":true}}', p_resolved => '{"langgraph":"1.2.22"}',
  p_output => '{"capture_id":"0192d000-0000-7000-8000-000000000001","node_id":"0192d000-0000-7000-8000-000000000002","selector_kind":"json_pointer","pointer":"/runs/0"}');
select api.propose_verdict(
  p_idempotency_key => 'probe:P20:verdict:claim-1:2026-11-16', p_claim_id => '0192b000-0000-7000-8000-000000000001',
  p_probe_id => '0192e000-0000-7000-8000-000000000001', p_verdict => 'directly_supported',
  p_cells => '{"D3-latest":{"root_ns_stays_empty":true}}', p_rationale => 'stored under the empty namespace in every cell');
```

A run's `outcome` is about the probe's own checks, not about the claim. `p_run` carries `ended_at`, `exit_code`, `lock_sha256`, `python_version`, `platform`, `tokens_in`, `tokens_out`, `cost_usd`, `latency_ms`; `p_sweep_id` ties the run to an open sweep of the same mission.

## Expected shape

`register_probe`: `probe_id`, `slug`, `state`, `claims`. `record_probe_run`: `probe_run_id`, `output_capture_id`, `output_locator_id`, `origin_kind`, `over_budget`. `propose_verdict`: `verdict_id`, `written`, `unchanged`, `review_state` (always `agent_proposed` for a written row), `supersedes_id`, `claim_status`, `claim_status_changed`, `needs_review`, `restatements_to_review`.

## Pitfalls

A verdict is a proposal: it never verifies a claim, and a person confirms or rejects it elsewhere. The same verdict again writes nothing (`unchanged`); a changed verdict is a new row that supersedes. A `contradicted` verdict from a deterministic probe (executed, static_docs, resolution, registry_check) moves a `proposed` claim to `disputed`; a live arm never does, and a verified claim is never changed (`needs_review` true instead). Every key of `p_cells` needs a recorded run: `VERDICT_CELL_NOT_RUN`. The claim must be one the probe was registered to test, or a restatement of one: `CLAIM_NOT_PROBED`. A run that passed or failed needs `p_output`; only a `live_model` probe reports tokens or cost. A verdict a person rejected is not proposed again: `VERDICT_REJECTED_BY_PERSON`.
