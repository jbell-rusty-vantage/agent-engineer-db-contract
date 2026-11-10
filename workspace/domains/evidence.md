---
id: "dom:evidence"
kind: domain
lens: evidence
schemas: [evidence, verification]
aliases: [claims, captures, locators, verification, admission, where was it read]
relations: [evidence.source, evidence.source_capture, evidence.locator, evidence.claim, evidence.claim_subject, evidence.segment_support, evidence.extraction_record, evidence.extraction_run, evidence.source_query, evidence.provider_result, evidence.source_encounter, evidence.capture_method, evidence.search_provider, verification.use_admission]
functions: [api.fact_locators, temporal.admit_support, temporal.withdraw_support, verification.assert_admitted_use, verification.require_receipt_admission]
tasks: [admit-support-for-claim, build-evidence-packet, compose-ingestion-intent, find-stale-facts, price-with-locator, what-do-we-know-about-entity]
summary: Source to capture to locator to claim; facts attach through segment_support; verified use is admitted in verification.use_admission.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# Source, evidence and admission

Source to capture to locator to claim; facts attach through segment_support; verified use is admitted in verification.use_admission.

> curated (model_assisted, unreviewed) — Lineage is `evidence.source` → `evidence.source_capture` (artifact_id, content_sha256,
> capture_method, and since Build 08 `acquisition_fetch_id` when a product/harness fetch
> produced the bytes) → `evidence.locator` (selector, selected_content_sha256, normalized
> value, timecode or page) → `evidence.claim`. `evidence.claim_subject` names entities as
> subject, object, or context. Canonical facts attach a `primary_claim_id` and, separately,
> k-stamped `evidence.segment_support` rows that point at a segment or an event occurrence
> plus a locator. `q:facts.locators` (`api.fact_locators`) walks a current fact back to its
> claim, locator, capture URL/time and the typed unit (`content.document_node`) it was read
> from — the answer to "where did this number come from".
> 
> Act 2 and act 3: `evidence.extraction_record` anchors a faithful extraction on a typed unit
> (`document_node_id`) and names the `content.unit_assertion_mapping` that interpreted it.
> Discovery leads are `evidence.source_query` → `evidence.provider_result` →
> `evidence.source_encounter`. Capture methods and search providers are vocabularies.
> 
> Acts 4–5 live in the shared Knowledge Services engine; this database keeps the admission
> ledger. A claim reaches `verified` only under a receipt bound to an admitted use decision,
> with `verification.use_admission` written by `verification.assert_admitted_use` in the same
> transaction (ADMISSION_REQUIRED otherwise). `verification.use_admission` is append-only.
> 
> app_reader cannot see evidence tables directly; it reaches them through `api.fact_locators`,
> `api.model_offerings.price_claim_id/price_locator_id` and `api.benchmark_scores.claim_id`.
> Use `q:evidence.claims_for_entity` and `q:evidence.claim_support` as pipeline_agent.
> Inserts into source/capture/locator/claim are permitted to pipeline_agent and
> executor_service; `evidence.segment_support` is helper-only (`temporal.admit_support`).
> 
> Traps: do not treat a verification run as already in `evidence.claim` — materialize cited
> claims first. Support role is supports, challenges or context. A prose summary is not
> evidence; only a locator on a captured unit is.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`evidence.source`](../relations/evidence/source.md) | Canonical source (URL/domain) with revisit and publisher pointers. | PK (id); unique (tenant_id, id), (tenant_id, source_class, logical_identity); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.source_capture`](../relations/evidence/source_capture.md) | One immutable capture of a source, hashed and stored as an artifact; points at the acquisition fetch that pro… | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.locator`](../relations/evidence/locator.md) | Precise selection inside a capture (text quote, table cell, timecode, page+bbox) with selected_content_sha256… | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent`, `verifier_agent` |
| [`evidence.claim`](../relations/evidence/claim.md) | Atomic statement with type, status, and creating receipt. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.claim_subject`](../relations/evidence/claim_subject.md) | Entity participation in a claim as subject, object, or context. | PK (tenant_id, claim_id, entity_id, role); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.segment_support`](../relations/evidence/segment_support.md) | K-stamped link from a claim and locator to a segment or occurrence. | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`evidence.extraction_record`](../relations/evidence/extraction_record.md) | Faithful extraction anchored on a typed unit and interpreted through an assertion mapping. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.extraction_run`](../relations/evidence/extraction_run.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.source_query`](../relations/evidence/source_query.md) | One provider query issued during discovery. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.provider_result`](../relations/evidence/provider_result.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.source_encounter`](../relations/evidence/source_encounter.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.capture_method`](../relations/evidence/capture_method.md) | Vocabulary of how a source_capture was taken. | PK (code) | `executor_service`, `pipeline_agent` |
| [`evidence.search_provider`](../relations/evidence/search_provider.md) | table | PK (code) | `executor_service`, `pipeline_agent` |
| [`verification.use_admission`](../relations/verification/use_admission.md) | Append-only record that knowledge_verification admitted a use decision inside the writing transaction; requir… | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest); RLS | `executor_service` |

## Functions

[`api.fact_locators`](../functions/api/fact_locators.md), [`temporal.admit_support`](../functions/temporal/admit_support.md), [`temporal.withdraw_support`](../functions/temporal/withdraw_support.md), [`verification.assert_admitted_use`](../functions/verification/assert_admitted_use.md), [`verification.require_receipt_admission`](../functions/verification/require_receipt_admission.md)

## Named queries

[`q:evidence.captures_for_source`](../queries/README.md), [`q:evidence.claim_support`](../queries/README.md), [`q:evidence.claims_for_entity`](../queries/README.md), [`q:evidence.sources_by_domain`](../queries/README.md), [`q:facts.locators`](../queries/README.md)

## Tasks

[`admit-support-for-claim`](../tasks/admit-support-for-claim.md), [`build-evidence-packet`](../tasks/build-evidence-packet.md), [`compose-ingestion-intent`](../tasks/compose-ingestion-intent.md), [`find-stale-facts`](../tasks/find-stale-facts.md), [`price-with-locator`](../tasks/price-with-locator.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`evidence`](../schemas/evidence/README.md), [`verification`](../schemas/verification/README.md).
