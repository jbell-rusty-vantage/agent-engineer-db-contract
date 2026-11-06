# Research report packages v1

Status: implemented database contract 0.4.0. Migrations `20260913010000_research_report_packages.sql` and `20260913020000_report_assessment_links.sql` extend the existing research and orchestration schemas. See [package deployment evidence](REPORT-CONTRACT-DEPLOYMENT.json) and [assessment deployment evidence](REPORT-ASSESSMENT-DEPLOYMENT.json) for the identified cloud target and preservation checks.

## Ownership and records

| Record | Responsibility |
|---|---|
| `research.report` | Stable tenant identity, optional mission, slug, type and purpose |
| `research.report_version` | Immutable version and primary Markdown/JSON artifact references; existing versions preserved |
| `research.report_package` | v1 scope, cutoff, producer, creation mode and ordered predecessor |
| `research.report_section` | Stable section identity within a report |
| `research.report_section_version` | Revision-specific heading, ordering, question, conclusion, context and JSON pointer |
| `research.report_section_dependency` | Required context, derivation or supersession of an exact section revision |
| `research.report_assertion` | Exact Markdown UTF-16 span, proposition, kind, qualifications, derivation and block pointer |
| `research.report_assertion_claim` | Run-qualified claim key/digest, evidence manifest, role and optional canonical claim ID |
| `research.report_artifact` | Structure, Markdown, manifest, optional HTML/PDF/verification and input artifact references |
| `research.report_question` / `report_question_section` | Original questions, required flags, coverage, gaps and answering sections |
| `research.report_package_seal` | Immutable structural registration seal, separate from verification and admission |
| `research.report_ingestion_link` | Append-only proposal, receipt, outcome and canonical-result references |
| `research.report_assessment` | Post-seal assessment artifact bound to exact report digest and optional canonical verification run |

Sources, captures, locators, claims, verification and policy outcomes retain their existing owners. Report rows reference `orchestration.artifact`; they do not introduce another artifact registry or copy bucket metadata. Artifact rows hold bucket/object path, digest, media type, size and availability. Signed URLs are transient access mechanisms, never identities.

## Authoring and immutable boundaries

`incremental` means a useful revision is assembled during research; `post_research` means assembly from already preserved research outputs. Both accept the same `research-report.v1` structure and can cite evidence from multiple runs. Neither requires a Mission Control record. Real producer attempts are linked when available; standalone producer identity/version is recorded without inventing an attempt.

Sections support scope, summary, findings, comparisons, timelines, measurements, synthesis, limitations, methods and sources. Blocks contain readable Markdown, including tables, captions and code examples. Assertion ranges are local to block text during authoring. KS renders headings/blocks and computes final UTF-16 ranges from the exact final string. JSON text preserves Unicode; normalization must not invalidate positions.

A new revision creates a new immutable version. Projection rows can be appended only while unsealed; they cannot be edited or deleted. Register a complete revision transactionally. Database row locks serialize sealing with projection insertion. Existing legacy report versions remain readable and are not falsely marked as v1 packages.

The seal requires structure/Markdown/manifest references, a section, available artifact metadata, matching primary rendition references, evidence bindings for non-illustrative assertions, and answering sections for positive coverage entries. Its scope is structural registration, not truth, source authority, exact-byte semantic completeness, or publication admission. Missing research answers can remain explicit gaps in a sealed partial report.

After verification, append `report_assessment` with the report artifact/digest, result artifact and canonical verification run when available. The report must already be sealed, its digest must match, and the result must be available in the same tenant. Verdict interpretation remains with the authoritative verifier and policy oracle. Assessments and ingestion links are external lifecycle records, not mutable additions to the sealed manifest.

Package artifacts use private `research-reports`. No anonymous/authenticated Storage policy grants access to its objects. Trusted server adapters authorize tenant access and resolve registered artifacts. Uploads use content-addressed keys and readback verification. Upload-before-transaction-failure may leave unreferenced bytes; retries reuse matching content. Local-only registrations remain `storage_pending`; storage reconciliation must actually restore/register remote bytes before a duplicate registration can seal. Registration never treats an upload acknowledgement alone as proof.

## Evidence and reuse

