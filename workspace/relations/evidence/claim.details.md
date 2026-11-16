---
id: "rel:evidence.claim#details"
kind: details
schema: evidence
name: claim
of: "rel:evidence.claim"
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# evidence.claim — details

Spill-over from [the main page](claim.md).

## Relationships

Outbound: `atomized_from_id` → [`evidence.claim`](claim.md)`.id` (+tenant); `claim_type` → [`evidence.claim_type`](claim_type.md)`.code`; `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id` (deferrable); `producer_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id` (+tenant); `relationship_id` → [`catalog.relationship`](../catalog/relationship.md)`.id`; `superseded_by_id` → [`evidence.claim`](claim.md)`.id` (+tenant).
Inbound: [`authoring.release_item`](../authoring/release_item.md).claim_id, [`authoring.revision_binding`](../authoring/revision_binding.md).claim_id, [`catalog.entity_alias`](../catalog/entity_alias.md).source_claim_id, [`catalog.relationship`](../catalog/relationship.md).primary_claim_id, [`content.digest_item`](../content/digest_item.md).claim_id, [`content.unit_entity_role`](../content/unit_entity_role.md).claim_id, [`evaluation.review_task`](../evaluation/review_task.md).claim_id, [`evidence.attribution`](attribution.md).claim_id, [`evidence.claim`](claim.md).atomized_from_id|superseded_by_id, [`evidence.claim_conflict`](claim_conflict.md).claim_a_id|claim_b_id, [`evidence.claim_evidence_link`](claim_evidence_link.md).claim_id, [`evidence.claim_record`](claim_record.md).claim_id, [`evidence.claim_subject`](claim_subject.md).claim_id, [`evidence.extraction_record`](extraction_record.md).claim_id, [`evidence.segment_support`](segment_support.md).claim_id, [`guidance.item`](../guidance/item.md).provenance_claim_id, [`inquiry.assertion`](../inquiry/assertion.md).promoted_claim_id|uses_claim_id, [`inquiry.support`](../inquiry/support.md).claim_id, [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md).claim_id, [`retrieval.chunk_claim_link`](../retrieval/chunk_claim_link.md).claim_id, [`retrieval.packet_member`](../retrieval/packet_member.md).claim_id, [`retrieval.projection_target`](../retrieval/projection_target.md).claim_id, [`taxonomy.assignment`](../taxonomy/assignment.md).provenance_claim_id, [`temporal.event_occurrence`](../temporal/event_occurrence.md).primary_claim_id, [`temporal.segment`](../temporal/segment.md).primary_claim_id, [`verification.claim_triage`](../verification/claim_triage.md).claim_id|duplicate_of_claim_id, [`verification.probe_claim`](../verification/probe_claim.md).claim_id, [`verification.probe_verdict`](../verification/probe_verdict.md).claim_id.
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject), [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_exactly_one).

## Indexes

| Index | Definition |
| --- | --- |
| `claim_producer_idx` | `CREATE INDEX claim_producer_idx ON evidence.claim USING btree (producer_attempt_id)` |
| `claim_status_idx` | `CREATE INDEX claim_status_idx ON evidence.claim USING btree (status, created_at DESC)` |
| `claim_tenant_id_uq` | `CREATE UNIQUE INDEX claim_tenant_id_uq ON evidence.claim USING btree (tenant_id, id)` |
| `claim_tenant_statement_md5_ix` | `CREATE INDEX claim_tenant_statement_md5_ix ON evidence.claim USING btree (tenant_id, md5(statement))` |
| `claim_type_idx` | `CREATE INDEX claim_type_idx ON evidence.claim USING btree (claim_type)` |

## Triggers

- `claim_content_provenance_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER claim_content_provenance_immutable BEFORE UPDATE OF tenant_id, claim_type, statement, structured, composite, atomized_from_id, producer_attempt_id, producer_origin_digest, created_by_receipt_id, created_at ON evidence.claim FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`
- `claim_requires_admission` → [`verification.require_receipt_admission`](../../functions/verification/require_receipt_admission.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER claim_requires_admission AFTER INSERT OR UPDATE OF created_by_receipt_id ON evidence.claim DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION verification.require_receipt_admission()`
- `claim_reviewed_preserved` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER claim_reviewed_preserved BEFORE DELETE ON evidence.claim FOR EACH ROW WHEN (old.status <> 'proposed'::evidence.claim_status) EXECUTE FUNCTION util.reject_mutation()`
- `claim_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md): `CREATE TRIGGER claim_set_updated_at BEFORE UPDATE ON evidence.claim FOR EACH ROW EXECUTE FUNCTION util.set_updated_at()`
- `claim_verified_gate` → [`evidence.enforce_verified_claim_gate`](../../functions/evidence/enforce_verified_claim_gate.md): `CREATE TRIGGER claim_verified_gate BEFORE INSERT OR UPDATE OF status ON evidence.claim FOR EACH ROW EXECUTE FUNCTION evidence.enforce_verified_claim_gate()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
- `product_api_owner_read` (SELECT) for `product_api_owner`: using `(tenant_id = product.tenant())`
