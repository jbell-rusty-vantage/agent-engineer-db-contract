---
id: "fn:orchestration.guard_receipt_target()"
kind: function
schema: orchestration
name: guard_receipt_target
domain: orchestration-ledger
overloads: ["fn:orchestration.guard_receipt_target()"]
security: invoker
volatility: volatile
executors: []
raises: [RECEIPT_TARGET_TENANT_MISMATCH]
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt], writes: [] }
tokens: [orchestration, guard_receipt_target, orchestration.guard_receipt_target]
defined_in: ["20261031010000_operation_receipt_targets.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.guard_receipt_target

Domain `orchestration-ledger`.

## guard_receipt_target() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `RECEIPT_TARGET_TENANT_MISMATCH`.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Defined in: `20261031010000_operation_receipt_targets.sql`.
