---
id: "fn:api.propose_verdict(text,uuid,uuid,text,jsonb,text,jsonb)"
kind: function
schema: api
name: propose_verdict
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.propose_verdict(text,uuid,uuid,text,jsonb,text,jsonb)"]
security: definer
volatility: volatile
executors: [control_plane, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [verification.probe, verification.probe_run], writes: [evidence.claim, evidence.claim_evidence_link, verification.probe_claim, verification.probe_verdict] }
tokens: [api, propose_verdict, api.propose_verdict]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.propose_verdict

Domain `verified-knowledge`, lens `corpus`.

## propose_verdict(text, uuid, uuid, text, jsonb, text, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Governed write: propose what a probe's recorded runs say about a claim the probe tests. Always review_state agent_proposed: a person confirms or rejects through a path no agent role holds, and only a Knowledge Services admission verifies. Append-only: a changed verdict supersedes the current one; the same verdict again writes nothing. A deterministic contradiction moves a proposed claim to disputed; no other status is touched. Idempotent on p_idempotency_key. Returns {verdict_id, written, unchanged, verdict, review_state, supersedes_id, claim_status, claim_status_changed, evidence_locator_id, needs_review, restatements_to_review, receipt_id, intent_id, replayed}. Errors: the common ones, CLAIM_NOT_FOUND, PROBE_NOT_FOUND, VERDICT_INVALID, RATIONALE_REQUIRED, VERDICT_REQUIRES_RUNS, VERDICT_CELL_NOT_RUN, CLAIM_NOT_PROBED, VERDICT_REJECTED_BY_PERSON.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_claim_id` | `uuid` | — | — |
| `p_probe_id` | `uuid` | — | — |
| `p_verdict` | `text` | — | — |
| `p_cells` | `jsonb` | — | — |
| `p_rationale` | `text` | — | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `control_plane`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`verification.probe`](../../relations/verification/probe.md), [`verification.probe_run`](../../relations/verification/probe_run.md); writes [`evidence.claim`](../../relations/evidence/claim.md), [`evidence.claim_evidence_link`](../../relations/evidence/claim_evidence_link.md), [`verification.probe_claim`](../../relations/verification/probe_claim.md), [`verification.probe_verdict`](../../relations/verification/probe_verdict.md); calls [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md).

TypeScript: `Database["api"]["Functions"]["propose_verdict"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
