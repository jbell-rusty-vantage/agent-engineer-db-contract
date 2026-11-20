---
id: "fn:api.publish_proposal(uuid,bool,text)"
kind: function
schema: api
name: publish_proposal
domain: api-surface
lens: corpus
overloads: ["fn:api.publish_proposal(uuid,bool,text)"]
security: definer
volatility: volatile
executors: []
raises: [HUMAN_REVIEW_NOT_AGENT_WRITABLE, PROPOSAL_NOT_FOUND, PROPOSAL_NOT_REVIEWED]
touches: { reads: [], writes: [catalog.proposal] }
tokens: [api, publish_proposal, api.publish_proposal]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.publish_proposal

Domain `api-surface`, lens `corpus`.

## publish_proposal(uuid, boolean, text) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. A person publishes (or unpublishes) a proposal. Not granted to any agent role.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_proposal` | `uuid` | — | — |
| `p_publish` | `boolean` | `true` | — |
| `p_published_by` | `text` | `NULL::text` | — |

Execute: no configured role.

Raises (mechanically extracted): `HUMAN_REVIEW_NOT_AGENT_WRITABLE`; `PROPOSAL_NOT_FOUND`; `PROPOSAL_NOT_REVIEWED`.

Touches (best effort): reads —; writes [`catalog.proposal`](../../relations/catalog/proposal.md); calls [`catalog.caller_is_person`](../catalog/caller_is_person.md), [`catalog.caller_role`](../catalog/caller_role.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["publish_proposal"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
