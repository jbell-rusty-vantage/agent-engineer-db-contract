---
id: "fn:temporal.guard_k()"
kind: function
schema: temporal
name: guard_k
domain: temporal-facts
lens: machinery
overloads: ["fn:temporal.guard_k()"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: [history cannot be deleted, only closure in an open tenant batch is allowed]
touches: { reads: [], writes: [] }
tokens: [temporal, guard_k, temporal.guard_k]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# temporal.guard_k

Domain `temporal-facts`, lens `machinery`.

## guard_k() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `history cannot be deleted`; `only closure in an open tenant batch is allowed`.

Touches (best effort): reads —; writes —; calls [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

Defined in: `20260912010400_km_04_temporal.sql`.
