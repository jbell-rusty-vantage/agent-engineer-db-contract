---
id: "task:navigate-report"
kind: task
domains: [research, evidence]
queries: [reports.versions, reports.sections, reports.assertions, reports.questions, reports.dependencies, reports.artifacts]
aliases: [report structure, report outline, report gaps, section reuse, report evidence]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Navigate a report revision, evidence and coverage

Domains: [`research`](../domains/research.md), [`evidence`](../domains/evidence.md). Queries: [`q:reports.versions`](../queries/README.md), [`q:reports.sections`](../queries/README.md), [`q:reports.assertions`](../queries/README.md), [`q:reports.questions`](../queries/README.md), [`q:reports.dependencies`](../queries/README.md), [`q:reports.artifacts`](../queries/README.md).

## Navigation

`domains/research.md` → choose the named query below; read only the relation needed for the question.

## Operation

Use reports.versions with report_id to choose an exact revision, including legacy versions. All other reports.* queries take report_version_id.

Use reports.sections for the ordered outline, reports.assertions for exact spans and claim bindings, reports.questions for coverage, reports.dependencies for reuse context and reports.artifacts for registered renditions. v1 packages are read-only history (REPORT_V1_WITHDRAWN on insert); seals, assessments and ingestion receipts of current reports live in the knowledge_verification component and research.report_v2_* projections.

For the assembled v1 package use `knowledge report get <reportVersionId>`; resolve returned artifacts through `knowledge artifact get <artifactId>`. Named queries execute as pipeline_agent under the caller tenant.

## Expected shape

Bounded rows (at most 200 per query). Assertion and question joins may return multiple rows per item. A null schema_version from reports.versions denotes a legacy revision. Section projections carry pointers; readable blocks live in the structure/Markdown artifacts.

## Pitfalls

A bounded slice is not a complete package export. Sealed does not mean admitted; missing assessments are not passing verdicts. Do not treat claim bindings as independent corroboration or infer an answer from coverage alone.
