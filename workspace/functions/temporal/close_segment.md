---
id: "fn:temporal.close_segment(uuid)"
kind: function
schema: temporal
name: close_segment
domain: temporal-facts
lens: corpus
overloads: ["fn:temporal.close_segment(uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [current segment not found]
touches: { reads: [], writes: [temporal.segment] }
tokens: [temporal, close_segment, temporal.close_segment]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# temporal.close_segment

Domain `temporal-facts`, lens `corpus`.

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
