---
id: "sch:evidence"
kind: schema
name: evidence
domains: [evidence]
relations: 26
functions: 9
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence

Sources, captures, locators, signatures, claims, support, verification. PROVISIONAL until the attribution lab stabilizes it. Domains: [`evidence`](../../domains/evidence.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`attribution`](../../relations/evidence/attribution.md) | table | unknown | — | → `evidence.claim`, → `corpus.entity`, → `evidence.extraction_record`, → `evidence.locator` |
| [`capture_method`](../../relations/evidence/capture_method.md) | table | unknown | Vocabulary of how a source_capture was taken. | — |
| [`claim`](../../relations/evidence/claim.md) | table | unknown | Atomic statement with type, status, and creating receipt. | → `evidence.claim_type`, → `orchestration.operation_receipt`, → `orchestration.attempt`, → `corpus.relationship` |
| [`claim_conflict`](../../relations/evidence/claim_conflict.md) | table | unknown | — | → `evidence.claim` |
| [`claim_evidence_link`](../../relations/evidence/claim_evidence_link.md) | table | unknown | — | → `evidence.claim`, → `evidence.locator` |
| [`claim_record`](../../relations/evidence/claim_record.md) | table | unknown | — | → `evidence.claim`, → `knowledge.record` |
| [`claim_subject`](../../relations/evidence/claim_subject.md) | table | unknown | Entity participation in a claim as subject, object, or context. | → `evidence.claim`, → `corpus.entity` |
| [`claim_type`](../../relations/evidence/claim_type.md) | table | unknown | — | — |
| [`conflict_reconciliation`](../../relations/evidence/conflict_reconciliation.md) | table | unknown | — | → `evidence.claim_conflict`, → `evaluation.review_task` |
| [`degraded_assurance`](../../relations/evidence/degraded_assurance.md) | table | unknown | — | → `evaluation.review_task`, → `evidence.source` |
| [`extraction_record`](../../relations/evidence/extraction_record.md) | table | unknown | — | → `evidence.claim`, → `evidence.extraction_run`, → `evidence.locator` |
| [`extraction_run`](../../relations/evidence/extraction_run.md) | table | unknown | — | → `orchestration.attempt`, → `content.document_representation`, → `orchestration.artifact` |
| [`extraction_signature`](../../relations/evidence/extraction_signature.md) | table | unknown | — | → `evidence.locator`, → `orchestration.attempt` |
| [`locator`](../../relations/evidence/locator.md) | table | unknown | Precise selection inside a capture, with selected_content_sha256. | → `evidence.source_capture`, → `orchestration.artifact` |
| [`provider_result`](../../relations/evidence/provider_result.md) | table | unknown | One ranked hit from a source_query; query_id points at the discovery query. | → `orchestration.artifact`, → `evidence.source_query`, → `evidence.source`, → `evidence.source_provider_attempt` |
| [`revalidation_event`](../../relations/evidence/revalidation_event.md) | table | unknown | — | → `evidence.revalidation_policy`, → `orchestration.work_item` |
| [`revalidation_policy`](../../relations/evidence/revalidation_policy.md) | table | unknown | — | — |
| [`search_provider`](../../relations/evidence/search_provider.md) | table | unknown | — | — |
| [`segment_support`](../../relations/evidence/segment_support.md) | table | unknown | K-stamped link from a claim and locator to a segment or occurrence. | → `evidence.claim`, → `temporal.event_occurrence`, → `evidence.locator`, → `temporal.segment` |
| [`source`](../../relations/evidence/source.md) | table | unknown | Canonical source (URL/domain) with revisit and publisher pointers. | → `evidence.source_capture`, → `corpus.entity` |
| [`source_capture`](../../relations/evidence/source_capture.md) | table | unknown | One immutable capture of a source, hashed and stored as an artifact. | → `orchestration.artifact`, → `evidence.capture_method`, → `knowledge_service.operation`, → `orchestration.attempt` |
| [`source_encounter`](../../relations/evidence/source_encounter.md) | table | unknown | When a provider result was seen as a source, optionally with a capture. | → `evidence.source_capture`, → `evidence.provider_result`, → `orchestration.operation_receipt`, → `evidence.source` |
| [`source_provider_attempt`](../../relations/evidence/source_provider_attempt.md) | table | unknown | — | → `orchestration.artifact`, → `evidence.search_provider`, → `evidence.source_query` |
| [`source_query`](../../relations/evidence/source_query.md) | table | unknown | One provider query issued during discovery. | → `orchestration.attempt`, → `evidence.search_provider`, → `orchestration.artifact` |
| [`source_result_selection`](../../relations/evidence/source_result_selection.md) | table | unknown | Append-only research inclusion revisions per provider result; reads choose the latest rec… | → `evidence.source_provider_attempt`, → `evidence.source_selection_revision`, → `orchestration.artifact` |
| [`source_selection_revision`](../../relations/evidence/source_selection_revision.md) | table | unknown | — | → `evidence.source_provider_attempt`, → `orchestration.artifact` |

Functions: [`enforce_claim_association_proposed`](../../functions/evidence/enforce_claim_association_proposed.md), [`enforce_verified_claim_gate`](../../functions/evidence/enforce_verified_claim_gate.md), [`guard_source_provider_attempt`](../../functions/evidence/guard_source_provider_attempt.md), [`guard_source_result_selection`](../../functions/evidence/guard_source_result_selection.md), [`rebuild_source_state`](../../functions/evidence/rebuild_source_state.md), [`require_source_selection_decisions`](../../functions/evidence/require_source_selection_decisions.md), [`validate_capture_artifact`](../../functions/evidence/validate_capture_artifact.md), [`validate_locator_capture_lineage`](../../functions/evidence/validate_locator_capture_lineage.md), [`verification_locator_artifacts_are_admitted`](../../functions/evidence/verification_locator_artifacts_are_admitted.md).

Types: [`types/evidence.md`](../../types/evidence.md).

Vocabularies: [`capture_method`](../../vocabularies/evidence.capture_method.md), [`search_provider`](../../vocabularies/evidence.search_provider.md).
