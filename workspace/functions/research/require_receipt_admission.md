---
id: "fn:research.require_receipt_admission()"
kind: function
schema: research
name: require_receipt_admission
domain: research-v2
overloads: ["fn:research.require_receipt_admission()"]
security: definer
volatility: volatile
executors: []
raises: [ADMISSION_REQUIRED]
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt, research.use_admission], writes: [] }
tokens: [research, require_receipt_admission, research.require_receipt_admission]
defined_in: ["20261024010100_research_report_v2_projection.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.require_receipt_admission

Domain `research-v2`.

## require_receipt_admission() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`. Deferred commit guard on orchestration.operation_receipt, corpus.entity, knowledge.record and evidence.claim: writes under a receipt that declares requires_admission need an admission in the same transaction (KSA06 ADMISSION_REQUIRED).

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `ADMISSION_REQUIRED`.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`research.use_admission`](../../relations/research/use_admission.md); writes —; calls [`research.assert_admitted_use`](assert_admitted_use.md).

Defined in: `20261024010100_research_report_v2_projection.sql`.
