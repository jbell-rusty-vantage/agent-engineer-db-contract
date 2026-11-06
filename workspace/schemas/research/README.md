---
id: "sch:research"
kind: schema
name: research
domains: [research, research-v2]
relations: 21
functions: 9
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research

Mission-scoped outputs: bundles, reports, findings, syntheses, handoffs. Domains: [`research`](../../domains/research.md), [`research-v2`](../../domains/research-v2.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`bundle_artifact`](../../relations/research/bundle_artifact.md) | table | unknown | — | → `orchestration.artifact`, → `research.research_bundle` |
| [`comparison`](../../relations/research/comparison.md) | table | unknown | — | → `orchestration.mission` |
| [`downstream_handoff`](../../relations/research/downstream_handoff.md) | table | unknown | — | → `orchestration.work_item`, → `orchestration.mission`, → `orchestration.artifact` |
| [`finding`](../../relations/research/finding.md) | table | unknown | — | → `orchestration.mission`, → `evidence.claim` |
| [`report`](../../relations/research/report.md) | table | unknown | Tenant report slug and title, optionally tied to a mission. | → `orchestration.mission` |
| [`report_artifact`](../../relations/research/report_artifact.md) | table | unknown | Package artifact roles referencing the shared artifact registry. | → `orchestration.artifact`, → `research.report_package` |
| [`report_assertion`](../../relations/research/report_assertion.md) | table | unknown | Proposition bound to an exact final Markdown span and structured block pointer. | → `orchestration.artifact`, → `research.report_section_version` |
| [`report_assertion_claim`](../../relations/research/report_assertion_claim.md) | table | unknown | Run-qualified claim identity, evidence manifest, role and optional canonical claim. | → `evidence.claim`, → `orchestration.artifact`, → `research.report_assertion` |
| [`report_claim`](../../relations/research/report_claim.md) | table | unknown | — | → `evidence.claim`, → `research.report_version` |
| [`report_package`](../../relations/research/report_package.md) | table | unknown | Version scope, cutoff, producer, authoring mode and predecessor. | → `orchestration.attempt`, → `research.report_version` |
| [`report_question`](../../relations/research/report_question.md) | table | unknown | Original research questions, coverage, explanations and missing evidence. | → `research.report_package` |
| [`report_question_section`](../../relations/research/report_question_section.md) | table | unknown | Question-to-section links within an exact report revision. | → `research.report_question`, → `research.report_section_version` |
| [`report_section`](../../relations/research/report_section.md) | table | unknown | Stable section key within one report. | → `research.report` |
| [`report_section_dependency`](../../relations/research/report_section_dependency.md) | table | unknown | Exact section-revision dependencies for context, derivation and supersession. | → `research.report_section_version` |
| [`report_section_version`](../../relations/research/report_section_version.md) | table | unknown | Ordered heading, question, conclusion, context and JSON pointer for an exact revision. | → `research.report_package`, → `research.report_section` |
| [`report_v2_assertion`](../../relations/research/report_v2_assertion.md) | table | unknown | Assertions cited by a projected v2 revision, keyed by the assertion Ref digest listed in … | → `research.report_v2_revision` |
| [`report_v2_ingestion`](../../relations/research/report_v2_ingestion.md) | table | unknown | Ingestion result of one admitted exact use (keyed by component use_decision_id): the deci… | → `orchestration.operation_intent`, → `orchestration.operation_receipt`, → `research.report_v2_assertion`, → `research.report_v2_revision` |
| [`report_v2_revision`](../../relations/research/report_v2_revision.md) | table | unknown | AI Engineer projection of one sealed knowledge_verification.report_revision (research-rep… | → `research.report` |
| [`report_version`](../../relations/research/report_version.md) | table | unknown | Immutable revision and primary Markdown/JSON references. | → `evaluation.eval_run`, → `orchestration.artifact`, → `research.report` |
| [`research_bundle`](../../relations/research/research_bundle.md) | table | unknown | — | → `orchestration.artifact`, → `orchestration.mission` |
| [`use_admission`](../../relations/research/use_admission.md) | table | unknown | AI Engineer native admission record: knowledge_verification.admit_exact_use admitted (dec… | — |

Functions: [`assert_admitted_use`](../../functions/research/assert_admitted_use.md), [`guard_report_projection`](../../functions/research/guard_report_projection.md), [`guard_report_v2_assertion`](../../functions/research/guard_report_v2_assertion.md), [`guard_report_v2_ingestion`](../../functions/research/guard_report_v2_ingestion.md), [`guard_report_v2_revision`](../../functions/research/guard_report_v2_revision.md), [`guard_use_admission`](../../functions/research/guard_use_admission.md), [`read_report_package`](../../functions/research/read_report_package.md), [`require_admitted_use`](../../functions/research/require_admitted_use.md), [`require_receipt_admission`](../../functions/research/require_receipt_admission.md).

Types: [`types/research.md`](../../types/research.md).
