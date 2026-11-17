---
id: "fn:api.restate_claim(text,uuid,text,bool,text,jsonb,jsonb)"
kind: function
schema: api
name: restate_claim
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.restate_claim(text,uuid,text,bool,text,jsonb,jsonb)"]
security: definer
volatility: volatile
executors: [executor_service, pipeline_agent, service_role]
raises: []
touches: { reads: [verification.probe, verification.probe_verdict], writes: [evidence.attribution, evidence.claim, evidence.claim_evidence_link, evidence.claim_subject] }
tokens: [api, restate_claim, api.restate_claim]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.restate_claim

Domain `verified-knowledge`, lens `corpus`.

## restate_claim(text, uuid, text, boolean, text, jsonb, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Governed write (D-80): restate an attribution-framed proposed claim as the statement a probe can test. A new proposed claim with atomized_from_id, the original's subjects, attributions and evidence links copied; the original is not changed. One restatement per original. Its verdict is proposed separately (api.propose_verdict) and confirmed by a person. Idempotent on p_idempotency_key. Returns {claim_id, original_claim_id, created, reused, status, probe, copied, receipt_id, intent_id, replayed}. Errors: the common ones, CLAIM_NOT_FOUND, CLAIM_NOT_RESTATABLE, STATEMENT_REQUIRED, RESTATEMENT_UNCHANGED, RESTATEMENT_EXISTS, POLARITY_INVALID.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_original_claim_id` | `uuid` | — | — |
| `p_statement` | `text` | — | — |
| `p_qualified` | `boolean` | `false` | — |
| `p_dropped` | `text` | `NULL::text` | — |
| `p_polarity` | `jsonb` | `NULL::jsonb` | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `executor_service`, `pipeline_agent`, `service_role`.

Touches (best effort): reads [`verification.probe`](../../relations/verification/probe.md), [`verification.probe_verdict`](../../relations/verification/probe_verdict.md); writes [`evidence.attribution`](../../relations/evidence/attribution.md), [`evidence.claim`](../../relations/evidence/claim.md), [`evidence.claim_evidence_link`](../../relations/evidence/claim_evidence_link.md), [`evidence.claim_subject`](../../relations/evidence/claim_subject.md); calls [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_norm`](../verification/chain_norm.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md).

TypeScript: `Database["api"]["Functions"]["restate_claim"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
