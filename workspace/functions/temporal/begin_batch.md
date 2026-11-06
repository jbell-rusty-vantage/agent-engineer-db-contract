---
id: "fn:temporal.begin_batch(int8)"
kind: function
schema: temporal
name: begin_batch
domain: temporal-facts
overloads: ["fn:temporal.begin_batch(int8)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [knowledge batch already open, rebase_required]
touches: { reads: [], writes: [temporal.knowledge_head] }
tokens: [temporal, begin_batch, temporal.begin_batch]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.begin_batch

Domain `temporal-facts`.

## begin_batch(bigint) → bigint

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_expected_head` | `bigint` | `NULL::bigint` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `knowledge batch already open`; `rebase_required`.

Touches (best effort): reads —; writes [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["begin_batch"]`.

Defined in: `20260912010400_km_04_temporal.sql`.
