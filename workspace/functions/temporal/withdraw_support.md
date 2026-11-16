---
id: "fn:temporal.withdraw_support(uuid)"
kind: function
schema: temporal
name: withdraw_support
domain: evidence
lens: corpus
overloads: ["fn:temporal.withdraw_support(uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [support not found]
touches: { reads: [], writes: [evidence.segment_support] }
tokens: [temporal, withdraw_support, temporal.withdraw_support]
defined_in: ["20260912011100_km_11_grants_rls.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# temporal.withdraw_support

Domain `evidence`, lens `corpus`.

## withdraw_support(uuid) → void

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_support` | `uuid` | — | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `support not found`.

Touches (best effort): reads —; writes [`evidence.segment_support`](../../relations/evidence/segment_support.md); calls [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["withdraw_support"]`.

Defined in: `20260912011100_km_11_grants_rls.sql`.
