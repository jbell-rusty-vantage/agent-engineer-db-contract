---
id: "fn:api.register_probe(text,text,text,text,text,jsonb,uuid[],jsonb,jsonb,jsonb,text,numeric,jsonb)"
kind: function
schema: api
name: register_probe
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.register_probe(text,text,text,text,text,jsonb,uuid[],jsonb,jsonb,jsonb,text,numeric,jsonb)"]
security: definer
volatility: volatile
executors: [control_plane, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, evidence.claim], writes: [verification.probe, verification.probe_claim] }
tokens: [api, register_probe, api.register_probe]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.register_probe

Domain `verified-knowledge`, lens `corpus`.

## register_probe(text, text, text, text, text, jsonb, uuid[], jsonb, jsonb, jsonb, text, numeric, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Governed write: register a probe (an experiment against a matrix of cells) with the claims it tests and what is expected of each before any run. Only a live_model probe has model_policy live and a budget. Idempotent on p_idempotency_key. Returns {probe_id, slug, state, claims, receipt_id, intent_id, replayed}. Errors: the common ones, PROBE_SLUG_INVALID, PROBE_INVALID, PROBE_KIND_INVALID, PROBE_MODEL_POLICY_INVALID, PROBE_MODEL_POLICY_MISMATCH, PROBE_BUDGET_INVALID, PROBE_CLAIMS_REQUIRED, CLAIM_NOT_FOUND, SUBJECT_NOT_FOUND, PROBE_SLUG_TAKEN.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_slug` | `text` | — | — |
| `p_title` | `text` | — | — |
| `p_hypothesis` | `text` | — | — |
| `p_kind` | `text` | — | — |
| `p_claims` | `jsonb` | — | — |
| `p_subject_entity_ids` | `uuid[]` | `'{}'::uuid[]` | — |
| `p_script` | `jsonb` | `'{}'::jsonb` | — |
| `p_environment` | `jsonb` | `'{}'::jsonb` | — |
| `p_matrix` | `jsonb` | `'[]'::jsonb` | — |
| `p_model_policy` | `text` | `'none'::text` | — |
| `p_budget_usd` | `numeric` | `0` | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `control_plane`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`evidence.claim`](../../relations/evidence/claim.md); writes [`verification.probe`](../../relations/verification/probe.md), [`verification.probe_claim`](../../relations/verification/probe_claim.md); calls [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md), [`verification.chain_uuid`](../verification/chain_uuid.md).

TypeScript: `Database["api"]["Functions"]["register_probe"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
