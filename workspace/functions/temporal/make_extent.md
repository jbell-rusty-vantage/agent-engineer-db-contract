---
id: "fn:temporal.make_extent(text,text,uuid,timestamptz,timestamptz,text)"
kind: function
schema: temporal
name: make_extent
domain: temporal-facts
lens: corpus
overloads: ["fn:temporal.make_extent(text,text,uuid,timestamptz,timestamptz,text)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [locator tenant mismatch, no open knowledge batch]
touches: { reads: [evidence.locator], writes: [temporal.extent] }
tokens: [temporal, make_extent, temporal.make_extent]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# temporal.make_extent

Domain `temporal-facts`, lens `corpus`.

## make_extent(text, text, uuid, timestamp with time zone, timestamp with time zone, text) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_source_text` | `text` | — | — |
| `p_precision` | `text` | — | — |
| `p_locator` | `uuid` | `NULL::uuid` | — |
| `p_earliest` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_latest` | `timestamp with time zone` | `NULL::timestamp with time zone` | — |
| `p_timezone` | `text` | `NULL::text` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `locator tenant mismatch`; `no open knowledge batch`.

Touches (best effort): reads [`evidence.locator`](../../relations/evidence/locator.md); writes [`temporal.extent`](../../relations/temporal/extent.md); calls [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["make_extent"]`.

Defined in: `20260912010400_km_04_temporal.sql`.
