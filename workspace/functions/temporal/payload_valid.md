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
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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
