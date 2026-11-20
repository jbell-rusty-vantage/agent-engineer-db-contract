---
id: "rel:catalog.proposal"
kind: table
schema: catalog
name: proposal
domain: identity
lens: corpus
aliases: []
tokens: [catalog, proposal, catalog.proposal, id, tenant_id, proposal_kind, subject_entity_id, object_entity_id, relationship_kind, label, target_segment_id, target_event_id, target_relationship_id, cause_event_id, statement, rationale, world_during, confidence, authored_by_kind, authored_by, review_state, decided_by, decided_at, decision_note, outcome_claim_id, publication, published_at, published_by, created_by_receipt_id, created_at, updated_at]
summary: "Our own view, never a fact: what a person or an agent proposes about how two things relate (relationship), why a recorded change happened (cause), or whether records are the same thing or a mix (identity). Private unless a person publishes it. No other read shows these rows."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"catalog\"][\"Tables\"][\"proposal\"][\"Row\"]"
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog.proposal

table in domain `identity`, lens `corpus` — Our own view, never a fact: what a person or an agent proposes about how two things relate (relationship), why a recorded change happened (cause), or whether records are the same thing or a mix (identity). Private unless a person publishes it. No other read shows these rows..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `proposal_kind` | `text` | no | — | — |
| 4 | `subject_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](entity.md).id |
| 5 | `object_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](entity.md).id |
| 6 | `relationship_kind` | `text` | yes | — | FK → [`taxonomy.relationship_kind`](../taxonomy/relationship_kind.md).code |
| 7 | `label` | `text` | yes | — | — |
| 8 | `target_segment_id` | `uuid` | yes | — | FK → [`temporal.segment`](../temporal/segment.md).id |
| 9 | `target_event_id` | `uuid` | yes | — | FK → [`temporal.event`](../temporal/event.md).id |
| 10 | `target_relationship_id` | `uuid` | yes | — | FK → [`catalog.relationship`](relationship.md).id |
| 11 | `cause_event_id` | `uuid` | yes | — | FK → [`temporal.event`](../temporal/event.md).id |
| 12 | `statement` | `text` | no | — | — |
| 13 | `rationale` | `text` | no | — | — |
| 14 | `world_during` | `tstzrange` | yes | — | — |
| 15 | `confidence` | `text` | no | — | — |
| 16 | `authored_by_kind` | `text` | no | — | — |
| 17 | `authored_by` | `text` | no | — | — |
| 18 | `review_state` | `text` | no | `'agent_proposed'::text` | agent_proposed, person_proposed, endorsed, rejected, withdrawn, confirmed_by_source or refuted_by_source. Anything but agent_proposed is a person's judgment. |
| 19 | `decided_by` | `text` | yes | — | — |
| 20 | `decided_at` | `timestamp with time zone` | yes | — | — |
| 21 | `decision_note` | `text` | yes | — | — |
| 22 | `outcome_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id; The sourced claim that later confirmed or refuted the proposal. |
| 23 | `publication` | `text` | no | `'private'::text` | private (default) or published. Only a person publishes. |
| 24 | `published_at` | `timestamp with time zone` | yes | — | — |
| 25 | `published_by` | `text` | yes | — | — |
| 26 | `created_by_receipt_id` | `uuid` | yes | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 27 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 28 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- 14 check constraints; see [details](proposal.details.md)

## Relationships

9 outbound and 3 inbound foreign keys; full list in [details](proposal.details.md).

## Indexes

3 indexes; see [details](proposal.details.md).

## Triggers

1 triggers; see [details](proposal.details.md).

## Row-level security

Enabled; 1 policies in [details](proposal.details.md).

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`api.decide_proposal`](../../functions/api/decide_proposal.md), [`api.propose`](../../functions/api/propose.md), [`api.publish_proposal`](../../functions/api/publish_proposal.md).

## TypeScript

insert: `Database["catalog"]["Tables"]["proposal"]["Insert"]`; row: `Database["catalog"]["Tables"]["proposal"]["Row"]`; update: `Database["catalog"]["Tables"]["proposal"]["Update"]`

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
