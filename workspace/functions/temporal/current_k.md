---
id: "fn:temporal.current_k()"
kind: function
schema: temporal
name: current_k
domain: temporal-facts
overloads: ["fn:temporal.current_k()"]
security: definer
volatility: stable
executors: [executor_service, service_role]
raises: []
touches: { reads: [temporal.knowledge_head], writes: [] }
tokens: [temporal, current_k, temporal.current_k]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.current_k

Domain `temporal-facts`.

## current_k() → bigint

function, stable, security definer, language sql, config `search_path=""`.

No arguments.

Execute: `executor_service`, `service_role`.

Touches (best effort): reads [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["current_k"]`.

Defined in: `20260912010400_km_04_temporal.sql`.
