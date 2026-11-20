---
id: "rel:catalog.proposal#details"
kind: details
schema: catalog
name: proposal
of: "rel:catalog.proposal"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# catalog.proposal — details

Spill-over from [the main page](proposal.md).

## Constraints
- PK (id)
- unique (tenant_id, id)
- check `proposal_agent_state`: `((authored_by_kind <> 'agent'::text) OR (review_state <> 'person_proposed'::text))`
- check `proposal_authored_by_check`: `(btrim(authored_by) <> ''::text)`
- check `proposal_authored_by_kind_check`: `(authored_by_kind = ANY (ARRAY['person'::text, 'agent'::text]))`
- check `proposal_cause_shape`: `((proposal_kind <> 'cause'::text) OR (num_nonnulls(target_segment_id, target_event_id, target_relationship_id) = 1))`
- check `proposal_confidence_check`: `(confidence = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text]))`
- check `proposal_identity_shape`: `((proposal_kind <> 'identity'::text) OR ((subject_entity_id IS NOT NULL) AND (object_entity_id IS DISTINCT FROM subject_entity_id)))`
- check `proposal_outcome_has_claim`: `((review_state <> ALL (ARRAY['confirmed_by_source'::text, 'refuted_by_source'::text])) OR (outcome_claim_id IS NOT NULL))`
- check `proposal_proposal_kind_check`: `(proposal_kind = ANY (ARRAY['relationship'::text, 'cause'::text, 'identity'::text]))`
- check `proposal_publication_check`: `(publication = ANY (ARRAY['private'::text, 'published'::text]))`
- check `proposal_published_is_reviewed`: `((publication = 'private'::text) OR (review_state = ANY (ARRAY['person_proposed'::text, 'endorsed'::text, 'confirmed_by_source'::text])))`
- check `proposal_rationale_check`: `((length(btrim(rationale)) >= 1) AND (length(btrim(rationale)) <= 8000))`
- check `proposal_relationship_shape`: `((proposal_kind <> 'relationship'::text) OR ((subject_entity_id IS NOT NULL) AND (object_entity_id IS NOT NULL) AND (subject_entity_id <> object_entity_id) AND (num_nonnulls(relationship_kind, NULLIF(btrim(label), ''::text)) >= 1)))`
- check `proposal_review_state_check`: `(review_state = ANY (ARRAY['agent_proposed'::text, 'person_proposed'::text, 'endorsed'::text, 'rejected'::text, 'withdrawn'::text, 'confirmed_by_source'::text, 'refuted_by_source'::text]))`
- check `proposal_statement_check`: `((length(btrim(statement)) >= 1) AND (length(btrim(statement)) <= 2000))`

## Relationships

Outbound: `cause_event_id` → [`temporal.event`](../temporal/event.md)`.id`; `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`; `object_entity_id` → [`catalog.entity`](entity.md)`.id`; `outcome_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `relationship_kind` → [`taxonomy.relationship_kind`](../taxonomy/relationship_kind.md)`.code`; `subject_entity_id` → [`catalog.entity`](entity.md)`.id`; `target_event_id` → [`temporal.event`](../temporal/event.md)`.id`; `target_relationship_id` → [`catalog.relationship`](relationship.md)`.id`; `target_segment_id` → [`temporal.segment`](../temporal/segment.md)`.id`.
Inbound: [`catalog.entity_merge`](entity_merge.md).proposal_id, [`catalog.entity_split`](entity_split.md).proposal_id, [`catalog.proposal_basis`](proposal_basis.md).proposal_id.
Polymorphic: exactly one of `target_segment_id`, `target_event_id`, `target_relationship_id` → [`catalog.relationship`](relationship.md) | [`temporal.event`](../temporal/event.md) | [`temporal.segment`](../temporal/segment.md) — basis: check constraint proposal_cause_shape.

## Indexes

| Index | Definition |
| --- | --- |
| `proposal_object_idx` | `CREATE INDEX proposal_object_idx ON catalog.proposal USING btree (tenant_id, object_entity_id)` |
| `proposal_subject_idx` | `CREATE INDEX proposal_subject_idx ON catalog.proposal USING btree (tenant_id, subject_entity_id)` |
| `proposal_tenant_id_id_key` | `CREATE UNIQUE INDEX proposal_tenant_id_id_key ON catalog.proposal USING btree (tenant_id, id)` |

## Triggers

- `proposal_human_judgment` → [`verification.guard_human_judgment`](../../functions/verification/guard_human_judgment.md): `CREATE TRIGGER proposal_human_judgment BEFORE INSERT OR UPDATE ON catalog.proposal FOR EACH ROW EXECUTE FUNCTION verification.guard_human_judgment()`

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
