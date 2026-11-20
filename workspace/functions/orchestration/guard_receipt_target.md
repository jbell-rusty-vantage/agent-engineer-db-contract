---
id: "fn:orchestration.guard_receipt_target()"
kind: function
schema: orchestration
name: guard_receipt_target
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.guard_receipt_target()"]
security: invoker
volatility: volatile
executors: []
raises: [RECEIPT_TARGET_TENANT_MISMATCH]
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt], writes: [] }
tokens: [orchestration, guard_receipt_target, orchestration.guard_receipt_target]
defined_in: ["20261031010000_operation_receipt_targets.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# orchestration.guard_receipt_target

Domain `orchestration-ledger`, lens `machinery`.

## guard_receipt_target() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `RECEIPT_TARGET_TENANT_MISMATCH`.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Defined in: `20261031010000_operation_receipt_targets.sql`.
