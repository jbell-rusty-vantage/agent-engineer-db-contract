---
id: "fn:temporal.stamp_k()"
kind: function
schema: temporal
name: stamp_k
domain: temporal-facts
lens: machinery
overloads: ["fn:temporal.stamp_k()"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: [no open tenant knowledge batch]
touches: { reads: [], writes: [] }
tokens: [temporal, stamp_k, temporal.stamp_k]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# temporal.stamp_k

Domain `temporal-facts`, lens `machinery`.

## stamp_k() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `no open tenant knowledge batch`.

Touches (best effort): reads —; writes —; calls [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Defined in: `20260912010400_km_04_temporal.sql`.
