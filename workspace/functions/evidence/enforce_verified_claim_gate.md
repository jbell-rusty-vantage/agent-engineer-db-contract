---
id: "fn:evidence.enforce_verified_claim_gate()"
kind: function
schema: evidence
name: enforce_verified_claim_gate
domain: evidence
overloads: ["fn:evidence.enforce_verified_claim_gate()"]
security: definer
volatility: volatile
executors: []
raises: [VERIFIED_CLAIM_REQUIRES_ADMITTED_USE]
touches: { reads: [orchestration.operation_receipt], writes: [] }
tokens: [evidence, enforce_verified_claim_gate, evidence.enforce_verified_claim_gate]
defined_in: ["20260829194310_harden_claim_extraction_and_verification_contract.sql", "20260829194915_require_direct_same_run_claim_verification.sql", "20260829194954_normalize_append_only_claim_evidence_assessments.sql", "20260915010000_official_claim_verification.sql", "20261025010000_withdraw_legacy_verification_truth.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.enforce_verified_claim_gate

Domain `evidence`.

## enforce_verified_claim_gate() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`. Status verified requires the creating receipt to be bound to an admitted exact-use decision of the knowledge_verification component (requires_admission, use_decision_id, bound_effect_digest); the receipt's deferred guard requires the same-transaction research.use_admission. The legacy AIDB verification-run path was withdrawn in 20261025010000.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `VERIFIED_CLAIM_REQUIRES_ADMITTED_USE`.

Touches (best effort): reads [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md); writes —; calls —.

Defined in: `20260829194310_harden_claim_extraction_and_verification_contract.sql`, `20260829194915_require_direct_same_run_claim_verification.sql`, `20260829194954_normalize_append_only_claim_evidence_assessments.sql`, `20260915010000_official_claim_verification.sql`, `20261025010000_withdraw_legacy_verification_truth.sql`.
