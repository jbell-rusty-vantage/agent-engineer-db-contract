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
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
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
