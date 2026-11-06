---
id: "task:register-report"
kind: task
domains: [research, orchestration-ledger]
queries: [reports.versions, reports.artifacts]
aliases: [report registration, incremental report, post research report]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Register an immutable report package revision

Domains: [`research`](../domains/research.md), [`orchestration-ledger`](../domains/orchestration-ledger.md). Queries: [`q:reports.versions`](../queries/README.md), [`q:reports.artifacts`](../queries/README.md).

## Navigation

`domains/research.md` → `research.report_v2_revision` (the v1 `research.report_package` projection is closed for new rows).

## Operation

Author research-report.v1 with report/revision identity, scope, cutoff, producer, ordered sections, blocks, assertions, run-qualified evidence references and original-question coverage. Call `knowledge report register report.json` (MCP report_register). Both incremental and post_research authoring support an optional mission.

Register a new immutable revision for changed content. KS renders final Markdown spans, verifies artifact readback and registers projections transactionally. Follow `knowledge report get <reportVersionId>` to inspect the result.

## Expected shape

Registration reports sealed or storage_pending and admission: not_evaluated. A sealed revision has structure, Markdown and manifest artifacts plus structural projections. Post-seal assessments and ingestion links remain separate lifecycle records.

## Pitfalls

Do not insert projections directly or invent producer attempts. storage_pending needs actual storage reconciliation. Registration is separate from legacy report.publish and from verification/admission. Attach reportBinding to normal ingestion proposals to retain receipt lineage.
