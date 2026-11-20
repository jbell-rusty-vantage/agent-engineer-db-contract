---
id: "rel:catalog.proposal_basis"
kind: table
schema: catalog
name: proposal_basis
domain: identity
lens: corpus
aliases: []
tokens: [catalog, proposal_basis, catalog.proposal_basis, id, tenant_id, proposal_id, role, claim_id, segment_id, event_id, relationship_id, note]
summary: "What a proposal reasons from (basis) or must answer (counter): a claim, a fact, an event or a relationship."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"catalog\"][\"Tables\"][\"proposal_basis\"][\"Row\"]"
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog.proposal_basis

table in domain `identity`, lens `corpus` — What a proposal reasons from (basis) or must answer (counter): a claim, a fact, an event or a relationship..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | — |
| 3 | `proposal_id` | `uuid` | no | — | FK → [`catalog.proposal`](proposal.md).id |
| 4 | `role` | `text` | no | `'basis'::text` | — |
| 5 | `claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 6 | `segment_id` | `uuid` | yes | — | FK → [`temporal.segment`](../temporal/segment.md).id |
| 7 | `event_id` | `uuid` | yes | — | FK → [`temporal.event`](../temporal/event.md).id |
| 8 | `relationship_id` | `uuid` | yes | — | FK → [`catalog.relationship`](relationship.md).id |
| 9 | `note` | `text` | yes | — | — |

## Constraints

- PK (id)
- check `proposal_basis_one_target`: `(num_nonnulls(claim_id, segment_id, event_id, relationship_id) = 1)`
- check `proposal_basis_role_check`: `(role = ANY (ARRAY['basis'::text, 'counter'::text]))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `event_id` → [`temporal.event`](../temporal/event.md)`.id`; `proposal_id` → [`catalog.proposal`](proposal.md)`.id`; `relationship_id` → [`catalog.relationship`](relationship.md)`.id`; `segment_id` → [`temporal.segment`](../temporal/segment.md)`.id`.
Inbound: none.
Polymorphic: exactly one of `claim_id`, `segment_id`, `event_id`, `relationship_id` → [`catalog.relationship`](relationship.md) | [`evidence.claim`](../evidence/claim.md) | [`temporal.event`](../temporal/event.md) | [`temporal.segment`](../temporal/segment.md) — basis: check constraint proposal_basis_one_target.

## Indexes

`proposal_basis_proposal_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`api.propose`](../../functions/api/propose.md).

## TypeScript

insert: `Database["catalog"]["Tables"]["proposal_basis"]["Insert"]`; row: `Database["catalog"]["Tables"]["proposal_basis"]["Row"]`; update: `Database["catalog"]["Tables"]["proposal_basis"]["Update"]`

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
