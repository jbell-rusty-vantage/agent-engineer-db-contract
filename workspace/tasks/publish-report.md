---
id: "task:publish-report"
kind: task
domains: [research, orchestration-ledger]
queries: [artifacts.by_type, receipts.for_intent, receipts.recent_for_mission]
aliases: [legacy report publish, report.publish]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Publish a report through the legacy compatibility proposal

Domains: [`research`](../domains/research.md), [`orchestration-ledger`](../domains/orchestration-ledger.md). Queries: [`q:artifacts.by_type`](../queries/README.md), [`q:receipts.for_intent`](../queries/README.md), [`q:receipts.recent_for_mission`](../queries/README.md).

## Navigation

`domains/research.md` → `domains/orchestration-ledger.md`

## Operation

For v1 authoring use task:register-report. This page describes the older report.publish compatibility path; it does not create a v1 package.

```json
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "publish-openai-products-2026-09-11",
  "context": { "tenantId": "00000000-0000-7000-8000-000000000001", "missionId": "0192a000-0000-7000-8000-000000000001", "correlationId": "exp3-a-r1", "actor": { "kind": "agent", "id": "eve:db-aware-research" } },
  "expectedKnowledgeHead": 41,
  "proposals": [
    {
      "proposalId": "p-report",
      "kind": "report.publish",
      "reportArtifactId": "0192c0e0-0000-7000-8000-000000000001",
      "title": "OpenAI products as of 2026-09-11",
      "asOf": "2026-09-11",
      "claimIds": ["c_0007", "c_0009", "c_0011"]
    }
  ]
}
```

## Expected shape

`research.report` plus `research.report_version` (markdown artifact) and `research.report_claim` rows. Receipt lists created ids. Staged: `mission_id` is required today.

## Pitfalls

Publish only a verification-run registered report artifact. Do not insert `research.report` yourself. Claims must already be materialized.
