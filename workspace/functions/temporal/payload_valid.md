---
id: "fn:temporal.payload_valid(jsonb,jsonb)"
kind: function
schema: temporal
name: payload_valid
domain: temporal-facts
lens: corpus
overloads: ["fn:temporal.payload_valid(jsonb,jsonb)"]
security: invoker
volatility: immutable
executors: [executor_service, service_role]
raises: []
touches: { reads: [], writes: [] }
tokens: [temporal, payload_valid, temporal.payload_valid]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# temporal.payload_valid

Domain `temporal-facts`, lens `corpus`.

## payload_valid(jsonb, jsonb) → boolean

function, immutable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_value` | `jsonb` | — | — |
| `p_schema` | `jsonb` | — | — |

Execute: `executor_service`, `service_role`.

TypeScript: `Database["temporal"]["Functions"]["payload_valid"]`.

Defined in: `20260912010400_km_04_temporal.sql`.
