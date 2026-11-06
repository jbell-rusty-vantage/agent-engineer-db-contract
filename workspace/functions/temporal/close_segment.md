---
id: "fn:temporal.close_segment(uuid)"
kind: function
schema: temporal
name: close_segment
domain: temporal-facts
overloads: ["fn:temporal.close_segment(uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [current segment not found]
touches: { reads: [], writes: [temporal.segment] }
tokens: [temporal, close_segment, temporal.close_segment]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.close_segment

Domain `temporal-facts`.

## close_segment(uuid) → void

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_segment` | `uuid` | — | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `current segment not found`.

Touches (best effort): reads —; writes [`temporal.segment`](../../relations/temporal/segment.md); calls [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["close_segment"]`.

Defined in: `20260912010400_km_04_temporal.sql`.
