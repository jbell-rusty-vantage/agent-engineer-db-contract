---
id: "fn:verification.record_admitted_claim_verification(uuid,text,text,int8,text,text,text,text)"
kind: function
schema: verification
name: record_admitted_claim_verification
domain: evidence
lens: evidence
overloads: ["fn:verification.record_admitted_claim_verification(uuid,text,text,int8,text,text,text,text)"]
security: definer
volatility: volatile
executors: [control_plane, executor_service, service_role, verifier_agent]
raises: [CLAIM_ALREADY_VERIFIED, CLAIM_NOT_FOUND, CLAIM_NOT_VERIFIABLE, EFFECT_DOES_NOT_MATCH_CLAIM, EFFECT_PAYLOAD_NOT_BOUND]
touches: { reads: [], writes: [evidence.claim, orchestration.operation_intent, orchestration.operation_receipt, orchestration.operation_receipt_target] }
tokens: [verification, record_admitted_claim_verification, verification.record_admitted_claim_verification]
defined_in: ["20261113150000_build08_ks_admission_verified_claims.sql", "20261113150000_build08_loop6_ks_admission.sql", "20261113160100_build08_loop6_fixup_bind_payload.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# verification.record_admitted_claim_verification

Domain `evidence`, lens `evidence`.

## record_admitted_claim_verification(uuid, text, text, bigint, text, text, text, text) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`. Loop 6: the AI Engineer native write of a Knowledge Services claim-verification admission, inside the caller's transaction. The payload text must hash to the semantic payload digest of the decision's bound effect (D-74) and name this claim and the sha256 of its statement; then: assert the admitted exact use (component rule + AIDB guard), write the intent and the admission-bound receipt, target the claim with action verified, set status verified. Re-presenting the same decision for an already verified claim returns its receipt; another decision is refused.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_claim` | `uuid` | — | — |
| `p_use_decision_id` | `text` | — | — |
| `p_bound_effect_digest` | `text` | — | — |
| `p_processed_epoch` | `bigint` | — | — |
| `p_normalized_values_digest` | `text` | — | — |
| `p_origin_digest` | `text` | — | — |
| `p_effect_text` | `text` | — | — |
| `p_executor` | `text` | — | — |

Execute: `control_plane`, `executor_service`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `CLAIM_ALREADY_VERIFIED`; `CLAIM_NOT_FOUND`; `CLAIM_NOT_VERIFIABLE`; `EFFECT_DOES_NOT_MATCH_CLAIM`; `EFFECT_PAYLOAD_NOT_BOUND`.

Touches (best effort): reads —; writes [`evidence.claim`](../../relations/evidence/claim.md), [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`orchestration.operation_receipt_target`](../../relations/orchestration/operation_receipt_target.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md), [`verification.assert_admitted_use`](assert_admitted_use.md).

TypeScript: `Database["verification"]["Functions"]["record_admitted_claim_verification"]`.

Defined in: `20261113150000_build08_ks_admission_verified_claims.sql`, `20261113150000_build08_loop6_ks_admission.sql`, `20261113160100_build08_loop6_fixup_bind_payload.sql`.
