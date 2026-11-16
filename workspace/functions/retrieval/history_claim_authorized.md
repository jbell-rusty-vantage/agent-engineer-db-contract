---
id: "fn:retrieval.history_claim_authorized(uuid)"
kind: function
schema: retrieval
name: history_claim_authorized
domain: retrieval
lens: corpus
overloads: ["fn:retrieval.history_claim_authorized(uuid)"]
security: definer
volatility: stable
executors: []
raises: []
touches: { reads: [evidence.claim, orchestration.operation_receipt, orchestration.operation_receipt_target, verification.use_admission], writes: [] }
tokens: [retrieval, history_claim_authorized, retrieval.history_claim_authorized]
defined_in: ["20260914011100_retrieval_history.sql", "20261025010000_withdraw_legacy_verification_truth.sql", "20261113150000_build08_ks_admission_verified_claims.sql", "20261113150000_build08_loop6_ks_admission.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# retrieval.history_claim_authorized

Domain `retrieval`, lens `corpus`.

## history_claim_authorized(uuid) → boolean

function, stable, security definer, language sql, config `search_path=""`. A historical claim is authorized for retrieval when it is verified (or superseded after verification) under a receipt bound to a knowledge_verification use decision with a recorded verification.use_admission: the creating receipt, or a receipt that verified it (loop 6). Admission is separate from belief.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_claim` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`evidence.claim`](../../relations/evidence/claim.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`orchestration.operation_receipt_target`](../../relations/orchestration/operation_receipt_target.md), [`verification.use_admission`](../../relations/verification/use_admission.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["history_claim_authorized"]`.

Defined in: `20260914011100_retrieval_history.sql`, `20261025010000_withdraw_legacy_verification_truth.sql`, `20261113150000_build08_ks_admission_verified_claims.sql`, `20261113150000_build08_loop6_ks_admission.sql`.
