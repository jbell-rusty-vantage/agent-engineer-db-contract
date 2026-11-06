---
id: "fn:temporal.admit_support(uuid,uuid,uuid,uuid,text)"
kind: function
schema: temporal
name: admit_support
domain: evidence
overloads: ["fn:temporal.admit_support(uuid,uuid,uuid,uuid,text)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: []
touches: { reads: [], writes: [evidence.segment_support] }
tokens: [temporal, admit_support, temporal.admit_support]
defined_in: ["20260912011100_km_11_grants_rls.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.admit_support

Domain `evidence`.

## admit_support(uuid, uuid, uuid, uuid, text) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_segment` | `uuid` | — | — |
| `p_occurrence` | `uuid` | — | — |
| `p_claim` | `uuid` | — | — |
| `p_locator` | `uuid` | — | — |
| `p_role` | `text` | `'supports'::text` | — |

Execute: `executor_service`, `service_role`.

Touches (best effort): reads —; writes [`evidence.segment_support`](../../relations/evidence/segment_support.md); calls —.

TypeScript: `Database["temporal"]["Functions"]["admit_support"]`.

Defined in: `20260912011100_km_11_grants_rls.sql`.
