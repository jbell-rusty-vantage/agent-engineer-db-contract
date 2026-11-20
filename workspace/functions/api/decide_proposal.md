---
id: "fn:api.decide_proposal(uuid,text,text,uuid,text)"
kind: function
schema: api
name: decide_proposal
domain: api-surface
lens: corpus
overloads: ["fn:api.decide_proposal(uuid,text,text,uuid,text)"]
security: definer
volatility: volatile
executors: []
raises: [DECISION_INVALID, HUMAN_REVIEW_NOT_AGENT_WRITABLE, OUTCOME_CLAIM_REQUIRED, PROPOSAL_NOT_FOUND]
touches: { reads: [], writes: [catalog.proposal] }
tokens: [api, decide_proposal, api.decide_proposal]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.decide_proposal

Domain `api-surface`, lens `corpus`.

## decide_proposal(uuid, text, text, uuid, text) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. A person endorses, rejects or withdraws a proposal, or marks it confirmed or refuted by a sourced claim. Not granted to any agent role.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_proposal` | `uuid` | — | — |
| `p_decision` | `text` | — | — |
| `p_note` | `text` | `NULL::text` | — |
| `p_outcome_claim` | `uuid` | `NULL::uuid` | — |
| `p_decided_by` | `text` | `NULL::text` | — |

Execute: no configured role.

Raises (mechanically extracted): `DECISION_INVALID`; `HUMAN_REVIEW_NOT_AGENT_WRITABLE`; `OUTCOME_CLAIM_REQUIRED`; `PROPOSAL_NOT_FOUND`.

Touches (best effort): reads —; writes [`catalog.proposal`](../../relations/catalog/proposal.md); calls [`catalog.caller_is_person`](../catalog/caller_is_person.md), [`catalog.caller_role`](../catalog/caller_role.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["decide_proposal"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
