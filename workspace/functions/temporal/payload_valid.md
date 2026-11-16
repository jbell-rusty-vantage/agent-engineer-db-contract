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
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
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
