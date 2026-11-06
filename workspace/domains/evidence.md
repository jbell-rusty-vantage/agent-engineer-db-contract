---
id: "dom:evidence"
kind: domain
schemas: [evidence]
aliases: [claims, captures, locators, verification]
relations: [evidence.source, evidence.source_capture, evidence.locator, evidence.claim, evidence.claim_subject, evidence.segment_support, evidence.source_query, evidence.provider_result, evidence.source_encounter, evidence.capture_method]
functions: [temporal.admit_support, temporal.withdraw_support]
tasks: [admit-support-for-claim, build-evidence-packet, compose-ingestion-intent, find-stale-facts, navigate-report, what-do-we-know-about-entity]
summary: Source to capture to locator to claim; facts attach through segment_support.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Source and evidence lineage

Source to capture to locator to claim; facts attach through segment_support.

> curated (model_assisted, unreviewed) — Lineage is `evidence.source` → `evidence.source_capture` (artifact_id, content_sha256,
> capture_method) → `evidence.locator` (selector, selected_content_sha256) →
> `evidence.claim`. `evidence.claim_subject` names entities as subject, object, or
> context. Canonical facts attach a `primary_claim_id` and, separately, k-stamped
> `evidence.segment_support` rows that point at a segment or an event occurrence plus a
> locator.
> 
> Discovery leads are `evidence.source_query` → `evidence.provider_result` →
> `evidence.source_encounter`. Capture methods and search providers are vocabularies.
> Verification runs, observations, seals and adjudication belong to the common
> `knowledge_verification` component (withdrawn from this schema in 20261025010000).
> A claim reaches `verified` only under a receipt bound to an admitted use decision,
> with `research.use_admission` recorded in the same transaction.
> 
> app_reader cannot see evidence tables. Use `q:evidence.claims_for_entity` and
> `q:evidence.claim_support` as pipeline_agent, or the claim/source slices inside
> `q:entity.card`. Inserts into source/capture/locator/claim are permitted to
> pipeline_agent and executor_service; `evidence.segment_support` is helper-only
> (`temporal.admit_support`) and is stamped by `temporal.stamp_k`.
> 
> Traps: do not treat a verification filesystem run as already in `evidence.claim`.
> Materialize cited claims first. Support role on the table is supports, challenges, or
> context. Nine evidence tables are insert-only. Reach for
> `q:evidence.claims_for_entity` when you already have an entity id, then
> `q:evidence.claim_support` to see which segments that claim currently backs.
> `admit-support-for-claim` is the write path; `build-evidence-packet` is the read
> path that assembles locators for a question. Discovery queries
> (`q:evidence.sources_by_domain`, `q:evidence.captures_for_source`) are how you
> walk from a registrable domain to the bytes you would quote.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`evidence.source`](../relations/evidence/source.md) | Canonical source (URL/domain) with revisit and publisher pointers. | PK (id); unique (tenant_id, id), (tenant_id, source_class, logical_identity); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.source_capture`](../relations/evidence/source_capture.md) | One immutable capture of a source, hashed and stored as an artifact. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.locator`](../relations/evidence/locator.md) | Precise selection inside a capture, with selected_content_sha256. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent`, `verifier_agent` |
| [`evidence.claim`](../relations/evidence/claim.md) | Atomic statement with type, status, and creating receipt. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.claim_subject`](../relations/evidence/claim_subject.md) | Entity participation in a claim as subject, object, or context. | PK (tenant_id, claim_id, entity_id, role); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.segment_support`](../relations/evidence/segment_support.md) | K-stamped link from a claim and locator to a segment or occurrence. | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`evidence.source_query`](../relations/evidence/source_query.md) | One provider query issued during discovery. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.provider_result`](../relations/evidence/provider_result.md) | One ranked hit from a source_query; query_id points at the discovery query. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.source_encounter`](../relations/evidence/source_encounter.md) | When a provider result was seen as a source, optionally with a capture. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`evidence.capture_method`](../relations/evidence/capture_method.md) | Vocabulary of how a source_capture was taken. | PK (code) | `executor_service`, `pipeline_agent` |

## Functions

[`temporal.admit_support`](../functions/temporal/admit_support.md), [`temporal.withdraw_support`](../functions/temporal/withdraw_support.md)

## Named queries

[`q:evidence.captures_for_source`](../queries/README.md), [`q:evidence.claim_support`](../queries/README.md), [`q:evidence.claims_for_entity`](../queries/README.md), [`q:evidence.sources_by_domain`](../queries/README.md)

## Tasks

[`admit-support-for-claim`](../tasks/admit-support-for-claim.md), [`build-evidence-packet`](../tasks/build-evidence-packet.md), [`compose-ingestion-intent`](../tasks/compose-ingestion-intent.md), [`find-stale-facts`](../tasks/find-stale-facts.md), [`navigate-report`](../tasks/navigate-report.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`evidence`](../schemas/evidence/README.md).
