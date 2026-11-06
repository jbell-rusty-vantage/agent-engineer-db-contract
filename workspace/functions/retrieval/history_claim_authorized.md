---
id: "fn:retrieval.history_claim_authorized(uuid)"
kind: function
schema: retrieval
name: history_claim_authorized
domain: retrieval
overloads: ["fn:retrieval.history_claim_authorized(uuid)"]
security: definer
volatility: stable
executors: []
raises: []
touches: { reads: [evidence.claim, orchestration.operation_receipt, research.use_admission], writes: [] }
tokens: [retrieval, history_claim_authorized, retrieval.history_claim_authorized]
defined_in: ["20260914011100_retrieval_history.sql", "20261025010000_withdraw_legacy_verification_truth.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.history_claim_authorized

Domain `retrieval`.

## history_claim_authorized(uuid) → boolean

function, stable, security definer, language sql, config `search_path=""`. A historical claim is authorized for retrieval when it is verified (or superseded after verification) and was created under a receipt bound to a knowledge_verification use decision with a recorded research.use_admission. Admission is separate from belief.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_claim` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`evidence.claim`](../../relations/evidence/claim.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`research.use_admission`](../../relations/research/use_admission.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["history_claim_authorized"]`.

Defined in: `20260914011100_retrieval_history.sql`, `20261025010000_withdraw_legacy_verification_truth.sql`.
