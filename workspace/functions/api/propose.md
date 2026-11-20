---
id: "fn:api.propose(text,text,text,text,text,uuid,uuid,text,text,jsonb,uuid,tstzrange,jsonb,jsonb)"
kind: function
schema: api
name: propose
domain: identity
lens: corpus
overloads: ["fn:api.propose(text,text,text,text,text,uuid,uuid,text,text,jsonb,uuid,tstzrange,jsonb,jsonb)"]
security: definer
volatility: volatile
executors: [executor_service, pipeline_agent, service_role]
raises: []
touches: { reads: [], writes: [catalog.proposal, catalog.proposal_basis] }
tokens: [api, propose, api.propose]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.propose

Domain `identity`, lens `corpus`.

## propose(text, text, text, text, text, uuid, uuid, text, text, jsonb, uuid, tstzrange, jsonb, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Record a proposal: our own view of a relationship, of the cause of a recorded change, or of an identity. An agent role writes agent_proposed and private; nothing here is a fact.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_kind` | `text` | — | — |
| `p_statement` | `text` | — | — |
| `p_rationale` | `text` | — | — |
| `p_confidence` | `text` | — | — |
| `p_subject` | `uuid` | `NULL::uuid` | — |
| `p_object` | `uuid` | `NULL::uuid` | — |
| `p_relationship_kind` | `text` | `NULL::text` | — |
| `p_label` | `text` | `NULL::text` | — |
| `p_target` | `jsonb` | `'{}'::jsonb` | — |
| `p_cause_event` | `uuid` | `NULL::uuid` | — |
| `p_world_during` | `tstzrange` | `NULL::tstzrange` | — |
| `p_basis` | `jsonb` | `'[]'::jsonb` | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `executor_service`, `pipeline_agent`, `service_role`.

Touches (best effort): reads —; writes [`catalog.proposal`](../../relations/catalog/proposal.md), [`catalog.proposal_basis`](../../relations/catalog/proposal_basis.md); calls [`catalog.caller_is_person`](../catalog/caller_is_person.md), [`catalog.caller_role`](../catalog/caller_role.md), [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md).

TypeScript: `Database["api"]["Functions"]["propose"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
