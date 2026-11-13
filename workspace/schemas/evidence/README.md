---
id: "sch:evidence"
kind: schema
name: evidence
lens: evidence
domains: [evidence]
relations: 27
functions: 11
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# evidence

Sources, captures, locators, signatures, claims, support, verification. PROVISIONAL until the attribution lab stabilizes it. Lens `evidence`. Domains: [`evidence`](../../domains/evidence.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`attribution`](../../relations/evidence/attribution.md) | table | small | — | → `evidence.claim`, → `catalog.entity`, → `evidence.extraction_record`, → `evidence.locator` |
| [`capture_method`](../../relations/evidence/capture_method.md) | table | unknown | Vocabulary of how a source_capture was taken. | — |
| [`claim`](../../relations/evidence/claim.md) | table | medium | Atomic statement with type, status, and creating receipt. | → `evidence.claim_type`, → `orchestration.operation_receipt`, → `orchestration.attempt`, → `catalog.relationship` |
| [`claim_conflict`](../../relations/evidence/claim_conflict.md) | table | unknown | — | → `evidence.claim` |
| [`claim_evidence_link`](../../relations/evidence/claim_evidence_link.md) | table | medium | — | → `evidence.claim`, → `evidence.locator` |
| [`claim_record`](../../relations/evidence/claim_record.md) | table | unknown | — | → `evidence.claim`, → `guidance.item` |
| [`claim_subject`](../../relations/evidence/claim_subject.md) | table | medium | Entity participation in a claim as subject, object, or context. | → `evidence.claim`, → `catalog.entity` |
| [`claim_type`](../../relations/evidence/claim_type.md) | table | unknown | — | — |
| [`conflict_reconciliation`](../../relations/evidence/conflict_reconciliation.md) | table | unknown | — | → `evidence.claim_conflict`, → `evaluation.review_task` |
| [`degraded_assurance`](../../relations/evidence/degraded_assurance.md) | table | unknown | — | → `evaluation.review_task`, → `evidence.source` |
| [`extraction_record`](../../relations/evidence/extraction_record.md) | table | medium | Faithful extraction anchored on a typed unit and interpreted through an assertion mapping. | → `evidence.claim`, → `evidence.extraction_run`, → `evidence.locator`, → `content.unit_assertion_mapping` |
| [`extraction_run`](../../relations/evidence/extraction_run.md) | table | small | — | → `orchestration.attempt`, → `content.document_representation`, → `orchestration.artifact` |
| [`extraction_signature`](../../relations/evidence/extraction_signature.md) | table | unknown | — | → `evidence.locator`, → `orchestration.attempt` |
| [`locator`](../../relations/evidence/locator.md) | table | medium | Precise selection inside a capture (text quote, table cell, timecode, page+bbox) with sel… | → `evidence.source_capture`, → `orchestration.artifact` |
| [`provider_result`](../../relations/evidence/provider_result.md) | table | unknown | — | → `orchestration.artifact`, → `evidence.source_query`, → `evidence.source`, → `evidence.source_provider_attempt` |
| [`revalidation_event`](../../relations/evidence/revalidation_event.md) | table | unknown | — | → `evidence.revalidation_policy`, → `orchestration.work_item` |
| [`revalidation_policy`](../../relations/evidence/revalidation_policy.md) | table | unknown | — | — |
| [`search_provider`](../../relations/evidence/search_provider.md) | table | unknown | — | — |
| [`segment_support`](../../relations/evidence/segment_support.md) | table | medium | K-stamped link from a claim and locator to a segment or occurrence. | → `evidence.claim`, → `temporal.event_occurrence`, → `evidence.locator`, → `temporal.segment` |
| [`source`](../../relations/evidence/source.md) | table | small | Canonical source (URL/domain) with revisit and publisher pointers. | → `catalog.entity`, → `evidence.source_capture` |
| [`source_assessment`](../../relations/evidence/source_assessment.md) | table | small | Loop 4: what we know about a source (channel, actor, organization, person) on a topic at … | → `content.source_role`, → `catalog.entity` |
| [`source_capture`](../../relations/evidence/source_capture.md) | table | small | One immutable capture of a source, hashed and stored as an artifact; points at the acquis… | → `acquisition.fetch`, → `orchestration.artifact`, → `evidence.capture_method`, → `knowledge_service.operation` |
| [`source_encounter`](../../relations/evidence/source_encounter.md) | table | unknown | — | → `evidence.source_capture`, → `evidence.provider_result`, → `orchestration.operation_receipt`, → `evidence.source` |
| [`source_provider_attempt`](../../relations/evidence/source_provider_attempt.md) | table | unknown | — | → `orchestration.artifact`, → `evidence.search_provider`, → `evidence.source_query` |
| [`source_query`](../../relations/evidence/source_query.md) | table | unknown | One provider query issued during discovery. | → `orchestration.attempt`, → `evidence.search_provider`, → `orchestration.artifact` |
| [`source_result_selection`](../../relations/evidence/source_result_selection.md) | table | unknown | Append-only research inclusion revisions per provider result; reads choose the latest rec… | → `evidence.source_provider_attempt`, → `evidence.source_selection_revision`, → `orchestration.artifact` |
| [`source_selection_revision`](../../relations/evidence/source_selection_revision.md) | table | unknown | — | → `evidence.source_provider_attempt`, → `orchestration.artifact` |

Functions: [`claim_is_self_stated`](../../functions/evidence/claim_is_self_stated.md), [`derive_source_assessment`](../../functions/evidence/derive_source_assessment.md), [`enforce_claim_association_proposed`](../../functions/evidence/enforce_claim_association_proposed.md), [`enforce_verified_claim_gate`](../../functions/evidence/enforce_verified_claim_gate.md), [`guard_source_provider_attempt`](../../functions/evidence/guard_source_provider_attempt.md), [`guard_source_result_selection`](../../functions/evidence/guard_source_result_selection.md), [`rebuild_source_state`](../../functions/evidence/rebuild_source_state.md), [`require_source_selection_decisions`](../../functions/evidence/require_source_selection_decisions.md), [`validate_capture_artifact`](../../functions/evidence/validate_capture_artifact.md), [`validate_locator_capture_lineage`](../../functions/evidence/validate_locator_capture_lineage.md), [`verification_locator_artifacts_are_admitted`](../../functions/evidence/verification_locator_artifacts_are_admitted.md).

Types: [`types/evidence.md`](../../types/evidence.md).

Vocabularies: [`capture_method`](../../vocabularies/evidence.capture_method.md), [`search_provider`](../../vocabularies/evidence.search_provider.md).
