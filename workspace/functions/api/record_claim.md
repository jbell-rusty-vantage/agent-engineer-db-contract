---
id: "fn:api.record_claim(text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb)"
kind: function
schema: api
name: record_claim
domain: verified-knowledge
lens: corpus
overloads: ["fn:api.record_claim(text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb)"]
security: definer
volatility: volatile
executors: [executor_service, pipeline_agent, service_role]
raises: []
touches: { reads: [api.claim_verdicts, api.community_claims, catalog.entity, evidence.claim_type, evidence.locator, evidence.source], writes: [evidence.attribution, evidence.claim, evidence.claim_evidence_link, evidence.claim_subject] }
tokens: [api, record_claim, api.record_claim]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.record_claim

Domain `verified-knowledge`, lens `corpus`.

## record_claim(text, text, text, jsonb, jsonb, jsonb, jsonb, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Governed write: record a claim read from a source, with its evidence anchors, subjects and attributions. Always proposed. Each anchor is an existing locator or a quote that is verbatim in a content unit of a capture; structured.quote and structured.node_id default to the first anchor. The same statement again returns the existing claim (reused) and adds nothing to it. Idempotent on p_idempotency_key. Returns {claim_id, created, reused, status, locator_ids, receipt_id, intent_id, replayed}. Errors: TENANT_CONTEXT_REQUIRED, IDEMPOTENCY_KEY_REQUIRED, IDEMPOTENCY_KEY_REUSED, ACTOR_INVALID, MISSION_NOT_FOUND, MISSION_ENDED, STATEMENT_REQUIRED, CLAIM_TYPE_UNKNOWN, STRUCTURED_INVALID, STRUCTURED_RESERVED, EVIDENCE_REQUIRED, EVIDENCE_INVALID, EVIDENCE_NOT_FOUND, EVIDENCE_UNIT_NOT_IN_CAPTURE, EVIDENCE_SELECTOR_UNSUPPORTED, QUOTE_REQUIRED, QUOTE_NOT_IN_UNIT, SUBJECT_INVALID, SUBJECT_NOT_FOUND, ATTRIBUTION_INVALID, ATTRIBUTION_ENTITY_NOT_FOUND, ATTRIBUTION_SOURCE_NOT_FOUND.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_claim_type` | `text` | — | — |
| `p_statement` | `text` | — | — |
| `p_evidence` | `jsonb` | — | — |
| `p_subjects` | `jsonb` | `'[]'::jsonb` | — |
| `p_attributions` | `jsonb` | `'[]'::jsonb` | — |
| `p_structured` | `jsonb` | `'{}'::jsonb` | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `executor_service`, `pipeline_agent`, `service_role`.

Touches (best effort): reads [`api.claim_verdicts`](../../relations/api/claim_verdicts.md), [`api.community_claims`](../../relations/api/community_claims.md), [`catalog.entity`](../../relations/catalog/entity.md), [`evidence.claim_type`](../../relations/evidence/claim_type.md), [`evidence.locator`](../../relations/evidence/locator.md), [`evidence.source`](../../relations/evidence/source.md); writes [`evidence.attribution`](../../relations/evidence/attribution.md), [`evidence.claim`](../../relations/evidence/claim.md), [`evidence.claim_evidence_link`](../../relations/evidence/claim_evidence_link.md), [`evidence.claim_subject`](../../relations/evidence/claim_subject.md); calls [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_anchor`](../verification/chain_anchor.md), [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md), [`verification.chain_uuid`](../verification/chain_uuid.md).

TypeScript: `Database["api"]["Functions"]["record_claim"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
