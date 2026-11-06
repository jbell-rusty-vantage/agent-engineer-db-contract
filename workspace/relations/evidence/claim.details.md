---
id: "rel:evidence.claim#details"
kind: details
schema: evidence
name: claim
of: "rel:evidence.claim"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.claim — details

Spill-over from [the main page](claim.md).

## Relationships

Outbound: `atomized_from_id` → [`evidence.claim`](claim.md)`.id` (+tenant); `claim_type` → [`evidence.claim_type`](claim_type.md)`.code`; `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id` (deferrable); `producer_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id` (+tenant); `relationship_id` → [`corpus.relationship`](../corpus/relationship.md)`.id`; `superseded_by_id` → [`evidence.claim`](claim.md)`.id` (+tenant).
Inbound: [`corpus.ai_model_version_spec`](../corpus/ai_model_version_spec.md).source_claim_id, [`corpus.entity_alias`](../corpus/entity_alias.md).source_claim_id, [`corpus.media_appearance`](../corpus/media_appearance.md).primary_claim_id, [`corpus.relationship`](../corpus/relationship.md).primary_claim_id, [`evaluation.review_task`](../evaluation/review_task.md).claim_id, [`evidence.attribution`](attribution.md).claim_id, [`evidence.claim`](claim.md).atomized_from_id|superseded_by_id, [`evidence.claim_conflict`](claim_conflict.md).claim_a_id|claim_b_id, [`evidence.claim_evidence_link`](claim_evidence_link.md).claim_id, [`evidence.claim_record`](claim_record.md).claim_id, [`evidence.claim_subject`](claim_subject.md).claim_id, [`evidence.extraction_record`](extraction_record.md).claim_id, [`evidence.segment_support`](segment_support.md).claim_id, [`knowledge.record`](../knowledge/record.md).provenance_claim_id, [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md).claim_id, [`ranking.group_membership`](../ranking/group_membership.md).provenance_claim_id, [`ranking.metric_observation`](../ranking/metric_observation.md).claim_id, [`research.finding`](../research/finding.md).provenance_claim_id, [`research.report_assertion_claim`](../research/report_assertion_claim.md).claim_id, [`research.report_claim`](../research/report_claim.md).claim_id, [`retrieval.chunk_claim_link`](../retrieval/chunk_claim_link.md).claim_id, [`retrieval.packet_member`](../retrieval/packet_member.md).claim_id, [`retrieval.projection_target`](../retrieval/projection_target.md).claim_id, [`taxonomy.assignment`](../taxonomy/assignment.md).provenance_claim_id, [`temporal.event_occurrence`](../temporal/event_occurrence.md).primary_claim_id, [`temporal.segment`](../temporal/segment.md).primary_claim_id.
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject), [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_check).

## Indexes

| Index | Definition |
| --- | --- |
| `claim_producer_idx` | `CREATE INDEX claim_producer_idx ON evidence.claim USING btree (producer_attempt_id)` |
| `claim_status_idx` | `CREATE INDEX claim_status_idx ON evidence.claim USING btree (status, created_at DESC)` |
| `claim_tenant_id_uq` | `CREATE UNIQUE INDEX claim_tenant_id_uq ON evidence.claim USING btree (tenant_id, id)` |
| `claim_type_idx` | `CREATE INDEX claim_type_idx ON evidence.claim USING btree (claim_type)` |

## Triggers

- `claim_content_provenance_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER claim_content_provenance_immutable BEFORE UPDATE OF tenant_id, claim_type, statement, structured, composite, atomized_from_id, producer_attempt_id, producer_origin_digest, created_by_receipt_id, created_at ON evidence.claim FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`
- `claim_requires_admission` → [`research.require_receipt_admission`](../../functions/research/require_receipt_admission.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER claim_requires_admission AFTER INSERT OR UPDATE OF created_by_receipt_id ON evidence.claim DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION research.require_receipt_admission()`
- `claim_reviewed_preserved` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER claim_reviewed_preserved BEFORE DELETE ON evidence.claim FOR EACH ROW WHEN (old.status <> 'proposed'::evidence.claim_status) EXECUTE FUNCTION util.reject_mutation()`
- `claim_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md): `CREATE TRIGGER claim_set_updated_at BEFORE UPDATE ON evidence.claim FOR EACH ROW EXECUTE FUNCTION util.set_updated_at()`
- `claim_verified_gate` → [`evidence.enforce_verified_claim_gate`](../../functions/evidence/enforce_verified_claim_gate.md): `CREATE TRIGGER claim_verified_gate BEFORE INSERT OR UPDATE OF status ON evidence.claim FOR EACH ROW EXECUTE FUNCTION evidence.enforce_verified_claim_gate()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
