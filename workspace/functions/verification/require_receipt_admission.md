---
id: "fn:verification.require_receipt_admission()"
kind: function
schema: verification
name: require_receipt_admission
domain: evidence
lens: machinery
overloads: ["fn:verification.require_receipt_admission()"]
security: definer
volatility: volatile
executors: []
raises: [ADMISSION_REQUIRED]
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt, verification.use_admission], writes: [] }
tokens: [verification, require_receipt_admission, verification.require_receipt_admission]
defined_in: []
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# verification.require_receipt_admission

Domain `evidence`, lens `machinery`.

## require_receipt_admission() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`. Deferred commit guard on orchestration.operation_receipt, corpus.entity, knowledge.record and evidence.claim: writes under a receipt that declares requires_admission need an admission in the same transaction (KSA06 ADMISSION_REQUIRED).

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `ADMISSION_REQUIRED`.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`verification.use_admission`](../../relations/verification/use_admission.md); writes —; calls [`verification.assert_admitted_use`](assert_admitted_use.md).

Defined in: unknown.