Statement kinds distinguish reported, observed, derived, interpretation, recommendation and illustrative content. Derived statements retain calculations or premises. A source-supported vendor statement is not proof of unrestricted world correctness. Illustrative status does not authorize factual content to bypass later report verification.

Claim identities are `(run_id, claim_key, claim_digest)`; canonical materialization is optional at authoring time. Evidence manifests preserve the route to claims, verification outputs, captures and locators. A claim binding alone does not assert admission. Section dependencies retain context for articles and lessons; rewritten content needs a new artifact and verification of its new assertions. A derived report is not independent corroboration of its own sources.

`reportBinding: { reportVersionId, assertionKey? }` on an ingestion proposal connects its result to the report. The executor writes an append-only link alongside the receipt. Links may arrive after sealing and cannot alter report content. Their intent tenant and receipt ownership are enforced. Automatic entity resolution, evidence admission, canonical proposal planning and report-wide factual omission detection remain KS responsibilities.

## Validation and compatibility

`supabase/tests/research_report_packages.sql` exercises role restrictions, tenant references, immutable content, late insertion rejection, predecessor ordering, required artifacts, unavailable storage, assertion bindings and coverage. Run in an isolated database as its owner; the file rolls back.

Cloud deployment applies the three existing ingestion prerequisite migrations before the report migration. Its runner first snapshots all protected `public.research_*` tables and existing report content, then verifies complete-row digests. It uses an isolated CLI migration directory with metadata markers for previously applied cloud history and exact canonical pending migration files. It never resets or seeds the populated database.

Rollback disables the new authoring surface or restores the previous executable while retaining the additive tables and immutable artifacts. Do not drop stored reports or rewrite migration history to roll back application behavior. Storage/DB reconciliation and reference-aware retention remain with the shared artifact service.

## Research report v2 projection and native use guards (Sprint V, unreleased)

Status: migration `20261024010100_research_report_v2_projection.sql`, proved on disposable Supabase databases only (SV-08, 2026-10-25); not a deployment claim. It follows `20261024010000_knowledge_component_binding.sql` and requires the common `knowledge_verification` component (2.x) installed first by `knowledge-db install --application ai-engineer`.

The component owns research-report.v2 revisions, custody, runs and seals, use decisions and `admit_exact_use`. This repository only projects them, without copied DDL or cross-schema foreign keys; triggers validate each row against the component under the caller's tenant.

| Object | Responsibility |
|---|---|
| `research.report_v2_revision` | Sealed component revision keyed `(tenant_id, report_id, revision)`, its run and verification snapshot digest, optional AI Engineer `research.report` identity |
| `research.report_v2_assertion` | Assertions cited by that exact revision, keyed by assertion ref digest |
| `research.report_v2_ingestion` | Native receipt that applied one admitted use, keyed by use decision id |
| `research.use_admission` | Proof that `admit_exact_use` admitted (decision, bound effect digest) inside the inserting transaction |
| `orchestration.operation_receipt.{requires_admission, use_decision_id, bound_effect_digest}` | A receipt that names a decision declares that its writes require admission |
| `research.read_report_package(tenant, report_id, revision)` | Exact revision read: custody refs, digests, assertion refs, run manifest index; `EXACT_REVISION_UNAVAILABLE` otherwise |
| `research.assert_admitted_use(tenant, use_decision_id, bound_effect_digest, processed_epoch)` | Guard called by `executor_service` inside the ingestion transaction |

Typed errors use message = K01 code and SQLSTATE class `KS`: `KSA01` STALE_DECISION (superseded, stale epoch, open closure, expired, invalidated), `KSA02` REVIEW_REQUIRED (held/rejected), `KSA03` EFFECT_CONFLICT (different bound digest), `KSA04` UNRESOLVED_EFFECT (unknown decision or unbound digest), `KSA05` EXACT_REVISION_UNAVAILABLE, `KSA06` ADMISSION_REQUIRED (deferred commit check on `orchestration.operation_receipt`, `corpus.entity`, `knowledge.record`, `evidence.claim`), `KSA07` REPORT_PROJECTION_MISMATCH. Tests: `supabase/tests/research_report_v2_projection.sql` (rolls back) and `supabase/tests/research_report_v2_concurrency.mjs` (two sessions, disposable tenant).
