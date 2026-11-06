---
id: "dom:research"
kind: domain
schemas: [research]
aliases: [reports, findings, bundles, report structure, report lifecycle, report navigation]
relations: [research.report, research.report_version, research.report_claim, research.report_package, research.report_section, research.report_section_version, research.report_assertion, research.report_assertion_claim, research.report_artifact, research.report_question, research.report_question_section, research.report_section_dependency, research.finding, research.research_bundle, research.bundle_artifact, research.comparison, research.downstream_handoff]
functions: [research.guard_report_projection]
tasks: [navigate-report, publish-report, register-report]
summary: "Immutable research packages, reusable sections, evidence bindings, coverage and ingestion lineage."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Research reports

Immutable research packages, reusable sections, evidence bindings, coverage and ingestion lineage.

> curated (model_assisted, unreviewed) — research.report is the identity; report_version is immutable. Versions without a
> report_package remain legacy reports. Package v1 adds scope, cutoff, producer,
> sections, assertions, coverage and an ordered predecessor.
> 
> Read path: task:navigate-report maps the reports.* queries below to parameters and
> result shapes. Select a revision, read its ordered sections, then follow assertion
> spans to run-qualified evidence or questions to answering sections and gaps.
> KS report_get assembles packages; queries return at most 200 rows.
> 
> Write path: task:register-report uses KS report_register for research-report.v1.
> Both authoring modes support optional missions and require new revisions for edits.
> The structural seal freezes projections; it is not verification or admission.
> Partial reports retain gaps. Post-seal assessments bind exact-byte result artifacts;
> ingestion links connect reportBinding proposals to receipts and canonical outcomes.
> Interpret verdicts at the verification/policy owner, never from link presence alone.
> 
> task:publish-report is the legacy compatibility path.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`research.report`](../relations/research/report.md) | Tenant report slug and title, optionally tied to a mission. | PK (id); unique (tenant_id, slug), (tenant_id, id); RLS | `control_plane`, `executor_service` |
| [`research.report_version`](../relations/research/report_version.md) | Immutable revision and primary Markdown/JSON references. | PK (id); unique (tenant_id, report_id, id), (report_id, version), (tenant_id, id); RLS | `control_plane`, `executor_service` |
| [`research.report_claim`](../relations/research/report_claim.md) | table | PK (report_version_id, claim_id, role); RLS | `control_plane`, `executor_service` |
| [`research.report_package`](../relations/research/report_package.md) | Version scope, cutoff, producer, authoring mode and predecessor. | PK (report_version_id); unique (tenant_id, report_id, report_version_id), (tenant_id, report_version_id); RLS | `control_plane`, `executor_service` |
| [`research.report_section`](../relations/research/report_section.md) | Stable section key within one report. | PK (id); unique (tenant_id, report_id, id), (tenant_id, report_id, section_key); RLS | `control_plane`, `executor_service` |
| [`research.report_section_version`](../relations/research/report_section_version.md) | Ordered heading, question, conclusion, context and JSON pointer for an exact revision. | PK (tenant_id, report_version_id, section_id); unique (report_version_id, ordinal); RLS | `control_plane`, `executor_service` |
| [`research.report_assertion`](../relations/research/report_assertion.md) | Proposition bound to an exact final Markdown span and structured block pointer. | PK (id); unique (report_version_id, assertion_key), (tenant_id, report_version_id, id); RLS | `control_plane`, `executor_service` |
| [`research.report_assertion_claim`](../relations/research/report_assertion_claim.md) | Run-qualified claim identity, evidence manifest, role and optional canonical claim. | PK (assertion_id, run_id, claim_key, claim_digest, role); RLS | `control_plane`, `executor_service` |
| [`research.report_artifact`](../relations/research/report_artifact.md) | Package artifact roles referencing the shared artifact registry. | PK (report_version_id, artifact_id, role); RLS | `control_plane`, `executor_service` |
| [`research.report_question`](../relations/research/report_question.md) | Original research questions, coverage, explanations and missing evidence. | PK (tenant_id, report_version_id, question_key); RLS | `control_plane`, `executor_service` |
| [`research.report_question_section`](../relations/research/report_question_section.md) | Question-to-section links within an exact report revision. | PK (report_version_id, question_key, section_id); RLS | `control_plane`, `executor_service` |
| [`research.report_section_dependency`](../relations/research/report_section_dependency.md) | Exact section-revision dependencies for context, derivation and supersession. | PK (report_version_id, section_id, required_version_id, required_section_id, relation); RLS | `control_plane`, `executor_service` |
| [`research.finding`](../relations/research/finding.md) | table | PK (id); RLS | `executor_service` |
| [`research.research_bundle`](../relations/research/research_bundle.md) | table | PK (id); unique (mission_id, bundle_version); RLS | `executor_service` |
| [`research.bundle_artifact`](../relations/research/bundle_artifact.md) | table | PK (bundle_id, artifact_id, role); RLS | `executor_service` |
| [`research.comparison`](../relations/research/comparison.md) | table | PK (id); RLS | `executor_service` |
| [`research.downstream_handoff`](../relations/research/downstream_handoff.md) | table | PK (id); RLS | `executor_service` |

## Functions

[`research.guard_report_projection`](../functions/research/guard_report_projection.md)

## Named queries

[`q:artifacts.by_type`](../queries/README.md), [`q:receipts.recent_for_mission`](../queries/README.md), [`q:reports.artifacts`](../queries/README.md), [`q:reports.assertions`](../queries/README.md), [`q:reports.dependencies`](../queries/README.md), [`q:reports.questions`](../queries/README.md), [`q:reports.sections`](../queries/README.md), [`q:reports.versions`](../queries/README.md)

## Tasks

[`navigate-report`](../tasks/navigate-report.md), [`publish-report`](../tasks/publish-report.md), [`register-report`](../tasks/register-report.md)

Schemas: [`research`](../schemas/research/README.md).
