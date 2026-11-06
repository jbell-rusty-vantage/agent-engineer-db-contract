---
id: "dom:research-v2"
kind: domain
schemas: [research]
aliases: [research-report.v2, report v2, exact report read, use admission, admitted use]
relations: [research.report_v2_revision, research.report_v2_assertion, research.report_v2_ingestion, research.use_admission]
functions: [research.assert_admitted_use, research.guard_report_v2_assertion, research.guard_report_v2_ingestion, research.guard_report_v2_revision, research.guard_use_admission, research.read_report_package, research.require_admitted_use, research.require_receipt_admission]
tasks: []
summary: "AI Engineer projection of sealed knowledge_verification report revisions, exact package reads and native exact-use guards."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Research reports v2 (sealed projection and admission)

AI Engineer projection of sealed knowledge_verification report revisions, exact package reads and native exact-use guards.

> curated (model_assisted, unreviewed) — The common component `knowledge_verification` owns report revisions, custody, runs, seals, use
> decisions and admission. This domain only projects them: `research.report_v2_revision` keys a
> sealed revision by (tenant_id, report_id, revision) and its run; `research.report_v2_assertion`
> keys cited assertions by assertion ref digest; `research.report_v2_ingestion` keys the native
> receipt that applied an admitted use by use decision id. Triggers validate every row against
> the component; there are no cross-schema foreign keys.
> 
> Read path: `research.read_report_package` returns custody refs, digests, assertion refs and the
> run manifest index for one exact revision of a sealed run, or EXACT_REVISION_UNAVAILABLE.
> 
> Write path (executor_service, inside the ingestion transaction): `research.assert_admitted_use`
> calls admit_exact_use under the epoch lock and records `research.use_admission` for the current
> transaction. A receipt that names a use decision, and every canonical row it creates, commits
> only with that admission (ADMISSION_REQUIRED otherwise).

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`research.report_v2_revision`](../relations/research/report_v2_revision.md) | AI Engineer projection of one sealed knowledge_verification.report_revision (research-report.v2), keyed (tena… | PK (tenant_id, report_id, revision); unique (tenant_id, report_revision_id); RLS | `executor_service` |
| [`research.report_v2_assertion`](../relations/research/report_v2_assertion.md) | Assertions cited by a projected v2 revision, keyed by the assertion Ref digest listed in the component revisi… | PK (tenant_id, report_id, revision, assertion_ref_digest); unique (tenant_id, report_id, revision, assertion_id); RLS | `executor_service` |
| [`research.report_v2_ingestion`](../relations/research/report_v2_ingestion.md) | Ingestion result of one admitted exact use (keyed by component use_decision_id): the decision's subject (repo… | PK (tenant_id, use_decision_id); unique (receipt_id); RLS | `executor_service` |
| [`research.use_admission`](../relations/research/use_admission.md) | AI Engineer native admission record: knowledge_verification.admit_exact_use admitted (decision, bound effect … | unique (tenant_id, use_decision_id, bound_effect_digest, xact_id, authoritative_epoch, normalized_values_digest); RLS | `executor_service` |

## Functions

[`research.assert_admitted_use`](../functions/research/assert_admitted_use.md), [`research.guard_report_v2_assertion`](../functions/research/guard_report_v2_assertion.md), [`research.guard_report_v2_ingestion`](../functions/research/guard_report_v2_ingestion.md), [`research.guard_report_v2_revision`](../functions/research/guard_report_v2_revision.md), [`research.guard_use_admission`](../functions/research/guard_use_admission.md), [`research.read_report_package`](../functions/research/read_report_package.md), [`research.require_admitted_use`](../functions/research/require_admitted_use.md), [`research.require_receipt_admission`](../functions/research/require_receipt_admission.md)

Schemas: [`research`](../schemas/research/README.md).
