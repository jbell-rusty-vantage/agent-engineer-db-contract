---
id: "fn:temporal.stamp_k()"
kind: function
schema: temporal
name: stamp_k
domain: temporal-facts
overloads: ["fn:temporal.stamp_k()"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: [no open tenant knowledge batch]
touches: { reads: [], writes: [] }
tokens: [temporal, stamp_k, temporal.stamp_k]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.stamp_k

Domain `temporal-facts`.

## stamp_k() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `no open tenant knowledge batch`.

Touches (best effort): reads —; writes —; calls [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Defined in: `20260912010400_km_04_temporal.sql`.
