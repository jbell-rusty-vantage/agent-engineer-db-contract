---
id: "fn:catalog.check_receipt_tenant()"
kind: function
schema: catalog
name: check_receipt_tenant
domain: identity
lens: machinery
overloads: ["fn:catalog.check_receipt_tenant()"]
security: invoker
volatility: volatile
executors: []
raises: [entity/record receipt tenant mismatch]
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt], writes: [] }
tokens: [catalog, check_receipt_tenant, catalog.check_receipt_tenant]
defined_in: []
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# catalog.check_receipt_tenant

Domain `identity`, lens `machinery`.

## check_receipt_tenant() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `entity/record receipt tenant mismatch`.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md); writes —; calls —.

Defined in: unknown.
