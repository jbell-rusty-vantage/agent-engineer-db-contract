---
id: "fn:evidence.enforce_verified_claim_gate()"
kind: function
schema: evidence
name: enforce_verified_claim_gate
domain: evidence
lens: machinery
overloads: ["fn:evidence.enforce_verified_claim_gate()"]
security: definer
volatility: volatile
executors: []
raises: [VERIFIED_CLAIM_REQUIRES_ADMITTED_USE]
touches: { reads: [orchestration.operation_receipt, orchestration.operation_receipt_target, verification.use_admission], writes: [] }
tokens: [evidence, enforce_verified_claim_gate, evidence.enforce_verified_claim_gate]
defined_in: ["20260829194310_harden_claim_extraction_and_verification_contract.sql", "20260829194915_require_direct_same_run_claim_verification.sql", "20260829194954_normalize_append_only_claim_evidence_assessments.sql", "20260915010000_official_claim_verification.sql", "20261025010000_withdraw_legacy_verification_truth.sql", "20261113150000_build08_ks_admission_verified_claims.sql", "20261113150000_build08_loop6_ks_admission.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# evidence.enforce_verified_claim_gate

Domain `evidence`, lens `machinery`.

## enforce_verified_claim_gate() → trigger

function, volatile, security definer, language plpgsql, config `search_path=""`. Status verified requires a receipt bound to an admitted exact-use decision of the knowledge_verification component: the creating receipt (requires_admission, use_decision_id, bound_effect_digest), or (loop 6, D-72) a receipt that targets the claim with action verified and whose use was admitted in the same transaction. The decision itself is issued only by the component from a sealed verification run.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `VERIFIED_CLAIM_REQUIRES_ADMITTED_USE`.

Touches (best effort): reads [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`orchestration.operation_receipt_target`](../../relations/orchestration/operation_receipt_target.md), [`verification.use_admission`](../../relations/verification/use_admission.md); writes —; calls —.

Defined in: `20260829194310_harden_claim_extraction_and_verification_contract.sql`, `20260829194915_require_direct_same_run_claim_verification.sql`, `20260829194954_normalize_append_only_claim_evidence_assessments.sql`, `20260915010000_official_claim_verification.sql`, `20261025010000_withdraw_legacy_verification_truth.sql`, `20261113150000_build08_ks_admission_verified_claims.sql`, `20261113150000_build08_loop6_ks_admission.sql`.
