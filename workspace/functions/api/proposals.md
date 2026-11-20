---
id: "fn:api.proposals(uuid,uuid,uuid,uuid,text[])"
kind: function
schema: api
name: proposals
domain: identity
lens: corpus
overloads: ["fn:api.proposals(uuid,uuid,uuid,uuid,text[])"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, catalog.proposal, catalog.proposal_basis], writes: [] }
tokens: [api, proposals, api.proposals]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.proposals

Domain `identity`, lens `corpus`.

## proposals(uuid, uuid, uuid, uuid, text[]) → TABLE(proposal_id uuid, proposal_kind text, statement text, rationale text, confidence text, authored_by_kind text, authored_by text, review_state text, publication text, subject_entity_id uuid, subject text, object_entity_id uuid, object text, relationship_kind text, label text, target jsonb, cause_event_id uuid, basis jsonb, outcome_claim_id uuid, created_at timestamp with time zone)

function, stable, security definer, language sql, config `search_path=""`. Proposals about an entity or a change. The service's reader roles see published ones only; agent and control roles see private ones too.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | `NULL::uuid` | — |
| `p_segment` | `uuid` | `NULL::uuid` | — |
| `p_event` | `uuid` | `NULL::uuid` | — |
| `p_relationship` | `uuid` | `NULL::uuid` | — |
| `p_review_states` | `text[]` | `NULL::text[]` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.proposal`](../../relations/catalog/proposal.md), [`catalog.proposal_basis`](../../relations/catalog/proposal_basis.md); writes —; calls [`catalog.caller_is_person`](../catalog/caller_is_person.md), [`catalog.caller_role`](../catalog/caller_role.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["proposals"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
