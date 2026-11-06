---
id: "fn:research.guard_report_v2_ingestion()"
kind: function
schema: research
name: guard_report_v2_ingestion
domain: research-v2
overloads: ["fn:research.guard_report_v2_ingestion()"]
security: invoker
volatility: volatile
executors: []
raises: [REPORT_PROJECTION_MISMATCH, TENANT_MISMATCH, UNRESOLVED_EFFECT]
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt], writes: [] }
tokens: [research, guard_report_v2_ingestion, research.guard_report_v2_ingestion]
defined_in: ["20261024010100_research_report_v2_projection.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.guard_report_v2_ingestion

Domain `research-v2`.

## guard_report_v2_ingestion() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `REPORT_PROJECTION_MISMATCH`; `TENANT_MISMATCH`; `UNRESOLVED_EFFECT`.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Defined in: `20261024010100_research_report_v2_projection.sql`.
