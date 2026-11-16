---
id: "fn:api.record_triage(text,uuid,text,text,text,numeric,jsonb,uuid,uuid,jsonb)"
kind: function
schema: api
name: record_triage
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.record_triage(text,uuid,text,text,text,numeric,jsonb,uuid,uuid,jsonb)"]
security: definer
volatility: volatile
executors: [control_plane, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [evidence.claim, verification.probe], writes: [verification.claim_triage] }
tokens: [api, record_triage, api.record_triage]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.record_triage

Domain `verified-knowledge`, lens `corpus`.

## record_triage(text, uuid, text, text, text, numeric, jsonb, uuid, uuid, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Governed write: record what to do with a proposed claim before anyone checks it (probe it, check the docs or a registry, not checkable, duplicate, out of scope). Never a judgment of truth. Always review_state agent_proposed; append-only: a changed triage supersedes the agent's current row, the same triage again writes nothing, and a row a person reviewed is not superseded by an agent. Idempotent on p_idempotency_key. Returns {triage_id, written, unchanged, disposition, review_state, supersedes_id, receipt_id, intent_id, replayed}. Errors: the common ones, CLAIM_NOT_FOUND, CLAIM_NOT_TRIAGEABLE, TRIAGE_INVALID, RATIONALE_REQUIRED, TRIAGE_DUPLICATE_INVALID, TRIAGE_PROBE_INVALID, TRIAGE_REVIEWED_BY_PERSON.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_claim_id` | `uuid` | — | — |
| `p_disposition` | `text` | — | — |
| `p_checkability` | `text` | — | — |
| `p_rationale` | `text` | — | — |
| `p_priority` | `numeric` | `NULL::numeric` | — |
| `p_components` | `jsonb` | `'{}'::jsonb` | — |
| `p_duplicate_of_claim_id` | `uuid` | `NULL::uuid` | — |
| `p_probe_id` | `uuid` | `NULL::uuid` | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `control_plane`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`evidence.claim`](../../relations/evidence/claim.md), [`verification.probe`](../../relations/verification/probe.md); writes [`verification.claim_triage`](../../relations/verification/claim_triage.md); calls [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md).

TypeScript: `Database["api"]["Functions"]["record_triage"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
